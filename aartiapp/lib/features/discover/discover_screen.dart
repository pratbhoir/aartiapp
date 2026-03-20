import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/day_deity_mapper.dart';
import '../../data/repositories/aarti_repository.dart';
import '../../providers/app_providers.dart';
import '../../widgets/aarti_app_bar.dart';
import '../../widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/search_bar.dart' as app;
import 'widgets/today_hero_card.dart';
import 'widgets/deity_chip.dart';
import 'widgets/aarti_card.dart';

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
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: AartiAppBar(
              onMenuTap: onOpenDrawer,
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
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AartiDetailScreen(aarti: aartis[todayIdx]),
                      ),
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
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => AartiDetailScreen(aarti: aarti),
                            ),
                          ),
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
    );
  }
}
