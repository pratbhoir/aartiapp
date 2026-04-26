import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/utils/aarti_language_resolver.dart';
import '../../../data/models/verse_data.dart';

class VerseBlock extends StatelessWidget {
  final VerseData verse;
  final bool isFirst;
  final AartiDetailContentMode contentMode;
  final int scriptMode;
  final String appLanguageCode;
  final double textScale;

  const VerseBlock({
    super.key,
    required this.verse,
    required this.isFirst,
    required this.contentMode,
    required this.scriptMode,
    required this.appLanguageCode,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final lyricsLines = AartiLanguageResolver.resolveLyricsLines(verse, scriptMode);
    final transliterationLines =
        AartiLanguageResolver.resolveTransliterationLines(verse);
    final meaningLines =
        AartiLanguageResolver.resolveMeaningLines(verse, appLanguageCode);
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    final lyricsTextStyle = script == AppScriptLanguage.english
        ? AppTypography.transliteration(size: 18 * textScale, color: AppColors.ink)
        : AppTypography.devanagari(size: 18 * textScale, color: AppColors.ink);
    final highlightedLyricsTextStyle = script == AppScriptLanguage.english
        ? AppTypography.transliteration(
            size: 18 * textScale,
            color: AppColors.saffron,
          )
        : AppTypography.devanagari(
            size: 18 * textScale,
            color: AppColors.saffron,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(verse.label, style: AppTypography.label()),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: AppColors.stone3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(lyricsLines.length, (i) {
            final isHighlighted = isFirst && i == 0;
            final lyricLine = i < lyricsLines.length ? lyricsLines[i] : '';
            final transliterationLine =
                i < transliterationLines.length ? transliterationLines[i] : lyricLine;
            final meaningLine = i < meaningLines.length ? meaningLines[i] : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contentMode == AartiDetailContentMode.lyrics)
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
                        lyricLine,
                        style: isHighlighted
                            ? highlightedLyricsTextStyle
                            : lyricsTextStyle,
                      ),
                    ),

                  if (contentMode == AartiDetailContentMode.transliteration)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lyricLine, style: lyricsTextStyle),
                        if (transliterationLine.isNotEmpty)
                          Text(
                            transliterationLine,
                            style: AppTypography.transliteration(
                              size: 14 * textScale,
                              color: AppColors.ink3,
                            ),
                          ),
                      ],
                    ),

                  if (contentMode == AartiDetailContentMode.meaning)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lyricLine, style: lyricsTextStyle),
                        if (meaningLine.isNotEmpty) ...[
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
                              meaningLine,
                              style: AppTypography.body(
                                size: 13 * textScale,
                                color: AppColors.ink3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
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
