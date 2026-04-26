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
  final VoidCallback? onNextAarti;
  final String? nextAartiTitle;

  const FocusModeOverlay({
    super.key,
    required this.aarti,
    required this.verses,
    required this.scriptMode,
    required this.onClose,
    this.onNextAarti,
    this.nextAartiTitle,
  });

  @override
  State<FocusModeOverlay> createState() => _FocusModeOverlayState();
}

class _FocusModeOverlayState extends State<FocusModeOverlay> {
  int _currentVerseIdx = 0;
  late List<VerseData> _displayVerses;
  final GlobalKey _contentAreaKey = GlobalKey();
  final GlobalKey _currentVerseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _displayVerses = widget.verses
        .where((verse) => verse.lines.isNotEmpty)
        .toList();
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

  bool get _isLastVerse => _currentVerseIdx >= _displayVerses.length - 1;

  void _handleTapDown(TapDownDetails details) {
    final double verseCenterY = _resolveCurrentVerseCenterY();
    if (details.globalPosition.dy < verseCenterY) {
      _prevVerse();
      return;
    }

    _nextVerse();
  }

  double _resolveCurrentVerseCenterY() {
    final BuildContext? verseContext = _currentVerseKey.currentContext;
    if (verseContext != null) {
      final RenderBox? verseBox = verseContext.findRenderObject() as RenderBox?;
      if (verseBox != null && verseBox.hasSize) {
        final Offset verseTopLeft = verseBox.localToGlobal(Offset.zero);
        return verseTopLeft.dy + (verseBox.size.height / 2);
      }
    }

    final BuildContext? contentContext = _contentAreaKey.currentContext;
    if (contentContext != null) {
      final RenderBox? contentBox =
          contentContext.findRenderObject() as RenderBox?;
      if (contentBox != null && contentBox.hasSize) {
        final Offset contentTopLeft = contentBox.localToGlobal(Offset.zero);
        return contentTopLeft.dy + (contentBox.size.height / 2);
      }
    }

    return MediaQuery.sizeOf(context).height / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
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
                          color: AppColors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.ink3,
                          size: 20,
                        ),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                key: _contentAreaKey,
                behavior: HitTestBehavior.opaque,
                onTapDown: _handleTapDown,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 0) {
                    _nextVerse();
                  } else {
                    _prevVerse();
                  }
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lgWide,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentVerseIdx > 0)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx - 1],
                            scriptMode: widget.scriptMode,
                            opacity: 0.3,
                            lineSize: 20,
                            lineVerticalPadding: AppSpacing.md,
                          ),
                        _FocusVerse(
                          key: _currentVerseKey,
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              child: _isLastVerse && widget.onNextAarti != null
                  ? _FocusModeNextButton(
                      label:
                          widget.nextAartiTitle == null ||
                              widget.nextAartiTitle!.trim().isEmpty
                          ? 'Next Aarti'
                          : 'Next: ${widget.nextAartiTitle!}',
                      onTap: widget.onNextAarti!,
                    )
                  : Text(
                      _currentVerseIdx > 0
                          ? 'Tap above for previous, tap on or below the highlighted verse for next'
                          : 'Tap on or below the highlighted verse to advance',
                      style: AppTypography.body(
                        size: 12,
                        color: AppColors.white.withValues(alpha: 0.25),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ],
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
    super.key,
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
    final displayedLines = AartiLanguageResolver.resolveLyricsLines(
      verse,
      scriptMode,
    );
    final script = AartiLanguageResolver.scriptFromMode(scriptMode);
    final TextStyle lineTextStyle =
        (script == AppScriptLanguage.english
                ? AppTypography.transliteration(
                    size: lineSize,
                    color: textColor,
                  )
                : AppTypography.devanagari(size: lineSize, color: textColor))
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
                bottom: index < displayedLines.length - 1
                    ? lineVerticalPadding
                    : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: renderedSegments
                    .map(
                      (segment) => AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: lineTextStyle,
                        child: Text(segment, textAlign: TextAlign.center),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(mainAxisSize: MainAxisSize.min, children: lineWidgets),
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

      final double score =
          (_measureTextWidth(
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

class _FocusModeNextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FocusModeNextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open next aarti in sequence',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.saffronLight,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(color: AppColors.saffronLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 13, color: AppColors.darkBg),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.skip_next_rounded,
                size: 18,
                color: AppColors.darkBg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
