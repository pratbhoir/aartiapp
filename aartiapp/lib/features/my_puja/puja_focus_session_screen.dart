import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/aarti_item.dart';
import '../../providers/app_providers.dart';
import '../../shared/utils/aarti_language_resolver.dart';
import '../../shared/widgets/focus_mode_settings_sheet.dart';
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
    final bool canShowSecondaryScript =
        AartiLanguageResolver.shouldShowSecondaryScriptMode(
          verses: _currentAarti.verses,
        );
    final selectedMode =
        canShowSecondaryScript &&
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
          appLanguageCode: appLanguageCode,
          canShowSecondaryScript: canShowSecondaryScript,
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
    required String appLanguageCode,
    required bool canShowSecondaryScript,
    required int preferredScriptMode,
  }) {
    showFocusModeSettingsSheet(
      context: context,
      appLanguageCode: appLanguageCode,
      scriptMode: _focusScriptMode,
      textScale: _focusTextScale,
      canShowSecondaryScript: canShowSecondaryScript,
      isSecondaryScriptOn:
          _contentMode == AartiDetailContentMode.transliteration,
      preferredScriptMode: preferredScriptMode,
      onScriptModeChanged: (newMode) {
        setState(() {
          _focusScriptMode = newMode;
          if (_contentMode == AartiDetailContentMode.transliteration &&
              !AartiLanguageResolver.shouldShowSecondaryScriptMode(
                verses: _currentAarti.verses,
              )) {
            _contentMode = AartiDetailContentMode.lyrics;
          }
        });
      },
      onSecondaryScriptChanged: (value) {
        setState(() {
          _contentMode = value
              ? AartiDetailContentMode.transliteration
              : AartiDetailContentMode.lyrics;
        });
      },
      onTextScaleChanged: (newScale) {
        setState(() {
          _focusTextScale = newScale;
        });
      },
      description: 'Adjust how the current aarti is shown in focus session.',
      footerNote: _hasNext
          ? 'Reach the final verse to continue to the next aarti in your puja order.'
          : 'Reach the final verse to finish this focus session.',
    );
  }

  int _preferredScriptModeForFocusSession(String appLanguageCode) {
    final int preferredScriptMode =
        AartiLanguageResolver.preferredScriptModeForLanguageCode(
          appLanguageCode,
        );
    return preferredScriptMode == 1 ? 0 : preferredScriptMode;
  }
}
