import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../data/models/aarti_item.dart';
import '../../../shared/utils/aarti_language_resolver.dart';

class PujaListItem extends StatelessWidget {
  final AartiItem aarti;
  final int scriptMode;
  final int index;
  final bool isPlaying;
  final Duration delay;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const PujaListItem({
    super.key,
    required this.aarti,
    required this.scriptMode,
    required this.index,
    required this.isPlaying,
    required this.delay,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentFill = isDark ? AppColors.saffronLight : AppColors.saffron;
    final accentForeground = isDark ? AppColors.darkBg : AppColors.white;
    final accentSurface =
        isDark ? AppColors.saffron.withValues(alpha: 0.18) : AppColors.saffronGlow;
    final scriptTitle = AartiLanguageResolver.resolveAartiTitle(aarti, scriptMode);
    final showScriptTitle = scriptTitle.trim() != aarti.title.trim();

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
                      size: 18, color: context.borderSubtle),
                ),
              ),

              // Number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isPlaying ? accentFill : context.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: isPlaying ? accentForeground : context.textCaption,
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
                        style: AppTypography.label(
                            size: 9, color: AppColors.saffron)),
                    const SizedBox(height: 1),
                    Text(
                      aarti.title,
                      style: AppTypography.serifBody(
                        size: 16,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showScriptTitle)
                      Text(
                        scriptTitle,
                        style: AppTypography.devanagari(
                          size: 11,
                          color: context.textCaption,
                        ),
                      ),
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
                    color: accentSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      size: 18, color: accentFill),
                ),
              ),
              const SizedBox(width: 8),

              Text(aarti.duration,
                  style: AppTypography.body(size: 12, color: context.textCaption)),

              if (onRemove != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.borderSubtle),
                    ),
                    child: Icon(Icons.close,
                        size: 12, color: context.textCaption),
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
