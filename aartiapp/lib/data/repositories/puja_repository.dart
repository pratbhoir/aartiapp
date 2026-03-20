import 'package:hive/hive.dart';

/// Repository for managing "My Daily Puja" list with ordering in Hive.
class PujaRepository {
  static const _boxName = 'puja_order';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Returns the ordered list of Aarti IDs in the puja list.
  List<String> getPujaOrder() {
    if (_box == null || _box!.isEmpty) return [];
    // Store order as indexed keys: "0", "1", "2"...
    final entries = <int, String>{};
    for (int i = 0; i < _box!.length; i++) {
      final val = _box!.getAt(i);
      if (val != null) entries[i] = val;
    }
    return entries.values.toList();
  }

  /// Saves the entire ordered puja list.
  Future<void> savePujaOrder(List<String> aartiIds) async {
    await _box?.clear();
    for (final id in aartiIds) {
      await _box?.add(id);
    }
  }

  /// Adds an Aarti to the puja list.
  Future<void> addToPuja(String aartiId) async {
    final current = getPujaOrder();
    if (!current.contains(aartiId)) {
      current.add(aartiId);
      await savePujaOrder(current);
    }
  }

  /// Removes an Aarti from the puja list.
  Future<void> removeFromPuja(String aartiId) async {
    final current = getPujaOrder();
    current.remove(aartiId);
    await savePujaOrder(current);
  }

  /// Checks if an Aarti is in the puja list.
  bool isInPuja(String aartiId) => getPujaOrder().contains(aartiId);
}
