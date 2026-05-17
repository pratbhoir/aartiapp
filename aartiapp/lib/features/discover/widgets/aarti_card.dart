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
    final hasAudio = aarti.audioUrl.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentSurface = isDark
      ? AppColors.white.withValues(alpha: 0.06)
      : AppColors.stone2.withValues(alpha: 0.72);
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
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaItem(
                        icon: Icons.schedule_outlined,
                        label: aarti.duration,
                      ),
                      if (hasAudio)
                        _StatusChip(
                          label: 'Audio',
                          icon: Icons.headphones_rounded,
                          backgroundColor: accentSurface,
                        ),
                    ],
                  ),
                ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.textCaption),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.body(
              size: 10,
              color: context.textCaption,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.ink3),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.body(size: 12, color: AppColors.ink3),
        ),
      ],
    );
  }
}
