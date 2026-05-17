import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/haptics.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/activity_log_service.dart';
import '../../core/services/sharing_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../core/l10n/app_localizations_ext.dart';
import '../../core/utils/day_deity_mapper.dart';
import '../../data/models/aarti_item.dart';
import '../../providers/app_providers.dart';
import '../../shared/utils/aarti_language_resolver.dart';
import '../../shared/widgets/focus_mode_settings_sheet.dart';
import 'widgets/action_chip.dart' as app;
import 'widgets/verse_block.dart';
import 'widgets/audio_player_widget.dart';
import 'widgets/focus_mode_overlay.dart';
import 'widgets/mantra_counter_overlay.dart';
import '../../shared/widgets/toggle_bar.dart';

class AartiDetailScreen extends ConsumerStatefulWidget {
  final AartiItem aarti;
  const AartiDetailScreen({super.key, required this.aarti});

  @override
  ConsumerState<AartiDetailScreen> createState() => _AartiDetailScreenState();
}

class _AartiDetailScreenState extends ConsumerState<AartiDetailScreen>
    with TickerProviderStateMixin {
  AartiDetailContentMode _contentMode = AartiDetailContentMode.lyrics;
  AartiDetailContentMode _focusContentMode = AartiDetailContentMode.lyrics;
  bool _focusMode = false;
  bool _showCounter = false;
  final ScrollController _scrollController = ScrollController();
  int _currentVerse = 0;
  bool _showNextFab = false;
  bool _repeatOn = false;
  int _focusScriptMode = 0;
  double _focusTextScale = 1.0;

  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // For share-as-image
  final GlobalKey _lyricsRepaintKey = GlobalKey();

  AartiItem? _resolveNextPujaAarti() {
    final userAartis = ref.read(userAartiProvider);
    final pujaAartis = ref
        .read(pujaOrderProvider.notifier)
        .getPujaAartis(userAartis: userAartis);
    return _nextPujaAarti(pujaAartis: pujaAartis);
  }

  AartiItem? _nextPujaAarti({required List<AartiItem> pujaAartis}) {
    final currentIndex = pujaAartis.indexWhere(
      (aarti) => aarti.id == widget.aarti.id,
    );
    if (currentIndex == -1 || currentIndex >= pujaAartis.length - 1) {
      return null;
    }

    return pujaAartis[currentIndex + 1];
  }

  void _openAarti(AartiItem aarti) {
    ref.read(recentlyPlayedProvider.notifier).addRecent(aarti.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AartiDetailScreen(aarti: aarti)),
    );
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    if (widget.aarti.audioUrl.trim().isNotEmpty) {
      _initAudio();
    }
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackScreen(
        '/aarti/${widget.aarti.id}',
        title: widget.aarti.title,
      );
      AnalyticsService.trackEvent(
        'aarti_detail',
        data: <String, Object>{
          'aarti_id': widget.aarti.id,
          'deity_name': widget.aarti.deity,
        },
        path: '/aarti/${widget.aarti.id}',
      );
    });
  }

  Future<void> _initAudio() async {
    try {
      final dur = await _audioPlayer.setUrl(widget.aarti.audioUrl);
      if (dur != null && mounted) {
        setState(() => _duration = dur);
      }
    } catch (e, stack) {
      ActivityLogService.warn(
        'Audio',
        'Failed to initialize audio for ${widget.aarti.id}: $e',
        stack,
      );
    }

    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
          _checkNextFabTrigger();
        });
      }
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null && mounted) setState(() => _duration = dur);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          if (_repeatOn) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
          } else if (_resolveNextPujaAarti() != null) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
            setState(() => _showNextFab = true);
          } else {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateVerseProgress();
    _checkScrollToBottom();
  }

  void _updateVerseProgress() {
    final verses = widget.aarti.verses;
    if (verses.isEmpty || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final scrollFraction = (_scrollController.offset / maxScroll).clamp(
      0.0,
      1.0,
    );
    final newVerse = (scrollFraction * verses.length).floor().clamp(
      0,
      verses.length - 1,
    );
    if (newVerse != _currentVerse) {
      setState(() => _currentVerse = newVerse);
    }
  }

  /// Check if user has scrolled to bottom → trigger Next FAB
  void _checkScrollToBottom() {
    if (_resolveNextPujaAarti() == null) return;
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final fraction = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    if (fraction >= 0.95 && !_showNextFab) {
      setState(() => _showNextFab = true);
    }
  }

  /// Check if audio progress ≥ 90% → trigger Next FAB
  void _checkNextFabTrigger() {
    if (_resolveNextPujaAarti() == null) return;
    if (_duration.inMilliseconds <= 0) return;
    final progress = _position.inMilliseconds / _duration.inMilliseconds;
    if (progress >= 0.9 && !_showNextFab) {
      setState(() => _showNextFab = true);
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      AnalyticsService.trackEvent(
        'detail_audio_pause_tapped',
        data: <String, Object>{
          'aarti_id': widget.aarti.id,
          'position_ms': _position.inMilliseconds,
        },
        path: '/aarti/${widget.aarti.id}',
      );
      _audioPlayer.pause();
    } else {
      AnalyticsService.trackEvent(
        'detail_audio_play_tapped',
        data: <String, Object>{'aarti_id': widget.aarti.id},
        path: '/aarti/${widget.aarti.id}',
      );
      _audioPlayer.play();
    }
  }

  void _toggleRepeat() {
    setState(() => _repeatOn = !_repeatOn);
    _audioPlayer.setLoopMode(_repeatOn ? LoopMode.one : LoopMode.off);
  }

  void _seekBackward() {
    final newPos = _position - const Duration(seconds: 10);
    _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void _seekForward() {
    final newPos = _position + const Duration(seconds: 10);
    _audioPlayer.seek(newPos > _duration ? _duration : newPos);
  }

  void _openFocusMode({
    required int scriptMode,
    required double textScale,
    required AartiDetailContentMode selectedMode,
  }) {
    AnalyticsService.trackEvent(
      'detail_focus_mode_entered',
      data: <String, Object>{'aarti_id': widget.aarti.id},
      path: '/aarti/${widget.aarti.id}',
    );
    setState(() {
      _focusScriptMode = scriptMode;
      _focusTextScale = textScale;
      _focusContentMode = selectedMode;
      _focusMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textScale = ref.watch(textScaleProvider);
    final scriptMode = ref.watch(scriptModeProvider);
    final appLanguageCode = ref.watch(preferredLanguageProvider);
    final accentFillColor = _accentFillColor(context);
    final accentSurfaceColor = _accentSurfaceColor(context);
    final accentTextColor = _accentTextColor(context);
    final bookmarks = ref.watch(bookmarkProvider);
    final userAartis = ref.watch(userAartiProvider);
    final pujaAartis = ref
        .watch(pujaOrderProvider.notifier)
        .getPujaAartis(userAartis: userAartis);
    final isBookmarked = bookmarks.contains(widget.aarti.id);
    final nextPujaAarti = _nextPujaAarti(pujaAartis: pujaAartis);
    final canShowNextFab = nextPujaAarti != null;
    final verses = widget.aarti.verses;
    final verseCount = verses.isNotEmpty ? verses.length : 0;
    final hasAudioUrl = widget.aarti.audioUrl.trim().isNotEmpty;
    final scriptTitle = AartiLanguageResolver.resolveAartiTitle(
      widget.aarti,
      scriptMode,
    );
    final showScriptTitle =
        scriptTitle.trim().isNotEmpty &&
        scriptTitle.trim() != widget.aarti.title.trim();
    final showSecondaryScript =
        AartiLanguageResolver.shouldShowSecondaryScriptMode(verses: verses);
    final showMeaning = AartiLanguageResolver.hasMeaning(verses);
    final availableModes = <AartiDetailContentMode>[
      AartiDetailContentMode.lyrics,
      if (showSecondaryScript) AartiDetailContentMode.transliteration,
      if (showMeaning) AartiDetailContentMode.meaning,
    ];
    final selectedMode = availableModes.contains(_contentMode)
        ? _contentMode
        : availableModes.first;
    final toggleLabels = availableModes
        .map(
          (mode) => _contentModeLabel(
            mode,
            scriptMode: scriptMode,
            appLanguageCode: appLanguageCode,
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button + Bookmark
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Semantics(
                                      label: l10n.commonBack,
                                      button: true,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 44,
                                        ),
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios_new,
                                              size: 14,
                                              color: context.textCaption,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              l10n.commonBack,
                                              style: AppTypography.body(
                                                size: 12,
                                                color: context.textCaption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // // Add to Puja button
                                      // Semantics(
                                      //   label: isInPuja
                                      //       ? 'Remove from My Puja'
                                      //       : 'Add to My Puja',
                                      //   button: true,
                                      //   child: GestureDetector(
                                      //     onTap: () {
                                      //       AppHaptics.selection();
                                      //       if (isInPuja) {
                                      //         ref
                                      //             .read(pujaOrderProvider
                                      //                 .notifier)
                                      //             .removeAarti(
                                      //                 widget.aarti.id);
                                      //       } else {
                                      //         ref
                                      //             .read(pujaOrderProvider
                                      //                 .notifier)
                                      //             .addAarti(widget.aarti.id);
                                      //       }
                                      //     },
                                      //     child: Container(
                                      //       width: 44,
                                      //       height: 44,
                                      //       decoration: BoxDecoration(
                                      //         color: isInPuja
                                      //             ? AppColors.saffronGlow
                                      //             : AppColors.white,
                                      //         borderRadius:
                                      //             BorderRadius.circular(12),
                                      //         border: Border.all(
                                      //           color: isInPuja
                                      //               ? AppColors.saffron
                                      //               : AppColors.stone3,
                                      //         ),
                                      //       ),
                                      //       child: Icon(
                                      //         isInPuja
                                      //             ? Icons.auto_awesome
                                      //             : Icons
                                      //                 .auto_awesome_outlined,
                                      //         size: 18,
                                      //         color: isInPuja
                                      //             ? AppColors.saffron
                                      //             : AppColors.ink3,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // const SizedBox(width: 8),
                                      // Bookmark button
                                      Semantics(
                                        label: isBookmarked
                                            ? l10n.aartiDetailRemoveBookmark
                                            : l10n.aartiDetailAddBookmark,
                                        button: true,
                                        child: GestureDetector(
                                          onTap: () {
                                            AppHaptics.selection();
                                            AnalyticsService.trackEvent(
                                              'bookmark_toggled',
                                              data: <String, Object>{
                                                'source': 'detail_screen',
                                                'aarti_id': widget.aarti.id,
                                                'deity_name':
                                                    widget.aarti.deity,
                                                'is_bookmarked': !isBookmarked,
                                              },
                                            );
                                            // if (!isBookmarked) {
                                            //   AnalyticsService.trackEvent(
                                            //     'detail_aarti_bookmarked',
                                            //     data: <String, Object>{
                                            //       'aarti_id': widget.aarti.id,
                                            //       'deity_name': widget.aarti.deity,
                                            //     },
                                            //     path: '/aarti/${widget.aarti.id}',
                                            //   );
                                            // }
                                            ref
                                                .read(bookmarkProvider.notifier)
                                                .toggle(widget.aarti.id);
                                          },
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isBookmarked
                                                  ? accentSurfaceColor
                                                  : context.surface,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isBookmarked
                                                    ? accentFillColor
                                                    : context.borderSubtle,
                                              ),
                                            ),
                                            child: Icon(
                                              isBookmarked
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_outline,
                                              size: 18,
                                              color: isBookmarked
                                                  ? accentFillColor
                                                  : context.textCaption,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              Text(
                                '${widget.aarti.deity.toUpperCase()} · ${DayDeityMapper.todaySpecialLabelLocalized(l10n).toUpperCase()}',
                                style: AppTypography.label(
                                  size: 10,
                                  color: accentTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.aarti.title,
                                style: AppTypography.displayLarge(context)
                                    .copyWith(
                                      fontSize: 38 * textScale,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              if (showScriptTitle) ...[
                                const SizedBox(height: 6),
                                Text(
                                  scriptTitle,
                                  style: _scriptTitleStyle(
                                    context: context,
                                    scriptMode: scriptMode,
                                    textScale: textScale,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Verse progress indicator
                              if (verseCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentSurfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.aartiDetailVerseProgress(
                                      _currentVerse + 1,
                                      verseCount,
                                    ),
                                    style: AppTypography.body(
                                      size: 12,
                                      color: accentTextColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Action buttons
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    app.ActionChip(
                                      icon: Icons.fullscreen_outlined,
                                      label: l10n.aartiDetailFocusMode,
                                      isPrimary: true,
                                      onTap: () => _openFocusMode(
                                        scriptMode: scriptMode,
                                        textScale: textScale,
                                        selectedMode: selectedMode,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.track_changes_outlined,
                                      label: l10n.aartiDetailMantraCounter,
                                      onTap: () {
                                        AnalyticsService.trackEvent(
                                          'detail_mantra_counter_opened',
                                          data: <String, Object>{
                                            'aarti_id': widget.aarti.id,
                                            'target_count': 108,
                                          },
                                        );
                                        setState(() => _showCounter = true);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.share_outlined,
                                      label: l10n.aartiDetailShare,
                                      onTap: () => _showShareOptions(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      if (toggleLabels.length > 1)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: ToggleBar(
                              labels: toggleLabels,
                              activeIndex: availableModes.indexOf(selectedMode),
                              onSelect: (i) {
                                AnalyticsService.trackEvent(
                                  'detail_view_mode_toggled',
                                  data: <String, Object>{
                                    'mode': availableModes[i].name,
                                  },
                                );
                                setState(
                                  () => _contentMode = availableModes[i],
                                );
                              },
                            ),
                          ),
                        ),

                      // Verses
                      verses.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(48),
                                child: Center(
                                  child: Text(
                                      l10n.aartiDetailVerseDataComingSoon,
                                    style: AppTypography.body(
                                      size: 14,
                                      color: context.textCaption,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                hasAudioUrl ? 160 : 24,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) => VerseBlock(
                                    verse: verses[i],
                                    isFirst: i == 0,
                                    contentMode: selectedMode,
                                    scriptMode: scriptMode,
                                    appLanguageCode: appLanguageCode,
                                    textScale: textScale,
                                  ),
                                  childCount: verses.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky audio player
          if (hasAudioUrl)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AudioPlayerWidget(
                aarti: widget.aarti,
                isPlaying: _isPlaying,
                position: _position,
                duration: _duration,
                onPlayPause: _togglePlay,
                onSkipPrevious: _seekBackward,
                onSkipNext: _seekForward,
                onRepeatToggle: _toggleRepeat,
                isRepeatOn: _repeatOn,
                onScrub: (v) {
                  final newPos = Duration(
                    milliseconds: (v * _duration.inMilliseconds).round(),
                  );
                  _audioPlayer.seek(newPos);
                },
                verseLabel: verseCount > 0
                    ? l10n.aartiDetailVerseProgress(
                        _currentVerse + 1,
                        verseCount,
                      )
                    : null,
              ),
            ),

          // "Next" FAB — triggered at 90% audio OR scroll-to-bottom
          if (_showNextFab && canShowNextFab)
            Positioned(
              bottom: hasAudioUrl ? 140 : 24,
              right: 24,
              child: _NextFab(
                onTap: () {
                  AnalyticsService.trackEvent(
                    'detail_next_fab_tapped',
                    data: <String, Object>{'aarti_id': widget.aarti.id},
                    path: '/aarti/${widget.aarti.id}',
                  );
                  _openAarti(nextPujaAarti);
                },
              ),
            ),

          // Focus mode overlay
          if (_focusMode)
            FocusModeOverlay(
              aarti: widget.aarti,
              verses: verses,
              scriptMode: _focusScriptMode,
              textScale: _focusTextScale,
              appLanguageCode: appLanguageCode,
              contentMode: _focusContentMode,
              headerLabel: l10n.aartiDetailFocusModeHeader,
              useSessionHeaderLayout: true,
              onOpenSettings: () => _showFocusModeSettings(
                context: context,
                appLanguageCode: appLanguageCode,
                canShowSecondaryScript: showSecondaryScript,
                hasNextAarti: nextPujaAarti != null,
              ),
              onNextAarti: nextPujaAarti == null
                  ? null
                  : () => _openAarti(nextPujaAarti),
              nextAartiTitle: nextPujaAarti?.title,
              onClose: () => setState(() => _focusMode = false),
            ),

          // Mantra counter overlay
          if (_showCounter)
            MantraCounterOverlay(
              onClose: () => setState(() => _showCounter = false),
              onCompleted: (count) {
                AnalyticsService.trackEvent(
                  'detail_mantra_counter_completed',
                  data: <String, Object>{
                    'aarti_id': widget.aarti.id,
                    'count': count,
                  },
                  path: '/aarti/${widget.aarti.id}',
                );
              },
            ),
        ],
      ),
    );
  }

  String _contentModeLabel(
    AartiDetailContentMode mode, {
    required int scriptMode,
    required String appLanguageCode,
  }) {
    final l10n = context.l10n;
    switch (mode) {
      case AartiDetailContentMode.lyrics:
        return l10n.aartiDetailContentLyrics;
      case AartiDetailContentMode.transliteration:
        return AartiLanguageResolver.localizedSecondaryScriptLabel(
          context,
          scriptMode: scriptMode,
          appLanguageCode: appLanguageCode,
        );
      case AartiDetailContentMode.meaning:
        return l10n.aartiDetailContentMeaning;
    }
  }

  void _showFocusModeSettings({
    required BuildContext context,
    required String appLanguageCode,
    required bool canShowSecondaryScript,
    required bool hasNextAarti,
  }) {
    final l10n = context.l10n;
    showFocusModeSettingsSheet(
      context: context,
      appLanguageCode: appLanguageCode,
      scriptMode: _focusScriptMode,
      textScale: _focusTextScale,
      canShowSecondaryScript: canShowSecondaryScript,
      activeScriptSurface:
          _focusContentMode == AartiDetailContentMode.transliteration
          ? FocusModeScriptSurface.secondary
          : FocusModeScriptSurface.primary,
      onScriptSurfaceChanged: (surface) {
        setState(() {
          _focusContentMode =
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
      description: l10n.aartiDetailFocusSettingsDescription,
      footerNote: hasNextAarti
          ? l10n.aartiDetailFocusSettingsFooterWithNext
          : l10n.aartiDetailFocusSettingsFooterReset,
    );
  }

  TextStyle _scriptTitleStyle({
    required BuildContext context,
    required int scriptMode,
    required double textScale,
  }) {
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    if (script == AppScriptLanguage.english) {
      return AppTypography.transliteration(
        size: 16 * textScale,
        color: context.textSecondary,
      );
    }

    return AppTypography.devanagari(
      size: 17 * textScale,
      color: context.textSecondary,
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.aartiDetailShareTitle,
              style: AppTypography.serifBody(
                size: 18,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.aarti.title,
              style: AppTypography.body(size: 13, color: context.textCaption),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ShareOption(
                    icon: Icons.text_snippet_outlined,
                    label: context.l10n.aartiDetailShareAsText,
                    onTap: () {
                      AnalyticsService.trackEvent(
                        'detail_share_tapped',
                        data: <String, Object>{
                          'aarti_id': widget.aarti.id,
                          'share_type': 'text',
                        },
                        path: '/aarti/${widget.aarti.id}',
                      );
                      Navigator.pop(ctx);
                      SharingService.instance.shareAsText(widget.aarti);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareOption(
                    icon: Icons.image_outlined,
                    label: context.l10n.aartiDetailShareAsImage,
                    onTap: () {
                      AnalyticsService.trackEvent(
                        'detail_share_tapped',
                        data: <String, Object>{
                          'aarti_id': widget.aarti.id,
                          'share_type': 'image',
                        },
                        path: '/aarti/${widget.aarti.id}',
                      );
                      Navigator.pop(ctx);
                      SharingService.instance.shareAsImage(_lyricsRepaintKey);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// "Next" Floating Action Button — appears at 90% audio progress
/// or when user scrolls to the bottom.
class _NextFab extends StatelessWidget {
  final VoidCallback onTap;
  const _NextFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (_, value, child) => Transform.scale(scale: value, child: child),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: isDark ? AppColors.saffronLight : AppColors.saffron,
        foregroundColor: isDark ? AppColors.darkBg : AppColors.white,
        icon: const Icon(Icons.skip_next_rounded, size: 20),
        label: Text(context.l10n.commonNext),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: context.border,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isDark ? AppColors.saffronLight : AppColors.saffron,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.body(size: 13, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

Color _accentFillColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.saffronLight : AppColors.saffron;
}

Color _accentSurfaceColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? AppColors.saffron.withValues(alpha: 0.18)
      : AppColors.saffronGlow;
}

Color _accentTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.saffronLight : AppColors.saffronDark;
}
