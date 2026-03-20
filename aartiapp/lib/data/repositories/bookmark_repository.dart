import 'package:hive/hive.dart';

/// Repository for managing bookmarked Aartis using Hive.
class BookmarkRepository {
  static const _boxName = 'bookmarks';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Returns set of bookmarked Aarti IDs.
  Set<String> getBookmarks() {
    if (_box == null) return {};
    return _box!.values.toSet();
  }

  /// Toggle bookmark state for an Aarti.
  Future<bool> toggleBookmark(String aartiId) async {
    final bookmarks = getBookmarks();
    if (bookmarks.contains(aartiId)) {
      // Find and remove the key
      final keys = _box!.keys.toList();
      for (final key in keys) {
        if (_box!.get(key) == aartiId) {
          await _box!.delete(key);
          break;
        }
      }
      return false; // now un-bookmarked
    } else {
      await _box!.add(aartiId);
      return true; // now bookmarked
    }
  }

  /// Check if an Aarti is bookmarked.
  bool isBookmarked(String aartiId) => getBookmarks().contains(aartiId);
}
