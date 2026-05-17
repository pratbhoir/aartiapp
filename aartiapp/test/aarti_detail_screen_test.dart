import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/data/models/aarti_item.dart';
import 'package:aartiapp/data/models/verse_data.dart';
import 'package:aartiapp/data/repositories/bookmark_repository.dart';
import 'package:aartiapp/data/repositories/puja_repository.dart';
import 'package:aartiapp/data/repositories/user_aarti_repository.dart';
import 'package:aartiapp/features/aarti_detail/aarti_detail_screen.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets(
    'AartiDetailScreen renders localized reading labels and focus settings',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'preferred_language': 'hi',
        'onboarding_completed': true,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            sharedPrefsProvider.overrideWithValue(prefs),
            bookmarkRepoProvider.overrideWithValue(_TestBookmarkRepository()),
            pujaRepoProvider.overrideWithValue(_TestPujaRepository()),
            userAartiRepoProvider.overrideWithValue(_TestUserAartiRepository()),
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
            home: AartiDetailScreen(aarti: _sampleAarti),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('वापस'), findsOneWidget);
      expect(find.text('श्लोक 1 में से 2'), findsOneWidget);
      expect(find.text('ध्यान मोड'), findsOneWidget);
      expect(find.text('मंत्र काउंटर'), findsOneWidget);
      expect(find.text('साझा करें'), findsOneWidget);

      await tester.tap(find.text('मंत्र काउंटर'));
      await tester.pumpAndSettle();

      expect(find.text('गिनने के लिए टैप करें · 108 जप'), findsOneWidget);
      expect(find.text('॥ जप के लिए टैप करें ॥'), findsOneWidget);
      expect(find.text('काउंटर रीसेट करें'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ध्यान मोड'));
      await tester.pumpAndSettle();

      expect(find.text('आरती ध्यान मोड'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.tune_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('पठन सेटिंग्स'), findsOneWidget);
      expect(find.text('पठन सतह'), findsOneWidget);
      expect(find.text('पाठ आकार'), findsOneWidget);
    },
  );
}

class _TestBookmarkRepository extends BookmarkRepository {
  @override
  Set<String> getBookmarks() => <String>{};

  @override
  Future<bool> toggleBookmark(String aartiId) async => true;
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
  @override
  List<AartiItem> getAll() => const <AartiItem>[];

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
  verses: <VerseData>[
    VerseData(
      label: 'Verse 1',
      lines: <String>['ॐ जय शिव ओंकारा'],
      transliteration: <String>['Om Jai Shiv Omkara'],
      meanings: <String>['Praise to Shiva, the primordial sound.'],
      gujarati: <String>['ૐ જય શિવ ઓમકારા'],
    ),
    VerseData(
      label: 'Verse 2',
      lines: <String>['स्वामी जय शिव ओंकारा'],
      transliteration: <String>['Swami Jai Shiv Omkara'],
      meanings: <String>['Glory to Shiva, revered Lord.'],
      gujarati: <String>['સ્વામી જય શિવ ઓમકારા'],
    ),
  ],
);