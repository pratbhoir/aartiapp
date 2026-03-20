import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/haptics.dart';
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

  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
    _scrollController.addListener(_updateVerseProgress);
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
      if (mounted) setState(() => _position = pos);
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null && mounted) setState(() => _duration = dur);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
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

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
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
                                      onTap: () {},
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
                              'Meaning'
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
}
