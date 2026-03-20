import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../painters/mala_painter.dart';

class MantraCounterOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const MantraCounterOverlay({super.key, required this.onClose});

  @override
  State<MantraCounterOverlay> createState() => _MantraCounterOverlayState();
}

class _MantraCounterOverlayState extends State<MantraCounterOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  static const int _total = 108;
  static const int _beads = 27;
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

  void _tap() async {
    if (_count < _total) {
      _tapCtrl.forward().then((_) => _tapCtrl.reverse());
      HapticFeedback.lightImpact();
      setState(() => _count++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: AppColors.ink.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: math.min(380, MediaQuery.of(context).size.width - 48),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      const Text(
                        'Mantra Counter',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.ink,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.stone2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.ink3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to count · 108 chants',
                      style:
                          AppTextStyles.body(size: 12, color: AppColors.ink3)),
                  const SizedBox(height: 28),

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
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 44,
                                fontWeight: FontWeight.w300,
                                color: AppColors.ink,
                                height: 1,
                              ),
                            ),
                            Text('/ $_total',
                                style: AppTextStyles.body(
                                    size: 14, color: AppColors.ink3)),
                          ],
                        ),
                      ],
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
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '॥ Tap to Chant ॥',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _count = 0),
                    child: Text('Reset counter',
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.ink3)),
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
