import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_aware_colors.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_outlined, size: 18, color: AppColors.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppTextStyles.body(size: 14),
              decoration: InputDecoration(
                hintText: 'Search deity, Aarti, or festival…',
                hintStyle: AppTextStyles.body(size: 14, color: AppColors.ink3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
