import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Un plan sau un pachet, asa cum il descrie serverul.
///
/// Preturile nu sunt scrise in aplicatie: vin de la `/billing/catalog`. Altfel
/// o schimbare de pret ar cere o versiune noua in magazin, iar ecranul ar putea
/// arata altceva decat se incaseaza.
class BillingPlan {
  final String productId;
  final String kind;
  final double priceEur;
  final String label;
  final String? tier;
  final int scans;
  final int? maxCars;

  const BillingPlan({
    required this.productId,
    required this.kind,
    required this.priceEur,
    required this.label,
    this.tier,
    this.scans = 0,
    this.maxCars,
  });

  bool get isSubscription => kind == 'subscription';

  factory BillingPlan.fromJson(Map<String, dynamic> j) => BillingPlan(
        productId: j['product_id'],
        kind: j['kind'],
        priceEur: (j['price_eur'] as num).toDouble(),
        label: j['label'],
        tier: j['tier'],
        scans: j['scans'] ?? 0,
        maxCars: j['max_cars'],
      );
}

/// Ce a raspuns serverul la o chitanta.
///
/// Distinctia conteaza: pentru `unavailable` cumpararea NU se marcheaza ca
/// finalizata la magazin, ca sa fie livrata din nou la urmatoarea pornire si
/// sa se poata reincerca. Pentru celelalte nu are rost sa se reincerce.
enum VerifyOutcome {
  /// Contul a primit ce a cumparat.
  granted,

  /// Chitanta e valida dar a fost deja folosita - de obicei pe alt cont, sau
  /// e o restaurare a unei cumparari deja acordate.
  alreadyUsed,

  /// Magazinul spune ca nu e o cumparare valabila. Reincercarea n-ar schimba
  /// nimic.
  refused,

  /// Nu s-a putut verifica acum: server picat, fara internet, cont de serviciu
  /// lipsa. Se reincearca.
  unavailable,
}


class BillingService {
  final Dio _dio = createDio();

  Future<List<BillingPlan>> catalog() async {
    final resp = await _dio.get('/billing/catalog');
    return (resp.data as List)
        .map((j) => BillingPlan.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Trimite chitanta serverului, care intreaba magazinul si acorda.
  Future<VerifyOutcome> verify(String productId, String purchaseToken) async {
    try {
      await _dio.post('/billing/verify', data: {
        'product_id': productId,
        'purchase_token': purchaseToken,
      });
      return VerifyOutcome.granted;
    } on DioException catch (e) {
      return switch (e.response?.statusCode) {
        409 => VerifyOutcome.alreadyUsed,
        400 => VerifyOutcome.refused,
        _ => VerifyOutcome.unavailable,
      };
    } catch (_) {
      return VerifyOutcome.unavailable;
    }
  }
}
