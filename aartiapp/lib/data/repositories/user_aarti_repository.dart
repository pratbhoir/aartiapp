import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/aarti_item.dart';

/// Repository for user-created private Aartis stored in Hive.
class UserAartiRepository {
  static const _boxName = 'user_aartis';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Returns all user-created aartis (stored as JSON strings).
  List<AartiItem> getAll() {
    if (_box == null || _box!.isEmpty) return [];
    return _box!.values
        .map((jsonStr) {
          try {
            final map = json.decode(jsonStr) as Map<String, dynamic>;
            return AartiItem.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .where((a) => a != null)
        .cast<AartiItem>()
        .toList();
  }

  /// Saves a new user aarti. Returns the generated ID.
  Future<String> save(AartiItem aarti) async {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final item = aarti.copyWith(id: id);
    await _box?.put(id, json.encode(item.toJson()));
    return id;
  }

  /// Deletes a user aarti by ID.
  Future<void> delete(String id) async {
    await _box?.delete(id);
  }

  /// Number of saved aartis.
  int get count => _box?.length ?? 0;
}
