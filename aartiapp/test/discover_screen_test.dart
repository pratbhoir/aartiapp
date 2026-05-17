import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/data/repositories/aarti_repository.dart';
import 'package:aartiapp/data/repositories/bookmark_repository.dart';
import 'package:aartiapp/data/repositories/puja_repository.dart';
import 'package:aartiapp/features/discover/discover_screen.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('DiscoverScreen renders localized labels and empty state', (
    WidgetTester tester,
  ) async {
    AartiRepository.instance.loadFromJsonString(_catalogFixture);
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
          home: DiscoverScreen(onOpenDrawer: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('खोज'), findsOneWidget);
    expect(find.text('देवता के अनुसार देखें'), findsOneWidget);
    expect(find.text('पर्व के अनुसार फ़िल्टर करें'), findsOneWidget);
    expect(find.text('4 मिले'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('कोई आरती नहीं मिली'), findsOneWidget);
  });
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

const String _catalogFixture = '''
{
  "version": 1,
  "deities": [
    {
      "emoji": "🕉️",
      "label": "All"
    },
    {
      "emoji": "🐘",
      "label": "Ganesha"
    },
    {
      "emoji": "🌙",
      "label": "Shiva"
    },
    {
      "emoji": "🌺",
      "label": "Durga"
    },
    {
      "emoji": "🌸",
      "label": "Saraswati"
    }
  ],
  "aartis": [
    {
      "id": "ganpati_aarti",
      "title": "Ganpati Aarti",
      "devanagari": "गणपति आरती",
      "deity": "Ganesha",
      "duration": "4:00",
      "audioUrl": "https://example.com/ganpati-aarti.mp3",
      "tags": ["Ganpati"],
      "festivalTags": ["Ganesh Chaturthi"],
      "verses": []
    },
    {
      "id": "shiv_aarti",
      "title": "Om Jai Shiv Omkara",
      "devanagari": "ॐ जय शिव ओंकारा",
      "deity": "Shiva",
      "duration": "7:32",
      "tags": ["Somvar"],
      "festivalTags": ["Maha Shivaratri"],
      "verses": []
    },
    {
      "id": "durga_aarti",
      "title": "Jai Ambe Gauri",
      "devanagari": "जय अम्बे गौरी",
      "deity": "Durga",
      "duration": "5:15",
      "tags": ["Shakti"],
      "festivalTags": ["Navratri"],
      "verses": []
    },
    {
      "id": "saraswati_vandana",
      "title": "Jai Saraswati Mata",
      "devanagari": "जय सरस्वती माता",
      "deity": "Saraswati",
      "duration": "2:10",
      "tags": ["Vasant Panchami"],
      "festivalTags": ["Vasant Panchami"],
      "verses": []
    }
  ]
}
''';