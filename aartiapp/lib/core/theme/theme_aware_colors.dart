import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Convenience extension that resolves the correct color
/// based on the current theme brightness (light / dark).
///
/// Usage:  `context.surface`, `context.textPrimary`, etc.
extension ThemeAwareColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  // ── backgrounds ──
  Color get scaffoldBg => _isDark ? AppColors.darkBg : AppColors.stone;
  Color get surface => _isDark ? AppColors.darkSurface : AppColors.white;

  // ── text ──
  Color get textPrimary => _isDark ? AppColors.white : AppColors.ink;
  Color get textSecondary => _isDark ? const Color(0xFFA8A29E) : AppColors.ink2;
  Color get textCaption => _isDark ? const Color(0xFF8C8880) : AppColors.ink3;

  // ── borders ──
  Color get border => _isDark ? AppColors.darkBorder : AppColors.stone2;
  Color get borderSubtle => _isDark ? AppColors.darkBorder : AppColors.stone3;
}
