import 'package:flutter/material.dart';

/// Supported application locales and helpers for persisted language codes.
abstract final class AppLocale {
  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');
  static const Locale gujarati = Locale('gu');

  static const List<Locale> supportedLocales = <Locale>[
    english,
    hindi,
    gujarati,
  ];

  static Locale fromLanguageCode(String code) {
    switch (code) {
      case 'hi':
        return hindi;
      case 'gu':
        return gujarati;
      case 'en':
      default:
        return english;
    }
  }
}