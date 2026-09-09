import 'package:flutter/material.dart';

import '../services/billing_service.dart';
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

class _UpgradeSheet extends StatefulWidget {
  final String? reason;
  const _UpgradeSheet({this.reason});

  @override
  State<_UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends State<_UpgradeSheet> {
  late Future<List<BillingPlan>> _plans;

  @override
  void initState() {
    super.initState();
    _plans = BillingService().catalog();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
            ],
            const Text('Planuri',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
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
                final subscriptions = plans.where((p) => p.isSubscription).toList();
                final packs = plans.where((p) => !p.isSubscription).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in subscriptions) _PlanTile(plan: p),
                    if (packs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Scanari suplimentare',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      for (final p in packs) _PlanTile(plan: p),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Cumpararea se face din magazin si va fi disponibila in versiunea '
              'publicata. Pana atunci, planurile se pot activa doar din contul '
              'de administrator.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final BillingPlan plan;
  const _PlanTile({required this.plan});

  String get _detail {
    if (plan.isSubscription) {
      return '${plan.maxCars} masini, raport PDF cu istoricul, fara reclame';
    }
    return plan.scans == 1 ? 'o scanare in plus' : '${plan.scans} scanari in plus';
  }

  String get _price {
    final value = plan.priceEur.toStringAsFixed(2).replaceAll('.', ',');
    return plan.isSubscription ? '$value EUR / an' : '$value EUR';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(plan.label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_detail, style: const TextStyle(fontSize: 12.5)),
        trailing: Text(_price,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
    );
  }
}
