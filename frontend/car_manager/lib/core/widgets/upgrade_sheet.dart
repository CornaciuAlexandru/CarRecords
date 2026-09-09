import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../providers/purchase_provider.dart';
import '../services/billing_service.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

/// Ofertele, aratate atunci cand serverul a raspuns ca ceva depaseste planul.
///
/// Apare in urma unui 402, deci intr-un moment in care omul tocmai a vrut sa
/// faca ceva anume. `reason` e exact mesajul serverului: "ai atins limita de 2
/// masini" e mai util decat un titlu general despre abonamente.
Future<void> showUpgradeSheet(BuildContext context, {String? reason}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _UpgradeSheet(reason: reason),
  );
}

class _UpgradeSheet extends ConsumerStatefulWidget {
  final String? reason;
  const _UpgradeSheet({this.reason});

  @override
  ConsumerState<_UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends ConsumerState<_UpgradeSheet> {
  late Future<List<BillingPlan>> _plans;
  Map<String, ProductDetails> _storePrices = {};
  StreamSubscription<PurchaseEvent>? _events;

  /// Produsul pentru care asteptam raspunsul magazinului. Cat e setat, toate
  /// butoanele sunt blocate: doua plati pornite odata sunt o incurcatura pe
  /// care nici magazinul nu o rezolva frumos.
  String? _busyProduct;

  @override
  void initState() {
    super.initState();
    _plans = _load();
    _events = ref.read(purchaseServiceProvider).events.listen(_onPurchaseEvent);
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<List<BillingPlan>> _load() async {
    final plans = await BillingService().catalog();
    // Pretul afisat trebuie sa fie cel pe care il incaseaza magazinul, in
    // moneda lui. Cel din catalog e doar rezerva, pentru cand magazinul tace.
    final prices = await ref
        .read(purchaseServiceProvider)
        .storePrices(plans.map((p) => p.productId).toSet());
    if (mounted) setState(() => _storePrices = prices);
    return plans;
  }

  void _onPurchaseEvent(PurchaseEvent event) {
    if (!mounted) return;
    switch (event.outcome) {
      case PurchaseOutcome.granted:
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gata. Contul a fost actualizat.'),
          backgroundColor: AppColors.success,
        ));
      case PurchaseOutcome.pending:
        setState(() => _busyProduct = event.productId);
      case PurchaseOutcome.canceled:
        setState(() => _busyProduct = null);
      case PurchaseOutcome.failed:
        setState(() => _busyProduct = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(event.message ?? 'Plata nu a putut fi finalizata.'),
          backgroundColor: AppColors.danger,
        ));
    }
  }

  Future<void> _buy(BillingPlan plan) async {
    final product = _storePrices[plan.productId];
    if (product == null) return;
    setState(() => _busyProduct = plan.productId);
    final started = await ref.read(purchaseServiceProvider).buy(plan, product);
    if (!started && mounted) setState(() => _busyProduct = null);
  }

  @override
  Widget build(BuildContext context) {
    final storeAvailable = PurchaseService.isSupported;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.reason != null) ...[
                Text(widget.reason!,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
              ],
              FutureBuilder<List<BillingPlan>>(
                future: _plans,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError || snap.data == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Planurile nu se pot incarca acum.'),
                    );
                  }
                  final plans = snap.data!;
                  final subscriptions =
                      plans.where((p) => p.isSubscription).toList();
                  final packs = plans.where((p) => !p.isSubscription).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Planuri',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      for (final p in subscriptions) _tile(p),
                      if (packs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Scanari suplimentare',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        for (final p in packs) _tile(p),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              if (storeAvailable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _busyProduct != null
                        ? null
                        : () => ref.read(purchaseServiceProvider).restore(),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Am cumparat deja'),
                  ),
                )
              else
                const Text(
                  'Cumpararea se face din aplicatia de telefon. Pe calculator '
                  'planul se vede, dar nu se poate cumpara.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BillingPlan plan) {
    final product = _storePrices[plan.productId];
    final busy = _busyProduct == plan.productId;
    final blocked = _busyProduct != null && !busy;
    // Pretul magazinului cand exista; al nostru cand magazinul inca tace, ca
    // sa nu ramana cardul gol.
    final price = product?.price ??
        '${plan.priceEur.toStringAsFixed(2).replaceAll('.', ',')} EUR';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Text(plan.isSubscription ? '$price / an' : price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(_detail(plan),
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (product == null || blocked) ? null : () => _buy(plan),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    // Magazinul nu cunoaste produsul: butonul ar duce in gol,
                    // deci spune de ce in loc sa para stricat.
                    : Text(product == null ? 'Indisponibil acum' : 'Cumpara'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _detail(BillingPlan plan) {
    if (plan.isSubscription) {
      return '${plan.maxCars} masini, raport PDF cu istoricul, fara reclame';
    }
    return plan.scans == 1 ? 'o scanare in plus' : '${plan.scans} scanari in plus';
  }
}
