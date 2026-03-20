import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/aarti_item.dart';
import '../models/verse_data.dart';

/// Central repository for all aarti catalog data.
///
/// Loads from the bundled `assets/data/aarti_catalog.json` at startup.
/// In v2 this will also merge data from a remote API + local cache.
class AartiRepository {
  AartiRepository._();

  static final AartiRepository _instance = AartiRepository._();
  static AartiRepository get instance => _instance;

  /// Catalog version (from JSON `version` field).
  int _version = 0;
  int get version => _version;

  /// All aartis loaded from the catalog.
  List<AartiItem> _aartis = const [];
  List<AartiItem> get aartis => _aartis;

  /// Deity chips (emoji + label) for the filter bar.
  List<Map<String, String>> _deities = const [];
  List<Map<String, String>> get deities => _deities;

  /// Whether the catalog has been loaded at least once.
  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ───────────────────── Loading ─────────────────────

  /// Initialise from the bundled asset JSON.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> load() async {
    if (_loaded) return;
    final jsonStr =
        await rootBundle.loadString('assets/data/aarti_catalog.json');
    loadFromJsonString(jsonStr);
  }

  /// Parse raw JSON string into in-memory models.
  /// Exposed so tests / API layers can feed data without rootBundle.
  void loadFromJsonString(String jsonStr) {
    final Map<String, dynamic> root = json.decode(jsonStr) as Map<String, dynamic>;
    _version = (root['version'] as int?) ?? 1;

    _deities = ((root['deities'] as List<dynamic>?) ?? [])
        .map((d) {
          final m = d as Map<String, dynamic>;
          return <String, String>{
            'emoji': m['emoji'] as String,
            'label': m['label'] as String,
          };
        })
        .toList();

    _aartis = ((root['aartis'] as List<dynamic>?) ?? [])
        .map((a) => AartiItem.fromJson(a as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  // ───────────────────── Accessors ─────────────────────

  /// Get the aarti by [id]. Returns `null` if not found.
  AartiItem? getAartiById(String id) {
    try {
      return _aartis.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get verses for a given aarti ID.
  List<VerseData> getVersesForAarti(String aartiId) {
    return getAartiById(aartiId)?.verses ?? const [];
  }

  /// Unique deity labels (excluding "All").
  List<String> get deityLabels =>
      _deities.where((d) => d['label'] != 'All').map((d) => d['label']!).toList();
}
