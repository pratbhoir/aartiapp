import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/aarti_item.dart';
import '../../../data/models/verse_data.dart';

class FocusModeOverlay extends StatefulWidget {
  final AartiItem aarti;
  final List<VerseData> verses;
  final VoidCallback onClose;

  const FocusModeOverlay({
    super.key,
    required this.aarti,
    required this.verses,
    required this.onClose,
  });

  @override
  State<FocusModeOverlay> createState() => _FocusModeOverlayState();
}

class _FocusModeOverlayState extends State<FocusModeOverlay> {
  int _currentLineIdx = 0;
  late List<String> _allLines;

  @override
  void initState() {
    super.initState();
    _allLines = [];
    for (final v in widget.verses) {
      _allLines.addAll(v.lines);
    }
    if (_allLines.isEmpty) {
      _allLines = [widget.aarti.devanagari];
    }
  }

  void _nextLine() {
    if (_currentLineIdx < _allLines.length - 1) {
      setState(() => _currentLineIdx++);
    }
  }

  void _prevLine() {
    if (_currentLineIdx > 0) {
      setState(() => _currentLineIdx--);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show 4 lines: previous faded, current highlighted, next faded
    return GestureDetector(
      onTap: _nextLine,
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
          _nextLine();
        } else {
          _prevLine();
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
                          style: AppTextStyles.label(
                            size: 10,
                            color: AppColors.ink3,
                          ),
                        ),
                        Text(
                          widget.aarti.title,
                          style: AppTextStyles.body(
                            size: 13,
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${_currentLineIdx + 1} / ${_allLines.length}',
                          style: AppTextStyles.body(
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
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentLineIdx > 1)
                          _FocusLine(
                            text: _allLines[_currentLineIdx - 2],
                            opacity: 0.15,
                            size: 18,
                          ),
                        if (_currentLineIdx > 0)
                          _FocusLine(
                            text: _allLines[_currentLineIdx - 1],
                            opacity: 0.3,
                            size: 20,
                          ),
                        _FocusLine(
                          text: _allLines[_currentLineIdx],
                          opacity: 1.0,
                          size: 28,
                          isCurrent: true,
                        ),
                        if (_currentLineIdx < _allLines.length - 1)
                          _FocusLine(
                            text: _allLines[_currentLineIdx + 1],
                            opacity: 0.3,
                            size: 20,
                          ),
                        if (_currentLineIdx < _allLines.length - 2)
                          _FocusLine(
                            text: _allLines[_currentLineIdx + 2],
                            opacity: 0.15,
                            size: 18,
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
                  style: AppTextStyles.body(
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

class _FocusLine extends StatelessWidget {
  final String text;
  final double opacity;
  final double size;
  final bool isCurrent;

  const _FocusLine({
    required this.text,
    required this.opacity,
    required this.size,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: AppTextStyles.devanagari(
        size: size,
        color: isCurrent
            ? AppColors.saffronLight
            : AppColors.white.withValues(alpha: opacity),
      ).copyWith(height: 2.5),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
