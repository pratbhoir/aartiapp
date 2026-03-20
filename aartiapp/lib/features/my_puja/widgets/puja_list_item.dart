import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/aarti_item.dart';

class PujaListItem extends StatelessWidget {
  final AartiItem aarti;
  final int index;
  final bool isPlaying;
  final Duration delay;

  const PujaListItem({
    super.key,
    required this.aarti,
    required this.index,
    required this.isPlaying,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stone2),
        ),
        child: Row(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.drag_indicator,
                  size: 18, color: AppColors.stone3),
            ),

            // Number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isPlaying ? AppColors.saffron : AppColors.stone2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPlaying ? AppColors.white : AppColors.ink3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aarti.deity.toUpperCase(),
                      style: AppTextStyles.label(
                          size: 9, color: AppColors.saffron)),
                  const SizedBox(height: 1),
                  Text(
                    aarti.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(aarti.devanagari,
                      style: AppTextStyles.devanagari(
                          size: 11, color: AppColors.ink3)),
                ],
              ),
            ),

            // Offline badge
            if (aarti.isOffline)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.saffronGlow,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.saffron.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_done,
                        size: 10, color: AppColors.saffron),
                    const SizedBox(width: 3),
                    Text('Ready',
                        style: AppTextStyles.body(
                            size: 10, color: AppColors.saffron)),
                  ],
                ),
              ),

            Text(aarti.duration,
                style: AppTextStyles.body(size: 12, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
