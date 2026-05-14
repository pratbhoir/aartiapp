import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/data/repositories/aarti_repository.dart';
import 'package:aartiapp/data/repositories/bookmark_repository.dart';
import 'package:aartiapp/data/repositories/festival_repository.dart';
import 'package:aartiapp/data/repositories/puja_repository.dart';
import 'package:aartiapp/data/repositories/recently_played_repository.dart';
import 'package:aartiapp/features/deity_detail/deity_detail_screen.dart';
import 'package:aartiapp/features/discover/discover_screen.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    AartiRepository.instance.loadFromJsonString(_aartiCatalogFixture);
    FestivalRepository.instance.loadFromJsonString(_festivalCatalogFixture);
  });

  testWidgets('tapping a non-All deity chip opens the deity page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _buildDiscoverHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ganesha').first);
    await tester.pumpAndSettle();

    expect(find.byType(DeityDetailScreen), findsOneWidget);
    expect(find.text('Ganesh Chaturthi'), findsWidgets);
    expect(find.text('Jai Ganesh Deva'), findsOneWidget);
  });

  testWidgets('deity page switches between devotional tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _buildDeityHarness());
    await tester.pumpAndSettle();

    expect(find.text('Jai Ganesh Deva'), findsOneWidget);

    await tester.tap(find.text('Chalisas'));
    await tester.pumpAndSettle();
    expect(find.text('Ganesh Chalisa'), findsOneWidget);

    await tester.tap(find.text('Shlokas'));
    await tester.pumpAndSettle();
    expect(find.text('Vakratunda Mahakaya'), findsOneWidget);
    expect(
      find.text(
        'This tab also includes stotras, mantras, chants, and other reading-first devotionals.',
      ),
      findsNothing,
    );
  });
}

Future<Widget> _buildDiscoverHarness() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: <Override>[
      sharedPrefsProvider.overrideWithValue(prefs),
      bookmarkRepoProvider.overrideWithValue(_FakeBookmarkRepository()),
      pujaRepoProvider.overrideWithValue(_FakePujaRepository()),
      recentlyPlayedRepoProvider.overrideWithValue(
        _FakeRecentlyPlayedRepository(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: DiscoverScreen(onOpenDrawer: () {})),
    ),
  );
}

Future<Widget> _buildDeityHarness() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: <Override>[
      sharedPrefsProvider.overrideWithValue(prefs),
      bookmarkRepoProvider.overrideWithValue(_FakeBookmarkRepository()),
      pujaRepoProvider.overrideWithValue(_FakePujaRepository()),
      recentlyPlayedRepoProvider.overrideWithValue(
        _FakeRecentlyPlayedRepository(),
      ),
    ],
    child: const MaterialApp(home: DeityDetailScreen(deityLabel: 'Ganesha')),
  );
}

class _FakeBookmarkRepository extends BookmarkRepository {
  final Set<String> _bookmarks = <String>{};

  @override
  Set<String> getBookmarks() => Set<String>.from(_bookmarks);

  @override
  Future<bool> toggleBookmark(String aartiId) async {
    if (_bookmarks.contains(aartiId)) {
      _bookmarks.remove(aartiId);
      return false;
    }

    _bookmarks.add(aartiId);
    return true;
  }
}

class _FakePujaRepository extends PujaRepository {
  final List<String> _pujaIds = <String>[];

  @override
  List<String> getPujaOrder() => List<String>.from(_pujaIds);

  @override
  Future<void> savePujaOrder(List<String> aartiIds) async {
    _pujaIds
      ..clear()
      ..addAll(aartiIds);
  }

  @override
  Future<void> addToPuja(String aartiId) async {
    if (!_pujaIds.contains(aartiId)) {
      _pujaIds.add(aartiId);
    }
  }

  @override
  Future<void> removeFromPuja(String aartiId) async {
    _pujaIds.remove(aartiId);
  }

  @override
  bool isInPuja(String aartiId) => _pujaIds.contains(aartiId);
}

class _FakeRecentlyPlayedRepository extends RecentlyPlayedRepository {
  final List<String> _recentIds = <String>[];

  @override
  List<String> getRecentIds() => List<String>.from(_recentIds);

  @override
  Future<void> addRecent(String aartiId) async {
    _recentIds.remove(aartiId);
    _recentIds.insert(0, aartiId);
  }
}

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
      "id": "ganesh_chalisa",
      "title": "Ganesh Chalisa",
      "type": "chalisa",
      "devanagari": "गणेश चालीसा",
      "deity": "Ganesha",
      "duration": "7:40",
      "festivalTags": ["Ganesh Chaturthi"],
      "verses": []
    },
    {
      "id": "vakratunda_mahakaya",
      "title": "Vakratunda Mahakaya",
      "type": "shloka",
      "devanagari": "वक्रतुण्ड महाकाय",
      "deity": "Ganesha",
      "duration": "1:30",
      "festivalTags": [],
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
