import 'package:flutter/material.dart';
import '../core/constants/haptics.dart';
import '../core/theme/theme_aware_colors.dart';
import '../features/home/home_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/my_puja/my_puja_screen.dart';
import '../features/contribute/contribute_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_drawer.dart';
import 'widgets/app_bottom_nav.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Discover'),
    NavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: 'My Puja'),
    NavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Collection'),
    NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings'),
  ];

  void _openDrawer() {
    _selectTab(4);
  }

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    AppHaptics.pageTransition();
    setState(() => _currentIndex = index);
  }

  void _openDiscoverTab() {
    _selectTab(1);
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onOpenDrawer: _openDrawer,
          onOpenDiscover: _openDiscoverTab,
        );
      case 1:
        return DiscoverScreen(onOpenDrawer: _openDrawer);
      case 2:
        return MyPujaScreen(onOpenDrawer: _openDrawer);
      case 3:
        return ContributeScreen(onOpenDrawer: _openDrawer);
      case 4:
        return SettingsScreen(onOpenDrawer: _openDrawer);
      default:
        return HomeScreen(
          onOpenDrawer: _openDrawer,
          onOpenDiscover: _openDiscoverTab,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildScreen(),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onSelect: _selectTab,
      ),
    );
  }
}
