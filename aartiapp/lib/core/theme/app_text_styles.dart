import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system using Google Fonts.
/// - Noto Serif Devanagari for Devanagari lyrics
/// - Lora for English serif text (titles, headings)
/// - Default sans-serif for UI labels and body
class AppTextStyles {
  AppTextStyles._();

  /// Large display heading (e.g., greeting)
  static TextStyle displayLarge(BuildContext ctx) => GoogleFonts.lora(
        fontSize: 36,
        fontWeight: FontWeight.w300,
        color: Theme.of(ctx).colorScheme.onSurface,
        height: 1.15,
        letterSpacing: -0.5,
      );

  /// Aarti title on detail screen
  static TextStyle scriptTitle(BuildContext ctx) => GoogleFonts.lora(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: Theme.of(ctx).colorScheme.onSurface,
        height: 1.2,
      );

  /// Devanagari lyrics — uses Noto Serif Devanagari
  static TextStyle devanagari({double size = 17, Color? color}) =>
      GoogleFonts.notoSerifDevanagari(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.ink3,
        height: 1.9,
      );

  /// Transliteration text — Lora italic
  static TextStyle transliteration({double size = 14, Color? color}) =>
      GoogleFonts.lora(
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: color ?? AppColors.ink3,
        height: 1.6,
      );

  /// Section labels and metadata
  static TextStyle label({double size = 10, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
        color: color ?? AppColors.ink3,
      );

  /// General body text
  static TextStyle body({double size = 13, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? AppColors.ink,
      );

  /// Serif body text using Lora
  static TextStyle serifBody({double size = 16, Color? color}) =>
      GoogleFonts.lora(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.ink,
        height: 1.3,
      );
}
