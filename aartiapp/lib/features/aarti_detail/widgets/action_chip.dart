import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../core/theme/app_typography.dart';

class ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const ActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryFill = isDark ? AppColors.saffronLight : AppColors.ink;
    final primaryForeground = isDark ? AppColors.darkBg : AppColors.white;
    final chipBackground = isPrimary ? primaryFill : context.surface;
    final chipBorder = isPrimary ? primaryFill : context.borderSubtle;
    final chipForeground =
        isPrimary ? primaryForeground : context.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: chipBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: chipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: chipForeground),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.body(
                size: 12,
                color: chipForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
