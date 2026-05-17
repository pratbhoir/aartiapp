import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations_ext.dart';
import '../../core/constants/haptics.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/aarti_repository.dart';
import '../../data/repositories/festival_repository.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/aarti_app_bar.dart';
import '../../shared/widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import '../deity_detail/deity_detail_screen.dart';
import 'widgets/search_bar.dart' as app;
import 'widgets/deity_chip.dart';
import 'widgets/aarti_card.dart';
import 'widgets/festival_filter_chips.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenDrawer;
  const DiscoverScreen({super.key, required this.onOpenDrawer});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(discoverFilterProvider).searchQuery,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // AnalyticsService.trackEvent('discover_screen_viewed', path: '/discover');
      AnalyticsService.trackScreen('/discover', title: 'Discover');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(contentRevisionProvider);
    ref.listen<DiscoverFilterState>(discoverFilterProvider, (_, next) {
      if (_searchController.text == next.searchQuery) {
        return;
      }

      _searchController.value = TextEditingValue(
        text: next.searchQuery,
        selection: TextSelection.collapsed(offset: next.searchQuery.length),
      );
    });

    final discoverFilter = ref.watch(discoverFilterProvider);
    final filteredIndices = ref.watch(filteredAartisProvider);
    final bookmarks = ref.watch(bookmarkProvider);
    final scriptMode = ref.watch(scriptModeProvider);
    final catalog = AartiRepository.instance;
    final aartis = catalog.aartis;
    final deities = catalog.deities;
    final festivalTags = FestivalRepository.instance.orderedFestivalTags(
      allowedTags: catalog.allFestivalTags,
    );

    return SafeArea(
      child: Column(
        children: [
          AartiAppBar(
            onMenuTap: widget.onOpenDrawer,
            showMenu: false,
            showLogoTitle: true,
            title: l10n.navigationDiscover,
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Deity chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 24, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 24),
                          child: SectionLabel(l10n.discoverBrowseByDeity),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(right: 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: deities.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final deityLabel = deities[i]['label']!;
                              return DeityChip(
                                emoji: deities[i]['emoji']!,
                                label: deityLabel,
                                isActive: i == 0
                                    ? discoverFilter.mode ==
                                          DiscoverFilterMode.none
                                    : discoverFilter.mode ==
                                              DiscoverFilterMode.deity &&
                                          discoverFilter.activeDeityIndex == i,
                                onTap: () {
                                  AnalyticsService.trackEvent(
                                    'discover_deity_filter_tapped',
                                    data: <String, Object>{
                                      'deity_name': deityLabel,
                                      'index': i,
                                    },
                                    path: '/discover',
                                  );

                                  if (i == 0) {
                                    ref
                                        .read(discoverFilterProvider.notifier)
                                        .selectDeity(i);
                                    return;
                                  }

                                  AppHaptics.pageTransition();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DeityDetailScreen(
                                        deityLabel: deityLabel,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: app.SearchBar(
                      controller: _searchController,
                      hintText: l10n.discoverSearchPlaceholder,
                      onChanged: (query) {
                        final normalized = query.trim();
                        if (normalized.isNotEmpty) {
                          AnalyticsService.trackEvent(
                            'discover_search_performed',
                            data: <String, Object>{'query': normalized},
                            path: '/discover',
                          );
                        }
                        ref
                            .read(discoverFilterProvider.notifier)
                            .applySearch(query);
                      },
                    ),
                  ),
                ),

                // Festival filter chips (v2.0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 16, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 24),
                          child: SectionLabel(l10n.discoverFilterByFestival),
                        ),
                        const SizedBox(height: 10),
                        FestivalFilterChips(
                          festivalTags: festivalTags,
                          activeTag: discoverFilter.activeFestivalTag,
                          onSelect: (tag) {
                            AnalyticsService.trackEvent(
                              'discover_festival_filter_tapped',
                              data: <String, Object>{'festival_tag': tag},
                              path: '/discover',
                            );
                            ref
                                .read(discoverFilterProvider.notifier)
                                .selectFestival(tag);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                    child: Row(
                      children: [
                        SectionLabel(l10n.discoverPopularAartis),
                        const Spacer(),
                        Text(
                          l10n.discoverResultCount(filteredIndices.length),
                          style: AppTypography.body(
                            size: 11,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Aarti grid — filtered
                filteredIndices.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.ink3.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.discoverNoAartisFound,
                                style: AppTypography.body(
                                  size: 14,
                                  color: AppColors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final aartiIdx = filteredIndices[i];
                            final aarti = aartis[aartiIdx];
                            return AartiCard(
                              aarti: aarti,
                              scriptMode: scriptMode,
                              isBookmarked: bookmarks.contains(aarti.id),
                              delay: Duration(milliseconds: i * 60),
                              onBookmark: () {
                                AnalyticsService.trackEvent(
                                  'bookmark_toggled',
                                  data: <String, Object>{
                                    'source': 'discover_screen',
                                    'aarti_id': aarti.id,
                                    'deity_name': aarti.deity,
                                    'is_bookmarked': !bookmarks.contains(
                                      aarti.id,
                                    ),
                                  },
                                );

                                ref
                                    .read(bookmarkProvider.notifier)
                                    .toggle(aarti.id);
                              },
                              onTap: () {
                                AnalyticsService.trackEvent(
                                  'discover_aarti_card_tapped',
                                  data: <String, Object>{
                                    'aarti_id': aarti.id,
                                    'deity_name': aarti.deity,
                                  },
                                  path: '/discover',
                                );
                                ref
                                    .read(recentlyPlayedProvider.notifier)
                                    .addRecent(aarti.id);
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AartiDetailScreen(aarti: aarti),
                                  ),
                                );
                              },
                            );
                          }, childCount: filteredIndices.length),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 260,
                                mainAxisExtent: 168,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
