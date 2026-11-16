import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final confirmed = status == 'confirmed';
    final color = confirmed ? AppColors.sage : AppColors.pending;
    final tint = confirmed ? AppColors.mist : AppColors.pendingTint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            confirmed ? 'Confirmed' : 'Pending',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}