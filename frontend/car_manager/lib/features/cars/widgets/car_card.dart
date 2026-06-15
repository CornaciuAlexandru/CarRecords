import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/app_theme.dart';

const _fuelIcons = {
  'benzina': Icons.local_gas_station,
  'motorina': Icons.local_gas_station,
  'electric': Icons.electric_bolt,
  'hybrid': Icons.eco,
  'gpl': Icons.propane,
};

const _fuelColors = {
  'benzina': AppColors.warning,
  'motorina': Colors.brown,
  'electric': Colors.green,
  'hybrid': Colors.teal,
  'gpl': Colors.blue,
};

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CarCard({super.key, required this.car, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Car icon with fuel color
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: (_fuelColors[car.fuelType] ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _fuelIcons[car.fuelType] ?? Icons.directions_car,
                  color: _fuelColors[car.fuelType] ?? AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(car.licensePlate,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        if (car.mileage != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.speed, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${car.mileage} km',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ],
                    ),
                    if (car.fuelType != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (_fuelColors[car.fuelType] ?? AppColors.primary).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.fuelType!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: _fuelColors[car.fuelType] ?? AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (v) { if (v == 'delete') onDelete(); },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                        SizedBox(width: 8),
                        Text('Șterge', style: TextStyle(color: AppColors.danger)),
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
