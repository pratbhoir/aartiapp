import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/aarti_item.dart';
import '../../../data/models/verse_data.dart';
import '../../../shared/utils/aarti_language_resolver.dart';

/// Full-screen distraction-free reading mode that advances one verse at a time.
class FocusModeOverlay extends StatefulWidget {
  final AartiItem aarti;
  final List<VerseData> verses;
  final int scriptMode;
  final VoidCallback onClose;

  const FocusModeOverlay({
    super.key,
    required this.aarti,
    required this.verses,
    required this.scriptMode,
    required this.onClose,
  });

  @override
  State<FocusModeOverlay> createState() => _FocusModeOverlayState();
}

class _FocusModeOverlayState extends State<FocusModeOverlay> {
  int _currentVerseIdx = 0;
  late List<VerseData> _displayVerses;

  @override
  void initState() {
    super.initState();
    _displayVerses = widget.verses.where((verse) => verse.lines.isNotEmpty).toList();
    if (_displayVerses.isEmpty) {
      final List<String> fallbackLines = widget.aarti.devanagari
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      _displayVerses = [
        VerseData(
          label: 'Verse',
          lines: fallbackLines.isEmpty ? [widget.aarti.title] : fallbackLines,
          transliteration: [widget.aarti.title],
          meanings: const [],
          gujarati: widget.aarti.gujarati.trim().isNotEmpty
              ? [widget.aarti.gujarati]
              : const [],
        ),
      ];
    }
  }

  void _nextVerse() {
    if (_currentVerseIdx < _displayVerses.length - 1) {
      setState(() => _currentVerseIdx++);
    }
  }

