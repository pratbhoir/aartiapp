import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_aware_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/painters/mala_painter.dart';

class MantraCounterOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const MantraCounterOverlay({super.key, required this.onClose});

  @override
  State<MantraCounterOverlay> createState() => _MantraCounterOverlayState();
}

class _MantraCounterOverlayState extends State<MantraCounterOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _total = 108;
  static const int _beads = 27;
  static const List<int> _presets = [11, 21, 27, 108, 1008];
  bool _completed = false;
  late AnimationController _tapCtrl;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _tapScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _tap() {
    if (_count < _total) {
      _tapCtrl.forward().then((_) => _tapCtrl.reverse());
      AppHaptics.mantraTap();
      setState(() {
        _count++;
        if (_count >= _total && !_completed) {
          _completed = true;
          AppHaptics.completion();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentTextColor =
        isDark ? AppColors.saffronLight : AppColors.saffronDark;
    final accentSurfaceColor = isDark
        ? AppColors.saffron.withValues(alpha: 0.18)
        : AppColors.saffronGlow;
    final buttonBackground = isDark
        ? (_completed ? AppColors.saffron : AppColors.saffronLight)
        : (_completed ? AppColors.saffron : AppColors.ink);
    final buttonForeground = isDark ? AppColors.darkBg : AppColors.white;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: math.min(380, MediaQuery.of(context).size.width - 48),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        'Mantra Counter',
                        style: AppTypography.serifBody(
                          size: 20,
                          color: context.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.border,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: context.textCaption,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to count · $_total chants',
                      style:
                          AppTypography.body(size: 12, color: context.textCaption)),

                  // Configurable count presets
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: _presets.map((preset) {
                      final isActive = _total == preset;
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          setState(() {
                            _total = preset;
                            _count = 0;
                            _completed = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isActive
                                ? accentSurfaceColor
                                : context.border,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive
                                  ? accentTextColor
                                  : context.borderSubtle,
                            ),
                          ),
                          child: Text(
                            '$preset',
                            style: AppTypography.body(
                              size: 11,
                              color: isActive
                                  ? accentTextColor
                                  : context.textCaption,
                              weight: isActive
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Mala
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(180, 180),
                          painter: MalaPainter(
                              count: _count, total: _total, beads: _beads),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_count',
                              style: AppTypography.displayLarge(context)
                                  .copyWith(
                                fontSize: 44,
                                height: 1,
                              ),
                            ),
                            Text('/ $_total',
                                style: AppTypography.body(
                                    size: 14, color: context.textCaption)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Completion message
                  if (_completed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentSurfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🪷 Mala Complete · Jai Ho!',
                          style: AppTypography.body(
                            size: 13,
                            color: accentTextColor,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Tap button
                  ScaleTransition(
                    scale: _tapScale,
                    child: GestureDetector(
                      onTap: _tap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: buttonBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _completed ? '॥ Complete! ॥' : '॥ Tap to Chant ॥',
                          textAlign: TextAlign.center,
                          style: AppTypography.serifBody(
                            size: 20,
                            color: buttonForeground,
                          ).copyWith(letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      _count = 0;
                      _completed = false;
                    }),
                    child: Text('Reset counter',
                        style: AppTypography.body(
                            size: 12, color: context.textCaption)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
