import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/aarti_item.dart';

class AartiCard extends StatelessWidget {
  final AartiItem aarti;
  final bool isBookmarked;
  final Duration delay;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const AartiCard({
    super.key,
    required this.aarti,
    required this.isBookmarked,
    required this.delay,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stone2, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              aarti.deity.toUpperCase(),
              style: AppTextStyles.label(size: 10, color: AppColors.saffron),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                aarti.title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              aarti.devanagari,
              style: AppTextStyles.devanagari(size: 12, color: AppColors.ink3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(aarti.duration,
                    style: AppTextStyles.body(size: 12, color: AppColors.ink3)),
                const Spacer(),
                GestureDetector(
                  onTap: onBookmark,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? AppColors.saffronGlow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBookmarked
                            ? AppColors.saffron
                            : AppColors.stone3,
                      ),
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      size: 14,
                      color: isBookmarked ? AppColors.saffron : AppColors.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
