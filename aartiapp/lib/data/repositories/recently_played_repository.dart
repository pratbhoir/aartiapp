import 'package:hive/hive.dart';

/// Repository for tracking recently played/viewed Aartis.
/// Stores up to [maxItems] aarti IDs in order (most recent first).
class RecentlyPlayedRepository {
  static const _boxName = 'recently_played';
  static const _key = 'recent_ids';
  static const int maxItems = 20;

  Box<dynamic>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  /// Returns the list of recently played aarti IDs (most recent first).
  List<String> getRecentIds() {
    if (_box == null) return [];
    final raw = _box!.get(_key);
    if (raw == null) return [];
    if (raw is List) {
      return raw.cast<String>().toList();
    }
    return [];
  }

  /// Adds an aarti ID to the front of the recently played list.
  /// Removes duplicates and trims to [maxItems].
  Future<void> addRecent(String aartiId) async {
    final list = getRecentIds();
    list.remove(aartiId);
    list.insert(0, aartiId);
    if (list.length > maxItems) {
      list.removeRange(maxItems, list.length);
    }
    await _box?.put(_key, list);
  }

  /// Clears all recently played history.
  Future<void> clear() async {
    await _box?.delete(_key);
  }
}
