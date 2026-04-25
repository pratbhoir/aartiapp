import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/search_engine.dart';
import '../../data/repositories/aarti_repository.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/aarti_app_bar.dart';
import '../../shared/widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/search_bar.dart' as app;
import 'widgets/deity_chip.dart';
import 'widgets/aarti_card.dart';
import 'widgets/festival_filter_chips.dart';

class DiscoverScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  const DiscoverScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDeity = ref.watch(activeDeityProvider);
    final filteredIndices = ref.watch(filteredAartisProvider);
    final bookmarks = ref.watch(bookmarkProvider);
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
                // Deity chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 24, 0, 0),
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
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
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
                    padding: const EdgeInsets.fromLTRB(15, 16, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 24),
                          child: SectionLabel('Filter by Festival'),
                        ),
                        const SizedBox(height: 10),
                        FestivalFilterChips(
                          festivalTags: SearchEngine.allFestivalTags(aartis),
                          activeTag: ref.watch(activeFestivalTagProvider),
                          onSelect: (tag) {
                            ref.read(activeFestivalTagProvider.notifier).state =
                                tag;
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
                        const SectionLabel('Popular Aartis'),
                        const Spacer(),
                        Text(
                          '${filteredIndices.length} found',
                          style:
                              AppTypography.body(size: 11, color: AppColors.ink3),
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
                                'No Aartis found',
                                style:
                                    AppTypography.body(size: 14, color: AppColors.ink3),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
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
