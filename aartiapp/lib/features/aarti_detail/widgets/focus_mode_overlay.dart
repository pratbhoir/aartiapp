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
  final double textScale;
  final String appLanguageCode;
  final AartiDetailContentMode contentMode;
  final VoidCallback onClose;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onPreviousAarti;
  final VoidCallback? onNextAarti;
  final VoidCallback? onComplete;
  final String? previousAartiTitle;
  final String? nextAartiTitle;
  final String headerLabel;
  final bool useSessionHeaderLayout;
  final String? progressLabel;
  final String? completionLabel;
  final int? sessionIndex;
  final int? sessionCount;

  const FocusModeOverlay({
    super.key,
    required this.aarti,
    required this.verses,
    required this.scriptMode,
    this.textScale = 1.0,
    this.appLanguageCode = 'en',
    this.contentMode = AartiDetailContentMode.lyrics,
    required this.onClose,
    this.onOpenSettings,
    this.onPreviousAarti,
    this.onNextAarti,
    this.onComplete,
    this.previousAartiTitle,
    this.nextAartiTitle,
    this.headerLabel = 'SADHANA MODE',
    this.useSessionHeaderLayout = false,
    this.progressLabel,
    this.completionLabel,
    this.sessionIndex,
    this.sessionCount,
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
    _displayVerses = _buildDisplayVerses();
  }

  @override
  void didUpdateWidget(covariant FocusModeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aarti.id != widget.aarti.id) {
      setState(() {
        _displayVerses = _buildDisplayVerses();
        _currentVerseIdx = 0;
      });
      return;
    }

    if (oldWidget.contentMode != widget.contentMode ||
        oldWidget.scriptMode != widget.scriptMode ||
        oldWidget.appLanguageCode != widget.appLanguageCode) {
      setState(() {
        _displayVerses = _buildDisplayVerses();
        _currentVerseIdx = _currentVerseIdx.clamp(0, _displayVerses.length - 1);
      });
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

  List<VerseData> _buildDisplayVerses() {
    final List<VerseData> verses = widget.verses
        .where((verse) => _resolveDisplayLines(verse).isNotEmpty)
        .toList();
    if (verses.isNotEmpty) {
      return verses;
    }

    final List<String> fallbackLines = widget.aarti.devanagari
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final String fallbackTitle = AartiLanguageResolver.resolveAartiTitle(
      widget.aarti,
      widget.scriptMode,
    );
    return [
      VerseData(
        label: _contentModeLabel(widget.contentMode),
        lines: fallbackLines.isEmpty ? [fallbackTitle] : fallbackLines,
        transliteration: [widget.aarti.title],
        meanings: widget.contentMode == AartiDetailContentMode.meaning
            ? [widget.aarti.title]
            : const [],
        gujarati: widget.aarti.gujarati.trim().isNotEmpty
            ? [widget.aarti.gujarati]
            : const [],
      ),
    ];
  }

  List<String> _resolveDisplayLines(VerseData verse) {
    switch (widget.contentMode) {
      case AartiDetailContentMode.lyrics:
        return AartiLanguageResolver.resolveLyricsLines(
          verse,
          widget.scriptMode,
        );
      case AartiDetailContentMode.transliteration:
        return AartiLanguageResolver.resolveTransliterationLines(verse);
      case AartiDetailContentMode.meaning:
        return AartiLanguageResolver.resolveMeaningLines(
          verse,
          widget.appLanguageCode,
        );
    }
  }

  String _contentModeLabel(AartiDetailContentMode mode) {
    switch (mode) {
      case AartiDetailContentMode.lyrics:
        return 'Lyrics';
      case AartiDetailContentMode.transliteration:
        return 'Transliteration';
      case AartiDetailContentMode.meaning:
        return 'Meaning';
    }
  }

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
    final String verseProgressLabel =
        '${_currentVerseIdx + 1} / ${_displayVerses.length}';

    return Container(
      color: AppColors.ink,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: widget.useSessionHeaderLayout
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SessionHeaderButton(
                          icon: Icons.close,
                          onTap: widget.onClose,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.headerLabel,
                                style: AppTypography.label(
                                  size: 10,
                                  color: AppColors.saffronLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget.aarti.title,
                                style: AppTypography.body(
                                  size: 12,
                                  color: AppColors.white.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        widget.onOpenSettings != null
                            ? _SessionHeaderButton(
                                icon: Icons.tune_outlined,
                                onTap: widget.onOpenSettings!,
                              )
                            : const SizedBox(width: 44, height: 44),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.headerLabel,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.progressLabel != null)
                                  Text(
                                    widget.progressLabel!,
                                    style: AppTypography.body(
                                      size: 11,
                                      color: AppColors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                Text(
                                  verseProgressLabel,
                                  style: AppTypography.body(
                                    size: 11,
                                    color: AppColors.white.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.onOpenSettings != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.tune_outlined,
                                  color: AppColors.ink3,
                                  size: 20,
                                ),
                                onPressed: widget.onOpenSettings,
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
            if (widget.useSessionHeaderLayout && widget.progressLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  widget.progressLabel!,
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.useSessionHeaderLayout &&
                widget.sessionIndex != null &&
                widget.sessionCount != null &&
                widget.sessionCount! > 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.huge,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.sessionCount!, (index) {
                    final bool isCurrent = index == widget.sessionIndex;
                    final bool isCompleted = index < widget.sessionIndex!;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 24 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.saffron
                            : isCompleted
                            ? AppColors.saffron.withValues(alpha: 0.4)
                            : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
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
                            contentMode: widget.contentMode,
                            scriptMode: widget.scriptMode,
                            appLanguageCode: widget.appLanguageCode,
                            textScale: widget.textScale,
                            opacity: 0.3,
                            lineSize: 20,
                            lineVerticalPadding: AppSpacing.md,
                          ),
                        _FocusVerse(
                          key: _currentVerseKey,
                          verse: _displayVerses[_currentVerseIdx],
                          contentMode: widget.contentMode,
                          scriptMode: widget.scriptMode,
                          appLanguageCode: widget.appLanguageCode,
                          textScale: widget.textScale,
                          opacity: 1.0,
                          lineSize: 22,
                          lineVerticalPadding: AppSpacing.md,
                          isCurrent: true,
                        ),
                        if (_currentVerseIdx < _displayVerses.length - 1)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx + 1],
                            contentMode: widget.contentMode,
                            scriptMode: widget.scriptMode,
                            appLanguageCode: widget.appLanguageCode,
                            textScale: widget.textScale,
                            opacity: 0.3,
                            lineSize: 20,
                            lineVerticalPadding: AppSpacing.md,
                          ),
                        if (_currentVerseIdx < _displayVerses.length - 2)
                          _FocusVerse(
                            verse: _displayVerses[_currentVerseIdx + 2],
                            contentMode: widget.contentMode,
                            scriptMode: widget.scriptMode,
                            appLanguageCode: widget.appLanguageCode,
                            textScale: widget.textScale,
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
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLastVerse && widget.onNextAarti != null) {
      return _FocusModeNextButton(
        label:
            widget.nextAartiTitle == null ||
                widget.nextAartiTitle!.trim().isEmpty
            ? 'Next Aarti'
            : 'Next: ${widget.nextAartiTitle!}',
        onTap: widget.onNextAarti!,
      );
    }

    if (_isLastVerse && widget.onComplete != null) {
      return _FocusModeNextButton(
        label: widget.completionLabel ?? 'Complete Session',
        onTap: widget.onComplete!,
      );
    }

    if (_currentVerseIdx == 0 && widget.onPreviousAarti != null) {
      return _FocusModeSecondaryButton(
        label:
            widget.previousAartiTitle == null ||
                widget.previousAartiTitle!.trim().isEmpty
            ? 'Previous Aarti'
            : 'Previous: ${widget.previousAartiTitle!}',
        onTap: widget.onPreviousAarti!,
        icon: Icons.skip_previous_rounded,
      );
    }

    return Text(
      _currentVerseIdx > 0
          ? 'Tap above for previous, tap on or below the highlighted verse for next'
          : 'Tap on or below the highlighted verse to advance',
      style: AppTypography.body(
        size: 12,
        color: AppColors.white.withValues(alpha: 0.25),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SessionHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SessionHeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: AppColors.ink3),
      ),
    );
  }
}

class _FocusVerse extends StatelessWidget {
  final VerseData verse;
  final AartiDetailContentMode contentMode;
  final int scriptMode;
  final String appLanguageCode;
  final double textScale;
  final double opacity;
  final double lineSize;
  final double lineVerticalPadding;
  final bool isCurrent;

  const _FocusVerse({
    super.key,
    required this.verse,
    required this.contentMode,
    required this.scriptMode,
    required this.appLanguageCode,
    required this.textScale,
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
    final displayedLines = _resolveDisplayLines();
    final TextStyle lineTextStyle = _lineTextStyle(textColor);
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

  List<String> _resolveDisplayLines() {
    switch (contentMode) {
      case AartiDetailContentMode.lyrics:
        return AartiLanguageResolver.resolveLyricsLines(verse, scriptMode);
      case AartiDetailContentMode.transliteration:
        return AartiLanguageResolver.resolveTransliterationLines(verse);
      case AartiDetailContentMode.meaning:
        return AartiLanguageResolver.resolveMeaningLines(
          verse,
          appLanguageCode,
        );
    }
  }

  TextStyle _lineTextStyle(Color textColor) {
    switch (contentMode) {
      case AartiDetailContentMode.lyrics:
        final script = AartiLanguageResolver.scriptFromMode(scriptMode);
        final baseStyle = script == AppScriptLanguage.english
            ? AppTypography.transliteration(
                size: lineSize * textScale,
                color: textColor,
              )
            : AppTypography.devanagari(
                size: lineSize * textScale,
                color: textColor,
              );
        return baseStyle.copyWith(height: 1.5);
      case AartiDetailContentMode.transliteration:
        return AppTypography.transliteration(
          size: lineSize * textScale,
          color: textColor,
        ).copyWith(height: 1.5);
      case AartiDetailContentMode.meaning:
        return AppTypography.body(
          size: lineSize * textScale,
          color: textColor,
          weight: FontWeight.w400,
        ).copyWith(height: 1.6);
    }
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

class _FocusModeSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const _FocusModeSecondaryButton({
    required this.label,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open previous aarti in sequence',
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
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 13, color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
