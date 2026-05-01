import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/data/repositories/aarti_repository.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  group('DiscoverFilterNotifier', () {
    setUp(_loadCatalogFixture);

    test('search clears deity and festival filters', () async {
      final container = await _buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoverFilterProvider.notifier);
      notifier.selectDeity(1);
      notifier.applySearch('shiv');

      final state = container.read(discoverFilterProvider);
      expect(state.mode, DiscoverFilterMode.search);
      expect(state.searchQuery, 'shiv');
      expect(state.activeDeityIndex, 0);
      expect(state.activeFestivalTag, isEmpty);
      expect(container.read(filteredAartisProvider), const [1]);
    });

    test('deity selection clears search and festival filters', () async {
      final container = await _buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoverFilterProvider.notifier);
      notifier.applySearch('ganpati');
      notifier.selectFestival('Maha Shivaratri');
      notifier.selectDeity(1);

      final state = container.read(discoverFilterProvider);
      expect(state.mode, DiscoverFilterMode.deity);
      expect(state.searchQuery, isEmpty);
      expect(state.activeDeityIndex, 1);
      expect(state.activeFestivalTag, isEmpty);
      expect(container.read(filteredAartisProvider), const [0]);
    });

    test('festival selection clears search and deity filters', () async {
      final container = await _buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoverFilterProvider.notifier);
      notifier.applySearch('durga');
      notifier.selectFestival('Maha Shivaratri');

      final state = container.read(discoverFilterProvider);
      expect(state.mode, DiscoverFilterMode.festival);
      expect(state.searchQuery, isEmpty);
      expect(state.activeDeityIndex, 0);
      expect(state.activeFestivalTag, 'Maha Shivaratri');
      expect(container.read(filteredAartisProvider), const [1]);
    });

    test('selecting All resets Discover to the full catalog', () async {
      final container = await _buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoverFilterProvider.notifier);
      notifier.selectFestival('Navratri');
      notifier.selectDeity(0);

      final state = container.read(discoverFilterProvider);
      expect(state.mode, DiscoverFilterMode.none);
      expect(state.searchQuery, isEmpty);
      expect(state.activeDeityIndex, 0);
      expect(state.activeFestivalTag, isEmpty);
      expect(container.read(filteredAartisProvider), const [0, 1, 2, 3]);
    });

    test('new deity labels remain filterable through catalog order', () async {
      final container = await _buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoverFilterProvider.notifier);
      notifier.selectDeity(4);

      final state = container.read(discoverFilterProvider);
      expect(state.mode, DiscoverFilterMode.deity);
      expect(state.activeDeityIndex, 4);
      expect(container.read(filteredAartisProvider), const [3]);
    });
  });
}

void _loadCatalogFixture() {
  AartiRepository.instance.loadFromJsonString(_catalogFixture);
}

Future<ProviderContainer> _buildContainer() async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
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
      "tags": [
        "Ganpati"
      ],
      "festivalTags": [
        "Ganesh Chaturthi"
      ],
      "verses": []
    },
    {
      "id": "shiv_aarti",
      "title": "Om Jai Shiv Omkara",
      "devanagari": "ॐ जय शिव ओंकारा",
      "deity": "Shiva",
      "duration": "7:32",
      "tags": [
        "Somvar"
      ],
      "festivalTags": [
        "Maha Shivaratri"
      ],
      "verses": []
    },
    {
      "id": "durga_aarti",
      "title": "Jai Ambe Gauri",
      "devanagari": "जय अम्बे गौरी",
      "deity": "Durga",
      "duration": "5:15",
      "tags": [
        "Shakti"
      ],
      "festivalTags": [
        "Navratri"
      ],
      "verses": []
    },
    {
      "id": "saraswati_vandana",
      "title": "Jai Saraswati Mata",
      "devanagari": "जय सरस्वती माता",
      "deity": "Saraswati",
      "duration": "2:10",
      "tags": [
        "Vasant Panchami"
      ],
      "festivalTags": [
        "Vasant Panchami"
      ],
      "verses": []
    }
  ]
}
''';
