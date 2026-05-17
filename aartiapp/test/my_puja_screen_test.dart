import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/data/models/aarti_item.dart';
import 'package:aartiapp/data/repositories/puja_repository.dart';
import 'package:aartiapp/data/repositories/user_aarti_repository.dart';
import 'package:aartiapp/features/my_puja/my_puja_screen.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('MyPujaScreen renders localized summary and actions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'preferred_language': 'hi',
      'onboarding_completed': true,
      'auto_play': true,
      'repeat_current': false,
      'crossfade_duration': 2,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPrefsProvider.overrideWithValue(prefs),
          pujaRepoProvider.overrideWithValue(
            _TestPujaRepository(<String>['shiv_aarti']),
          ),
          userAartiRepoProvider.overrideWithValue(
            _TestUserAartiRepository(<AartiItem>[_sampleAarti]),
          ),
        ],
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
          home: MyPujaScreen(onOpenDrawer: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('मेरी दैनिक पूजा'), findsNWidgets(2));
    expect(find.text('1 आरतियाँ · अनुमानित 3 मिनट'), findsOneWidget);
    expect(find.text('आरतियाँ चलाएँ'), findsOneWidget);
    expect(find.text('आरतियाँ पढ़ें'), findsOneWidget);
    expect(find.text('ऑटो-प्ले चालू'), findsOneWidget);
    expect(find.text('क्रॉसफेड 2से'), findsOneWidget);
  });

  testWidgets('MyPujaScreen renders localized empty state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'preferred_language': 'hi',
      'onboarding_completed': true,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPrefsProvider.overrideWithValue(prefs),
          pujaRepoProvider.overrideWithValue(_TestPujaRepository(const <String>[])),
          userAartiRepoProvider.overrideWithValue(
            _TestUserAartiRepository(const <AartiItem>[]),
          ),
        ],
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
          home: MyPujaScreen(onOpenDrawer: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('आपकी दैनिक पूजा खाली है'), findsOneWidget);
    expect(
      find.text('अपनी दैनिक पूजा सूची बनाने के लिए\nखोज टैब से आरतियाँ बुकमार्क करें।'),
      findsOneWidget,
    );
  });
}

class _TestPujaRepository extends PujaRepository {
  _TestPujaRepository(this._ids);

  final List<String> _ids;

  @override
  List<String> getPujaOrder() => List<String>.from(_ids);

  @override
  Future<void> savePujaOrder(List<String> aartiIds) async {}

  @override
  Future<void> addToPuja(String aartiId) async {}

  @override
  Future<void> removeFromPuja(String aartiId) async {}
}

class _TestUserAartiRepository extends UserAartiRepository {
  _TestUserAartiRepository(this._aartis);

  final List<AartiItem> _aartis;

  @override
  List<AartiItem> getAll() => _aartis;

  @override
  Future<String> save(AartiItem aarti) async => aarti.id;

  @override
  Future<void> delete(String id) async {}
}

const AartiItem _sampleAarti = AartiItem(
  id: 'shiv_aarti',
  title: 'Om Jai Shiv Omkara',
  devanagari: 'ॐ जय शिव ओंकारा',
  gujarati: 'ૐ જય શિવ ઓમકારા',
  deity: 'Shiva',
  duration: '3:20',
  versesLabel: '2 verses',
);