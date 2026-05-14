import 'package:flutter_test/flutter_test.dart';

import 'package:aartiapp/data/repositories/aarti_repository.dart';

void main() {
  group('AartiRepository deity accessors', () {
    setUp(() {
      AartiRepository.instance.loadFromJsonString(_catalogFixture);
    });

    test('returns matching deity metadata by label', () {
      final deity = AartiRepository.instance.getDeityByLabel('shiva');

      expect(deity, isNotNull);
      expect(deity!['emoji'], '🌙');
      expect(deity['label'], 'Shiva');
    });

    test('returns only devotional items for the selected deity', () {
      final items = AartiRepository.instance.getAartisForDeity('Ganesha');

      expect(items.map((item) => item.id), <String>[
        'jai_ganesh_deva',
        'ganesh_chalisa',
        'vakratunda_mahakaya',
      ]);
    });

    test('returns an empty list for an unknown deity', () {
      final items = AartiRepository.instance.getAartisForDeity('Unknown');

      expect(items, isEmpty);
    });
  });
}

const String _catalogFixture = '''
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
