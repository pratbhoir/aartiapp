import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_aware_colors.dart';

/// Hero header for the deity detail page.
class DeityHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String devanagariTitle;
  final String tagline;
  final String summary;
  final String mantra;
  final String auspiciousDay;
  final Color accentColor;
  final int devotionalCount;
  final List<String> festivalNames;
  final double heroProgress;

  const DeityHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.devanagariTitle,
    required this.tagline,
    required this.summary,
    required this.mantra,
    required this.auspiciousDay,
    required this.accentColor,
    required this.devotionalCount,
    required this.festivalNames,
    required this.heroProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final heroOpacity = (1 - heroProgress).clamp(0.0, 1.0);
    final surface = context.surface;
    final primaryText = context.textPrimary;
    final secondaryText = context.textSecondary;
    final captionText = context.textCaption;
    final baseGradientEnd = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBg
        : AppColors.stone;
    final gradientTop = Theme.of(context).brightness == Brightness.dark
        ? AppColors.ink
        : Color.lerp(AppColors.ink, AppColors.saffronDark, 0.08)!;
    final overlayGlow = Theme.of(context).brightness == Brightness.dark
        ? AppColors.saffronLight.withValues(alpha: 0.18)
        : AppColors.saffron.withValues(alpha: 0.14);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            gradientTop,
            Color.lerp(baseGradientEnd, surface, 0.45)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: -64,
            right: -44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[overlayGlow, Colors.transparent],
                ),
              ),
              child: const SizedBox(width: 240, height: 240),
            ),
          ),
          Positioned(
            bottom: -36,
            left: -18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const SizedBox(width: 210, height: 210),
            ),
          ),
          Positioned(
            right: -12,
            bottom: 52,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12 * heroOpacity,
                child: Text(emoji, style: const TextStyle(fontSize: 134)),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                62,
                AppSpacing.xl,
                AppSpacing.lgWide,
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isCompact = constraints.maxHeight < 280;
                  final titleSize = isCompact ? 30.0 : 38.0;
                  final sectionGap = isCompact ? AppSpacing.sm : AppSpacing.md;

                  return Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Opacity(
                        opacity: heroOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Text(
                            //   'BROWSE BY DEITY',
                            //   style: AppTypography.label(
                            //     size: 10,
                            //     color: AppColors.white.withValues(alpha: 0.64),
                            //   ),
                            // ),
                            // SizedBox(height: sectionGap),
                            // Container(
                            //   width: badgeSize,
                            //   height: badgeSize,
                            //   alignment: Alignment.center,
                            //   decoration: BoxDecoration(
                            //     color: AppColors.white.withValues(alpha: 0.14),
                            //     borderRadius: BorderRadius.circular(22),
                            //     border: Border.all(
                            //       color: AppColors.white.withValues(
                            //         alpha: 0.16,
                            //       ),
                            //     ),
                            //   ),
                            //   child: Text(
                            //     emoji,
                            //     style: TextStyle(fontSize: isCompact ? 30 : 34),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: isCompact ? AppSpacing.md : AppSpacing.lg,
                            // ),
                            // Text(
                            //   devanagariTitle,
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: AppTypography.devanagari(
                            //     size: isCompact ? 15 : 17,
                            //     color: AppColors.white.withValues(alpha: 0.84),
                            //   ).copyWith(height: 1.3),
                            // ),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: '$emoji ',
                                          style: TextStyle(
                                            fontSize: isCompact ? 24 : 28,
                                          ),
                                        ),
                                        TextSpan(
                                          text: title,
                                          style:
                                              AppTypography.displayLarge(
                                                context,
                                              ).copyWith(
                                                fontSize: titleSize,
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    tagline,
                                    maxLines: isCompact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(
                                      size: 13,
                                      color: AppColors.white.withValues(
                                        alpha: 0.76,
                                      ),
                                      weight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: sectionGap),
                                  Text(
                                    summary,
                                    maxLines: isCompact ? 2 : 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(
                                      size: 13,
                                      color: AppColors.white.withValues(
                                        alpha: 0.68,
                                      ),
                                      weight: FontWeight.w400,
                                    ).copyWith(height: 1.45),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: isCompact ? AppSpacing.md : AppSpacing.lg,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: isCompact
                                    ? AppSpacing.sm
                                    : AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: surface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 16,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          l10n.deityDetailDailyMantraLabel,
                                          style: AppTypography.label(
                                            size: 9,
                                            color: captionText,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          mantra,
                                          maxLines: isCompact ? 2 : 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.body(
                                            size: 12,
                                            color: primaryText,
                                            weight: FontWeight.w400,
                                          ).copyWith(height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: isCompact ? AppSpacing.md : AppSpacing.lg,
                            ),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: <Widget>[
                                _DeityHeaderChip(
                                  label: l10n.deityDetailDevotionalCount(
                                    devotionalCount,
                                  ),
                                  accentColor: accentColor,
                                  foregroundColor: primaryText,
                                  backgroundColor: surface.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                                _DeityHeaderChip(
                                  label: auspiciousDay,
                                  accentColor: accentColor,
                                  foregroundColor: secondaryText,
                                  backgroundColor: surface.withValues(
                                    alpha: 0.86,
                                  ),
                                  icon: Icons.calendar_today_rounded,
                                ),
                                if (festivalNames.isNotEmpty)
                                  _DeityHeaderChip(
                                    label: festivalNames.first,
                                    accentColor: accentColor,
                                    foregroundColor: secondaryText,
                                    backgroundColor: surface.withValues(
                                      alpha: 0.86,
                                    ),
                                    icon: Icons.celebration_outlined,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeityHeaderChip extends StatelessWidget {
  const _DeityHeaderChip({
    required this.label,
    required this.accentColor,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
  });

  final String label;
  final Color accentColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smWide,
        vertical: AppSpacing.smTight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: accentColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.body(
              size: 11,
              color: foregroundColor,
              weight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
