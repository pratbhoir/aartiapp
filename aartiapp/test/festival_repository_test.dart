import 'package:flutter_test/flutter_test.dart';

import 'package:aartiapp/data/repositories/festival_repository.dart';

void main() {
  group('FestivalRepository.orderedFestivalTags', () {
    test('returns only current and upcoming tags in date order', () {
      final repository = FestivalRepository.instance;
      repository.loadFromJsonString(_festivalFixture);

      final ordered = repository.orderedFestivalTags(
        now: DateTime(2026, 4, 27),
        allowedTags: const [
          'Maha Shivaratri',
          'Janmashtami',
          'Diwali',
          'Holi',
          'Navratri',
        ],
      );

      expect(
        ordered,
        const [
          'Maha Shivaratri',
          'Janmashtami',
          'Navratri',
          'Diwali',
        ],
      );
    });

    test('limits the filter list to five upcoming tags', () {
      final repository = FestivalRepository.instance;
      repository.loadFromJsonString(_festivalFixture);

      final ordered = repository.orderedFestivalTags(
        now: DateTime(2026, 4, 27),
        allowedTags: const [
          'Maha Shivaratri',
          'Janmashtami',
          'Diwali',
          'Navratri',
          'Ganesh Chaturthi',
          'Ram Navami',
        ],
      );

      expect(ordered, hasLength(5));
      expect(
        ordered,
        const [
          'Maha Shivaratri',
          'Ram Navami',
          'Janmashtami',
          'Ganesh Chaturthi',
          'Navratri',
        ],
      );
    });

    test('collapses duplicate yearly festival tags to one chip', () {
      final repository = FestivalRepository.instance;
      repository.loadFromJsonString(_festivalFixture);

      final ordered = repository.orderedFestivalTags(
        now: DateTime(2026, 4, 27),
        allowedTags: const ['Maha Shivaratri', 'Janmashtami'],
      );

      expect(ordered.where((tag) => tag == 'Maha Shivaratri'), hasLength(1));
      expect(ordered, const ['Maha Shivaratri', 'Janmashtami']);
    });
  });
}

const String _festivalFixture = '''
{
  "festivals": [
    {
      "id": "maha-shivaratri-2026",
      "name": "Maha Shivaratri",
      "nameDevanagari": "महाशिवरात्रि",
      "date": "2026-04-27",
      "deity": "Shiva",
      "description": "Active today",
      "aartiTag": "Maha Shivaratri",
      "emoji": "🌙"
    },
    {
      "id": "holi-2026",
      "name": "Holi",
      "nameDevanagari": "होली",
      "date": "2026-03-01",
      "deity": "Krishna",
      "description": "Recent past festival",
      "aartiTag": "Holi",
      "emoji": "🎨"
    },
    {
      "id": "janmashtami-2026",
      "name": "Janmashtami",
      "nameDevanagari": "जन्माष्टमी",
      "date": "2026-08-16",
      "deity": "Krishna",
      "description": "Upcoming festival",
      "aartiTag": "Janmashtami",
      "emoji": "🦚"
    },
    {
      "id": "ram-navami-2026",
      "name": "Ram Navami",
      "nameDevanagari": "राम नवमी",
      "date": "2026-06-01",
      "deity": "Rama",
      "description": "Earlier upcoming festival",
      "aartiTag": "Ram Navami",
      "emoji": "☀️"
    },
    {
      "id": "ganesh-chaturthi-2026",
      "name": "Ganesh Chaturthi",
      "nameDevanagari": "गणेश चतुर्थी",
      "date": "2026-09-01",
      "deity": "Ganesha",
      "description": "Another upcoming festival",
      "aartiTag": "Ganesh Chaturthi",
      "emoji": "🐘"
    },
    {
      "id": "navratri-2026",
      "name": "Navratri",
      "nameDevanagari": "नवरात्रि",
      "date": "2026-10-01",
      "deity": "Durga",
      "description": "Autumn festival",
      "aartiTag": "Navratri",
      "emoji": "🌺"
    },
    {
      "id": "diwali-2026",
      "name": "Diwali",
      "nameDevanagari": "दिवाली",
      "date": "2026-11-08",
      "deity": "Lakshmi",
      "description": "Later upcoming festival",
      "aartiTag": "Diwali",
      "emoji": "🪔"
    },
    {
      "id": "maha-shivaratri-2027",
      "name": "Maha Shivaratri",
      "nameDevanagari": "महाशिवरात्रि",
      "date": "2027-03-05",
      "deity": "Shiva",
      "description": "Duplicate yearly tag",
      "aartiTag": "Maha Shivaratri",
      "emoji": "🌙"
    }
  ]
}
''';