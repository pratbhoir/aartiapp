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

  const AudioPlayerWidget({
    super.key,
    required this.aarti,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onScrub,
    this.verseLabel,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.stone.withValues(alpha: 0.92),
          border: const Border(
            top: BorderSide(color: AppColors.stone3, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress
            Row(
              children: [
                Text(_formatDuration(position),
                    style: AppTextStyles.body(size: 11, color: AppColors.ink3)),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.saffron,
                      inactiveTrackColor: AppColors.stone3,
                      thumbColor: AppColors.saffron,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
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
                    style: AppTextStyles.body(size: 11, color: AppColors.ink3)),
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
                _CtrlBtn(icon: Icons.skip_previous_rounded, onTap: () {}),
                const SizedBox(width: 4),
                PlayPauseBtn(isPlaying: isPlaying, onTap: onPlayPause),
                const SizedBox(width: 4),
                _CtrlBtn(icon: Icons.skip_next_rounded, onTap: () {}),
                const SizedBox(width: 8),
                _CtrlBtn(icon: Icons.repeat_rounded, onTap: () {}),
                _CtrlBtn(icon: Icons.volume_up_outlined, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: AppColors.ink2),
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
        decoration: const BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
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
