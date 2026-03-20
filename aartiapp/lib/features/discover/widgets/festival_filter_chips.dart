import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_aware_colors.dart';

/// Horizontal scrollable festival filter chips for the Discover screen.
class FestivalFilterChips extends StatelessWidget {
  final List<String> festivalTags;
  final String activeTag;
  final ValueChanged<String> onSelect;

  const FestivalFilterChips({
    super.key,
    required this.festivalTags,
    required this.activeTag,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: festivalTags.length + 1, // +1 for "All" chip
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final isActive = activeTag.isEmpty;
            return _FestivalChip(
              label: 'All Festivals',
              emoji: '🕉️',
              isActive: isActive,
              onTap: () => onSelect(''),
            );
          }
          final tag = festivalTags[i - 1];
          final isActive = activeTag == tag;
          return _FestivalChip(
            label: tag,
            emoji: _festivalEmoji(tag),
            isActive: isActive,
            onTap: () => onSelect(tag),
          );
        },
      ),
    );
  }

  static String _festivalEmoji(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('diwali')) return '🪔';
    if (t.contains('holi')) return '🎨';
    if (t.contains('navratri')) return '🌺';
    if (t.contains('dussehra')) return '🏹';
    if (t.contains('janmashtami')) return '🦚';
    if (t.contains('ganesh')) return '🐘';
    if (t.contains('shivaratri')) return '🌙';
    if (t.contains('ram navami')) return '☀️';
    if (t.contains('hanuman')) return '🌟';
    if (t.contains('guru')) return '🙏';
    if (t.contains('vasant') || t.contains('saraswati')) return '🌸';
    if (t.contains('raksha')) return '🪷';
    if (t.contains('makar')) return '☀️';
    return '🎪';
  }
}

class _FestivalChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _FestivalChip({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.saffronGlow : context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.saffron : context.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body(
                size: 12,
                color: isActive ? AppColors.saffronDark : AppColors.ink3,
                weight: isActive ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
