import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GradientDivider extends StatelessWidget {
  const GradientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.saffron.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
