import 'package:flutter/material.dart';

/// Design palette from Product Strategy v1.0
class AppColors {
  AppColors._();

  // Backgrounds
  static const stone = Color(0xFFF5F2ED);       // Temple Stone — scaffold bg
  static const stone2 = Color(0xFFEDE8E0);       // Card divider bg
  static const stone3 = Color(0xFFD8D0C4);       // Subtle borders

  // Primary accent — use sparingly for CTAs
  static const saffron = Color(0xFFE8820C);       // Deep Saffron — primary CTAs
  static const saffronDark = Color(0xFFC46A00);   // Accessible saffron for text on light
  static const saffronLight = Color(0xFFE8950F);  // Highlights
  static const saffronGlow = Color(0x1FE8820C);   // Saffron at ~12% opacity

  // Text hierarchy
  static const ink = Color(0xFF2C2420);           // Warm near-black — body text, titles
  static const ink2 = Color(0xFF4A4035);          // Secondary text
  static const ink3 = Color(0xFF8C8880);          // Temple Stone secondary — captions, metadata

  // Surfaces
  static const white = Color(0xFFFDFAF6);         // Sacred White — card backgrounds
  static const gold = Color(0xFFB8972A);          // Accent gold

  // Dark theme surfaces
  static const darkBg = Color(0xFF1A1614);        // Dark scaffold
  static const darkSurface = Color(0xFF2C2420);   // Dark card bg
  static const darkBorder = Color(0xFF3D3530);    // Dark borders
}
