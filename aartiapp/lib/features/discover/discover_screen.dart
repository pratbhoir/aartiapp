import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/sample_data.dart';
import '../../widgets/aarti_app_bar.dart';
import '../../widgets/section_label.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/search_bar.dart' as app;
import 'widgets/today_hero_card.dart';
import 'widgets/deity_chip.dart';
import 'widgets/aarti_card.dart';

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
            child: AartiAppBar(
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
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: AppColors.ink,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      children: [
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
              child: app.SearchBar(),
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
                      itemCount: kDeities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => DeityChip(
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: SectionLabel('Popular Aartis'),
            ),
          ),

          // Aarti grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => AartiCard(
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
