import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n.dart';

final maintenanceFutureProvider =
    FutureProvider.family<List<MaintenanceRecord>, String>((ref, carId) =>
        CarService().getMaintenance(carId));

/// Eticheta tradusa pentru tipul de interventie.
String _typeLabel(BuildContext context, String type) => {
  'schimb_ulei':     tr(context).svcOilChange,
  'filtre':          tr(context).svcFilters,
  'placute_frana':   tr(context).svcBrakePads,
  'anvelope':        tr(context).svcTyres,
  'distributie':     tr(context).svcTimingBelt,
  'curea_alternator':tr(context).svcAltBelt,
  'baterie':         tr(context).svcBattery,
  'amortizoare':     tr(context).svcShocks,
  'bujii':           tr(context).svcSparkPlugs,
  'altul':           tr(context).other,
}[type] ?? type;

const _typeIcons = {
  'schimb_ulei': Icons.water_drop, 'filtre': Icons.filter_alt, 'placute_frana': Icons.disc_full,
  'anvelope': Icons.tire_repair, 'distributie': Icons.settings, 'curea_alternator': Icons.electric_bolt,
  'baterie': Icons.battery_charging_full, 'amortizoare': Icons.car_repair, 'bujii': Icons.bolt, 'altul': Icons.build,
};

class MaintenanceScreen extends ConsumerWidget {
  final String carId;
  const MaintenanceScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(maintenanceFutureProvider(carId));
    return Scaffold(
      appBar: AppBar(title: Text(tr(context).maintenance)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cars/$carId/maintenance/add'),
        icon: const Icon(Icons.add), label: Text(tr(context).add),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr(context).errorWith('\$e'))),
        data: (records) => records.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.build_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(tr(context).noMaintenance, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/cars/$carId/maintenance/add'),
                  icon: const Icon(Icons.add), label: Text(tr(context).addMaintenance),
                ),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _MaintenanceCard(
                  record: records[i], carId: carId,
                  onChanged: () => ref.invalidate(maintenanceFutureProvider(carId)),
                ),
              ),
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceRecord record;
  final String carId;
  final VoidCallback onChanged;
  const _MaintenanceCard({required this.record, required this.carId, required this.onChanged});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteMaintenance),
        content: Text(tr(context).deleteConfirmGeneric(_typeLabel(context, record.type))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(context).cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: Text(tr(context).delete)),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CarService().deleteMaintenance(carId, record.id);
      onChanged();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context).errorWith('\$e')), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    final icon = _typeIcons[record.type] ?? Icons.build;
    final label = _typeLabel(context, record.type);
    final nextSoon = record.nextServiceDate != null &&
        record.nextServiceDate!.difference(DateTime.now()).inDays < 30;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(fmt.format(record.performedDate), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ])),
            if (record.cost != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${record.cost!.toStringAsFixed(0)} ${record.currency}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') context.push('/cars/$carId/maintenance/add', extra: record);
                if (v == 'delete') _delete(context);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: AppColors.primary), title: Text(tr(context).edit), dense: true)),
                PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: AppColors.danger), title: Text(tr(context).delete, style: TextStyle(color: AppColors.danger)), dense: true)),
              ],
            ),
          ]),
          if (record.mileageAtService != null) ...[
            const Divider(height: 16),
            Row(children: [
              const Icon(Icons.speed, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(tr(context).atKm('${record.mileageAtService}'), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              if (record.nextServiceMileage != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(tr(context).nextAtKm('${record.nextServiceMileage}'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ]),
          ],
          if (record.serviceShopName != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('${record.serviceShopName}${record.city != null ? ', ${record.city}' : ''}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ],
          if (nextSoon) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                const SizedBox(width: 6),
                Text(tr(context).nextServiceOn(fmt.format(record.nextServiceDate!)),
                    style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
