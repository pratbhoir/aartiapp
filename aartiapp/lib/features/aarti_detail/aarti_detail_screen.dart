import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/haptics.dart';
import '../../core/services/sharing_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../core/utils/day_deity_mapper.dart';
import '../../data/models/aarti_item.dart';
import '../../providers/app_providers.dart';
import 'widgets/action_chip.dart' as app;
import 'widgets/toggle_bar.dart';
import 'widgets/verse_block.dart';
import 'widgets/audio_player_widget.dart';
import 'widgets/focus_mode_overlay.dart';
import 'widgets/mantra_counter_overlay.dart';

class AartiDetailScreen extends ConsumerStatefulWidget {
  final AartiItem aarti;
  const AartiDetailScreen({super.key, required this.aarti});

  @override
  ConsumerState<AartiDetailScreen> createState() => _AartiDetailScreenState();
}

class _AartiDetailScreenState extends ConsumerState<AartiDetailScreen>
    with TickerProviderStateMixin {
  int _viewMode = 0; // 0=lyrics, 1=roman, 2=meaning
  bool _focusMode = false;
  bool _showCounter = false;
  final ScrollController _scrollController = ScrollController();
  int _currentVerse = 0;
  bool _showNextFab = false;
  bool _repeatOn = false;

  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // For share-as-image
  final GlobalKey _lyricsRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initAudio() async {
    try {
      final dur = await _audioPlayer.setUrl(widget.aarti.audioUrl);
      if (dur != null && mounted) {
        setState(() => _duration = dur);
      }
    } catch (_) {
      // URL may be unreachable — fail silently
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
          } else {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
            setState(() => _showNextFab = true);
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
    final scrollFraction =
        (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    final newVerse = (scrollFraction * verses.length).floor().clamp(0, verses.length - 1);
    if (newVerse != _currentVerse) {
      setState(() => _currentVerse = newVerse);
    }
  }

  /// Check if user has scrolled to bottom → trigger Next FAB
  void _checkScrollToBottom() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final fraction =
        (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    if (fraction >= 0.95 && !_showNextFab) {
      setState(() => _showNextFab = true);
    }
  }

  /// Check if audio progress ≥ 90% → trigger Next FAB
  void _checkNextFabTrigger() {
    if (_duration.inMilliseconds <= 0) return;
    final progress =
        _position.inMilliseconds / _duration.inMilliseconds;
    if (progress >= 0.9 && !_showNextFab) {
      setState(() => _showNextFab = true);
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _toggleRepeat() {
    setState(() => _repeatOn = !_repeatOn);
    _audioPlayer.setLoopMode(_repeatOn ? LoopMode.one : LoopMode.off);
  }

  void _seekBackward() {
    final newPos = _position - const Duration(seconds: 10);
    _audioPlayer
        .seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void _seekForward() {
    final newPos = _position + const Duration(seconds: 10);
    _audioPlayer.seek(
        newPos > _duration ? _duration : newPos);
  }

  @override
  Widget build(BuildContext context) {
    final textScale = ref.watch(textScaleProvider);
    final bookmarks = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarks.contains(widget.aarti.id);
    final isInPuja = ref.watch(pujaOrderProvider.notifier).isInPuja(widget.aarti.id);
    final verses = widget.aarti.verses;
    final verseCount = verses.isNotEmpty ? verses.length : 0;

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
                                      label: 'Go back',
                                      button: true,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.arrow_back_ios_new,
                                                size: 14,
                                                color: AppColors.ink3),
                                            const SizedBox(width: 4),
                                            Text('Back',
                                                style: AppTextStyles.body(
                                                    size: 12,
                                                    color: AppColors.ink3)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Add to Puja button
                                      Semantics(
                                        label: isInPuja
                                            ? 'Remove from My Puja'
                                            : 'Add to My Puja',
                                        button: true,
                                        child: GestureDetector(
                                          onTap: () {
                                            AppHaptics.selection();
                                            if (isInPuja) {
                                              ref
                                                  .read(pujaOrderProvider
                                                      .notifier)
                                                  .removeAarti(
                                                      widget.aarti.id);
                                            } else {
                                              ref
                                                  .read(pujaOrderProvider
                                                      .notifier)
                                                  .addAarti(widget.aarti.id);
                                            }
                                          },
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isInPuja
                                                  ? AppColors.saffronGlow
                                                  : AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isInPuja
                                                    ? AppColors.saffron
                                                    : AppColors.stone3,
                                              ),
                                            ),
                                            child: Icon(
                                              isInPuja
                                                  ? Icons.auto_awesome
                                                  : Icons
                                                      .auto_awesome_outlined,
                                              size: 18,
                                              color: isInPuja
                                                  ? AppColors.saffron
                                                  : AppColors.ink3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Bookmark button
                                      Semantics(
                                        label: isBookmarked
                                            ? 'Remove bookmark'
                                            : 'Add bookmark',
                                        button: true,
                                        child: GestureDetector(
                                          onTap: () {
                                            AppHaptics.selection();
                                            ref
                                                .read(bookmarkProvider
                                                    .notifier)
                                                .toggle(widget.aarti.id);
                                          },
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isBookmarked
                                                  ? AppColors.saffronGlow
                                                  : AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isBookmarked
                                                    ? AppColors.saffron
                                                    : AppColors.stone3,
                                              ),
                                            ),
                                            child: Icon(
                                              isBookmarked
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_outline,
                                              size: 18,
                                              color: isBookmarked
                                                  ? AppColors.saffron
                                                  : AppColors.ink3,
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
                                '${widget.aarti.deity.toUpperCase()} · ${DayDeityMapper.todayHindiName().toUpperCase()}',
                                style: AppTextStyles.label(
                                    size: 10, color: AppColors.saffronDark),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.aarti.title,
                                style: AppTextStyles.displayLarge(context)
                                    .copyWith(
                                  fontSize: 38 * textScale,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(widget.aarti.devanagari,
                                  style: AppTextStyles.devanagari(
                                      size: 17 * textScale)),
                              const SizedBox(height: 16),

                              // Verse progress indicator
                              if (verseCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.saffronGlow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Verse ${_currentVerse + 1} of $verseCount',
                                    style: AppTextStyles.body(
                                        size: 12, color: AppColors.saffronDark),
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
                                      label: 'Focus Mode',
                                      isPrimary: true,
                                      onTap: () =>
                                          setState(() => _focusMode = true),
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.track_changes_outlined,
                                      label: 'Mantra Counter',
                                      onTap: () =>
                                          setState(() => _showCounter = true),
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
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

                      // Toggle bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: ToggleBar(
                            labels: const [
                              'Lyrics',
                              'Transliteration',
                              'Meaning',
                              'ગુજરાતી',
                            ],
                            activeIndex: _viewMode,
                            onSelect: (i) => setState(() => _viewMode = i),
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
                                    'Verse data coming soon for this Aarti.',
                                    style: AppTextStyles.body(
                                        size: 14, color: AppColors.ink3),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 160),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) => VerseBlock(
                                    verse: verses[i],
                                    isFirst: i == 0,
                                    viewMode: _viewMode,
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
                    milliseconds:
                        (v * _duration.inMilliseconds).round());
                _audioPlayer.seek(newPos);
              },
              verseLabel: verseCount > 0
                  ? 'Verse ${_currentVerse + 1} of $verseCount'
                  : null,
            ),
          ),

          // "Next" FAB — triggered at 90% audio OR scroll-to-bottom
          if (_showNextFab)
            Positioned(
              bottom: 140,
              right: 24,
              child: _NextFab(
                onTap: () {
                  setState(() => _showNextFab = false);
                  Navigator.pop(context);
                },
              ),
            ),

          // Focus mode overlay
          if (_focusMode)
            FocusModeOverlay(
              aarti: widget.aarti,
              verses: verses,
              onClose: () => setState(() => _focusMode = false),
            ),

          // Mantra counter overlay
          if (_showCounter)
            MantraCounterOverlay(
              onClose: () => setState(() => _showCounter = false),
            ),
        ],
      ),
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stone3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share Aarti',
                style: AppTextStyles.serifBody(
                    size: 18, color: context.textPrimary)),
            const SizedBox(height: 4),
            Text(widget.aarti.title,
                style: AppTextStyles.body(
                    size: 13, color: AppColors.ink3)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ShareOption(
                    icon: Icons.text_snippet_outlined,
                    label: 'As Text',
                    onTap: () {
                      Navigator.pop(ctx);
                      SharingService.instance
                          .shareAsText(widget.aarti);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareOption(
                    icon: Icons.image_outlined,
                    label: 'As Image',
                    onTap: () {
                      Navigator.pop(ctx);
                      SharingService.instance
                          .shareAsImage(_lyricsRepaintKey);
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (_, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: AppColors.saffron,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.skip_next_rounded, size: 20),
        label: const Text('Next'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.stone2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stone3),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.saffron),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.body(
                    size: 13, color: AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}
