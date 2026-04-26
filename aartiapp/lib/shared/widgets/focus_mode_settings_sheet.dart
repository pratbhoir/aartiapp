import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../utils/aarti_language_resolver.dart';

/// Shows the temporary focus-mode reading settings sheet.
Future<void> showFocusModeSettingsSheet({
  required BuildContext context,
  required String appLanguageCode,
  required int scriptMode,
  required double textScale,
  required bool canShowSecondaryScript,
  required bool isSecondaryScriptOn,
  required int preferredScriptMode,
  required ValueChanged<int> onScriptModeChanged,
  required ValueChanged<bool> onSecondaryScriptChanged,
  required ValueChanged<double> onTextScaleChanged,
  required String description,
  required String footerNote,
}) {
  int localScriptMode = scriptMode;
  double localTextScale = textScale;
  bool localSecondaryScriptOn = isSecondaryScriptOn;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final String secondaryScriptLabel =
              AartiLanguageResolver.secondaryScriptLabel(
                scriptMode: localScriptMode,
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
                  'Reading Settings',
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
                const SizedBox(height: AppSpacing.xl),
                _FocusModeSettingSection(
                  label: 'Script Language',
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _ScriptOptionButton(
                            label: AartiLanguageResolver.scriptLabel(1),
                            isActive: localScriptMode == 1,
                            onTap: () {
                              onScriptModeChanged(1);
                              setSheetState(() {
                                localScriptMode = 1;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: _ScriptOptionButton(
                          label: AartiLanguageResolver.scriptLabel(
                            preferredScriptMode,
                          ),
                          isActive: localScriptMode == preferredScriptMode,
                          onTap: () {
                            onScriptModeChanged(preferredScriptMode);
                            setSheetState(() {
                              localScriptMode = preferredScriptMode;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (canShowSecondaryScript) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _FocusModeSettingSection(
                    label: 'Secondary Script',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Show $secondaryScriptLabel',
                                  style: AppTypography.body(
                                    size: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  'The app language defines the secondary script. Matching choices fall back to Devanagari.',
                                  style: AppTypography.body(
                                    size: 11,
                                    color: AppColors.white.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: localSecondaryScriptOn,
                            activeTrackColor: AppColors.saffron,
                            onChanged: (value) {
                              onSecondaryScriptChanged(value);
                              setSheetState(() {
                                localSecondaryScriptOn = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _FocusModeSettingSection(
                  label: 'Text Size',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
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
                                size: 13,
                                color: AppColors.white,
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

class _ScriptOptionButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ScriptOptionButton({
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
        height: AppSpacing.touchTarget,
        decoration: BoxDecoration(
          color: isActive ? AppColors.saffronGlow : AppColors.darkBg,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: isActive ? AppColors.saffron : AppColors.darkBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body(
              size: 12,
              color: isActive ? AppColors.saffronLight : AppColors.white,
              weight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
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
          border: Border.all(color: AppColors.saffron),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body(
              size: 13,
              color: AppColors.saffronLight,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
