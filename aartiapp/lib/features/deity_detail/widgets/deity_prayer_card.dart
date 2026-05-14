import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../data/models/aarti_item.dart';
import '../../../shared/utils/aarti_language_resolver.dart';

/// List card used on the deity page for each devotional item.
class DeityPrayerCard extends StatelessWidget {
  /// The devotional item rendered by the card.
  final AartiItem aarti;

  /// The active global script mode used for script-aware subtitle rendering.
  final int scriptMode;

  /// Whether the item is already bookmarked.
  final bool isBookmarked;

  /// Called when the main card body is tapped.
  final VoidCallback onTap;

  /// Called when the bookmark affordance is tapped.
  final VoidCallback onBookmark;

  /// Creates a deity-page devotional list card.
  const DeityPrayerCard({
    super.key,
    required this.aarti,
    required this.scriptMode,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = AartiLanguageResolver.resolveAartiTitle(
      aarti,
      scriptMode,
    );
    final showResolvedTitle = resolvedTitle.trim() != aarti.title.trim();
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    final subtitleStyle = script == AppScriptLanguage.english
        ? AppTypography.transliteration(size: 12, color: context.textCaption)
        : AppTypography.devanagari(size: 12, color: context.textCaption);
    final typeStyle = _typeStyleFor(aarti.type);
    final typeIcon = _typeIconFor(aarti.type);
    final hasAudio = aarti.audioUrl.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentSurface = isDark
        ? AppColors.white.withValues(alpha: 0.06)
        : AppColors.stone2.withValues(alpha: 0.72);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxs,
                      AppSpacing.xxs,
                      AppSpacing.xxs,
                      AppSpacing.md,
                    ),
                    child: Container(
                      width: AppSpacing.xxxl,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppSpacing.xxs),
                      ),
                    ),
                  ),
                  const Spacer(),

                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: AppSpacing.xxl,
                    height: AppSpacing.xxl,
                    margin: const EdgeInsets.only(top: AppSpacing.xxs),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: typeStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(AppSpacing.smWide),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeStyle.foregroundColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          aarti.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.serifBody(
                            size: 20,
                            color: context.textPrimary,
                          ).copyWith(height: 1.25),
                        ),
                        if (showResolvedTitle) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            resolvedTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // const Spacer(),
                  Semantics(
                    label: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                    button: true,
                    child: GestureDetector(
                      onTap: onBookmark,
                      child: SizedBox(
                        width: AppSpacing.touchTarget,
                        height: AppSpacing.touchTarget,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isBookmarked
                                  ? AppColors.saffronGlow
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                              border: Border.all(
                                color: isBookmarked
                                    ? AppColors.saffron
                                    : context.borderSubtle,
                              ),
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              size: 14,
                              color: isBookmarked
                                  ? AppColors.saffron
                                  : context.textCaption,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        _MetaItem(
                          icon: Icons.schedule_outlined,
                          label: aarti.duration,
                        ),
                        _MetaItem(
                          icon: Icons.format_list_numbered_outlined,
                          label: aarti.versesLabel,
                        ),
                        _MetaItem(
                          icon: typeIcon,
                          label: _displayTypeLabel(aarti.type),
                          foregroundColor: typeStyle.foregroundColor,
                        ),
                      ],
                    ),
                  ),
                  if (hasAudio) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    _StatusChip(
                      label: 'Audio',
                      icon: Icons.headphones_rounded,
                      backgroundColor: accentSurface,
                    ),
                  ],
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: context.textCaption),
          const SizedBox(width: AppSpacing.xs),
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
  const _MetaItem({
    required this.label,
    required this.icon,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = foregroundColor ?? context.textCaption;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: resolvedColor),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.body(
            size: 12,
            color: resolvedColor,
            weight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _TypeStyle {
  const _TypeStyle({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}

_TypeStyle _typeStyleFor(String rawType) {
  switch (rawType.trim().toLowerCase()) {
    case 'chalisa':
      return _TypeStyle(
        backgroundColor: AppColors.gold.withValues(alpha: 0.14),
        foregroundColor: AppColors.gold,
      );
    case 'shloka':
    case 'stotra':
    case 'mantra':
    case 'chant':
    case 'vandana':
    case 'abhang':
    case 'bhajan':
      return _TypeStyle(
        backgroundColor: AppColors.saffronGlow,
        foregroundColor: AppColors.saffronDark,
      );
      // return _TypeStyle(
      //   backgroundColor: AppColors.stone2,
      //   foregroundColor: AppColors.ink2,
      // );
    case 'aarti':
    default:
      return _TypeStyle(
        backgroundColor: AppColors.saffronGlow,
        foregroundColor: AppColors.saffronDark,
      );
  }
}

IconData _typeIconFor(String rawType) {
  switch (rawType.trim().toLowerCase()) {
    case 'chalisa':
      return Icons.auto_stories_outlined;
    case 'shloka':
    case 'stotra':
    case 'mantra':
    case 'chant':
    case 'vandana':
    case 'abhang':
    case 'bhajan':
      return Icons.notes_rounded;
    case 'aarti':
    default:
      return Icons.wb_incandescent_rounded;
  }
}

String _displayTypeLabel(String rawType) {
  final normalized = rawType.trim().toLowerCase();
  switch (normalized) {
    case 'aarti':
      return 'AARTI';
    case 'chalisa':
      return 'CHALISA';
    case 'shloka':
      return 'SHLOKA';
    case 'stotra':
      return 'STOTRA';
    case 'mantra':
      return 'MANTRA';
    case 'chant':
      return 'CHANT';
    case 'vandana':
      return 'VANDANA';
    case 'abhang':
      return 'ABHANG';
    case 'bhajan':
      return 'BHAJAN';
    default:
      return normalized.toUpperCase();
  }
}
