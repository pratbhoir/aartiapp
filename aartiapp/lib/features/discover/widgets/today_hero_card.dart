import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TodayHeroCard extends StatefulWidget {
  final VoidCallback onTap;
  const TodayHeroCard({super.key, required this.onTap});

  @override
  State<TodayHeroCard> createState() => _TodayHeroCardState();
}

class _TodayHeroCardState extends State<TodayHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Radial glow top-right
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.saffron.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.saffron.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.saffronLight.withValues(
                                  alpha: 0.4 + _pulse.value * 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Somvar Special',
                            style: AppTextStyles.label(
                              size: 10,
                              color: AppColors.saffronLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'SHIVA',
                  style: AppTextStyles.label(
                      size: 11, color: AppColors.saffronLight),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Om Jai Shiv Omkara',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text('ॐ जय शिव ओंकारा',
                    style: AppTextStyles.devanagari(
                      size: 14,
                      color: AppColors.white.withValues(alpha: 0.45),
                    )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _MetaChip(icon: Icons.schedule_outlined, label: '7:32'),
                    const SizedBox(width: 16),
                    _MetaChip(
                        icon: Icons.format_list_numbered_outlined,
                        label: '6 verses'),
                    const Spacer(),
                    const PlayCircleButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.body(
                size: 12, color: AppColors.white.withValues(alpha: 0.5))),
      ],
    );
  }
}

class PlayCircleButton extends StatefulWidget {
  const PlayCircleButton({super.key});

  @override
  State<PlayCircleButton> createState() => _PlayCircleButtonState();
}

class _PlayCircleButtonState extends State<PlayCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.saffron,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}
