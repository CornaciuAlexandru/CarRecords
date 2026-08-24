import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cars_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/car_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/l10n.dart';

class CarsScreen extends ConsumerWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final carsAsync = ref.watch(carsProvider);
    final user = ref.watch(authStateProvider).value;
    final maxCars = user?.maxCars ?? 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context).myCars),
        actions: [
          // Indicator limita masini
          carsAsync.whenOrNull(
            data: (cars) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cars.length >= maxCars
                        ? AppColors.danger.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr(context).carsCount(cars.length, maxCars),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cars.length >= maxCars ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ) ?? const SizedBox(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(carsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: carsAsync.whenOrNull(data: (cars) => cars.length >= maxCars ? null : () => context.push('/cars/add')) ?? () => context.push('/cars/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(tr(context).addCar),
      ),
      body: carsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(tr(context).errorWith('$e'), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(carsProvider.notifier).refresh(),
                child: Text(tr(context).retry),
              ),
            ],
          ),
        ),
        data: (cars) => cars.isEmpty
            ? _EmptyState(onAdd: () => context.push('/cars/add'), t: t)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => CarCard(
                  car: cars[i],
                  onTap: () {
                    ref.read(selectedCarProvider.notifier).state = cars[i];
                    context.push('/cars/${cars[i].id}');
                  },
                  onDelete: () => _confirmDelete(context, ref, cars[i]),
                ),
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Car car) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteCar),
        content: Text(tr(context).deleteCarConfirm(car.displayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(context).cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(carsProvider.notifier).deleteCar(car.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(tr(context).delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final AppLocalizations t;
  const _EmptyState({required this.onAdd, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(tr(context).noCarsYet,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tr(context).noCarsHint,
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(tr(context).addCar),
            ),
          ],
        ),
      ),
    );
  }
}
