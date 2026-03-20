import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_aware_colors.dart';

class DeityChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const DeityChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? AppColors.saffron : context.borderSubtle,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.saffron.withValues(alpha: 0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: AppTextStyles.body(
                size: 11,
                color: isActive ? AppColors.saffron : AppColors.ink3,
                weight: isActive ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
