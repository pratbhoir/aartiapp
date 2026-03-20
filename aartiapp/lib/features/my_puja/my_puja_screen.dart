import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/sample_data.dart';
import '../../widgets/aarti_app_bar.dart';
import 'widgets/puja_list_item.dart';

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
            child: AartiAppBar(onMenuTap: onOpenDrawer),
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
                  _SettingChip(
                      icon: Icons.tune_outlined, label: 'Crossfade 1s'),
                  _SettingChip(
                      icon: Icons.download_outlined, label: 'Download All'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(height: 1, color: AppColors.stone2),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => PujaListItem(
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
