import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/haptics.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../data/models/aarti_item.dart';
import '../../data/models/festival.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/toggle_bar.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/deity_header.dart';
import 'widgets/deity_prayer_card.dart';

/// Dedicated deity browse page showing devotional content grouped by type.
class DeityDetailScreen extends ConsumerStatefulWidget {
  /// The selected deity label from the catalog.
  final String deityLabel;

  /// Creates a deity detail page for the provided catalog deity label.
  const DeityDetailScreen({super.key, required this.deityLabel});

  @override
  ConsumerState<DeityDetailScreen> createState() => _DeityDetailScreenState();
}

class _DeityDetailScreenState extends ConsumerState<DeityDetailScreen>
    with SingleTickerProviderStateMixin {
  static const List<_DeityTabDefinition> _tabs = <_DeityTabDefinition>[
    _DeityTabDefinition(label: 'Aartis', types: <String>{'aarti'}),
    _DeityTabDefinition(
      label: 'Shlokas',
      types: <String>{
        'shloka',
        'stotra',
        'mantra',
        'chant',
        'vandana',
        'abhang',
        'bhajan',
      },
    ),
    _DeityTabDefinition(label: 'Chalisas', types: <String>{'chalisa'}),
  ];

  static const Map<String, _DeityProfile> _profiles = <String, _DeityProfile>{
    'Ganesha': _DeityProfile(
      devanagariName: 'गणेश',
      tagline: 'Remover of Obstacles · Lord of Beginnings',
      mantra: 'Om Gan Ganapataye Namah',
      auspiciousDay: 'Tuesday',
      accentColor: AppColors.saffron,
    ),
    'Shiva': _DeityProfile(
      devanagariName: 'शिव',
      tagline: 'The Auspicious One · Keeper of Stillness',
      mantra: 'Om Namah Shivaya',
      auspiciousDay: 'Monday',
      accentColor: AppColors.ink2,
    ),
    'Lakshmi': _DeityProfile(
      devanagariName: 'लक्ष्मी',
      tagline: 'Goddess of Prosperity · Radiance and Grace',
      mantra: 'Om Shreem Mahalakshmyai Namah',
      auspiciousDay: 'Friday',
      accentColor: AppColors.gold,
    ),
    'Durga': _DeityProfile(
      devanagariName: 'दुर्गा',
      tagline: 'Protector of Dharma · Fierce Compassion',
      mantra: 'Om Dum Durgayai Namah',
      auspiciousDay: 'Friday',
      accentColor: AppColors.saffronDark,
    ),
    'Sai': _DeityProfile(
      devanagariName: 'साईं',
      tagline: 'Compassion, Surrender, and Grace',
      mantra: 'Om Sai Namo Namah',
      auspiciousDay: 'Thursday',
      accentColor: AppColors.gold,
    ),
    'Hanuman': _DeityProfile(
      devanagariName: 'हनुमान',
      tagline: 'Strength, Devotion, and Fearlessness',
      mantra: 'Om Hanumate Namah',
      auspiciousDay: 'Tuesday',
      accentColor: AppColors.saffron,
    ),
    'Krishna': _DeityProfile(
      devanagariName: 'कृष्ण',
      tagline: 'Divine Love · Joy, Wisdom, and Playfulness',
      mantra: 'Om Namo Bhagavate Vasudevaya',
      auspiciousDay: 'Wednesday',
      accentColor: AppColors.gold,
    ),
    'Rama': _DeityProfile(
      devanagariName: 'राम',
      tagline: 'Maryada, Courage, and Devotion',
      mantra: 'Shri Ram Jai Ram Jai Jai Ram',
      auspiciousDay: 'Thursday',
      accentColor: AppColors.saffronDark,
    ),
  };

  late final TabController _tabController;
  late final ScrollController _scrollController;
  int _trackedTabIndex = 0;
  double _heroProgress = 0;

  bool get _showCollapsedTitle => _heroProgress > 0.58;

  String get _path => '/deity/${_slugify(widget.deityLabel)}';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackScreen(_path, title: widget.deityLabel);
      AnalyticsService.trackEvent(
        'deity_screen_viewed',
        data: <String, Object>{'deity_name': widget.deityLabel},
        path: _path,
      );
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    const collapseRange = 190.0;
    final nextProgress = (_scrollController.offset / collapseRange).clamp(
      0.0,
      1.0,
    );
    if ((nextProgress - _heroProgress).abs() < 0.02) {
      return;
    }

    setState(() {
      _heroProgress = nextProgress;
    });
  }

  void _handleTabChange() {
    final nextIndex = _tabController.index;
    if (nextIndex == _trackedTabIndex) {
      return;
    }

    setState(() {
      _trackedTabIndex = nextIndex;
    });
    AnalyticsService.trackEvent(
      'deity_tab_changed',
      data: <String, Object>{
        'deity_name': widget.deityLabel,
        'tab_name': _tabs[nextIndex].label.toLowerCase(),
      },
      path: _path,
    );
  }

  void _openAarti(AartiItem aarti) {
    AppHaptics.pageTransition();
    AnalyticsService.trackEvent(
      'deity_aarti_tapped',
      data: <String, Object>{
        'aarti_id': aarti.id,
        'deity_name': aarti.deity,
        'tab_name': _tabs[_tabController.index].label.toLowerCase(),
      },
      path: _path,
    );
    ref.read(recentlyPlayedProvider.notifier).addRecent(aarti.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AartiDetailScreen(aarti: aarti)),
    );
  }

  void _toggleBookmark(AartiItem aarti, {required bool isBookmarked}) {
    AppHaptics.selection();
    AnalyticsService.trackEvent(
      'deity_bookmark_toggled',
      data: <String, Object>{
        'source': 'deity_screen',
        'aarti_id': aarti.id,
        'deity_name': aarti.deity,
        'is_bookmarked': !isBookmarked,
      },
      path: _path,
    );
    ref.read(bookmarkProvider.notifier).toggle(aarti.id);
  }

  @override
  Widget build(BuildContext context) {
    final deityMetadata = ref.watch(deityMetadataProvider(widget.deityLabel));
    final deityItems = ref.watch(deityItemsProvider(widget.deityLabel));
    final deityFestivals = ref.watch(deityFestivalsProvider(widget.deityLabel));
    final bookmarks = ref.watch(bookmarkProvider);
    final scriptMode = ref.watch(scriptModeProvider);

    final deityLabel = deityMetadata?['label'] ?? widget.deityLabel;
    final deityEmoji = deityMetadata?['emoji'] ?? '🕉️';
    final profile = _resolveProfile(deityLabel, deityFestivals);
    final tabStates = _tabs
        .map(
          (tab) =>
              _DeityTabState(definition: tab, items: tab.filter(deityItems)),
        )
        .toList();
    final summary = _buildSummary(
      deityLabel: deityLabel,
      itemCount: deityItems.length,
      festivalCount: deityFestivals.length,
    );
    final appBarColor = Color.lerp(
      AppColors.ink,
      context.scaffoldBg,
      _heroProgress * 0.9,
    )!;
    final leadingFill = Color.lerp(
      AppColors.white.withValues(alpha: 0.12),
      context.surface,
      _heroProgress,
    )!;
    final leadingBorder = Color.lerp(
      AppColors.white.withValues(alpha: 0.14),
      context.border,
      _heroProgress,
    )!;
    final leadingIconColor = Color.lerp(
      AppColors.white,
      context.textPrimary,
      _heroProgress,
    )!;
    final titleColor = Color.lerp(
      AppColors.white,
      context.textPrimary,
      _heroProgress,
    )!;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: NestedScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (_, __) => <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 384,
            backgroundColor: appBarColor,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Semantics(
                label: 'Back to Discover',
                button: true,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: AppSpacing.touchTarget,
                    height: AppSpacing.touchTarget,
                    decoration: BoxDecoration(
                      color: leadingFill,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                      border: Border.all(color: leadingBorder),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: leadingIconColor,
                    ),
                  ),
                ),
              ),
            ),
            titleSpacing: 8,
            title: AnimatedOpacity(
              opacity: _showCollapsedTitle ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Row(
                children: <Widget>[
                  Text(deityEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      deityLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serifBody(
                        size: 18,
                        color: titleColor,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: DeityHeader(
                emoji: deityEmoji,
                title: deityLabel,
                devanagariTitle: profile.devanagariName,
                tagline: profile.tagline,
                summary: summary,
                mantra: profile.mantra,
                auspiciousDay: profile.auspiciousDay,
                accentColor: profile.accentColor,
                devotionalCount: deityItems.length,
                festivalNames: deityFestivals
                    .take(3)
                    .map((festival) => festival.name)
                    .toList(),
                heroProgress: _heroProgress,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: _DeityTabBar(
                controller: _tabController,
                tabs: tabStates,
                activeIndex: _trackedTabIndex,
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            for (final tabState in tabStates)
              _DeityTabList(
                key: PageStorageKey<String>(
                  '${widget.deityLabel}-${tabState.definition.label}',
                ),
                deityLabel: deityLabel,
                tab: tabState.definition,
                items: tabState.items,
                scriptMode: scriptMode,
                bookmarks: bookmarks,
                onTapAarti: _openAarti,
                onBookmark: _toggleBookmark,
              ),
          ],
        ),
      ),
    );
  }

  static String _buildSummary({
    required String deityLabel,
    required int itemCount,
    required int festivalCount,
  }) {
    if (itemCount == 0) {
      return 'No devotionals are available for $deityLabel yet.';
    }

    if (festivalCount > 0) {
      return '$itemCount devotionals and $festivalCount related festivals for $deityLabel.';
    }

    return '$itemCount devotionals gathered for prayer, reading, and listening.';
  }

  _DeityProfile _resolveProfile(String deityLabel, List<Festival> festivals) {
    final baseProfile =
        _profiles[deityLabel] ??
        const _DeityProfile(
          devanagariName: 'आरती',
          tagline: 'Daily prayer, listening, and reflection',
          mantra: 'Sacred verses and daily devotion',
          auspiciousDay: 'Every day',
          accentColor: AppColors.saffron,
        );
    if (festivals.isEmpty) {
      return baseProfile;
    }

    final primaryFestival = festivals.first;
    return baseProfile.copyWith(
      tagline: primaryFestival.description.isNotEmpty
          ? primaryFestival.description
          : baseProfile.tagline,
    );
  }
}

class _DeityTabBar extends StatelessWidget {
  const _DeityTabBar({
    required this.controller,
    required this.tabs,
    required this.activeIndex,
  });

  final TabController controller;
  final List<_DeityTabState> tabs;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: ToggleBar(
        labels: tabs.map((tab) => tab.definition.label).toList(growable: false),
        activeIndex: activeIndex,
        onSelect: controller.animateTo,
      ),
    );
  }
}

