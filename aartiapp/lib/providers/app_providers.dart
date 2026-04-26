import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/aarti_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/puja_repository.dart';
import '../data/repositories/bookmark_repository.dart';
import '../data/repositories/user_aarti_repository.dart';
import '../data/repositories/recently_played_repository.dart';
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

final userAartiRepoProvider = Provider<UserAartiRepository>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final recentlyPlayedRepoProvider = Provider<RecentlyPlayedRepository>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ─── User Aarti Collection State ────────────────────────────────────────────

final userAartiProvider =
    StateNotifierProvider<UserAartiNotifier, List<AartiItem>>((ref) {
      final repo = ref.watch(userAartiRepoProvider);
      return UserAartiNotifier(repo);
    });

class UserAartiNotifier extends StateNotifier<List<AartiItem>> {
  final UserAartiRepository _repo;
  UserAartiNotifier(this._repo) : super(_repo.getAll());

  Future<String> save(AartiItem aarti) async {
    final id = await _repo.save(aarti);
    state = _repo.getAll();
    return id;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }
}

// ─── Recently Played State ──────────────────────────────────────────────────

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<String>>((ref) {
      final repo = ref.watch(recentlyPlayedRepoProvider);
      return RecentlyPlayedNotifier(repo);
    });

class RecentlyPlayedNotifier extends StateNotifier<List<String>> {
  final RecentlyPlayedRepository _repo;
  RecentlyPlayedNotifier(this._repo) : super(_repo.getRecentIds());

  Future<void> addRecent(String aartiId) async {
    await _repo.addRecent(aartiId);
    state = _repo.getRecentIds();
  }

  Future<void> clear() async {
    await _repo.clear();
    state = [];
  }

  /// Resolves aarti IDs to AartiItem objects, searching both catalog and user aartis.
  List<AartiItem> getRecentAartis({List<AartiItem> userAartis = const []}) {
    final catalog = AartiRepository.instance.aartis;
    final allAartis = [...catalog, ...userAartis];
    return state
        .map((id) {
          try {
            return allAartis.firstWhere((a) => a.id == id);
          } catch (_) {
            return null;
          }
        })
        .where((a) => a != null)
        .cast<AartiItem>()
        .toList();
  }
}

// ─── Theme State ────────────────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
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

final textScaleProvider = StateNotifierProvider<TextScaleNotifier, double>((
  ref,
) {
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

/// 0 = Devanagari, 1 = English, 2 = Gujarati
final scriptModeProvider = StateNotifierProvider<ScriptModeNotifier, int>((
  ref,
) {
  final repo = ref.watch(settingsRepoProvider);
  return ScriptModeNotifier(repo);
});

class ScriptModeNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  ScriptModeNotifier(this._repo) : super(_repo.getScriptMode());

  void setMode(int mode) {
    state = mode.clamp(0, 2);
    _repo.setScriptMode(mode);
  }

  void cycle() => setMode((state + 1) % 3);
}

// ─── Bookmark State ─────────────────────────────────────────────────────────

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, Set<String>>((
  ref,
) {
  final repo = ref.watch(bookmarkRepoProvider);
  final pujaNotifier = ref.read(pujaOrderProvider.notifier);
  return BookmarkNotifier(repo, pujaNotifier);
});

class BookmarkNotifier extends StateNotifier<Set<String>> {
  final BookmarkRepository _repo;
  final PujaOrderNotifier _pujaNotifier;
  BookmarkNotifier(this._repo, this._pujaNotifier)
    : super(_repo.getBookmarks());

  Future<void> toggle(String aartiId) async {
    final wasBookmarked = state.contains(aartiId);
    await _repo.toggleBookmark(aartiId);
    state = _repo.getBookmarks();

    // Sync with puja list: bookmark adds, unbookmark removes
    if (!wasBookmarked) {
      await _pujaNotifier.addAarti(aartiId);
    } else {
      await _pujaNotifier.removeAarti(aartiId);
    }
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
  /// Searches both the catalog and user-created aartis.
  List<AartiItem> getPujaAartis({List<AartiItem> userAartis = const []}) {
    final catalog = AartiRepository.instance.aartis;
    final allAartis = [...catalog, ...userAartis];
    return state
        .map(
          (id) => allAartis.firstWhere(
            (a) => a.id == id,
            orElse: () => catalog.first,
          ),
        )
        .where((a) => state.contains(a.id))
        .toList();
  }
}

// ─── Discover Screen State ──────────────────────────────────────────────────

/// The currently active Discover filter type.
enum DiscoverFilterMode {
  /// No active filter. Discover defaults to the full catalog with deity All selected.
  none,

  /// Full-text search is active.
  search,

  /// A deity chip is active.
  deity,

  /// A festival chip is active.
  festival,
}

/// Immutable Discover filter state.
class DiscoverFilterState {
  /// Creates the current Discover filter selection.
  const DiscoverFilterState({
    this.mode = DiscoverFilterMode.none,
    this.searchQuery = '',
    this.activeDeityIndex = 0,
    this.activeFestivalTag = '',
  });

  /// Which Discover filter is currently active.
  final DiscoverFilterMode mode;

  /// Current search text.
  final String searchQuery;

  /// Currently selected deity chip index.
  final int activeDeityIndex;

  /// Currently selected festival tag.
  final String activeFestivalTag;
}

/// Coordinates Discover filters so only one of search, deity, or festival is active.
class DiscoverFilterNotifier extends StateNotifier<DiscoverFilterState> {
  /// Creates the Discover filter controller.
  DiscoverFilterNotifier() : super(const DiscoverFilterState());

  /// Activates search and clears deity and festival filters.
  void applySearch(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      clearAll();
      return;
    }

    state = DiscoverFilterState(
      mode: DiscoverFilterMode.search,
      searchQuery: query,
    );
  }

  /// Activates a deity filter. Selecting index 0 resets Discover to All.
  void selectDeity(int deityIndex) {
    if (deityIndex <= 0) {
      clearAll();
      return;
    }

    state = DiscoverFilterState(
      mode: DiscoverFilterMode.deity,
      activeDeityIndex: deityIndex,
    );
  }

  /// Activates a festival filter. Selecting an empty tag resets Discover to All.
  void selectFestival(String festivalTag) {
    final normalized = festivalTag.trim();
    if (normalized.isEmpty) {
      clearAll();
      return;
    }

    state = DiscoverFilterState(
      mode: DiscoverFilterMode.festival,
      activeFestivalTag: normalized,
    );
  }

  /// Clears Discover back to the default All state.
  void clearAll() {
    state = const DiscoverFilterState();
  }
}

final discoverFilterProvider =
    StateNotifierProvider<DiscoverFilterNotifier, DiscoverFilterState>((ref) {
      return DiscoverFilterNotifier();
    });

final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(discoverFilterProvider).searchQuery;
});

