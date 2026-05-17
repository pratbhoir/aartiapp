import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/data/models/aarti_item.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/features/my_puja/puja_session_screen.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('PujaSessionScreen renders localized header and settings sheet', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'preferred_language': 'hi',
      'onboarding_completed': true,
      'auto_play': true,
      'repeat_current': true,
      'crossfade_duration': 2,
      'script_mode': 0,
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
          home: PujaSessionScreen(pujaAartis: const <AartiItem>[_sessionAarti]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('पूजा सत्र'), findsOneWidget);
    expect(find.text('1 में से 1'), findsOneWidget);
    expect(find.text('दोहराव'), findsOneWidget);
    expect(find.text('इस आरती के लिए ऑडियो उपलब्ध नहीं है।'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pumpAndSettle();

    expect(find.text('सत्र सेटिंग्स'), findsOneWidget);
    expect(find.text('अगली ऑटो-प्ले'), findsOneWidget);
    expect(find.text('वर्तमान दोहराएँ'), findsOneWidget);
    expect(find.text('क्रॉसफेड'), findsOneWidget);
    expect(find.text('आरतियों के बीच 2से का अंतर'), findsOneWidget);
  });
}

const AartiItem _sessionAarti = AartiItem(
  id: 'shiv_aarti',
  title: 'Om Jai Shiv Omkara',
  devanagari: 'ॐ जय शिव ओंकारा',
  gujarati: 'ૐ જય શિવ ઓમકારા',
  deity: 'Shiva',
  duration: '3:20',
  versesLabel: '2 verses',
);