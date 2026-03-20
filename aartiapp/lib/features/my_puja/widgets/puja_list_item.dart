import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../data/models/aarti_item.dart';

class PujaListItem extends StatelessWidget {
  final AartiItem aarti;
  final int index;
  final bool isPlaying;
  final Duration delay;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const PujaListItem({
    super.key,
    required this.aarti,
    required this.index,
    required this.isPlaying,
    required this.delay,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index - 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.drag_indicator,
                      size: 18, color: AppColors.stone3),
                ),
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
                      style: AppTextStyles.serifBody(
                        size: 16,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(aarti.devanagari,
                        style: AppTextStyles.devanagari(
                            size: 11, color: AppColors.ink3)),
                  ],
                ),
              ),

              // Play button
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.saffronGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 18, color: AppColors.saffron),
                ),
              ),
              const SizedBox(width: 8),

              Text(aarti.duration,
                  style: AppTextStyles.body(size: 12, color: AppColors.ink3)),

              if (onRemove != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.stone2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: AppColors.ink3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
