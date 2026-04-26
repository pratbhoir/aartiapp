import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../data/models/aarti_item.dart';
import '../../../shared/utils/aarti_language_resolver.dart';

class AartiCard extends StatelessWidget {
  final AartiItem aarti;
  final int scriptMode;
  final bool isBookmarked;
  final Duration delay;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const AartiCard({
    super.key,
    required this.aarti,
    required this.scriptMode,
    required this.isBookmarked,
    required this.delay,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scriptTitle = AartiLanguageResolver.resolveAartiTitle(aarti, scriptMode);
    final showScriptTitle = scriptTitle.trim() != aarti.title.trim();
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    final subtitleStyle = script == AppScriptLanguage.english
        ? AppTypography.transliteration(size: 12, color: AppColors.ink3)
        : AppTypography.devanagari(size: 12, color: AppColors.ink3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
              child: Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              aarti.deity.toUpperCase(),
              style: AppTypography.label(size: 10, color: AppColors.saffron),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                aarti.title,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: context.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showScriptTitle)
              Text(
                scriptTitle,
                style: subtitleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(aarti.duration,
                    style: AppTypography.body(size: 12, color: AppColors.ink3)),
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
