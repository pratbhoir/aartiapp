import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/festival.dart';

/// Repository for the bundled Hindu festival calendar (2026–2028).
class FestivalRepository {
  FestivalRepository._();

  static final FestivalRepository _instance = FestivalRepository._();
  static FestivalRepository get instance => _instance;

  List<Festival> _festivals = const [];
  List<Festival> get festivals => _festivals;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Load festival data from the bundled JSON asset.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final jsonStr = await rootBundle
          .loadString('assets/data/festivals/hindu_calendar_2026_2028.json');
      loadFromJsonString(jsonStr);
    } catch (_) {
      // Fail silently — festival features degrade gracefully.
      _loaded = true;
    }
  }

  void loadFromJsonString(String jsonStr) {
    final root = json.decode(jsonStr) as Map<String, dynamic>;
    _festivals = ((root['festivals'] as List<dynamic>?) ?? [])
        .map((f) => Festival.fromJson(f as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _loaded = true;
  }

  /// Returns a festival that is active TODAY, or `null` if none.
  Festival? todayFestival({DateTime? now}) {
    final today = now ?? DateTime.now();
    for (final f in _festivals) {
      if (f.isActiveOn(today)) return f;
    }
    return null;
  }

  /// Returns the next upcoming festival within [days] days.
  Festival? nextUpcoming({int days = 7, DateTime? from}) {
    final now = from ?? DateTime.now();
    for (final f in _festivals) {
      if (f.isUpcomingWithin(days, from: now)) return f;
    }
    return null;
  }

  /// Returns today's or upcoming festival (today first, then next 7 days).
  Festival? todayOrUpcoming({DateTime? now}) {
    return todayFestival(now: now) ?? nextUpcoming(from: now);
  }
}
