import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';

/// Shared segmented control used for compact mode and tab switching.
class ToggleBar extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const ToggleBar({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? context.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.18 : 0.08,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: AppTypography.body(
                      size: 12,
                      color: isActive
                          ? context.textPrimary
                          : context.textCaption,
                      weight: isActive ? FontWeight.w500 : FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