class _DeityTabList extends StatelessWidget {
  const _DeityTabList({
    super.key,
    required this.deityLabel,
    required this.tab,
    required this.items,
    required this.scriptMode,
    required this.bookmarks,
    required this.onTapAarti,
    required this.onBookmark,
  });

  final String deityLabel;
  final _DeityTabDefinition tab;
  final List<AartiItem> items;
  final int scriptMode;
  final Set<String> bookmarks;
  final ValueChanged<AartiItem> onTapAarti;
  final void Function(AartiItem aarti, {required bool isBookmarked}) onBookmark;

  @override
  Widget build(BuildContext context) {
    final showMergedTypesNotice =
        tab.label == 'Shlokas' &&
        items.any((item) => item.type.toLowerCase() != 'shloka');
    final popularItems = items.take(items.length > 3 ? 2 : 1).toList();
    final remainingItems = items.skip(popularItems.length).toList();

    if (items.isEmpty) {
      return _DeityEmptyState(tabLabel: tab.label, deityLabel: deityLabel);
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.scrollEnd,
      ),
      children: <Widget>[
        if (showMergedTypesNotice)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: context.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              'This tab also includes stotras, mantras, chants, and other reading-first devotionals.',
              style: AppTypography.body(
                size: 12,
                color: context.textSecondary,
                weight: FontWeight.w400,
              ),
            ),
          ),
        _DeitySectionHeader(
          title: 'Popular',
          caption: '${popularItems.length} picks for $deityLabel',
        ),
        const SizedBox(height: AppSpacing.md),
        ..._buildCards(popularItems),
        if (remainingItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          _DeitySectionHeader(
            title: tab.label == 'Aartis' ? 'More Aartis' : 'More ${tab.label}',
            caption: 'Continue your prayer with the full collection',
          ),
          const SizedBox(height: AppSpacing.md),
          ..._buildCards(remainingItems),
        ],
      ],
    );
  }

  List<Widget> _buildCards(List<AartiItem> sectionItems) {
    return <Widget>[
      for (var index = 0; index < sectionItems.length; index++) ...<Widget>[
        DeityPrayerCard(
          aarti: sectionItems[index],
          scriptMode: scriptMode,
          isBookmarked: bookmarks.contains(sectionItems[index].id),
          onTap: () => onTapAarti(sectionItems[index]),
          onBookmark: () => onBookmark(
            sectionItems[index],
            isBookmarked: bookmarks.contains(sectionItems[index].id),
          ),
        ),
        if (index < sectionItems.length - 1)
          const SizedBox(height: AppSpacing.listItemGap),
      ],
    ];
  }
}

