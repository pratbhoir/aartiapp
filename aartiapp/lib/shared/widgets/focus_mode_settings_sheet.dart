import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../utils/aarti_language_resolver.dart';

/// Script surfaces available in temporary focus-mode reading settings.
enum FocusModeScriptSurface { primary, secondary }

/// Shows the temporary focus-mode reading settings sheet.
Future<void> showFocusModeSettingsSheet({
  required BuildContext context,
  required String appLanguageCode,
  required int scriptMode,
  required double textScale,
  required bool canShowSecondaryScript,
  required FocusModeScriptSurface activeScriptSurface,
  required ValueChanged<FocusModeScriptSurface> onScriptSurfaceChanged,
  required ValueChanged<double> onTextScaleChanged,
  required String description,
  required String footerNote,
}) {
  double localTextScale = textScale;
  FocusModeScriptSurface localScriptSurface = activeScriptSurface;
  final l10n = context.l10n;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final String primaryScriptLabel =
              AartiLanguageResolver.localizedScriptLabel(context, scriptMode);
          final String secondaryScriptLabel =
              AartiLanguageResolver.localizedSecondaryScriptLabel(
                context,
                scriptMode: scriptMode,
                appLanguageCode: appLanguageCode,
              );

          return Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lgWide),
                  Text(
                    l10n.focusModeSettingsTitle,
                    style: AppTypography.serifBody(
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.body(
                      size: 12,
                      color: AppColors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  if (canShowSecondaryScript) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _FocusModeSettingSection(
                      label: l10n.focusModeSettingsReadingSurface,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: _ScriptSurfaceButton(
                                label: primaryScriptLabel,
                                isActive:
                                    localScriptSurface ==
                                    FocusModeScriptSurface.primary,
                                onTap: () {
                                  onScriptSurfaceChanged(
                                    FocusModeScriptSurface.primary,
                                  );
                                  setSheetState(() {
                                    localScriptSurface =
                                        FocusModeScriptSurface.primary;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: _ScriptSurfaceButton(
                              label: secondaryScriptLabel,
                              isActive:
                                  localScriptSurface ==
                                  FocusModeScriptSurface.secondary,
                              onTap: () {
                                onScriptSurfaceChanged(
                                  FocusModeScriptSurface.secondary,
                                );
                                setSheetState(() {
                                  localScriptSurface =
                                      FocusModeScriptSurface.secondary;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _FocusModeSettingSection(
                    label: l10n.focusModeSettingsTextSize,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius,
                        ),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          _TextScaleButton(
                            label: 'A-',
                            onTap: () {
                              final double nextScale = (localTextScale - 0.1)
                                  .clamp(0.8, 1.6);
                              onTextScaleChanged(nextScale);
                              setSheetState(() {
                                localTextScale = nextScale;
                              });
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(localTextScale * 100).round()}%',
                                style: AppTypography.body(
                                  size: 12,
                                  color: AppColors.white,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          _TextScaleButton(
                            label: 'A+',
                            onTap: () {
                              final double nextScale = (localTextScale + 0.1)
                                  .clamp(0.8, 1.6);
                              onTextScaleChanged(nextScale);
                              setSheetState(() {
                                localTextScale = nextScale;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    footerNote,
                    style: AppTypography.body(
                      size: 11,
                      color: AppColors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _FocusModeSettingSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FocusModeSettingSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.label(size: 10, color: AppColors.ink3),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _ScriptSurfaceButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ScriptSurfaceButton({
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
        constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppColors.saffronGlow : AppColors.darkBg,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: isActive ? AppColors.saffron : AppColors.darkBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 12,
            color: isActive ? AppColors.saffronLight : AppColors.white,
            weight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TextScaleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TextScaleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppSpacing.touchTarget,
          minHeight: AppSpacing.touchTarget,
        ),
        decoration: BoxDecoration(
          color: AppColors.saffronGlow,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: AppColors.darkBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.body(
            size: 12,
            color: AppColors.saffronLight,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
