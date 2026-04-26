import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../app_drawer.dart';

/// Temple Dock style bottom navigation for top-level app sections.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int> onSelect;

  static const LinearGradient _activeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.saffron, AppColors.saffron],
  );

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxs,
          AppSpacing.md,
          0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(color: context.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink3.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final item = items[i];
                return Expanded(
                  child: _BottomNavItem(
                    item: item,
                    isActive: i == currentIndex,
                    onTap: () => onSelect(i),
                    activeGradient: _activeGradient,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final LinearGradient activeGradient;

  const _BottomNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeGradient,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = isActive ? item.activeIcon : item.icon;
    final inactiveColor = context.textSecondary;
    final activeColor = AppColors.saffron;

    return Semantics(
      button: true,
      selected: isActive,
      label: '${item.label} tab',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        opacity: isActive ? 1 : 0,
                        child: Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.saffron.withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedScale(
                        scale: isActive ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: Icon(
                          iconData,
                          size: 26,
                          color: isActive ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 10,
                      color: isActive ? activeColor : inactiveColor,
                      weight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: isActive ? 1 : 0,
                    child: Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: activeGradient,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.saffron.withValues(alpha: 0.32),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}