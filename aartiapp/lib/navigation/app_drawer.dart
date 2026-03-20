import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/app_providers.dart';
import '../widgets/gradient_divider.dart';

class AppDrawer extends ConsumerWidget {
  final int currentIndex;
  final List<NavItem> navItems;
  final ValueChanged<int> onSelect;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.navItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    return Drawer(
      width: 280,
      backgroundColor: AppColors.ink,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + app name
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on,
                        color: AppColors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aarti Sangrah',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'Prayer Book',
                        style: AppTextStyles.label(
                          size: 10,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Thin divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: GradientDivider(),
            ),
            const SizedBox(height: 20),

            // Nav items
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = i == currentIndex;
              return _DrawerNavTile(
                icon: isActive ? item.activeIcon : item.icon,
                label: item.label,
                isActive: isActive,
                onTap: () => onSelect(i),
              );
            }),

            const Spacer(),

            // Bottom divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: GradientDivider(),
            ),
            const SizedBox(height: 16),

            // User profile row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.saffron, AppColors.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.body(
                          size: 14,
                          color: AppColors.white,
                          weight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Jai Shri Krishna 🙏',
                        style:
                            AppTextStyles.body(size: 11, color: AppColors.ink3),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onSelect(3), // Navigate to Settings
                    child: const Icon(Icons.settings_outlined,
                        size: 18, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.saffron.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: AppColors.saffron.withValues(alpha: 0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.saffronLight : AppColors.ink3,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
                    color: isActive ? AppColors.white : AppColors.ink3,
                    letterSpacing: 0.2,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.saffron,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
