import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/aarti_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/puja_repository.dart';
import '../data/repositories/bookmark_repository.dart';
import '../data/models/aarti_item.dart';
import '../core/utils/search_engine.dart';

// ─── Repository Providers ───────────────────────────────────────────────────

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPrefsProvider));
});

final pujaRepoProvider = Provider<PujaRepository>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final bookmarkRepoProvider = Provider<BookmarkRepository>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ─── Theme State ────────────────────────────────────────────────────────────

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return ThemeModeNotifier(repo);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repo;
  ThemeModeNotifier(this._repo) : super(_repo.getThemeMode());

  void setTheme(ThemeMode mode) {
    state = mode;
    _repo.setThemeMode(mode);
  }

  void cycle() {
    final modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final next = modes[(modes.indexOf(state) + 1) % modes.length];
    setTheme(next);
  }
}

// ─── Text Scale State ───────────────────────────────────────────────────────

final textScaleProvider =
    StateNotifierProvider<TextScaleNotifier, double>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return TextScaleNotifier(repo);
});

class TextScaleNotifier extends StateNotifier<double> {
  final SettingsRepository _repo;
  TextScaleNotifier(this._repo) : super(_repo.getTextScale());

  void setScale(double scale) {
    state = scale.clamp(0.8, 1.6);
    _repo.setTextScale(state);
  }

  void increase() => setScale(state + 0.1);
  void decrease() => setScale(state - 0.1);
}

// ─── Script Mode State ──────────────────────────────────────────────────────

/// 0 = Devanagari, 1 = Roman Transliteration
final scriptModeProvider =
    StateNotifierProvider<ScriptModeNotifier, int>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return ScriptModeNotifier(repo);
});

class ScriptModeNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  ScriptModeNotifier(this._repo) : super(_repo.getScriptMode());

  void setMode(int mode) {
    state = mode;
    _repo.setScriptMode(mode);
  }

  void toggle() => setMode(state == 0 ? 1 : 0);
}

// ─── Bookmark State ─────────────────────────────────────────────────────────

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, Set<String>>((ref) {
  final repo = ref.watch(bookmarkRepoProvider);
  return BookmarkNotifier(repo);
});

class BookmarkNotifier extends StateNotifier<Set<String>> {
  final BookmarkRepository _repo;
  BookmarkNotifier(this._repo) : super(_repo.getBookmarks());

  Future<void> toggle(String aartiId) async {
    await _repo.toggleBookmark(aartiId);
    state = _repo.getBookmarks();
  }

  bool isBookmarked(String aartiId) => state.contains(aartiId);
}

// ─── Puja Order State ───────────────────────────────────────────────────────

final pujaOrderProvider =
    StateNotifierProvider<PujaOrderNotifier, List<String>>((ref) {
  final repo = ref.watch(pujaRepoProvider);
  return PujaOrderNotifier(repo);
});

class PujaOrderNotifier extends StateNotifier<List<String>> {
  final PujaRepository _repo;
  PujaOrderNotifier(this._repo) : super(_repo.getPujaOrder());

  Future<void> addAarti(String aartiId) async {
    await _repo.addToPuja(aartiId);
    state = _repo.getPujaOrder();
  }

  Future<void> removeAarti(String aartiId) async {
    await _repo.removeFromPuja(aartiId);
    state = _repo.getPujaOrder();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<String>.from(state);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _repo.savePujaOrder(list);
    state = list;
  }

  bool isInPuja(String aartiId) => state.contains(aartiId);

  /// Returns AartiItems in puja order.
  List<AartiItem> getPujaAartis() {
    final catalog = AartiRepository.instance.aartis;
    return state
        .map((id) => catalog.firstWhere(
              (a) => a.id == id,
              orElse: () => catalog.first,
            ))
        .toList();
  }
}

// ─── Discover Screen State ──────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeDeityProvider = StateProvider<int>((ref) => 0);

final filteredAartisProvider = Provider<List<int>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final deityIdx = ref.watch(activeDeityProvider);
  final deities = AartiRepository.instance.deities;
  final deity = deities[deityIdx]['label']!;
  return SearchEngine.searchAndFilter(
      AartiRepository.instance.aartis, query, deity);
});

// ─── User Name ──────────────────────────────────────────────────────────────

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return UserNameNotifier(repo);
});

class UserNameNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  UserNameNotifier(this._repo) : super(_repo.getUserName());

  void setName(String name) {
    state = name;
    _repo.setUserName(name);
  }
}
