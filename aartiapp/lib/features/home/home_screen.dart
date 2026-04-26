import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/day_deity_mapper.dart';
import '../../data/models/aarti_item.dart';
import '../../data/repositories/aarti_repository.dart';
import '../../data/repositories/festival_repository.dart';
import '../../providers/app_providers.dart';
import '../../shared/utils/aarti_language_resolver.dart';
import '../../shared/widgets/aarti_app_bar.dart';
import '../../shared/widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import '../discover/widgets/festive_banner.dart';
import '../discover/widgets/today_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback? onOpenDiscover;

  const HomeScreen({
    super.key,
    required this.onOpenDrawer,
    this.onOpenDiscover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final userAartis = ref.watch(userAartiProvider);
    final recentIds = ref.watch(recentlyPlayedProvider);
    final scriptMode = ref.watch(scriptModeProvider);
    final todayIdx = DayDeityMapper.todayAartiIndex();
    final catalog = AartiRepository.instance;
    final aartis = catalog.aartis;
    final deities = catalog.deities;

    return SafeArea(
      child: Column(
        children: [
          AartiAppBar(
            onMenuTap: onOpenDrawer,
            showMenu: false,
            showLogoTitle: true,
            title: 'Home',
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Greeting
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTypography.displayLarge(context).copyWith(
                              fontSize: 34,
                            ),
                            children: [
                              const TextSpan(text: 'Jai '),
                              TextSpan(
                                text: 'Shri Krishna, ',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.saffron,
                                ),
                              ),
                              // TextSpan(text: ' ${userName.split(' ').first}'),
                              TextSpan(text: '\n$userName'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DayDeityMapper.todaySubtitle(),
                          style:
                              AppTypography.body(size: 13, color: AppColors.ink3),
                        ),
                      ],
                    ),
                  ),
                ),

                // Aarti of the day
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Aarti of the Day'),
                        const SizedBox(height: 13),
                        TodayHeroCard(
                          aarti: aartis[todayIdx],
                          scriptMode: scriptMode,
                          onTap: () {
                            ref
                                .read(recentlyPlayedProvider.notifier)
                                .addRecent(aartis[todayIdx].id);
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

                // Festive banner
                Builder(
                  builder: (context) {
                    final festival = FestivalRepository.instance.todayOrUpcoming();
                    if (festival == null) return const SliverToBoxAdapter();
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: FestiveBanner(
                          festival: festival,
                          onTap: () {
                            final deityIdx = deities.indexWhere(
                              (d) =>
                                  d['label']!.toLowerCase() ==
                                  festival.deity.toLowerCase(),
                            );
                            if (deityIdx >= 0) {
                              ref.read(activeDeityProvider.notifier).state = deityIdx;
                            }
                            onOpenDiscover?.call();
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Recently played
                Builder(
                  builder: (context) {
                    if (recentIds.isEmpty) return const SliverToBoxAdapter();
                    final recentAartis = ref
                        .watch(recentlyPlayedProvider.notifier)
                        .getRecentAartis(userAartis: userAartis);
                    if (recentAartis.isEmpty) return const SliverToBoxAdapter();
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 24, 15, 40),
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
                                    scriptMode: scriptMode,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyPlayedCard extends StatelessWidget {
  final AartiItem aarti;
  final int scriptMode;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({
    required this.aarti,
    required this.scriptMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scriptTitle = AartiLanguageResolver.resolveAartiTitle(aarti, scriptMode);
    final showScriptTitle = scriptTitle.trim() != aarti.title.trim();

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
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 16,
                color: AppColors.saffron,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              aarti.deity.toUpperCase(),
              style: AppTypography.label(size: 8, color: AppColors.saffron),
            ),
            const SizedBox(height: 2),
            Text(
              aarti.title,
              style: AppTypography.body(size: 12, color: AppColors.ink),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showScriptTitle)
              Text(
                scriptTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.devanagari(
                  size: 11,
                  color: AppColors.ink3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
