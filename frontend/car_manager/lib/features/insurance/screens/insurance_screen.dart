import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';

final insuranceFutureProvider =
    FutureProvider.family<List<InsurancePolicy>, String>(
        (ref, carId) => CarService().getInsurance(carId));

class InsuranceScreen extends ConsumerWidget {
  final String carId;
  const InsuranceScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insuranceFutureProvider(carId));
    return Scaffold(
      appBar: AppBar(title: const Text('Asigurări')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cars/$carId/insurance/add'),
        icon: const Icon(Icons.add),
        label: const Text('Adaugă'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Eroare: $e')),
        data: (policies) => policies.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Nicio asigurare adăugată', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/cars/$carId/insurance/add'),
                  icon: const Icon(Icons.add), label: const Text('Adaugă asigurare'),
                ),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: policies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _InsuranceCard(
                  policy: policies[i],
                  carId: carId,
                  onChanged: () => ref.invalidate(insuranceFutureProvider(carId)),
                ),
              ),
      ),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  final InsurancePolicy policy;
  final String carId;
  final VoidCallback onChanged;
  const _InsuranceCard({required this.policy, required this.carId, required this.onChanged});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Șterge asigurarea'),
        content: Text('Ștergi asigurarea ${policy.type} - ${policy.insurerCompany}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anulează')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CarService().deleteInsurance(carId, policy.id);
      onChanged();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    final typeColor = policy.type == 'RCA' ? AppColors.primary : Colors.indigo;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(policy.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Text(policy.insurerCompany, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                Row(children: [
                  StatusBadge(status: policy.status),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') context.push('/cars/$carId/insurance/add', extra: policy);
                      if (v == 'delete') _delete(context);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: ListTile(
                        leading: Icon(Icons.edit_outlined, color: AppColors.primary),
                        title: Text('Editează'), dense: true,
                      )),
                      const PopupMenuItem(value: 'delete', child: ListTile(
                        leading: Icon(Icons.delete_outline, color: AppColors.danger),
                        title: Text('Șterge', style: TextStyle(color: AppColors.danger)), dense: true,
                      )),
                    ],
                  ),
                ]),
              ],
            ),
            const Divider(height: 20),
            _row(Icons.calendar_today, 'Valabilă de la', fmt.format(policy.validFrom)),
            _row(Icons.event, 'Expiră', fmt.format(policy.validUntil)),
            if (!policy.isExpired)
              _row(Icons.timelapse, 'Zile rămase', '${policy.daysLeft} zile',
                  color: policy.daysLeft < 14 ? AppColors.danger : null),
            if (policy.policyNumber != null) _row(Icons.confirmation_number, 'Nr. poliță', policy.policyNumber!),
            if (policy.premiumAmount != null) _row(Icons.payments_outlined, 'Primă', '${policy.premiumAmount} ${policy.currency}'),
            if (policy.agentName != null) _row(Icons.person_outline, 'Agent', policy.agentName!),
            if (policy.roadsideAssistance) _row(Icons.car_repair, 'Asistență rutieră', 'Inclusă', color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
    ]),
  );
}
