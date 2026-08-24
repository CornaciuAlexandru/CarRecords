import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/utils/l10n.dart';

final vignettesFutureProvider =
    FutureProvider.family<List<Vignette>, String>((ref, carId) =>
        CarService().getVignettes(carId));

class VignettesScreen extends ConsumerWidget {
  final String carId;
  const VignettesScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vignettesFutureProvider(carId));
    return Scaffold(
      appBar: AppBar(title: Text(tr(context).vignettes)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cars/$carId/vignette/add'),
        icon: const Icon(Icons.add),
        label: Text(tr(context).add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr(context).errorWith('\$e'))),
        data: (vignettes) => vignettes.isEmpty
            ? _empty(context)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vignettes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VignetteCard(
                  vignette: vignettes[i],
                  carId: carId,
                  onChanged: () => ref.invalidate(vignettesFutureProvider(carId)),
                ),
              ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.card_membership, size: 64, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text(tr(context).noVignettes, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () => context.push('/cars/$carId/vignette/add'),
        icon: const Icon(Icons.add), label: Text(tr(context).addVignette),
      ),
    ]),
  );
}

class _VignetteCard extends ConsumerWidget {
  final Vignette vignette;
  final String carId;
  final VoidCallback onChanged;
  const _VignetteCard({required this.vignette, required this.carId, required this.onChanged});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteVignette),
        content: Text(tr(context).deleteVignetteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(tr(context).delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CarService().deleteVignette(carId, vignette.id);
      onChanged();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context).errorWith('\$e')), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd.MM.yyyy');
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
                  const Icon(Icons.card_membership, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('${tr(context).vignette} ${vignette.validityPeriod.replaceAll('_', ' ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                Row(children: [
                  StatusBadge(status: vignette.status),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') context.push('/cars/$carId/vignette/add', extra: vignette);
                      if (v == 'delete') _delete(context, ref);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: ListTile(
                        leading: Icon(Icons.edit_outlined, color: AppColors.primary),
                        title: Text(tr(context).edit), dense: true,
                      )),
                      PopupMenuItem(value: 'delete', child: ListTile(
                        leading: Icon(Icons.delete_outline, color: AppColors.danger),
                        title: Text(tr(context).delete, style: TextStyle(color: AppColors.danger)), dense: true,
                      )),
                    ],
                  ),
                ]),
              ],
            ),
            const Divider(height: 20),
            _row(Icons.calendar_today, tr(context).validFrom, fmt.format(vignette.validFrom)),
            _row(Icons.event, tr(context).expires, fmt.format(vignette.validUntil)),
            if (!vignette.isExpired)
              _row(Icons.timelapse, tr(context).daysLeft, '${vignette.daysLeft} zile',
                  color: vignette.daysLeft < 7 ? AppColors.danger : null),
            if (vignette.issuerCompany != null) _row(Icons.business, tr(context).issuer, vignette.issuerCompany!),
            if (vignette.price != null) _row(Icons.payments_outlined, tr(context).price, '${vignette.price} ${vignette.currency}'),
            if (vignette.invoiceNumber != null) _row(Icons.receipt_long, tr(context).invoiceNr, vignette.invoiceNumber!),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
    ]),
  );
}
