import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user.dart';
import '../../core/widgets/upgrade_sheet.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cars/providers/cars_provider.dart';
import 'scan_card.dart';

/// ScanCard care isi afla singura cota ramasa.
///
/// Exista ca sa nu repete fiecare ecran de adaugare aceeasi cautare a masinii
/// si a contului. Ecranele stiu doar ce document scaneaza; cate scanari au mai
/// ramas e treaba asta.
class CarScanCard extends ConsumerWidget {
  final String carId;
  final File? scannedImage;
  final bool isScanning;
  final Future<void> Function(String filePath) onScan;

  const CarScanCard({
    super.key,
    required this.carId,
    required this.scannedImage,
    required this.isScanning,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider).value ?? const <Car>[];
    Car? car;
    for (final c in cars) {
      if (c.id == carId) {
        car = c;
        break;
      }
    }
    final credits = ref.watch(authStateProvider).value?.scanCredits ?? 0;

    return ScanCard(
      scannedImage: scannedImage,
      isScanning: isScanning,
      onScan: onScan,
      // Lipsa masinii din lista (inca se incarca) inseamna "nu stiu", nu
      // "zero": ecranul nu blocheaza scanarea pe o presupunere.
      scansLeft: car?.ocrScansLeft,
      credits: credits,
      onNeedMore: () => showUpgradeSheet(
        context,
        reason: 'Ai folosit toate scanarile incluse cu aceasta masina.',
      ),
    );
  }
}
