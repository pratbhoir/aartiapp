import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/features/settings/settings_screen.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('SettingsScreen renders translated labels for Hindi', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'onboarding_completed': true,
      'preferred_language': 'hi',
      'user_name': 'Bhakt',
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('hi'),
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          home: SettingsScreen(onOpenDrawer: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ऐप भाषा'), findsOneWidget);
    expect(find.text('प्रदर्शित नाम'), findsOneWidget);
    expect(find.text('दैनिक पूजा स्मरण'), findsOneWidget);
    expect(find.text('प्रतिक्रिया भेजें'), findsOneWidget);
    expect(find.text('App Language'), findsNothing);
  });
}