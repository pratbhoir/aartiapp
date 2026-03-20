import '../../data/models/aarti_item.dart';

/// Full-text local search engine for Aartis.
/// Searches across title, deity, devanagari, festival tags, and general tags.
class SearchEngine {
  SearchEngine._();

  /// Search Aartis matching [query] against title, deity, devanagari, lyrics content.
  /// Returns indices of matching items for the given list.
  static List<int> search(List<AartiItem> aartis, String query) {
    if (query.trim().isEmpty) return List.generate(aartis.length, (i) => i);

    final q = query.trim().toLowerCase();
    final results = <int>[];

    for (int i = 0; i < aartis.length; i++) {
      final a = aartis[i];
      if (_matches(a, q)) {
        results.add(i);
      }
    }
    return results;
  }

  static bool _matches(AartiItem a, String query) {
    // Match against title
    if (a.title.toLowerCase().contains(query)) return true;
    // Match against deity
    if (a.deity.toLowerCase().contains(query)) return true;
    // Match against Devanagari title
    if (a.devanagari.contains(query)) return true;
    // Match against general tags
    for (final tag in a.tags) {
      if (tag.toLowerCase().contains(query)) return true;
    }
    // Match against festival tags
    for (final tag in a.festivalTags) {
      if (tag.toLowerCase().contains(query)) return true;
    }
    return false;
  }

  /// Filter Aartis by deity. Returns all if deity is 'All'.
  static List<int> filterByDeity(List<AartiItem> aartis, String deity) {
    if (deity == 'All') return List.generate(aartis.length, (i) => i);
    return [
      for (int i = 0; i < aartis.length; i++)
        if (aartis[i].deity.toLowerCase() == deity.toLowerCase()) i,
    ];
  }

  /// Filter Aartis by festival tag. Returns all if festivalTag is empty.
  static List<int> filterByFestival(List<AartiItem> aartis, String festivalTag) {
    if (festivalTag.isEmpty) return List.generate(aartis.length, (i) => i);
    final lower = festivalTag.toLowerCase();
    return [
      for (int i = 0; i < aartis.length; i++)
        if (aartis[i].festivalTags
            .any((t) => t.toLowerCase() == lower))
          i,
    ];
  }

  /// Combined search + deity filter + optional festival filter.
  static List<int> searchAndFilter(
      List<AartiItem> aartis, String query, String deity,
      {String festivalTag = ''}) {
    final searchResults = search(aartis, query).toSet();
    final deityResults = filterByDeity(aartis, deity).toSet();
    var results = searchResults.intersection(deityResults);
    if (festivalTag.isNotEmpty) {
      final festivalResults = filterByFestival(aartis, festivalTag).toSet();
      results = results.intersection(festivalResults);
    }
    return results.toList()..sort();
  }

  /// Get all unique festival tags from the catalog.
  static List<String> allFestivalTags(List<AartiItem> aartis) {
    final tags = <String>{};
    for (final a in aartis) {
      tags.addAll(a.festivalTags);
    }
    return tags.toList()..sort();
  }
}
