import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AartiAppBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final Widget? trailing;

  const AartiAppBar({super.key, required this.onMenuTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HamburgerButton(onTap: onMenuTap),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class HamburgerButton extends StatefulWidget {
  final VoidCallback onTap;
  const HamburgerButton({super.key, required this.onTap});

  @override
  State<HamburgerButton> createState() => _HamburgerButtonState();
}

class _HamburgerButtonState extends State<HamburgerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
      onTap: () {
        _ctrl.forward().then((_) => _ctrl.reverse());
        widget.onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stone3, width: 1),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HamLine(width: 18, delay: 0, ctrl: _ctrl),
                _HamLine(width: 14, delay: 0.15, ctrl: _ctrl),
                _HamLine(width: 18, delay: 0.3, ctrl: _ctrl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HamLine extends StatelessWidget {
  final double width;
  final double delay;
  final AnimationController ctrl;

  const _HamLine({
    required this.width,
    required this.delay,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = Curves.easeInOut.transform(
          (ctrl.value - delay).clamp(0.0, 1.0) /
              (1.0 - delay).clamp(0.01, 1.0),
        );
        return Container(
          width: width * (1 - v * 0.3),
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.ink2,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }
}
