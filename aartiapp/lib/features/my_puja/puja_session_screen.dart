import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/aarti_item.dart';
import '../../providers/app_providers.dart';
import '../aarti_detail/widgets/audio_player_widget.dart';

/// Puja session mode: plays through the "My Daily Puja" list sequentially
/// with optional auto-play, repeat-current, and crossfade transitions.
class PujaSessionScreen extends ConsumerStatefulWidget {
  final List<AartiItem> pujaAartis;
  final int startIndex;

  const PujaSessionScreen({
    super.key,
    required this.pujaAartis,
    this.startIndex = 0,
  });

  @override
  ConsumerState<PujaSessionScreen> createState() => _PujaSessionScreenState();
}

class _PujaSessionScreenState extends ConsumerState<PujaSessionScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _autoPlay = true;
  bool _repeatCurrent = false;
  int _crossfadeSec = 1;

  // Animation for verse display
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  AartiItem get _currentAarti => widget.pujaAartis[_currentIndex];
  bool get _hasNext => _currentIndex < widget.pujaAartis.length - 1;
  bool get _hasPrev => _currentIndex > 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex.clamp(0, widget.pujaAartis.length - 1);
    _audioPlayer = AudioPlayer();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();

    _loadAndPlay(_currentIndex);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAndPlay(int index) async {
    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    // Animate transition
    _fadeCtrl.reset();
    _fadeCtrl.forward();

    try {
      final dur = await _audioPlayer.setUrl(_currentAarti.audioUrl);
      if (dur != null && mounted) {
        setState(() => _duration = dur);
      }
    } catch (_) {
      // Fail silently
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
          _onTrackComplete();
        }
      }
    });

    if (_autoPlay) {
      // Apply crossfade delay before playing
      if (_crossfadeSec > 0 && index > widget.startIndex) {
        await Future.delayed(Duration(seconds: _crossfadeSec));
      }
      if (mounted) _audioPlayer.play();
    }
  }

  void _onTrackComplete() {
    if (_repeatCurrent) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_autoPlay && _hasNext) {
      _goNext();
    } else {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.pause();
    }
  }

  void _goNext() {
    if (_hasNext) {
      AppHaptics.pageTransition();
      _audioPlayer.stop();
      _loadAndPlay(_currentIndex + 1);
    }
  }

  void _goPrev() {
    if (_hasPrev) {
      AppHaptics.pageTransition();
      _audioPlayer.stop();
      _loadAndPlay(_currentIndex - 1);
    } else {
      _audioPlayer.seek(Duration.zero);
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
    final autoPlay = ref.watch(autoPlayProvider);
    final repeatCurrent = ref.watch(repeatCurrentProvider);
    final crossfade = ref.watch(crossfadeProvider);
    _autoPlay = autoPlay;
    _repeatCurrent = repeatCurrent;
    _crossfadeSec = crossfade;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.ink3),
                    ),
                  ),
                  Column(
                    children: [
                      Text('PUJA SESSION',
                          style: AppTextStyles.label(
                              size: 10, color: AppColors.saffronLight)),
                      Text(
                        '${_currentIndex + 1} of ${widget.pujaAartis.length}',
                        style: AppTextStyles.body(
                            size: 12,
                            color:
                                AppColors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                  // Settings / toggles
                  GestureDetector(
                    onTap: () => _showSessionSettings(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_outlined,
                          size: 18, color: AppColors.ink3),
                    ),
                  ),
                ],
              ),
            ),

            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.pujaAartis.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentIndex ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? AppColors.saffron
                          : i < _currentIndex
                              ? AppColors.saffron.withValues(alpha: 0.4)
                              : AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),

            // Main content — current aarti
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Deity / day label
                      Text(
                        _currentAarti.deity.toUpperCase(),
                        style: AppTextStyles.label(
                            size: 11, color: AppColors.saffronLight),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        _currentAarti.title,
                        style: AppTextStyles.serifBody(
                          size: 30,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentAarti.devanagari,
                        style: AppTextStyles.devanagari(
                          size: 18,
                          color: AppColors.white.withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Verse preview (first verse if available)
                      if (_currentAarti.verses.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.darkBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _currentAarti.verses.first.label,
                                style: AppTextStyles.label(
                                    size: 9, color: AppColors.ink3),
                              ),
                              const SizedBox(height: 8),
                              ...(_currentAarti.verses.first.lines
                                  .take(3)
                                  .map((line) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          line,
                                          style: AppTextStyles.devanagari(
                                            size: 16,
                                            color: AppColors.white
                                                .withValues(alpha: 0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ))),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Meta chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SessionChip(
                            icon: Icons.schedule_outlined,
                            label: _currentAarti.duration,
                          ),
                          const SizedBox(width: 12),
                          _SessionChip(
                            icon: Icons.format_list_numbered,
                            label: _currentAarti.versesLabel,
                          ),
                          if (_repeatCurrent) ...[
                            const SizedBox(width: 12),
                            _SessionChip(
                              icon: Icons.repeat_one,
                              label: 'Repeat',
                              isActive: true,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.6),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Progress
                  Row(
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: AppTextStyles.body(
                            size: 11,
                            color:
                                AppColors.white.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.saffron,
                            inactiveTrackColor: AppColors.darkBorder,
                            thumbColor: AppColors.saffron,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5),
                            trackHeight: 2.5,
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            value: _duration.inMilliseconds > 0
                                ? (_position.inMilliseconds /
                                        _duration.inMilliseconds)
                                    .clamp(0.0, 1.0)
                                : 0.0,
                            onChanged: (v) {
                              _audioPlayer.seek(Duration(
                                  milliseconds:
                                      (v * _duration.inMilliseconds)
                                          .round()));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatDuration(_duration),
                        style: AppTextStyles.body(
                            size: 11,
                            color:
                                AppColors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Repeat toggle
                      IconButton(
                        icon: Icon(
                          _repeatCurrent
                              ? Icons.repeat_one
                              : Icons.repeat,
                          size: 22,
                          color: _repeatCurrent
                              ? AppColors.saffron
                              : AppColors.ink3,
                        ),
                        onPressed: () {
                          ref.read(repeatCurrentProvider.notifier).toggle();
                        },
                      ),
                      const SizedBox(width: 12),

                      // Previous
                      IconButton(
                        icon: Icon(Icons.skip_previous_rounded,
                            size: 32,
                            color: _hasPrev
                                ? AppColors.white
                                : AppColors.darkBorder),
                        onPressed: _hasPrev ? _goPrev : null,
                      ),
                      const SizedBox(width: 12),

                      // Play/Pause
                      PlayPauseBtn(
                        isPlaying: _isPlaying,
                        onTap: _togglePlay,
                      ),
                      const SizedBox(width: 12),

                      // Next
                      IconButton(
                        icon: Icon(Icons.skip_next_rounded,
                            size: 32,
                            color: _hasNext
                                ? AppColors.white
                                : AppColors.darkBorder),
                        onPressed: _hasNext ? _goNext : null,
                      ),
                      const SizedBox(width: 12),

                      // Auto-play toggle
                      IconButton(
                        icon: Icon(
                          Icons.playlist_play_rounded,
                          size: 22,
                          color: _autoPlay
                              ? AppColors.saffron
                              : AppColors.ink3,
                        ),
                        onPressed: () {
                          ref.read(autoPlayProvider.notifier).toggle();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showSessionSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final crossfade = ref.watch(crossfadeProvider);
          final autoPlay = ref.watch(autoPlayProvider);
          final repeat = ref.watch(repeatCurrentProvider);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border:
                  Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Session Settings',
                    style: AppTextStyles.serifBody(
                        size: 18, color: AppColors.white)),
                const SizedBox(height: 24),

                _SessionSettingRow(
                  label: 'Auto-play next',
                  subtitle: 'Play next aarti automatically',
                  trailing: Switch.adaptive(
                    value: autoPlay,
                    activeTrackColor: AppColors.saffron,
                    onChanged: (v) {
                      ref.read(autoPlayProvider.notifier).set(v);
                      setSheetState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),

                _SessionSettingRow(
                  label: 'Repeat current',
                  subtitle: 'Loop the current aarti',
                  trailing: Switch.adaptive(
                    value: repeat,
                    activeTrackColor: AppColors.saffron,
                    onChanged: (_) {
                      ref.read(repeatCurrentProvider.notifier).toggle();
                      setSheetState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),

                _SessionSettingRow(
                  label: 'Crossfade',
                  subtitle: '${crossfade}s gap between aartis',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (i) {
                      final isActive = crossfade == i;
                      return GestureDetector(
                        onTap: () {
                          ref.read(crossfadeProvider.notifier).set(i);
                          setSheetState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 32,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.saffronGlow
                                : AppColors.darkBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.saffron
                                  : AppColors.darkBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${i}s',
                              style: AppTextStyles.body(
                                size: 11,
                                color: isActive
                                    ? AppColors.saffron
                                    : AppColors.ink3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }
}

class _SessionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SessionChip({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.saffron.withValues(alpha: 0.15)
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isActive ? AppColors.saffron : AppColors.darkBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: isActive
                  ? AppColors.saffronLight
                  : AppColors.ink3),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.body(
                size: 12,
                color: isActive
                    ? AppColors.saffronLight
                    : AppColors.ink3,
              )),
        ],
      ),
    );
  }
}

class _SessionSettingRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final Widget trailing;

  const _SessionSettingRow({
    required this.label,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.body(
                        size: 14,
                        color: AppColors.white,
                        weight: FontWeight.w400)),
                Text(subtitle,
                    style: AppTextStyles.body(
                        size: 11, color: AppColors.ink3)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
