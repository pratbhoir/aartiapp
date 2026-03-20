import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/aarti_app_bar.dart';
import '../aarti_detail/aarti_detail_screen.dart';
import 'widgets/puja_list_item.dart';

class MyPujaScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  const MyPujaScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pujaIds = ref.watch(pujaOrderProvider);
    final userAartis = ref.watch(userAartiProvider);
    final pujaAartis =
        ref.watch(pujaOrderProvider.notifier).getPujaAartis(userAartis: userAartis);

    // Calculate total estimated duration
    int totalMinutes = 0;
    for (final a in pujaAartis) {
      final parts = a.duration.split(':');
      if (parts.length == 2) {
        totalMinutes += int.tryParse(parts[0]) ?? 0;
      }
    }

    return SafeArea(
      child: Column(
        children: [
          AartiAppBar(onMenuTap: onOpenDrawer),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.displayLarge(context).copyWith(
                            fontSize: 34,
                          ),
                          children: const [
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
                      Text(
                        '${pujaAartis.length} aartis · Est. $totalMinutes min',
                        style: AppTextStyles.body(
                            size: 13, color: AppColors.ink3),
                      ),
                    ],
                  ),
                ),
                if (pujaAartis.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to first aarti in focus mode
                      if (pujaAartis.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AartiDetailScreen(aarti: pujaAartis.first),
                          ),
                        );
                      }
                    },
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

          // Settings chips
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _SettingChip(
                    icon: Icons.play_circle_outline, label: 'Auto-play on'),
                _SettingChip(
                    icon: Icons.tune_outlined, label: 'Crossfade 1s'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(height: 1, color: context.border),
          ),

          // Reorderable puja list
          Expanded(
            child: pujaAartis.isEmpty
                ? _EmptyPujaView()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    physics: const BouncingScrollPhysics(),
                    proxyDecorator: (child, index, anim) {
                      return AnimatedBuilder(
                        animation: anim,
                        builder: (_, __) => Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.transparent,
                          child: child,
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      AppHaptics.reorder();
                      ref
                          .read(pujaOrderProvider.notifier)
                          .reorder(oldIndex, newIndex);
                    },
                    itemCount: pujaAartis.length,
                    itemBuilder: (_, i) => PujaListItem(
                      key: ValueKey(pujaIds[i]),
                      aarti: pujaAartis[i],
                      index: i + 1,
                      isPlaying: false,
                      delay: Duration(milliseconds: i * 60),
                      onRemove: () {
                        ref
                            .read(pujaOrderProvider.notifier)
                            .removeAarti(pujaAartis[i].id);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AartiDetailScreen(aarti: pujaAartis[i]),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPujaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined,
                size: 48, color: AppColors.ink3.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Your daily puja is empty',
              style: AppTextStyles.serifBody(
                size: 18,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark Aartis from the Discover tab\nto build your daily puja list.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 13, color: AppColors.ink3),
            ),
          ],
        ),
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
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderSubtle),
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
