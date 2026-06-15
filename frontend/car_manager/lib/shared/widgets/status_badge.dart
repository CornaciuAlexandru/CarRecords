import 'package:flutter/material.dart';
import '../../core/models/documents.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final StatusLevel status;
  final String? customLabel;

  const StatusBadge({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      StatusLevel.ok => (AppColors.success, 'Valabil'),
      StatusLevel.warning => (AppColors.warning, 'Expira curand'),
      StatusLevel.critical => (AppColors.danger, 'Critic'),
      StatusLevel.expired => (Colors.grey, 'Expirat'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        customLabel ?? label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
