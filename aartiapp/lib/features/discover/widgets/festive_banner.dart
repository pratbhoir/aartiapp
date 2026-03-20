import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/festival.dart';

/// A festive banner card shown on the Discover screen when a Hindu festival
/// is active today or upcoming within 7 days.
class FestiveBanner extends StatelessWidget {
  final Festival festival;
  final VoidCallback? onTap;

  const FestiveBanner({
    super.key,
    required this.festival,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = festival.isActiveOn(DateTime.now());
    final daysLeft = festival.daysUntil();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.saffron.withValues(alpha: 0.15),
              AppColors.gold.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.saffron.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  festival.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.saffron,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('TODAY',
                              style: AppTextStyles.label(
                                  size: 8, color: AppColors.white)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.saffronGlow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  AppColors.saffron.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'IN $daysLeft DAY${daysLeft == 1 ? '' : 'S'}',
                            style: AppTextStyles.label(
                                size: 8, color: AppColors.saffronDark),
                          ),
                        ),
                      Text(
                        festival.deity.toUpperCase(),
                        style: AppTextStyles.label(
                            size: 9, color: AppColors.saffronDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    festival.name,
                    style: AppTextStyles.serifBody(
                        size: 17, color: AppColors.ink),
                  ),
                  Text(
                    festival.nameDevanagari,
                    style: AppTextStyles.devanagari(
                        size: 12, color: AppColors.ink3),
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.saffronGlow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.saffronDark),
            ),
          ],
        ),
      ),
    );
  }
}
