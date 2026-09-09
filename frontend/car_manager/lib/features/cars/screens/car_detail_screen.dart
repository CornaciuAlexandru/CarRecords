import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/user.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/upgrade_sheet.dart';
import '../providers/cars_provider.dart';
import '../../../core/utils/l10n.dart';

class CarDetailScreen extends ConsumerWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr(context).carDetails),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(icon: Icon(Icons.description_outlined), text: tr(context).documents),
              Tab(icon: Icon(Icons.shield_outlined), text: tr(context).insurance),
              Tab(icon: Icon(Icons.build_outlined), text: tr(context).maintenanceShort),
              Tab(icon: Icon(Icons.tune_outlined), text: tr(context).modifications),
              Tab(icon: Icon(Icons.info_outline), text: tr(context).info),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DocumentsTab(carId: carId),
            _InsuranceTab(carId: carId),
            _MaintenanceTab(carId: carId),
            _ModificationsTab(carId: carId),
            _InfoTab(carId: carId),
          ],
        ),
      ),
    );
  }
}

// ── Tab Documente (Rovinieta + Talon) ──────────────────────────────────────
class _DocumentsTab extends StatelessWidget {
  final String carId;
  const _DocumentsTab({required this.carId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: tr(context).vignette,
          icon: Icons.card_membership,
          iconColor: AppColors.accent,
          onAdd: () => context.push('/cars/$carId/vignette/add'),
          onView: () => context.push('/cars/$carId/vignettes'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: tr(context).registrationDoc,
          icon: Icons.assignment,
          iconColor: Colors.teal,
          onAdd: () => context.push('/cars/$carId/registration/add'),
          onView: () => context.push('/cars/$carId/registrations'),
        ),
      ],
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  final String carId;
  const _InsuranceTab({required this.carId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'RCA',
          icon: Icons.shield,
          iconColor: AppColors.primary,
          onAdd: () => context.push('/cars/$carId/insurance/add?type=RCA'),
          onView: () => context.push('/cars/$carId/insurance'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'CASCO',
          icon: Icons.security,
          iconColor: Colors.indigo,
          onAdd: () => context.push('/cars/$carId/insurance/add?type=CASCO'),
          onView: () => context.push('/cars/$carId/insurance'),
        ),
      ],
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  final String carId;
  const _MaintenanceTab({required this.carId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: tr(context).maintenance,
          icon: Icons.build,
          iconColor: Colors.orange,
          onAdd: () => context.push('/cars/$carId/maintenance/add'),
          onView: () => context.push('/cars/$carId/maintenance'),
        ),
      ],
    );
  }
}

class _ModificationsTab extends StatelessWidget {
  final String carId;
  const _ModificationsTab({required this.carId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: tr(context).modifications,
          icon: Icons.tune,
          iconColor: Colors.purple,
          onAdd: () => context.push('/cars/$carId/modifications/add'),
          onView: () => context.push('/cars/$carId/modifications'),
        ),
      ],
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final String carId;
  const _InfoTab({required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final cars = carsAsync.value ?? const <Car>[];
    Car? car;
    for (final c in cars) {
      if (c.id == carId) {
        car = c;
        break;
      }
    }
    // Cautarea de dinainte cadea inapoi pe prima masina din lista cand nu o
    // gasea pe cea ceruta - deci ecranul arata linistit datele altei masini,
    // iar acum ar fi exportat si un PDF cu istoricul ei.
    if (car == null) {
      return Center(
        child: carsAsync.isLoading
            ? const CircularProgressIndicator()
            : const Text('Masina nu mai exista.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoCard(tr(context).generalInfo, [
          _row(tr(context).brand, car.brand),
          _row(tr(context).model, car.model),
          _row(tr(context).manufacturingYear, '${car.year}'),
          if (car.color != null) _row(tr(context).color, car.color!),
          _row(tr(context).plateNumber, car.licensePlate),
          if (car.registrationNumber != null)
            _row(tr(context).plateNumber, car.registrationNumber!),
        ]),
        const SizedBox(height: 16),
        _infoCard('Date tehnice', [
          if (car.fuelType != null)
            _row(tr(context).fuelType, car.fuelType!.toUpperCase()),
          if (car.engineCapacity != null)
            _row(tr(context).engineCapacity, '${car.engineCapacity} cc'),
          if (car.enginePower != null)
            _row(tr(context).enginePower, '${car.enginePower} CP'),
          if (car.mileage != null)
            _row(tr(context).mileage, '${car.mileage} km'),
          if (car.vinNumber != null) _row(tr(context).vin, car.vinNumber!),
        ]),
        const SizedBox(height: 16),
        _ReportCard(car: car),
      ],
    );
  }

  Widget _infoCard(String title, List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary)),
              const Divider(height: 16),
              ...rows,
            ],
          ),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      );
}

/// Exportul istoricului ca PDF.
///
/// Cel mai bun motiv de plata din aplicatie: la vanzare, un istoric documentat
/// schimba pretul, iar datele exista doar aici. De asta cardul se vede si pe
/// conturile gratuite - refuzul serverului deschide oferta, in loc sa ascunda
/// functia si sa n-o afle nimeni.
class _ReportCard extends ConsumerStatefulWidget {
  final Car car;
  const _ReportCard({required this.car});

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final bytes = await CarService().downloadCarReport(widget.car.id);
      final dir = await getTemporaryDirectory();
      final plate = widget.car.licensePlate.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
      final file = File('${dir.path}/CarRecords-$plate.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Istoric ${widget.car.displayName}',
      );
    } catch (e) {
      if (!mounted) return;
      // Planul nu ajunge: aratam ce ar debloca, nu un mesaj de eroare.
      if (isPaymentRequired(e)) {
        showUpgradeSheet(context,
            reason: (e as dynamic).response?.data?['detail'] as String?);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(parseError(context, e)),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Istoric pentru vanzare',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Un PDF cu tot ce ai trecut aici: revizii, kilometraj, ITP, '
              'asigurari, modificari. Il atasezi la anunt sau il arati '
              'cumparatorului.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _export,
                icon: _busy
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.ios_share),
                label: Text(_busy ? 'Se genereaza...' : 'Genereaza PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onAdd;
  final VoidCallback onView;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onAdd,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(tr(context).tapForDetails, style: TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: onAdd),
            IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: onView),
          ],
        ),
      ),
    );
  }
}