class _DeitySectionHeader extends StatelessWidget {
  const _DeitySectionHeader({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppTypography.serifBody(
                  size: 18,
                  color: context.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                caption,
                style: AppTypography.body(
                  size: 12,
                  color: context.textCaption,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        ),
      ],
    );
  }
}

class _DeityEmptyState extends StatelessWidget {
  const _DeityEmptyState({required this.tabLabel, required this.deityLabel});

  final String tabLabel;
  final String deityLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: context.border),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                color: context.textCaption,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No $tabLabel yet',
              style: AppTypography.scriptTitle(context).copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$deityLabel does not have items in this section yet.',
              style: AppTypography.body(
                size: 13,
                color: context.textSecondary,
                weight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeityTabDefinition {
  const _DeityTabDefinition({required this.label, required this.types});

  final String label;
  final Set<String> types;

  List<AartiItem> filter(List<AartiItem> items) {
    return items
        .where((item) => types.contains(item.type.toLowerCase()))
        .toList();
  }
}

class _DeityTabState {
  const _DeityTabState({required this.definition, required this.items});

  final _DeityTabDefinition definition;
  final List<AartiItem> items;
}

class _DeityProfile {
  const _DeityProfile({
    required this.devanagariName,
    required this.tagline,
    required this.mantra,
    required this.auspiciousDay,
    required this.accentColor,
  });

  final String devanagariName;
  final String tagline;
  final String mantra;
  final String auspiciousDay;
  final Color accentColor;

  _DeityProfile copyWith({String? tagline}) {
    return _DeityProfile(
      devanagariName: devanagariName,
      tagline: tagline ?? this.tagline,
      mantra: mantra,
      auspiciousDay: auspiciousDay,
      accentColor: accentColor,
    );
  }
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
