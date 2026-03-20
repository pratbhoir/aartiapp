import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/aarti_item.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AartiItem aarti;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onScrub;
  final String? verseLabel;
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onSkipNext;
  final VoidCallback? onRepeatToggle;
  final bool isRepeatOn;

  const AudioPlayerWidget({
    super.key,
    required this.aarti,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onScrub,
    this.verseLabel,
    this.onSkipPrevious,
    this.onSkipNext,
    this.onRepeatToggle,
    this.isRepeatOn = false,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          decoration: BoxDecoration(
            // Glassmorphic: translucent background with blurred backdrop
            color: AppColors.stone.withValues(alpha: 0.78),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: AppColors.saffron.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.stone3.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Progress bar
              Row(
                children: [
                  Text(_formatDuration(position),
                      style:
                          AppTextStyles.body(size: 11, color: AppColors.ink3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.saffron,
                        inactiveTrackColor:
                            AppColors.stone3.withValues(alpha: 0.5),
                        thumbColor: AppColors.saffron,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5),
                        trackHeight: 2.5,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: duration.inMilliseconds > 0
                            ? (position.inMilliseconds /
                                    duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: onScrub,
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_formatDuration(duration),
                      style:
                          AppTextStyles.body(size: 11, color: AppColors.ink3)),
                ],
              ),
              const SizedBox(height: 8),

              // Controls
              Row(
                children: [
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aarti.title,
                          style: AppTextStyles.serifBody(
                            size: 16,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (verseLabel != null)
                          Text(verseLabel!,
                              style: AppTextStyles.body(
                                  size: 11, color: AppColors.ink3)),
                      ],
                    ),
                  ),

                  // Buttons
                  _CtrlBtn(
                    icon: Icons.skip_previous_rounded,
                    onTap: onSkipPrevious ?? () {},
                  ),
                  const SizedBox(width: 4),
                  PlayPauseBtn(
                      isPlaying: isPlaying, onTap: onPlayPause),
                  const SizedBox(width: 4),
                  _CtrlBtn(
                    icon: Icons.skip_next_rounded,
                    onTap: onSkipNext ?? () {},
                  ),
                  const SizedBox(width: 8),
                  _CtrlBtn(
                    icon: Icons.repeat_rounded,
                    onTap: onRepeatToggle ?? () {},
                    isActive: isRepeatOn,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _CtrlBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: isActive ? AppColors.saffron : AppColors.ink2,
      ),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }
}

class PlayPauseBtn extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PlayPauseBtn({super.key, required this.isPlaying, required this.onTap});

  @override
  State<PlayPauseBtn> createState() => _PlayPauseBtnState();
}

class _PlayPauseBtnState extends State<PlayPauseBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void didUpdateWidget(PlayPauseBtn old) {
    super.didUpdateWidget(old);
    widget.isPlaying ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _ctrl,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}