  void _prevVerse() {
    if (_currentVerseIdx > 0) {
      setState(() => _currentVerseIdx--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextVerse,
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
          _nextVerse();
        } else {
          _prevVerse();
        }
      },
      child: Container(
        color: AppColors.ink,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SADHANA MODE',
                          style: AppTypography.label(
                            size: 10,
                            color: AppColors.ink3,
                          ),
                        ),
                        Text(
                          widget.aarti.title,
                          style: AppTypography.body(
                            size: 13,
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${_currentVerseIdx + 1} / ${_displayVerses.length}',
                          style: AppTypography.body(
                              size: 11,
                              color: AppColors.white.withValues(alpha: 0.4)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.ink3, size: 20),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (_currentVerseIdx > 1)
                        //   _FocusVerse(
                        //     verse: _displayVerses[_currentVerseIdx - 2],
                        //     opacity: 0.15,
                        //     lineSize: 18,
                        //   ),
                        if (_currentVerseIdx > 0)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx - 1],
                            scriptMode: widget.scriptMode,
                            opacity: 0.3,
                            lineSize: 20,
                            lineVerticalPadding: AppSpacing.md,
                          ),
                        _FocusVerse(
                          verse: _displayVerses[_currentVerseIdx],
                          scriptMode: widget.scriptMode,
                          opacity: 1.0,
                          lineSize: 22,
                          lineVerticalPadding: AppSpacing.md,
                          isCurrent: true,
                        ),
                        if (_currentVerseIdx < _displayVerses.length - 1)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx + 1],
                            scriptMode: widget.scriptMode,
                            opacity: 0.3,
                            lineSize: 20,
                            lineVerticalPadding: AppSpacing.md,
                          ),
                        if (_currentVerseIdx < _displayVerses.length - 2)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx + 2],
                            scriptMode: widget.scriptMode,
                            opacity: 0.15,
                            lineSize: 18,
                            lineVerticalPadding: AppSpacing.sm,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hint
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Tap or swipe to advance',
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusVerse extends StatelessWidget {
  final VerseData verse;
  final int scriptMode;
  final double opacity;
  final double lineSize;
  final double lineVerticalPadding;
  final bool isCurrent;

  const _FocusVerse({
    required this.verse,
    required this.scriptMode,
    required this.opacity,
    required this.lineSize,
    required this.lineVerticalPadding,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isCurrent
        ? AppColors.saffronLight
        : AppColors.white.withValues(alpha: opacity);
    final displayedLines =
        AartiLanguageResolver.resolveLyricsLines(verse, scriptMode);
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    final TextStyle lineTextStyle = (script == AppScriptLanguage.english
            ? AppTypography.transliteration(
                size: lineSize,
                color: textColor,
              )
            : AppTypography.devanagari(
                size: lineSize,
                color: textColor,
              ))
        .copyWith(height: 1.5);
    final TextDirection textDirection = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> lineWidgets = <Widget>[];
        final bool shouldForceBalancedSplit = displayedLines.any(
          (line) => _shouldBalanceLine(
            line,
            style: lineTextStyle,
            maxWidth: constraints.maxWidth,
            textDirection: textDirection,
            textScaler: textScaler,
          ),
        );

        for (int index = 0; index < displayedLines.length; index++) {
          final List<String> renderedSegments = _balanceLine(
            displayedLines[index],
            style: lineTextStyle,
            maxWidth: constraints.maxWidth,
            textDirection: textDirection,
            textScaler: textScaler,
            forceSplit: shouldForceBalancedSplit,
          );

          lineWidgets.add(
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    index < displayedLines.length - 1 ? lineVerticalPadding : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: renderedSegments
                    .map(
                      (segment) => AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: lineTextStyle,
                        child: Text(
                          segment,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: lineWidgets,
          ),
        );
      },
    );
  }

  List<String> _balanceLine(
    String line, {
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
    bool forceSplit = false,
  }) {
    final String normalizedLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedLine.isEmpty || maxWidth <= 0 || maxWidth.isInfinite) {
      return [normalizedLine];
    }

    final List<String> words = normalizedLine.split(' ');
    if (words.length < 2) {
      return [normalizedLine];
    }

    final bool fitsOnSingleLine = _fitsOnSingleLine(
      normalizedLine,
      style: style,
      maxWidth: maxWidth,
      textDirection: textDirection,
      textScaler: textScaler,
    );
    if (!forceSplit && fitsOnSingleLine) {
      return [normalizedLine];
    }

    List<String>? bestSplit;
    double? bestScore;

    for (int splitIndex = 1; splitIndex < words.length; splitIndex++) {
      final String firstHalf = words.take(splitIndex).join(' ');
      final String secondHalf = words.skip(splitIndex).join(' ');

      if (!_fitsOnSingleLine(
            firstHalf,
            style: style,
            maxWidth: maxWidth,
            textDirection: textDirection,
            textScaler: textScaler,
          ) ||
          !_fitsOnSingleLine(
            secondHalf,
            style: style,
            maxWidth: maxWidth,
            textDirection: textDirection,
            textScaler: textScaler,
          )) {
        continue;
      }

      final double score = (_measureTextWidth(
                    firstHalf,
                    style: style,
                    textDirection: textDirection,
                    textScaler: textScaler,
                  ) -
                  _measureTextWidth(
                    secondHalf,
                    style: style,
                    textDirection: textDirection,
                    textScaler: textScaler,
                  ))
              .abs();

      if (bestScore == null || score < bestScore) {
        bestScore = score;
        bestSplit = [firstHalf, secondHalf];
      }
    }

    return bestSplit ?? [normalizedLine];
  }

  bool _shouldBalanceLine(
    String line, {
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final String normalizedLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedLine.isEmpty) {
      return false;
    }

    return !_fitsOnSingleLine(
      normalizedLine,
      style: style,
      maxWidth: maxWidth,
      textDirection: textDirection,
      textScaler: textScaler,
    );
  }

  bool _fitsOnSingleLine(
    String text, {
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    return !textPainter.didExceedMaxLines;
  }

  double _measureTextWidth(
    String text, {
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();

    return textPainter.width;
  }
}
