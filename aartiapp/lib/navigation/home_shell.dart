import 'package:flutter/material.dart';
import '../core/constants/haptics.dart';
import '../core/theme/app_colors.dart';
import '../features/discover/discover_screen.dart';
import '../features/my_puja/my_puja_screen.dart';
import '../features/contribute/contribute_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _drawerAnimCtrl;

  final List<NavItem> _navItems = const [
    NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Discover'),
    NavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: 'My Daily Puja'),
    NavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'My Collection'),
    NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _drawerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerAnimCtrl.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return DiscoverScreen(onOpenDrawer: _openDrawer);
      case 1:
        return MyPujaScreen(onOpenDrawer: _openDrawer);
      case 2:
        return ContributeScreen(onOpenDrawer: _openDrawer);
      case 3:
        return SettingsScreen(onOpenDrawer: _openDrawer);
      default:
        return DiscoverScreen(onOpenDrawer: _openDrawer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.stone,
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        navItems: _navItems,
        onSelect: (i) {
          AppHaptics.pageTransition();
          setState(() => _currentIndex = i);
          Navigator.of(context).pop();
        },
      ),
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
    );
  }
}
