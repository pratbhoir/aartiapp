import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AartiSangrahApp());
}

// ── Design tokens ──────────────────────────────────────────────────────────
class AppColors {
  static const stone = Color(0xFFF5F1EC);
  static const stone2 = Color(0xFFEDE8E0);
  static const stone3 = Color(0xFFD8D0C4);
  static const saffron = Color(0xFFC4700A);
  static const saffronLight = Color(0xFFE8950F);
  static const saffronGlow = Color(0x1FC4700A);
  static const ink = Color(0xFF221C14);
  static const ink2 = Color(0xFF4A4035);
  static const ink3 = Color(0xFF7A6E60);
  static const white = Color(0xFFFDFAF5);
  static const gold = Color(0xFFB8972A);
}

class AppTextStyles {
  static const cormorant = 'serif'; // fallback — use GoogleFonts in real app
  static TextStyle displayLarge(BuildContext ctx) => TextStyle(
        fontFamily: 'Georgia',
        fontSize: 36,
        fontWeight: FontWeight.w300,
        color: AppColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle scriptTitle(BuildContext ctx) => const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.2,
      );

  static TextStyle devanagari({double size = 17, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: color ?? AppColors.ink3,
        height: 1.9,
      );

  static TextStyle label({double size = 10, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
        color: color ?? AppColors.ink3,
      );

  static TextStyle body({double size = 13, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? AppColors.ink,
      );
}

// ── Data models ────────────────────────────────────────────────────────────
class AartiItem {
  final String title;
  final String devanagari;
  final String deity;
  final String duration;
  final String verses;
  final bool isBookmarked;
  final bool isOffline;

  const AartiItem({
    required this.title,
    required this.devanagari,
    required this.deity,
    required this.duration,
    required this.verses,
    this.isBookmarked = false,
    this.isOffline = false,
  });
}

class VerseData {
  final String label;
  final List<String> lines;
  final List<String> transliteration;
  final List<String> meanings;

  const VerseData({
    required this.label,
    required this.lines,
    required this.transliteration,
    required this.meanings,
  });
}

// ── Sample data ────────────────────────────────────────────────────────────
const List<AartiItem> kAartis = [
  AartiItem(
    title: 'Om Jai Shiv Omkara',
    devanagari: 'ॐ जय शिव ओंकारा',
    deity: 'Shiva',
    duration: '7:32',
    verses: '6 verses',
    isBookmarked: true,
    isOffline: true,
  ),
  AartiItem(
    title: 'Jai Ganesh Deva',
    devanagari: 'जय गणेश देव',
    deity: 'Ganesha',
    duration: '5:14',
    verses: '5 verses',
    isBookmarked: true,
    isOffline: true,
  ),
  AartiItem(
    title: 'Om Jai Lakshmi Mata',
    devanagari: 'ॐ जय लक्ष्मी माता',
    deity: 'Lakshmi',
    duration: '6:02',
    verses: '7 verses',
  ),
  AartiItem(
    title: 'Aarti Kije Hanuman Lala Ki',
    devanagari: 'आरती कीजे हनुमान लला की',
    deity: 'Hanuman',
    duration: '4:45',
    verses: '5 verses',
  ),
  AartiItem(
    title: 'Aarti Kunj Bihari Ki',
    devanagari: 'आरती कुंज बिहारी की',
    deity: 'Krishna',
    duration: '6:30',
    verses: '6 verses',
  ),
  AartiItem(
    title: 'Om Jai Jagdish Hare',
    devanagari: 'ॐ जय जगदीश हरे',
    deity: 'Vishnu',
    duration: '8:15',
    verses: '8 verses',
  ),
];

const List<VerseData> kVerses = [
  VerseData(
    label: 'Dhruva Pad',
    lines: [
      'ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।',
      'ब्रह्मा, विष्णु, सदाशिव, अर्द्धांगी धारा॥',
    ],
    transliteration: [
      'Om Jai Shiv Omkara, Swami Jai Shiv Omkara.',
      'Brahma, Vishnu, Sadashiv, Ardhangee Dhara.',
    ],
    meanings: [
      'Praise be to Lord Shiva, the embodiment of the sacred syllable Om.',
      'Brahma, Vishnu and Sada Shiva — the one who holds his half-body as the divine feminine.',
    ],
  ),
  VerseData(
    label: 'Verse 1',
    lines: [
      'एकानन चतुरानन पञ्चानन राजे।',
      'हंसानन गरुड़ासन वृषवाहन साजे॥',
    ],
    transliteration: [
      'Ekaanan Chaturaanan Panchaanan Raaje.',
      'Hansaanan Garudaasan Vrishavaahan Saaje.',
    ],
    meanings: [
      'The one-faced, four-faced, and five-faced lord reigns supreme.',
      'Riding upon the swan, the eagle and the bull — each form adorned magnificently.',
    ],
  ),
  VerseData(
    label: 'Verse 2',
    lines: [
      'दो भुज चार चतुर्भुज दस भुज अति सोहे।',
      'तीनों रूप निरखते त्रिभुवन जन मोहे॥',
    ],
    transliteration: [
      'Do Bhuj Char Chaturbhuj Das Bhuj Ati Sohe.',
      'Teeno Roop Nirakhte Tribhuvan Jan Mohe.',
    ],
    meanings: [
      'Two-armed, four-armed, ten-armed — each form resplendent in its glory.',
      'Beholding these three forms, all beings of the three worlds are enchanted.',
    ],
  ),
];

const List<Map<String, String>> kDeities = [
  {'emoji': '🕉️', 'label': 'All'},
  {'emoji': '🐘', 'label': 'Ganesha'},
  {'emoji': '🌙', 'label': 'Shiva'},
  {'emoji': '🪷', 'label': 'Lakshmi'},
  {'emoji': '🦚', 'label': 'Krishna'},
  {'emoji': '☀️', 'label': 'Rama'},
  {'emoji': '🌺', 'label': 'Durga'},
  {'emoji': '🌟', 'label': 'Hanuman'},
];

// ── App Root ───────────────────────────────────────────────────────────────
class AartiSangrahApp extends StatelessWidget {
  const AartiSangrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarti Sangrah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.stone,
        colorScheme: const ColorScheme.light(
          primary: AppColors.saffron,
          surface: AppColors.white,
        ),
        fontFamily: 'Georgia',
        splashColor: AppColors.saffronGlow,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeShell(),
    );
  }
}

// ── Home Shell with Drawer ─────────────────────────────────────────────────
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

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Discover'),
    _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'My Daily Puja'),
    _NavItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Contribute'),
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
      default:
        return DiscoverScreen(onOpenDrawer: _openDrawer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.stone,
      drawer: _AppDrawer(
        currentIndex: _currentIndex,
        navItems: _navItems,
        onSelect: (i) {
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ── App Drawer ─────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onSelect;

  const _AppDrawer({
    required this.currentIndex,
    required this.navItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: const Icon(Icons.location_on, color: AppColors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _GradientDivider(),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _GradientDivider(),
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
                        color: Colors.white.withOpacity(0.12),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
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
                        'Pratik',
                        style: AppTextStyles.body(
                          size: 14,
                          color: AppColors.white,
                          weight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Jai Shri Krishna 🙏',
                        style: AppTextStyles.body(size: 11, color: AppColors.ink3),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.settings_outlined,
                      size: 18, color: AppColors.ink3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.saffron.withOpacity(0.4),
            Colors.transparent,
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
                  ? AppColors.saffron.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: AppColors.saffron.withOpacity(0.25),
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

// ── Common: Hamburger App Bar ──────────────────────────────────────────────
class _AartiAppBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final Widget? trailing;

  const _AartiAppBar({required this.onMenuTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HamburgerButton(onTap: onMenuTap),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _HamburgerButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HamburgerButton({required this.onTap});

  @override
  State<_HamburgerButton> createState() => _HamburgerButtonState();
}

class _HamburgerButtonState extends State<_HamburgerButton>
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

  const _HamLine(
      {required this.width, required this.delay, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = Curves.easeInOut.transform(
          (ctrl.value - delay).clamp(0.0, 1.0) / (1.0 - delay).clamp(0.01, 1.0),
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

// ── Screen 1: Discover ─────────────────────────────────────────────────────
class DiscoverScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const DiscoverScreen({super.key, required this.onOpenDrawer});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _activeDeity = 0;
  final Set<int> _bookmarked = {0, 1};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: _AartiAppBar(
              onMenuTap: widget.onOpenDrawer,
              trailing: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.saffron, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Center(
                  child: Text('P',
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                ),
              ),
            ),
          ),

          // Greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: AppColors.ink,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(text: 'Jai '),
                        TextSpan(
                          text: 'Shri Krishna,',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.saffron,
                          ),
                        ),
                        TextSpan(text: '\nPratik'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monday · Somvar · Begin with Shiva',
                    style: AppTextStyles.body(size: 13, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _SearchBar(),
            ),
          ),

          // Today hero
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Aarti of the Day'),
                  const SizedBox(height: 12),
                  _TodayHeroCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AartiDetailScreen(aarti: kAartis[0])),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Deity chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _SectionLabel('Browse by Deity'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: kDeities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _DeityChip(
                        emoji: kDeities[i]['emoji']!,
                        label: kDeities[i]['label']!,
                        isActive: _activeDeity == i,
                        onTap: () => setState(() => _activeDeity = i),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: _SectionLabel('Popular Aartis'),
            ),
          ),

          // Aarti grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _AartiCard(
                  aarti: kAartis[i],
                  isBookmarked: _bookmarked.contains(i),
                  delay: Duration(milliseconds: i * 60),
                  onBookmark: () => setState(() {
                    if (_bookmarked.contains(i)) {
                      _bookmarked.remove(i);
                    } else {
                      _bookmarked.add(i);
                    }
                  }),
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                            AartiDetailScreen(aarti: kAartis[i])),
                  ),
                ),
                childCount: kAartis.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 168,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stone3, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_outlined, size: 18, color: AppColors.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: AppTextStyles.body(size: 14),
              decoration: InputDecoration(
                hintText: 'Search deity, Aarti, or festival…',
                hintStyle: AppTextStyles.body(size: 14, color: AppColors.ink3),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label(size: 10, color: AppColors.ink3),
    );
  }
}

// ── Today Hero Card ────────────────────────────────────────────────────────
class _TodayHeroCard extends StatefulWidget {
  final VoidCallback onTap;
  const _TodayHeroCard({required this.onTap});

  @override
  State<_TodayHeroCard> createState() => _TodayHeroCardState();
}

class _TodayHeroCardState extends State<_TodayHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Radial glow top-right
            Positioned(
              top: -40, right: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.saffron.withOpacity(0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.saffron.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.saffronLight.withOpacity(
                                  0.4 + _pulse.value * 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Somvar Special',
                            style: AppTextStyles.label(
                              size: 10,
                              color: AppColors.saffronLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'SHIVA',
                  style: AppTextStyles.label(
                      size: 11, color: AppColors.saffronLight),
                ),
                const SizedBox(height: 5),
                Text(
                  'Om Jai Shiv Omkara',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text('ॐ जय शिव ओंकारा',
                    style: AppTextStyles.devanagari(
                      size: 14,
                      color: AppColors.white.withOpacity(0.45),
                    )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _MetaChip(icon: Icons.schedule_outlined, label: '7:32'),
                    const SizedBox(width: 16),
                    _MetaChip(
                        icon: Icons.format_list_numbered_outlined,
                        label: '6 verses'),
                    const Spacer(),
                    _PlayCircleButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.white.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.body(
                size: 12, color: AppColors.white.withOpacity(0.5))),
      ],
    );
  }
}

class _PlayCircleButton extends StatefulWidget {
  @override
  State<_PlayCircleButton> createState() => _PlayCircleButtonState();
}

class _PlayCircleButtonState extends State<_PlayCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.saffron,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

// ── Deity Chip ─────────────────────────────────────────────────────────────
class _DeityChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DeityChip({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? AppColors.saffron : AppColors.stone3,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.saffron.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: AppTextStyles.body(
                size: 11,
                color: isActive ? AppColors.saffron : AppColors.ink3,
                weight: isActive ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aarti Card ─────────────────────────────────────────────────────────────
class _AartiCard extends StatelessWidget {
  final AartiItem aarti;
  final bool isBookmarked;
  final Duration delay;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const _AartiCard({
    required this.aarti,
    required this.isBookmarked,
    required this.delay,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stone2, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              aarti.deity.toUpperCase(),
              style: AppTextStyles.label(size: 10, color: AppColors.saffron),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                aarti.title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              aarti.devanagari,
              style: AppTextStyles.devanagari(size: 12, color: AppColors.ink3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 12, color: AppColors.ink3),
                const SizedBox(width: 4),
                Text(aarti.duration,
                    style: AppTextStyles.body(size: 12, color: AppColors.ink3)),
                const Spacer(),
                GestureDetector(
                  onTap: onBookmark,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? AppColors.saffronGlow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBookmarked
                            ? AppColors.saffron
                            : AppColors.stone3,
                      ),
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      size: 14,
                      color: isBookmarked ? AppColors.saffron : AppColors.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Screen 2: Aarti Detail ─────────────────────────────────────────────────
class AartiDetailScreen extends StatefulWidget {
  final AartiItem aarti;
  const AartiDetailScreen({super.key, required this.aarti});

  @override
  State<AartiDetailScreen> createState() => _AartiDetailScreenState();
}

class _AartiDetailScreenState extends State<AartiDetailScreen>
    with TickerProviderStateMixin {
  int _viewMode = 0; // 0=lyrics, 1=roman, 2=meaning
  bool _isPlaying = false;
  bool _focusMode = false;
  bool _showCounter = false;
  double _progress = 0.35;
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _progressCtrl.addListener(() {
      if (mounted) setState(() => _progress = _progressCtrl.value * 0.65 + 0.35);
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _progressCtrl.forward();
    } else {
      _progressCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_back_ios_new,
                                        size: 14, color: AppColors.ink3),
                                    const SizedBox(width: 4),
                                    Text('Back',
                                        style: AppTextStyles.body(
                                            size: 12,
                                            color: AppColors.ink3)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                '${widget.aarti.deity.toUpperCase()} · SOMVAR',
                                style: AppTextStyles.label(
                                    size: 10, color: AppColors.saffron),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.aarti.title,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.ink,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(widget.aarti.devanagari,
                                  style: AppTextStyles.devanagari(size: 17)),
                              const SizedBox(height: 20),

                              // Action buttons
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    _ActionChip(
                                      icon: Icons.fullscreen_outlined,
                                      label: 'Focus Mode',
                                      isPrimary: true,
                                      onTap: () =>
                                          setState(() => _focusMode = true),
                                    ),
                                    const SizedBox(width: 8),
                                    _ActionChip(
                                      icon: Icons.track_changes_outlined,
                                      label: 'Mantra Counter',
                                      onTap: () =>
                                          setState(() => _showCounter = true),
                                    ),
                                    const SizedBox(width: 8),
                                    _ActionChip(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    _ActionChip(
                                      icon: Icons.download_outlined,
                                      label: 'Offline',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Toggle bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: _ToggleBar(
                            labels: const ['Lyrics', 'Transliteration', 'Meaning'],
                            activeIndex: _viewMode,
                            onSelect: (i) => setState(() => _viewMode = i),
                          ),
                        ),
                      ),

                      // Verses
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _VerseBlock(
                              verse: kVerses[i],
                              isFirst: i == 0,
                              viewMode: _viewMode,
                            ),
                            childCount: kVerses.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky audio player
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _AudioPlayer(
              aarti: widget.aarti,
              isPlaying: _isPlaying,
              progress: _progress,
              onPlayPause: _togglePlay,
              onScrub: (v) => setState(() => _progress = v),
            ),
          ),

          // Focus mode overlay
          if (_focusMode)
            _FocusModeOverlay(
              aarti: widget.aarti,
              onClose: () => setState(() => _focusMode = false),
            ),

          // Mantra counter overlay
          if (_showCounter)
            _MantraCounterOverlay(
              onClose: () => setState(() => _showCounter = false),
            ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? AppColors.ink : AppColors.stone3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isPrimary ? AppColors.white : AppColors.ink2),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.body(
                size: 12,
                color: isPrimary ? AppColors.white : AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBar extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _ToggleBar({
    required this.labels,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.stone2,
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
                  color: isActive ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.ink.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: AppTextStyles.body(
                      size: 12,
                      color: isActive ? AppColors.ink : AppColors.ink3,
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

class _VerseBlock extends StatelessWidget {
  final VerseData verse;
  final bool isFirst;
  final int viewMode;

  const _VerseBlock({
    required this.verse,
    required this.isFirst,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(verse.label, style: AppTextStyles.label()),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: AppColors.stone3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(verse.lines.length, (i) {
            final isHighlighted = isFirst && i == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main line (lyrics)
                  if (viewMode == 0)
                    Container(
                      padding: isHighlighted
                          ? const EdgeInsets.only(left: 12)
                          : EdgeInsets.zero,
                      decoration: isHighlighted
                          ? const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    color: AppColors.saffron, width: 2),
                              ),
                            )
                          : null,
                      child: Text(
                        verse.lines[i],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: isHighlighted
                              ? AppColors.saffron
                              : AppColors.ink,
                          height: 1.9,
                        ),
                      ),
                    ),

                  // Transliteration
                  if (viewMode == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(verse.lines[i],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.ink,
                                height: 1.9)),
                        Text(
                          verse.transliteration[i],
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: AppColors.ink3,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),

                  // Meaning
                  if (viewMode == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(verse.lines[i],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.ink,
                                height: 1.9)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.stone2,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              left: BorderSide(
                                  color: AppColors.saffronLight, width: 2),
                            ),
                          ),
                          child: Text(
                            verse.meanings[i],
                            style: AppTextStyles.body(
                                size: 13, color: AppColors.ink3),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Audio Player ───────────────────────────────────────────────────────────
class _AudioPlayer extends StatelessWidget {
  final AartiItem aarti;
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onScrub;

  const _AudioPlayer({
    required this.aarti,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onScrub,
  });

  String _formatTime(double progress, int totalSec) {
    final sec = (progress * totalSec).toInt();
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.stone.withOpacity(0.92),
          border: Border(
            top: BorderSide(color: AppColors.stone3, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress
            Row(
              children: [
                Text(_formatTime(progress, 452),
                    style: AppTextStyles.body(size: 11, color: AppColors.ink3)),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTapDown: (d) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                    },
                    onHorizontalDragUpdate: (d) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                    },
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.saffron,
                        inactiveTrackColor: AppColors.stone3,
                        thumbColor: AppColors.saffron,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 5),
                        trackHeight: 2.5,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: onScrub,
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('7:32',
                    style: AppTextStyles.body(size: 11, color: AppColors.ink3)),
              ],
            ),
            const SizedBox(height: 8),

            // Controls
            Row(
              children: [
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aarti.title,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Verse 1 of 6',
                          style: AppTextStyles.body(
                              size: 11, color: AppColors.ink3)),
                    ],
                  ),
                ),

                // Buttons
                _CtrlBtn(icon: Icons.skip_previous_rounded, onTap: () {}),
                const SizedBox(width: 4),
                _PlayPauseBtn(isPlaying: isPlaying, onTap: onPlayPause),
                const SizedBox(width: 4),
                _CtrlBtn(icon: Icons.skip_next_rounded, onTap: () {}),
                const SizedBox(width: 8),
                _CtrlBtn(icon: Icons.repeat_rounded, onTap: () {}),
                _CtrlBtn(icon: Icons.volume_up_outlined, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: AppColors.ink2),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }
}

class _PlayPauseBtn extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseBtn({required this.isPlaying, required this.onTap});

  @override
  State<_PlayPauseBtn> createState() => _PlayPauseBtnState();
}

class _PlayPauseBtnState extends State<_PlayPauseBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void didUpdateWidget(_PlayPauseBtn old) {
    super.didUpdateWidget(old);
    widget.isPlaying ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
        ),
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _ctrl,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ── Focus Mode Overlay ─────────────────────────────────────────────────────
class _FocusModeOverlay extends StatelessWidget {
  final AartiItem aarti;
  final VoidCallback onClose;

  const _FocusModeOverlay({required this.aarti, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: AppColors.ink,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SADHANA MODE',
                          style: AppTextStyles.label(
                            size: 10,
                            color: AppColors.ink3,
                          ),
                        ),
                        Text(
                          aarti.title,
                          style: AppTextStyles.body(
                            size: 13,
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.ink3, size: 20),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ब्रह्मा, विष्णु, सदाशिव',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withOpacity(0.3),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'ॐ जय शिव ओंकारा',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppColors.saffronLight,
                            fontWeight: FontWeight.w400,
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'स्वामी जय शिव ओंकारा',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withOpacity(0.3),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'अर्द्धांगी धारा',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.white.withOpacity(0.2),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mantra Counter Overlay ─────────────────────────────────────────────────
class _MantraCounterOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _MantraCounterOverlay({required this.onClose});

  @override
  State<_MantraCounterOverlay> createState() => _MantraCounterOverlayState();
}

class _MantraCounterOverlayState extends State<_MantraCounterOverlay>
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
        color: AppColors.ink.withOpacity(0.5),
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
                      style: AppTextStyles.body(
                          size: 12, color: AppColors.ink3)),
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
                          painter: _MalaPainter(
                              count: _count,
                              total: _total,
                              beads: _beads),
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

class _MalaPainter extends CustomPainter {
  final int count;
  final int total;
  final int beads;

  const _MalaPainter(
      {required this.count, required this.total, required this.beads});

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
  bool shouldRepaint(_MalaPainter old) => old.count != count;
}

// ── Screen 3: My Daily Puja ────────────────────────────────────────────────
class MyPujaScreen extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  const MyPujaScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _AartiAppBar(onMenuTap: onOpenDrawer),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 34,
                              fontWeight: FontWeight.w300,
                              color: AppColors.ink,
                            ),
                            children: [
                              TextSpan(text: 'My Daily '),
                              TextSpan(
                                text: 'Puja',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.saffron,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('5 aartis · Est. 31 min',
                            style: AppTextStyles.body(
                                size: 13, color: AppColors.ink3)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: const Text('Start Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w400),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SettingChip(
                      icon: Icons.play_circle_outline, label: 'Auto-play on'),
                  _SettingChip(icon: Icons.tune_outlined, label: 'Crossfade 1s'),
                  _SettingChip(
                      icon: Icons.download_outlined, label: 'Download All'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(height: 1, color: AppColors.stone2),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PujaListItem(
                  aarti: kAartis[i],
                  index: i + 1,
                  isPlaying: i == 0,
                  delay: Duration(milliseconds: i * 60),
                ),
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stone3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label == 'Auto-play on') ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: AppColors.saffron, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 13, color: AppColors.ink2),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: AppTextStyles.body(size: 12, color: AppColors.ink2)),
        ],
      ),
    );
  }
}

class _PujaListItem extends StatelessWidget {
  final AartiItem aarti;
  final int index;
  final bool isPlaying;
  final Duration delay;

  const _PujaListItem({
    required this.aarti,
    required this.index,
    required this.isPlaying,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stone2),
        ),
        child: Row(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.drag_indicator,
                  size: 18, color: AppColors.stone3),
            ),

            // Number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isPlaying ? AppColors.saffron : AppColors.stone2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPlaying ? AppColors.white : AppColors.ink3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aarti.deity.toUpperCase(),
                      style: AppTextStyles.label(
                          size: 9, color: AppColors.saffron)),
                  const SizedBox(height: 1),
                  Text(
                    aarti.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(aarti.devanagari,
                      style: AppTextStyles.devanagari(
                          size: 11, color: AppColors.ink3)),
                ],
              ),
            ),

            // Offline badge
            if (aarti.isOffline)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.saffronGlow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.saffron.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_done,
                        size: 10, color: AppColors.saffron),
                    const SizedBox(width: 3),
                    Text('Ready',
                        style: AppTextStyles.body(
                            size: 10, color: AppColors.saffron)),
                  ],
                ),
              ),

            Text(aarti.duration,
                style: AppTextStyles.body(size: 12, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}

// ── Screen 4: Contribute ───────────────────────────────────────────────────
class ContributeScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const ContributeScreen({super.key, required this.onOpenDrawer});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  int _privacyMode = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _AartiAppBar(onMenuTap: widget.onOpenDrawer),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTRIBUTE',
                      style: AppTextStyles.label(
                          size: 10, color: AppColors.ink3)),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: AppColors.ink,
                      ),
                      children: [
                        TextSpan(text: 'Add an '),
                        TextSpan(
                          text: 'Aarti',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.saffron,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share a prayer with the community or keep it for yourself',
                    style:
                        AppTextStyles.body(size: 13, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _FormField(
                    label: 'Deity Name',
                    hint: 'e.g. Ganesha, Shiva, Lakshmi…'),
                const SizedBox(height: 18),
                _FormField(
                    label: 'Aarti Title (English)',
                    hint: 'e.g. Jai Ganesh Deva'),
                const SizedBox(height: 18),
                _FormField(
                  label: 'Title in Devanagari',
                  hint: 'e.g. जय गणेश देव',
                ),
                const SizedBox(height: 18),
                _FormField(
                  label: 'Lyrics (Devanagari)',
                  hint: 'ॐ जय जगदीश हरे…',
                  maxLines: 6,
                ),
                const SizedBox(height: 18),
                _FormField(
                    label: 'Audio URL (optional)',
                    hint: 'https://…'),
                const SizedBox(height: 24),

                // Privacy
                Text('VISIBILITY',
                    style: AppTextStyles.label(
                        size: 10, color: AppColors.ink3)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PrivacyOption(
                        title: 'Private',
                        subtitle: 'Only visible to you',
                        isSelected: _privacyMode == 0,
                        onTap: () => setState(() => _privacyMode = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PrivacyOption(
                        title: 'Submit for Review',
                        subtitle: 'Added to global library if approved',
                        isSelected: _privacyMode == 1,
                        onTap: () => setState(() => _privacyMode = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_privacyMode == 0
                            ? 'Aarti saved privately.'
                            : 'Aarti submitted for review. 🙏'),
                        backgroundColor: AppColors.ink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Submit Aarti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                    elevation: 0,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppTextStyles.label(size: 10, color: AppColors.ink3)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          style: AppTextStyles.body(size: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(size: 14, color: AppColors.ink3),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.stone3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.stone3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.saffron, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronGlow : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.saffron : AppColors.stone3,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.body(
                    size: 13,
                    color: AppColors.ink,
                    weight: FontWeight.w400)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    AppTextStyles.body(size: 11, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}