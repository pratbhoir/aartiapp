import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/l10n/app_locale.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/data/models/aarti_item.dart';
import 'package:aartiapp/data/repositories/aarti_repository.dart';
import 'package:aartiapp/data/repositories/bookmark_repository.dart';
import 'package:aartiapp/data/repositories/festival_repository.dart';
import 'package:aartiapp/data/repositories/puja_repository.dart';
import 'package:aartiapp/data/repositories/recently_played_repository.dart';
import 'package:aartiapp/data/repositories/user_aarti_repository.dart';
import 'package:aartiapp/features/contribute/contribute_screen.dart';
import 'package:aartiapp/features/discover/discover_screen.dart';
import 'package:aartiapp/features/home/home_screen.dart';
import 'package:aartiapp/features/my_puja/my_puja_screen.dart';
import 'package:aartiapp/features/settings/settings_screen.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'package:aartiapp/navigation/home_shell.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'user_name': 'Pratik',
      'preferred_language': 'en',
      'onboarding_completed': true,
      'auto_play': true,
      'repeat_current': false,
      'crossfade_duration': 2,
    });
    AartiRepository.instance.loadFromJsonString(_aartiCatalogFixture);
    FestivalRepository.instance.loadFromJsonString(_festivalCatalogFixture);
  });

  testWidgets('HomeShell back from secondary tabs returns to Home', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(await _buildHomeShellHarness());
    await _pumpShell(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(_rootPlaceholderText), findsNothing);

    final List<({String tabLabel, Type screenType})> navCases =
        <({String tabLabel, Type screenType})>[
          (tabLabel: 'Discover', screenType: DiscoverScreen),
          (tabLabel: 'My Puja', screenType: MyPujaScreen),
          (tabLabel: 'Collection', screenType: ContributeScreen),
          (tabLabel: 'Settings', screenType: SettingsScreen),
        ];

    for (final navCase in navCases) {
      await tester.tap(find.text(navCase.tabLabel).last);
      await _pumpShell(tester);

      expect(find.byType(navCase.screenType), findsOneWidget);

      await tester.binding.handlePopRoute();
      await _pumpShell(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(_rootPlaceholderText), findsNothing);
    }
  });

  testWidgets('HomeShell back from Home pops the shell route', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(await _buildHomeShellHarness());
    await _pumpShell(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(_rootPlaceholderText), findsNothing);

    await tester.binding.handlePopRoute();
    await _pumpShell(tester);

    expect(find.text(_rootPlaceholderText), findsOneWidget);
  });
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<Widget> _buildHomeShellHarness() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: <Override>[
      sharedPrefsProvider.overrideWithValue(prefs),
      bookmarkRepoProvider.overrideWithValue(_FakeBookmarkRepository()),
      pujaRepoProvider.overrideWithValue(_FakePujaRepository()),
      recentlyPlayedRepoProvider.overrideWithValue(
        _FakeRecentlyPlayedRepository(const <String>[]),
      ),
      userAartiRepoProvider.overrideWithValue(_FakeUserAartiRepository()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      initialRoute: '/shell',
      routes: <String, WidgetBuilder>{
        '/': (_) => const Scaffold(
          body: Center(child: Text(_rootPlaceholderText)),
        ),
        '/shell': (_) => const HomeShell(),
      },
    ),
  );
}

class _FakeBookmarkRepository extends BookmarkRepository {
  @override
  Set<String> getBookmarks() => <String>{};

  @override
  Future<bool> toggleBookmark(String aartiId) async => true;
}

class _FakePujaRepository extends PujaRepository {
  @override
  List<String> getPujaOrder() => const <String>[];

  @override
  Future<void> savePujaOrder(List<String> aartiIds) async {}

  @override
  Future<void> addToPuja(String aartiId) async {}

  @override
  Future<void> removeFromPuja(String aartiId) async {}
}

class _FakeRecentlyPlayedRepository extends RecentlyPlayedRepository {
  _FakeRecentlyPlayedRepository(this._recentIds);

  final List<String> _recentIds;

  @override
  List<String> getRecentIds() => List<String>.from(_recentIds);

  @override
  Future<void> addRecent(String aartiId) async {
    _recentIds.remove(aartiId);
    _recentIds.insert(0, aartiId);
  }
}

class _FakeUserAartiRepository extends UserAartiRepository {
  @override
  List<AartiItem> getAll() => const <AartiItem>[];

  @override
  Future<String> save(AartiItem aarti) async => aarti.id;

  @override
  Future<void> delete(String id) async {}
}

const String _rootPlaceholderText = 'Root Placeholder';

const String _aartiCatalogFixture = '''
{
  "version": 1,
  "deities": [
    {"emoji": "🕉️", "label": "All"},
    {"emoji": "🐘", "label": "Ganesha"},
    {"emoji": "🌙", "label": "Shiva"}
  ],
  "aartis": [
    {
      "id": "jai_ganesh_deva",
      "title": "Jai Ganesh Deva",
      "type": "aarti",
      "devanagari": "जय गणेश देव",
      "deity": "Ganesha",
      "duration": "5:14",
      "festivalTags": ["Ganesh Chaturthi"],
      "verses": []
    },
    {
      "id": "om_jai_shiv_omkara",
      "title": "Om Jai Shiv Omkara",
      "type": "aarti",
      "devanagari": "ॐ जय शिव ओंकारा",
      "deity": "Shiva",
      "duration": "7:32",
      "festivalTags": ["Maha Shivaratri"],
      "verses": []
    }
  ]
}
''';

const String _festivalCatalogFixture = '''
{
  "version": 1,
  "festivals": [
    {
      "id": "ganesh_chaturthi_2026",
      "name": "Ganesh Chaturthi",
      "nameDevanagari": "गणेश चतुर्थी",
      "date": "2026-09-12",
      "deity": "Ganesha",
      "description": "Festival celebrating Lord Ganesha.",
      "aartiTag": "Ganesh Chaturthi",
      "emoji": "🐘"
    }
  ]
}
''';