final activeDeityProvider = Provider<int>((ref) {
  return ref.watch(discoverFilterProvider).activeDeityIndex;
});

final activeFestivalTagProvider = Provider<String>((ref) {
  return ref.watch(discoverFilterProvider).activeFestivalTag;
});

final filteredAartisProvider = Provider<List<int>>((ref) {
  final discoverFilter = ref.watch(discoverFilterProvider);
  final aartis = AartiRepository.instance.aartis;
  final deities = AartiRepository.instance.deities;

  switch (discoverFilter.mode) {
    case DiscoverFilterMode.search:
      return SearchEngine.search(aartis, discoverFilter.searchQuery);
    case DiscoverFilterMode.deity:
      final safeDeityIndex =
          discoverFilter.activeDeityIndex >= 0 &&
              discoverFilter.activeDeityIndex < deities.length
          ? discoverFilter.activeDeityIndex
          : 0;
      final deity = deities[safeDeityIndex]['label']!;
      return SearchEngine.filterByDeity(aartis, deity);
    case DiscoverFilterMode.festival:
      return SearchEngine.filterByFestival(
        aartis,
        discoverFilter.activeFestivalTag,
      );
    case DiscoverFilterMode.none:
      return List.generate(aartis.length, (index) => index);
  }
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

// ─── v1.5: Crossfade Duration ───────────────────────────────────────────────

final crossfadeProvider = StateNotifierProvider<CrossfadeNotifier, int>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return CrossfadeNotifier(repo);
});

class CrossfadeNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  CrossfadeNotifier(this._repo) : super(_repo.getCrossfadeDuration());

  void set(int seconds) {
    state = seconds.clamp(0, 3);
    _repo.setCrossfadeDuration(state);
  }
}

// ─── v1.5: Auto-Play ────────────────────────────────────────────────────────

final autoPlayProvider = StateNotifierProvider<AutoPlayNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return AutoPlayNotifier(repo);
});

class AutoPlayNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  AutoPlayNotifier(this._repo) : super(_repo.getAutoPlay());

  void toggle() {
    state = !state;
    _repo.setAutoPlay(state);
  }

  void set(bool value) {
    state = value;
    _repo.setAutoPlay(value);
  }
}

// ─── v1.5: Repeat Current ──────────────────────────────────────────────────

final repeatCurrentProvider =
    StateNotifierProvider<RepeatCurrentNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return RepeatCurrentNotifier(repo);
    });

class RepeatCurrentNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  RepeatCurrentNotifier(this._repo) : super(_repo.getRepeatCurrent());

  void toggle() {
    state = !state;
    _repo.setRepeatCurrent(state);
  }
}

// ─── v1.5: Notification Settings ────────────────────────────────────────────

final notificationEnabledProvider =
    StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return NotificationEnabledNotifier(repo);
    });

class NotificationEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  NotificationEnabledNotifier(this._repo)
    : super(_repo.getNotificationEnabled());

  void set(bool value) {
    state = value;
    _repo.setNotificationEnabled(value);
  }
}

final notificationTimeProvider =
    StateNotifierProvider<NotificationTimeNotifier, TimeOfDay>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return NotificationTimeNotifier(repo);
    });

class NotificationTimeNotifier extends StateNotifier<TimeOfDay> {
  final SettingsRepository _repo;
  NotificationTimeNotifier(this._repo) : super(_repo.getNotificationTime());

  void set(TimeOfDay time) {
    state = time;
    _repo.setNotificationTime(time);
  }
}

// ─── v2.0: Onboarding State ────────────────────────────────────────────────

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return OnboardingCompletedNotifier(repo);
    });

class OnboardingCompletedNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  OnboardingCompletedNotifier(this._repo)
    : super(_repo.getOnboardingCompleted());

  void complete() {
    state = true;
    _repo.setOnboardingCompleted(true);
  }
}

// ─── v2.0: Preferred Language ──────────────────────────────────────────────

final preferredLanguageProvider =
    StateNotifierProvider<PreferredLanguageNotifier, String>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return PreferredLanguageNotifier(repo);
    });

class PreferredLanguageNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  PreferredLanguageNotifier(this._repo) : super(_repo.getPreferredLanguage());

  void set(String lang) {
    state = lang;
    _repo.setPreferredLanguage(lang);
  }
}
