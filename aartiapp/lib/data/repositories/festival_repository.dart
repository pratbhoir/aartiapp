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

  /// Returns up to [maxCount] unique current or upcoming festival tags.
  ///
  /// Tags are ordered by the nearest festival date starting from today, with
  /// active festivals naturally appearing first. When multiple yearly festival
  /// entries share the same tag, only the nearest current or upcoming one is
  /// kept.
  List<String> orderedFestivalTags({
    DateTime? now,
    int maxCount = 5,
    Iterable<String>? allowedTags,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final allowedTagMap = <String, String>{};

    if (allowedTags != null) {
      for (final tag in allowedTags) {
        allowedTagMap.putIfAbsent(tag.toLowerCase(), () => tag);
      }
    }

    final upcomingByTag = <String, _FestivalTagOrder>{};

    for (final festival in _festivals) {
      final normalizedTag = festival.aartiTag.toLowerCase();
      if (allowedTagMap.isNotEmpty && !allowedTagMap.containsKey(normalizedTag)) {
        continue;
      }

      final candidate = _buildTagOrder(
        festival,
        today: today,
        displayTag: allowedTagMap[normalizedTag] ?? festival.aartiTag,
      );
      if (candidate == null) {
        continue;
      }

      final current = upcomingByTag[normalizedTag];
      if (current == null || _compareFestivalTagOrder(candidate, current) < 0) {
        upcomingByTag[normalizedTag] = candidate;
      }
    }

    final ordered = upcomingByTag.values.toList()..sort(_compareFestivalTagOrder);
    return ordered.take(maxCount).map((entry) => entry.tag).toList();
  }

  static _FestivalTagOrder? _buildTagOrder(
    Festival festival, {
    required DateTime today,
    required String displayTag,
  }) {
    if (festival.isActiveOn(today) || !festival.date.isBefore(today)) {
      return _FestivalTagOrder(
        tag: displayTag,
        normalizedTag: festival.aartiTag.toLowerCase(),
        priority: festival.isActiveOn(today) ? 0 : 1,
        offsetDays: festival.isActiveOn(today) ? 0 : festival.daysUntil(from: today),
      );
    }

    return null;
  }

  static int _compareFestivalTagOrder(
    _FestivalTagOrder a,
    _FestivalTagOrder b,
  ) {
    final priorityCompare = a.priority.compareTo(b.priority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }

    final offsetCompare = a.offsetDays.compareTo(b.offsetDays);
    if (offsetCompare != 0) {
      return offsetCompare;
    }

    return a.tag.toLowerCase().compareTo(b.tag.toLowerCase());
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _FestivalTagOrder {
  const _FestivalTagOrder({
    required this.tag,
    required this.normalizedTag,
    required this.priority,
    required this.offsetDays,
  });

  final String tag;
  final String normalizedTag;
  final int priority;
  final int offsetDays;
}
