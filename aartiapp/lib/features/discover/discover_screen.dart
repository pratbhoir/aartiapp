import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/day_deity_mapper.dart';
import '../../core/utils/search_engine.dart';
import '../../data/models/aarti_item.dart';
import '../../data/repositories/aarti_repository.dart';
import '../../data/repositories/festival_repository.dart';
import '../../providers/app_providers.dart';
import '../../widgets/aarti_app_bar.dart';
import '../../widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/search_bar.dart' as app;
import 'widgets/today_hero_card.dart';
import 'widgets/deity_chip.dart';
import 'widgets/aarti_card.dart';
import 'widgets/festive_banner.dart';
import 'widgets/festival_filter_chips.dart';

class DiscoverScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  const DiscoverScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDeity = ref.watch(activeDeityProvider);
    final filteredIndices = ref.watch(filteredAartisProvider);
    final bookmarks = ref.watch(bookmarkProvider);
    final userName = ref.watch(userNameProvider);
    final todayIdx = DayDeityMapper.todayAartiIndex();
    final catalog = AartiRepository.instance;
    final aartis = catalog.aartis;
    final deities = catalog.deities;

    return SafeArea(
      child: Column(
        children: [
          AartiAppBar(onMenuTap: onOpenDrawer),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
          // Greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.displayLarge(context).copyWith(
                        fontSize: 34,
                      ),
                      children: [
                        const TextSpan(text: 'Jai '),
                        TextSpan(
                          text: 'Shri Krishna,',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.saffron,
                          ),
                        ),
                        TextSpan(text: '\n$userName'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DayDeityMapper.todaySubtitle(),
                    style: AppTextStyles.body(size: 13, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),

          // Today hero
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Aarti of the Day'),
                  const SizedBox(height: 12),
                  TodayHeroCard(
                    aarti: aartis[todayIdx],
                    onTap: () {
                      ref.read(recentlyPlayedProvider.notifier).addRecent(aartis[todayIdx].id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AartiDetailScreen(aarti: aartis[todayIdx]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Festive banner (v1.5)
          Builder(
            builder: (context) {
              final festival =
                  FestivalRepository.instance.todayOrUpcoming();
              if (festival == null) return const SliverToBoxAdapter();
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: FestiveBanner(
                    festival: festival,
                    onTap: () {
                      // Filter by the festival's deity
                      final deityIdx = deities.indexWhere(
                          (d) =>
                              d['label']!.toLowerCase() ==
                              festival.deity.toLowerCase());
                      if (deityIdx >= 0) {
                        ref.read(activeDeityProvider.notifier).state =
                            deityIdx;
                      }
                    },
                  ),
                ),
              );
            },
          ),

          // Recently Played (v2.0)
          Builder(
            builder: (context) {
              final recentIds = ref.watch(recentlyPlayedProvider);
              if (recentIds.isEmpty) return const SliverToBoxAdapter();
              final userAartis = ref.watch(userAartiProvider);
              final recentAartis = ref
                  .watch(recentlyPlayedProvider.notifier)
                  .getRecentAartis(userAartis: userAartis);
              if (recentAartis.isEmpty) return const SliverToBoxAdapter();
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 24),
                        child: SectionLabel('Recently Played'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: recentAartis.length.clamp(0, 10),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (ctx, i) {
                            final ra = recentAartis[i];
                            return _RecentlyPlayedCard(
                              aarti: ra,
                              onTap: () {
                                ref
                                    .read(recentlyPlayedProvider.notifier)
                                    .addRecent(ra.id);
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AartiDetailScreen(aarti: ra),
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
              );
            },
          ),

          // Deity chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: SectionLabel('Browse by Deity'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: deities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => DeityChip(
                        emoji: deities[i]['emoji']!,
                        label: deities[i]['label']!,
                        isActive: activeDeity == i,
                        onTap: () {
                          ref.read(activeDeityProvider.notifier).state = i;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: app.SearchBar(
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),
          ),

          // Festival filter chips (v2.0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: SectionLabel('Filter by Festival'),
                  ),
                  const SizedBox(height: 10),
                  FestivalFilterChips(
                    festivalTags:
                        SearchEngine.allFestivalTags(aartis),
                    activeTag: ref.watch(activeFestivalTagProvider),
                    onSelect: (tag) {
                      ref.read(activeFestivalTagProvider.notifier).state = tag;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Grid label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Row(
                children: [
                  const SectionLabel('Popular Aartis'),
                  const Spacer(),
                  Text(
                    '${filteredIndices.length} found',
                    style: AppTextStyles.body(size: 11, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),

          // Aarti grid — filtered
          filteredIndices.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.ink3.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No Aartis found',
                          style: AppTextStyles.body(
                              size: 14, color: AppColors.ink3),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final aartiIdx = filteredIndices[i];
                        final aarti = aartis[aartiIdx];
                        return AartiCard(
                          aarti: aarti,
                          isBookmarked: bookmarks.contains(aarti.id),
                          delay: Duration(milliseconds: i * 60),
                          onBookmark: () {
                            ref.read(bookmarkProvider.notifier).toggle(aarti.id);
                          },
                          onTap: () {
                            ref.read(recentlyPlayedProvider.notifier).addRecent(aarti.id);
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => AartiDetailScreen(aarti: aarti),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredIndices.length,
                    ),
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

/// Compact card for the Recently Played horizontal list.
class _RecentlyPlayedCard extends StatelessWidget {
  final AartiItem aarti;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({required this.aarti, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stone3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.saffronGlow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 16, color: AppColors.saffron),
            ),
            const SizedBox(height: 8),
            Text(
              aarti.deity.toUpperCase(),
              style: AppTextStyles.label(size: 8, color: AppColors.saffron),
            ),
            const SizedBox(height: 2),
            Text(
              aarti.title,
              style: AppTextStyles.body(size: 12, color: AppColors.ink),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
