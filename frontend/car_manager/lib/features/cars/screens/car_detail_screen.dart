import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cars_provider.dart';

class CarDetailScreen extends ConsumerWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalii mașină'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(icon: Icon(Icons.description_outlined), text: 'Documente'),
              Tab(icon: Icon(Icons.shield_outlined), text: 'Asigurare'),
              Tab(icon: Icon(Icons.build_outlined), text: 'Service'),
              Tab(icon: Icon(Icons.tune_outlined), text: 'Modificări'),
              Tab(icon: Icon(Icons.info_outline), text: 'Info'),
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
          title: 'Rovinietă',
          icon: Icons.card_membership,
          iconColor: AppColors.accent,
          onAdd: () => context.push('/cars/$carId/vignette/add'),
          onView: () => context.push('/cars/$carId/vignettes'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Talon / ITP',
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
          title: 'Schimburi & Service',
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
          title: 'Modificări aduse',
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
    final cars = ref.watch(carsProvider).value ?? [];
    final car = cars.firstWhere((c) => c.id == carId,
        orElse: () => cars.isEmpty ? throw Exception() : cars.first);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoCard('Informații generale', [
          _row('Marcă', car.brand),
          _row('Model', car.model),
          _row('An fabricație', '${car.year}'),
          if (car.color != null) _row('Culoare', car.color!),
          _row('Nr. înmatriculare', car.licensePlate),
          if (car.registrationNumber != null)
            _row('Nr. înregistrare', car.registrationNumber!),
        ]),
        const SizedBox(height: 16),
        _infoCard('Date tehnice', [
          if (car.fuelType != null)
            _row('Combustibil', car.fuelType!.toUpperCase()),
          if (car.engineCapacity != null)
            _row('Cilindree', '${car.engineCapacity} cc'),
          if (car.enginePower != null)
            _row('Putere', '${car.enginePower} CP'),
          if (car.mileage != null)
            _row('Kilometraj', '${car.mileage} km'),
          if (car.vinNumber != null) _row('Serie șasiu (VIN)', car.vinNumber!),
        ]),
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
        subtitle: const Text('Apasă pentru detalii', style: TextStyle(fontSize: 12)),
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
