import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/aarti_item.dart';
import '../../providers/app_providers.dart';
import '../../shared/utils/aarti_language_resolver.dart';
import '../aarti_detail/widgets/focus_mode_overlay.dart';

/// Sequential reading session for the My Daily Puja list.
class PujaFocusSessionScreen extends ConsumerStatefulWidget {
  final List<AartiItem> pujaAartis;
  final int startIndex;

  const PujaFocusSessionScreen({
    super.key,
    required this.pujaAartis,
    this.startIndex = 0,
  });

  @override
  ConsumerState<PujaFocusSessionScreen> createState() =>
      _PujaFocusSessionScreenState();
}

class _PujaFocusSessionScreenState
    extends ConsumerState<PujaFocusSessionScreen> {
  late int _currentIndex;
  late int _focusScriptMode;
  late double _focusTextScale;
  AartiDetailContentMode _contentMode = AartiDetailContentMode.lyrics;

  AartiItem get _currentAarti => widget.pujaAartis[_currentIndex];
  bool get _hasNext => _currentIndex < widget.pujaAartis.length - 1;
  bool get _hasPrev => _currentIndex > 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex.clamp(0, widget.pujaAartis.length - 1);
    _focusScriptMode = ref.read(scriptModeProvider);
    _focusTextScale = ref.read(textScaleProvider);
    _markCurrentAartiVisited();
  }

  void _markCurrentAartiVisited() {
    ref.read(recentlyPlayedProvider.notifier).addRecent(_currentAarti.id);
  }

  void _goNext() {
    if (!_hasNext) {
      return;
    }

    AppHaptics.pageTransition();
    setState(() {
      _currentIndex++;
    });
    _markCurrentAartiVisited();
  }

  void _goPrev() {
    if (!_hasPrev) {
      return;
    }

    AppHaptics.pageTransition();
    setState(() {
      _currentIndex--;
    });
    _markCurrentAartiVisited();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguageCode = ref.watch(preferredLanguageProvider);
    final int preferredScriptMode = _preferredScriptModeForFocusSession(
      appLanguageCode,
    );
    final bool canShowTransliteration =
        AartiLanguageResolver.shouldShowTransliteration(
          scriptMode: _focusScriptMode,
          appLanguageCode: appLanguageCode,
          verses: _currentAarti.verses,
        );
    final selectedMode =
        canShowTransliteration &&
            _contentMode == AartiDetailContentMode.transliteration
        ? AartiDetailContentMode.transliteration
        : AartiDetailContentMode.lyrics;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: FocusModeOverlay(
        key: ValueKey(
          '${_currentAarti.id}-${selectedMode.name}-$_focusScriptMode-$appLanguageCode',
        ),
        aarti: _currentAarti,
        verses: _currentAarti.verses,
        scriptMode: _focusScriptMode,
        textScale: _focusTextScale,
        appLanguageCode: appLanguageCode,
        contentMode: selectedMode,
        headerLabel: 'PUJA FOCUS SESSION',
        useSessionHeaderLayout: true,
        progressLabel: '${_currentIndex + 1} of ${widget.pujaAartis.length}',
        sessionIndex: _currentIndex,
        sessionCount: widget.pujaAartis.length,
        onOpenSettings: () => _showSessionSettings(
          context: context,
          canShowTransliteration: canShowTransliteration,
          preferredScriptMode: preferredScriptMode,
        ),
        onPreviousAarti: _hasPrev ? _goPrev : null,
        previousAartiTitle: _hasPrev
            ? widget.pujaAartis[_currentIndex - 1].title
            : null,
        onNextAarti: _hasNext ? _goNext : null,
        nextAartiTitle: _hasNext
            ? widget.pujaAartis[_currentIndex + 1].title
            : null,
        onComplete: () => Navigator.pop(context),
        completionLabel: 'Complete Session',
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showSessionSettings({
    required BuildContext context,
    required bool canShowTransliteration,
    required int preferredScriptMode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final int currentScriptMode = _focusScriptMode;
            final double currentTextScale = _focusTextScale;
            final bool showTransliterationToggle =
                canShowTransliteration &&
                _currentAarti.verses.any(
                  (verse) => verse.transliteration.isNotEmpty,
                );
            final bool isTransliterationOn =
                _contentMode == AartiDetailContentMode.transliteration;

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
                    'Adjust how the current aarti is shown in focus session.',
                    style: AppTypography.body(
                      size: 12,
                      color: AppColors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _FocusSessionSettingSection(
                    label: 'Script Language',
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: _ScriptOptionButton(
                              label: AartiLanguageResolver.scriptLabel(1),
                              isActive: currentScriptMode == 1,
                              onTap: () {
                                _setScriptMode(
                                  newMode: 1,
                                  setSheetState: setSheetState,
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ScriptOptionButton(
                            label: AartiLanguageResolver.scriptLabel(
                              preferredScriptMode,
                            ),
                            isActive: currentScriptMode == preferredScriptMode,
                            onTap: () {
                              _setScriptMode(
                                newMode: preferredScriptMode,
                                setSheetState: setSheetState,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showTransliterationToggle) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _FocusSessionSettingSection(
                      label: 'Transliteration',
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
                                    'Show transliteration',
                                    style: AppTypography.body(
                                      size: 13,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Text(
                                    'Use romanized text when the selected script differs from your reading language.',
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
                              value: isTransliterationOn,
                              activeTrackColor: AppColors.saffron,
                              onChanged: (value) {
                                setState(() {
                                  _contentMode = value
                                      ? AartiDetailContentMode.transliteration
                                      : AartiDetailContentMode.lyrics;
                                });
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _FocusSessionSettingSection(
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
                              _setTextScale(
                                newScale: _focusTextScale - 0.1,
                                setSheetState: setSheetState,
                              );
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(currentTextScale * 100).round()}%',
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
                              _setTextScale(
                                newScale: _focusTextScale + 0.1,
                                setSheetState: setSheetState,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _hasNext
                        ? 'Reach the final verse to continue to the next aarti in your puja order.'
                        : 'Reach the final verse to finish this focus session.',
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

  int _preferredScriptModeForFocusSession(String appLanguageCode) {
    final AppScriptLanguage preferredScript =
        AartiLanguageResolver.preferredScriptForLanguage(
          AartiLanguageResolver.appLanguageFromCode(appLanguageCode),
        );
    switch (preferredScript) {
      case AppScriptLanguage.gujarati:
        return 2;
      case AppScriptLanguage.english:
      case AppScriptLanguage.devanagari:
        return 0;
    }
  }

  void _setScriptMode({
    required int newMode,
    required StateSetter setSheetState,
  }) {
    setState(() {
      _focusScriptMode = newMode;
      if (_contentMode == AartiDetailContentMode.transliteration &&
          !AartiLanguageResolver.shouldShowTransliteration(
            scriptMode: newMode,
            appLanguageCode: ref.read(preferredLanguageProvider),
            verses: _currentAarti.verses,
          )) {
        _contentMode = AartiDetailContentMode.lyrics;
      }
    });
    setSheetState(() {});
  }

  void _setTextScale({
    required double newScale,
    required StateSetter setSheetState,
  }) {
    setState(() {
      _focusTextScale = newScale.clamp(0.8, 1.6);
    });
    setSheetState(() {});
  }
}

class _FocusSessionSettingSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FocusSessionSettingSection({required this.label, required this.child});

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
