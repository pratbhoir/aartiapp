import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/verse_data.dart';

class VerseBlock extends StatelessWidget {
  final VerseData verse;
  final bool isFirst;
  final int viewMode;
  final double textScale;

  const VerseBlock({
    super.key,
    required this.verse,
    required this.isFirst,
    required this.viewMode,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(verse.label, style: AppTextStyles.label()),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: AppColors.stone3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(verse.lines.length, (i) {
            final isHighlighted = isFirst && i == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main line (lyrics — Devanagari)
                  if (viewMode == 0)
                    Container(
                      padding: isHighlighted
                          ? const EdgeInsets.only(left: 12)
                          : EdgeInsets.zero,
                      decoration: isHighlighted
                          ? const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    color: AppColors.saffron, width: 2),
                              ),
                            )
                          : null,
                      child: Text(
                        verse.lines[i],
                        style: AppTextStyles.devanagari(
                          size: 18 * textScale,
                          color: isHighlighted
                              ? AppColors.saffron
                              : AppColors.ink,
                        ),
                      ),
                    ),

                  // Transliteration (Roman)
                  if (viewMode == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(verse.lines[i],
                            style: AppTextStyles.devanagari(
                              size: 18 * textScale,
                              color: AppColors.ink,
                            )),
                        if (i < verse.transliteration.length)
                        Text(
                          verse.transliteration[i],
                          style: AppTextStyles.transliteration(
                            size: 14 * textScale,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),

                  // Meaning
                  if (viewMode == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(verse.lines[i],
                            style: AppTextStyles.devanagari(
                              size: 18 * textScale,
                              color: AppColors.ink,
                            )),
                        if (i < verse.meanings.length) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.stone2,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              left: BorderSide(
                                  color: AppColors.saffronLight, width: 2),
                            ),
                          ),
                          child: Text(
                            verse.meanings[i],
                            style: AppTextStyles.body(
                                size: 13 * textScale, color: AppColors.ink3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ],
                      ],
                    ),

                  // Gujarati script
                  if (viewMode == 3)
                    Container(
                      padding: isHighlighted
                          ? const EdgeInsets.only(left: 12)
                          : EdgeInsets.zero,
                      decoration: isHighlighted
                          ? const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    color: AppColors.saffron, width: 2),
                              ),
                            )
                          : null,
                      child: Text(
                        (verse.gujarati.isNotEmpty && i < verse.gujarati.length)
                            ? verse.gujarati[i]
                            : verse.lines[i], // fallback to Devanagari
                        style: AppTextStyles.devanagari(
                          size: 18 * textScale,
                          color: isHighlighted
                              ? AppColors.saffron
                              : AppColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
