import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/aarti_item.dart';
import '../../data/sample_data.dart';
import 'widgets/action_chip.dart' as app;
import 'widgets/toggle_bar.dart';
import 'widgets/verse_block.dart';
import 'widgets/audio_player_widget.dart';
import 'widgets/focus_mode_overlay.dart';
import 'widgets/mantra_counter_overlay.dart';

class AartiDetailScreen extends StatefulWidget {
  final AartiItem aarti;
  const AartiDetailScreen({super.key, required this.aarti});

  @override
  State<AartiDetailScreen> createState() => _AartiDetailScreenState();
}

class _AartiDetailScreenState extends State<AartiDetailScreen>
    with TickerProviderStateMixin {
  int _viewMode = 0; // 0=lyrics, 1=roman, 2=meaning
  bool _isPlaying = false;
  bool _focusMode = false;
  bool _showCounter = false;
  double _progress = 0.35;
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _progressCtrl.addListener(() {
      if (mounted) {
        setState(() => _progress = _progressCtrl.value * 0.65 + 0.35);
      }
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _progressCtrl.forward();
    } else {
      _progressCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_back_ios_new,
                                        size: 14, color: AppColors.ink3),
                                    const SizedBox(width: 4),
                                    Text('Back',
                                        style: AppTextStyles.body(
                                            size: 12, color: AppColors.ink3)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                '${widget.aarti.deity.toUpperCase()} · SOMVAR',
                                style: AppTextStyles.label(
                                    size: 10, color: AppColors.saffron),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.aarti.title,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.ink,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(widget.aarti.devanagari,
                                  style:
                                      AppTextStyles.devanagari(size: 17)),
                              const SizedBox(height: 20),

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
                                      onTap: () => setState(
                                          () => _focusMode = true),
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon:
                                          Icons.track_changes_outlined,
                                      label: 'Mantra Counter',
                                      onTap: () => setState(
                                          () => _showCounter = true),
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    app.ActionChip(
                                      icon: Icons.download_outlined,
                                      label: 'Offline',
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
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: ToggleBar(
                            labels: const [
                              'Lyrics',
                              'Transliteration',
                              'Meaning'
                            ],
                            activeIndex: _viewMode,
                            onSelect: (i) =>
                                setState(() => _viewMode = i),
                          ),
                        ),
                      ),

                      // Verses
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 160),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => VerseBlock(
                              verse: kVerses[i],
                              isFirst: i == 0,
                              viewMode: _viewMode,
                            ),
                            childCount: kVerses.length,
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
              progress: _progress,
              onPlayPause: _togglePlay,
              onScrub: (v) => setState(() => _progress = v),
            ),
          ),

          // Focus mode overlay
          if (_focusMode)
            FocusModeOverlay(
              aarti: widget.aarti,
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
