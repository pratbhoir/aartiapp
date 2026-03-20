import 'package:flutter/services.dart';

/// Scoped haptic feedback definitions per Product Strategy.
/// - lightImpact: page transitions
/// - mediumImpact: mantra tap
/// - selectionClick: bookmark toggle
class AppHaptics {
  AppHaptics._();

  /// Page transitions, tab switches
  static void pageTransition() => HapticFeedback.lightImpact();

  /// Mantra counter tap
  static void mantraTap() => HapticFeedback.mediumImpact();

  /// Bookmark toggle, chip selection
  static void selection() => HapticFeedback.selectionClick();

  /// Mantra cycle completion (108, etc.)
  static void completion() => HapticFeedback.heavyImpact();

  /// Drag-to-reorder feedback
  static void reorder() => HapticFeedback.selectionClick();
}
