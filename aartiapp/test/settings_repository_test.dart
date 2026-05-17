import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/data/repositories/settings_repository.dart';

void main() {
  group('SettingsRepository preferred language seeding', () {
    test('seeds Hindi on first launch when device locale is supported', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'onboarding_completed': false,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsRepository repository = SettingsRepository(prefs);

      final String seeded = await repository.seedPreferredLanguageFromDeviceLocales(
        deviceLocales: const <Locale>[Locale('hi')],
      );

      expect(seeded, 'hi');
      expect(repository.getPreferredLanguage(), 'hi');
      expect(prefs.getString('preferred_language'), 'hi');
    });

    test('falls back to English for unsupported device locale', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'onboarding_completed': false,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsRepository repository = SettingsRepository(prefs);

      final String seeded = await repository.seedPreferredLanguageFromDeviceLocales(
        deviceLocales: const <Locale>[Locale('fr')],
      );

      expect(seeded, 'en');
      expect(repository.getPreferredLanguage(), 'en');
      expect(prefs.getString('preferred_language'), isNull);
    });

    test('does not override an explicit persisted preferred language', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'onboarding_completed': false,
        'preferred_language': 'en',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsRepository repository = SettingsRepository(prefs);

      final String seeded = await repository.seedPreferredLanguageFromDeviceLocales(
        deviceLocales: const <Locale>[Locale('gu')],
      );

      expect(seeded, 'en');
      expect(repository.getPreferredLanguage(), 'en');
      expect(prefs.getString('preferred_language'), 'en');
    });
  });
}