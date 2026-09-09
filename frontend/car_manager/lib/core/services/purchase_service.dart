import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_service.dart';

enum PurchaseOutcome {
  /// Contul a primit ce a cumparat.
  granted,

  /// Plata e in curs de aprobare (card cu confirmare, plata la magazin fizic).
  /// Nu e un esec: rezultatul vine mai tarziu, prin acelasi flux.
  pending,

  /// Utilizatorul s-a razgandit.
  canceled,

  /// Magazinul sau serverul a refuzat.
  failed,
}

class PurchaseEvent {
  final PurchaseOutcome outcome;
  final String? productId;
  final String? message;

  const PurchaseEvent(this.outcome, {this.productId, this.message});
}

/// Cumpararile din magazin.
///
/// Aplicatia nu decide niciodata singura ca un cont a platit. Magazinul da o
/// chitanta, chitanta pleaca la server, si serverul intreaba Google. Codul de
/// aici doar duce hartia dintr-o parte in alta.
class PurchaseService {
  PurchaseService({required this.onGranted});

  /// Chemata dupa ce serverul a acordat ceva, ca sa se reciteasca contul:
  /// planul si scanarile din interfata trebuie sa se schimbe imediat.
  final Future<void> Function() onGranted;

  final InAppPurchase _iap = InAppPurchase.instance;
  final BillingService _billing = BillingService();
  final StreamController<PurchaseEvent> _events =
      StreamController<PurchaseEvent>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Magazinul exista doar pe telefoane. Pe Windows nu se apeleaza nimic:
  /// pluginul n-are implementare acolo si ar arunca.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Stream<PurchaseEvent> get events => _events.stream;

  /// Porneste ascultarea. Se cheama o data, la pornirea aplicatiei.
  ///
  /// Ascultarea trebuie sa fie activa tot timpul, nu doar cat e deschis
  /// ecranul de cumparare: o plata lasata in asteptare se finalizeaza mai
  /// tarziu, iar magazinul o livreaza la urmatoarea pornire.
  void start() {
    if (!isSupported || _sub != null) return;
    _sub = _iap.purchaseStream.listen(
      _handle,
      onError: (Object e) {
        debugPrint('Cumparari: flux intrerupt ($e)');
        _events.add(const PurchaseEvent(PurchaseOutcome.failed));
      },
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _events.close();
  }

  /// Preturile reale din magazin, in moneda utilizatorului.
  ///
  /// Preturile din `/billing/catalog` sunt cele stabilite de noi, in euro;
  /// magazinul le afiseaza in lei si le poate schimba pe tara. Cand magazinul
  /// raspunde, pretul lui castiga - altfel am arata alt pret decat se incaseaza.
  Future<Map<String, ProductDetails>> storePrices(Set<String> productIds) async {
    if (!isSupported || productIds.isEmpty) return {};
    try {
      if (!await _iap.isAvailable()) return {};
      final response = await _iap.queryProductDetails(productIds);
      return {for (final p in response.productDetails) p.id: p};
    } catch (e) {
      debugPrint('Cumparari: preturile din magazin nu se pot citi ($e)');
      return {};
    }
  }

  /// Deschide fluxul de plata al magazinului.
  ///
  /// Rezultatul NU vine de aici: vine pe `events`, fiindca plata poate dura
  /// (confirmare de card, aprobare parentala) si poate sosi si dupa ce
  /// aplicatia a fost inchisa intre timp.
  Future<bool> buy(BillingPlan plan, ProductDetails product) async {
    if (!isSupported) return false;
    final param = PurchaseParam(productDetails: product);
    try {
      if (plan.isSubscription) {
        return await _iap.buyNonConsumable(purchaseParam: param);
      }
      // Scanarile se consuma: fara asta, acelasi pachet n-ar putea fi cumparat
      // a doua oara. Consumarea are loc la completePurchase, adica dupa ce
      // serverul a acordat.
      return await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
    } catch (e) {
      debugPrint('Cumparari: nu am putut deschide plata ($e)');
      _events.add(PurchaseEvent(PurchaseOutcome.failed,
          productId: plan.productId, message: '$e'));
      return false;
    }
  }

  /// Readuce abonamentele cumparate anterior - la reinstalare sau pe alt
  /// telefon. Chitantele vin tot prin flux si trec prin aceeasi verificare.
  Future<void> restore() async {
    if (!isSupported) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Cumparari: restaurare esuata ($e)');
    }
  }

  // ── Fluxul magazinului ───────────────────────────────────────

  Future<void> _handle(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _events.add(PurchaseEvent(PurchaseOutcome.pending,
              productId: purchase.productID));
          continue;

        case PurchaseStatus.canceled:
          _events.add(PurchaseEvent(PurchaseOutcome.canceled,
              productId: purchase.productID));
          await _finish(purchase);
          continue;

        case PurchaseStatus.error:
          _events.add(PurchaseEvent(PurchaseOutcome.failed,
              productId: purchase.productID,
              message: purchase.error?.message));
          await _finish(purchase);
          continue;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grant(purchase);
      }
    }
  }

  Future<void> _grant(PurchaseDetails purchase) async {
    final outcome = await _billing.verify(
      purchase.productID,
      purchase.verificationData.serverVerificationData,
    );

    switch (outcome) {
      case VerifyOutcome.granted:
        await onGranted();
        _events.add(PurchaseEvent(PurchaseOutcome.granted,
            productId: purchase.productID));
        await _finish(purchase);

      case VerifyOutcome.alreadyUsed:
        // De obicei o restaurare a ceva deja acordat. Reimprospatam contul si
        // inchidem cumpararea: lasata deschisa, ar reveni la fiecare pornire.
        await onGranted();
        _events.add(PurchaseEvent(PurchaseOutcome.granted,
            productId: purchase.productID));
        await _finish(purchase);

      case VerifyOutcome.refused:
        _events.add(PurchaseEvent(PurchaseOutcome.failed,
            productId: purchase.productID,
            message: 'Magazinul nu a confirmat plata.'));
        await _finish(purchase);

      case VerifyOutcome.unavailable:
        // Cumpararea NU se inchide. Ramane in asteptare la magazin si e
        // livrata din nou la urmatoarea pornire, cand serverul raspunde. Daca
        // am inchide-o acum, omul ar fi platit fara sa primeasca nimic.
        _events.add(PurchaseEvent(PurchaseOutcome.failed,
            productId: purchase.productID,
            message: 'Plata nu s-a putut confirma acum. '
                'Se reincearca la urmatoarea deschidere.'));
    }
  }

  Future<void> _finish(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(purchase);
    } catch (e) {
      debugPrint('Cumparari: finalizare esuata ($e)');
    }
  }
}
