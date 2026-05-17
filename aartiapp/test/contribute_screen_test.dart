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
import 'package:aartiapp/features/contribute/contribute_screen.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('ContributeScreen renders localized labels and validation copy', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final _TestUserAartiRepository userRepo = _TestUserAartiRepository();
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'preferred_language': 'hi',
      'onboarding_completed': true,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPrefsProvider.overrideWithValue(prefs),
          pujaRepoProvider.overrideWithValue(_TestPujaRepository()),
          userAartiRepoProvider.overrideWithValue(userRepo),
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
          home: Scaffold(body: ContributeScreen(onOpenDrawer: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('मेरा संग्रह'), findsNWidgets(2));
    expect(find.text('निजी संग्रह'), findsOneWidget);

    await tester.tap(find.text('नई आरती जोड़ें'));
    await tester.pumpAndSettle();

    expect(find.text('देवता का नाम'), findsOneWidget);
    expect(find.text('आरती शीर्षक (अंग्रेज़ी)'), findsOneWidget);
    expect(find.text('गीत (देवनागरी)'), findsOneWidget);

    final Finder saveButton = find.widgetWithText(
      ElevatedButton,
      'मेरे संग्रह में सहेजें',
    );
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('कृपया कम से कम देवता और शीर्षक भरें।'), findsOneWidget);
  });

  testWidgets('ContributeScreen shows localized success snackbar after save', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final _TestUserAartiRepository userRepo = _TestUserAartiRepository();
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'preferred_language': 'hi',
      'onboarding_completed': true,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPrefsProvider.overrideWithValue(prefs),
          pujaRepoProvider.overrideWithValue(_TestPujaRepository()),
          userAartiRepoProvider.overrideWithValue(userRepo),
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
          home: Scaffold(body: ContributeScreen(onOpenDrawer: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('नई आरती जोड़ें'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Shiva');
    await tester.enterText(find.byType(TextFormField).at(1), 'Om Jai Shiv Omkara');
    final Finder saveButton = find.widgetWithText(
      ElevatedButton,
      'मेरे संग्रह में सहेजें',
    );
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('आरती आपके संग्रह में सहेज दी गई! 🙏'), findsOneWidget);
  });
}

class _TestPujaRepository extends PujaRepository {
  @override
  List<String> getPujaOrder() => const <String>[];

  @override
  Future<void> savePujaOrder(List<String> aartiIds) async {}

  @override
  Future<void> addToPuja(String aartiId) async {}

  @override
  Future<void> removeFromPuja(String aartiId) async {}
}

class _TestUserAartiRepository extends UserAartiRepository {
  final List<AartiItem> _aartis = <AartiItem>[];

  @override
  List<AartiItem> getAll() => List<AartiItem>.from(_aartis);

  @override
  Future<String> save(AartiItem aarti) async {
    final AartiItem saved = aarti.copyWith(id: aarti.id.isEmpty ? 'user_1' : aarti.id);
    _aartis.removeWhere((item) => item.id == saved.id);
    _aartis.add(saved);
    return saved.id;
  }

  @override
  Future<void> delete(String id) async {
    _aartis.removeWhere((item) => item.id == id);
  }
}