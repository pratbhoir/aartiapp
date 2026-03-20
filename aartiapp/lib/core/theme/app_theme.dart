import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds ThemeData for Light, Dark, and System modes.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scaffoldBg: AppColors.stone,
        surface: AppColors.white,
        primary: AppColors.saffron,
        onPrimary: AppColors.white,
        textColor: AppColors.ink,
        secondaryText: AppColors.ink3,
        cardBorder: AppColors.stone2,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scaffoldBg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        primary: AppColors.saffronLight,
        onPrimary: AppColors.darkBg,
        textColor: AppColors.white,
        secondaryText: AppColors.ink3,
        cardBorder: AppColors.darkBorder,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color textColor,
    required Color secondaryText,
    required Color cardBorder,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.gold,
      onSecondary: AppColors.white,
      error: const Color(0xFFB3261E),
      onError: AppColors.white,
      surface: surface,
      onSurface: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.loraTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      splashColor: AppColors.saffronGlow,
      highlightColor: Colors.transparent,
      dividerColor: cardBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
