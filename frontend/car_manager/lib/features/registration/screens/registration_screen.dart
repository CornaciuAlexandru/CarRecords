import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/widgets/ad_banner.dart';

final registrationFutureProvider =
    FutureProvider.family<List<VehicleRegistration>, String>(
        (ref, carId) => CarService().getRegistrations(carId));

class RegistrationScreen extends ConsumerWidget {
  final String carId;
  const RegistrationScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(registrationFutureProvider(carId));
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(title: Text(tr(context).registrationDoc)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cars/$carId/registration/add'),
        icon: const Icon(Icons.add), label: Text(tr(context).add),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr(context).errorWith('$e'))),
        data: (regs) => regs.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(tr(context).noRegistration, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/cars/$carId/registration/add'),
                  icon: const Icon(Icons.add), label: Text(tr(context).addRegistration),
                ),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: regs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _RegistrationCard(
                  reg: regs[i], carId: carId,
                  onChanged: () => ref.invalidate(registrationFutureProvider(carId)),
                ),
              ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final VehicleRegistration reg;
  final String carId;
  final VoidCallback onChanged;
  const _RegistrationCard({required this.reg, required this.carId, required this.onChanged});

  String _cardTitle() {
    final parts = [reg.brand, reg.model].whereType<String>().join(' ').trim();
    return parts.isNotEmpty ? parts : 'Talon';
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteRegistration),
        content: Text(tr(context).deleteRegistrationConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(context).cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: Text(tr(context).delete)),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CarService().deleteRegistration(carId, reg.id);
      onChanged();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context).errorWith('$e')), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.assignment, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _cardTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                if (reg.registrationNumber != null)
                  Text(
                    reg.registrationNumber!,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
              ]),
            ),
            if (reg.itpStatus != null) StatusBadge(status: reg.itpStatus!),
            PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') context.push('/cars/$carId/registration/add', extra: reg);
                  if (v == 'delete') _delete(context);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: AppColors.primary), title: Text(tr(context).edit), dense: true)),
                  PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: AppColors.danger), title: Text(tr(context).delete, style: TextStyle(color: AppColors.danger)), dense: true)),
                ],
              ),
          ]),
          const Divider(height: 20),
          if (reg.manufacturingYear != null) _row(Icons.factory_outlined, tr(context).manufacturingYear, reg.manufacturingYear!),
          if (reg.carSeries != null) _row(Icons.pin_outlined, 'VIN', reg.carSeries!),
          if (reg.registrationDate != null)
            _row(Icons.calendar_today, tr(context).registrationDate, fmt.format(reg.registrationDate!)),
          if (reg.itpExpiryDate != null)
            _row(Icons.event, tr(context).itpExpires, fmt.format(reg.itpExpiryDate!),
                color: reg.itpExpiryDate!.isBefore(DateTime.now()) ? AppColors.danger : null),
          if (reg.ownerName != null) _row(Icons.person_outline, tr(context).owner, reg.ownerName!),
          if (reg.ownerAddress != null) _row(Icons.home_outlined, tr(context).address, reg.ownerAddress!),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color))),
    ]),
  );
}
