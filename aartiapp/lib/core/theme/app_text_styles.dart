import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge(BuildContext ctx) => const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 36,
        fontWeight: FontWeight.w300,
        color: AppColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle scriptTitle(BuildContext ctx) => const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.2,
      );

  static TextStyle devanagari({double size = 17, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: color ?? AppColors.ink3,
        height: 1.9,
      );

  static TextStyle label({double size = 10, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
        color: color ?? AppColors.ink3,
      );

  static TextStyle body({double size = 13, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w300,
        color: color ?? AppColors.ink,
      );
}
