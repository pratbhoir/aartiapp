import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/haptics.dart';
import '../../core/l10n/app_localizations_ext.dart';
import '../../core/services/analytics_service.dart';
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
  bool _didCompleteSession = false;
  bool _didTrackExit = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackScreen(
        '/puja-focus-session',
        title: 'Puja Focus Session',
      );
    });
  }

  @override
  void dispose() {
    _trackExitIfNeeded();
    super.dispose();
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

  void _trackExitIfNeeded() {
    if (_didCompleteSession || _didTrackExit) {
      return;
    }

    _didTrackExit = true;

    AnalyticsService.trackEvent(
      'puja_focus_session_exited',
      data: <String, Object>{
        'current_index': _currentIndex,
        'total_count': widget.pujaAartis.length,
      },
      path: '/puja-focus-session',
    );
  }

  void _completeSession() {
    if (_didCompleteSession) {
      Navigator.pop(context);
      return;
    }

    _didCompleteSession = true;
    AnalyticsService.trackEvent(
      'puja_focus_session_completed',
      data: <String, Object>{'total_count': widget.pujaAartis.length},
      path: '/puja-focus-session',
    );
    Navigator.pop(context);
  }

  void _closeSession() {
    _trackExitIfNeeded();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appLanguageCode = ref.watch(preferredLanguageProvider);
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
        headerLabel: l10n.pujaFocusSessionHeader,
        useSessionHeaderLayout: true,
        progressLabel: l10n.pujaSessionProgress(
          _currentIndex + 1,
          widget.pujaAartis.length,
        ),
        sessionIndex: _currentIndex,
        sessionCount: widget.pujaAartis.length,
        onOpenSettings: () => _showSessionSettings(
          context: context,
          appLanguageCode: appLanguageCode,
          canShowSecondaryScript: canShowSecondaryScript,
        ),
        onPreviousAarti: _hasPrev ? _goPrev : null,
        previousAartiTitle: _hasPrev
            ? widget.pujaAartis[_currentIndex - 1].title
            : null,
        onNextAarti: _hasNext ? _goNext : null,
        nextAartiTitle: _hasNext
            ? widget.pujaAartis[_currentIndex + 1].title
            : null,
        onComplete: _completeSession,
        completionLabel: l10n.focusModeOverlayCompleteSession,
        onClose: _closeSession,
      ),
    );
  }

  void _showSessionSettings({
    required BuildContext context,
    required String appLanguageCode,
    required bool canShowSecondaryScript,
  }) {
    showFocusModeSettingsSheet(
      context: context,
      appLanguageCode: appLanguageCode,
      scriptMode: _focusScriptMode,
      textScale: _focusTextScale,
      canShowSecondaryScript: canShowSecondaryScript,
      activeScriptSurface:
          _contentMode == AartiDetailContentMode.transliteration
          ? FocusModeScriptSurface.secondary
          : FocusModeScriptSurface.primary,
      onScriptSurfaceChanged: (surface) {
        AnalyticsService.trackEvent(
          'puja_focus_mode_changed',
          data: <String, Object>{
            'mode': surface == FocusModeScriptSurface.secondary
                ? 'secondary'
                : 'primary',
            'aarti_id': _currentAarti.id,
          },
          path: '/puja-focus-session',
        );
        setState(() {
          _contentMode =
              surface == FocusModeScriptSurface.secondary &&
                  canShowSecondaryScript
              ? AartiDetailContentMode.transliteration
              : AartiDetailContentMode.lyrics;
        });
      },
      onTextScaleChanged: (newScale) {
        setState(() {
          _focusTextScale = newScale;
        });
      },
      description: context.l10n.pujaFocusSettingsDescription,
      footerNote: _hasNext
          ? context.l10n.pujaFocusSettingsFooterContinue
          : context.l10n.pujaFocusSettingsFooterComplete,
    );
  }
}
