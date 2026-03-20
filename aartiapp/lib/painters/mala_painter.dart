import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MalaPainter extends CustomPainter {
  final int count;
  final int total;
  final int beads;

  const MalaPainter({
    required this.count,
    required this.total,
    required this.beads,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 12;

    // Ring
    final ringPaint = Paint()
      ..color = AppColors.stone2
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), r, ringPaint);

    final done = (count / total * beads).floor();

    for (int i = 0; i < beads; i++) {
      final angle = (i / beads) * math.pi * 2 - math.pi / 2;
      final bx = cx + r * math.cos(angle);
      final by = cy + r * math.sin(angle);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = i < done
            ? AppColors.saffron
            : (i == done ? AppColors.saffronLight : AppColors.stone3);

      canvas.drawCircle(Offset(bx, by), 6, paint);
    }
  }

  @override
  bool shouldRepaint(MalaPainter old) => old.count != count;
}
