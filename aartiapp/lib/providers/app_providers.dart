import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/content_cache_service.dart';
import '../core/services/content_sync_service.dart';
import '../core/services/feedback_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/user_sync_service.dart';
import '../data/repositories/aarti_repository.dart';
import '../data/repositories/festival_repository.dart';
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

final userSyncServiceProvider = Provider<UserSyncService>((ref) {
  final service = UserSyncService(
    settingsRepository: ref.watch(settingsRepoProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService(
    settingsRepository: ref.watch(settingsRepoProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final contentCacheServiceProvider = Provider<ContentCacheService>((ref) {
  return ContentCacheService();
});

final contentSyncServiceProvider = Provider<ContentSyncService>((ref) {
  final service = ContentSyncService(
    settingsRepository: ref.watch(settingsRepoProvider),
    cacheService: ref.watch(contentCacheServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final contentSyncProvider =
    StateNotifierProvider<ContentSyncNotifier, ContentSyncState>((ref) {
      return ContentSyncNotifier(
        settingsRepository: ref.watch(settingsRepoProvider),
        service: ref.watch(contentSyncServiceProvider),
      );
    });

final contentRevisionProvider = Provider<int>((ref) {
  return ref.watch(contentSyncProvider).revision;
});

void _reidentifyAnalyticsIfReady(SettingsRepository settingsRepository) {
  if (!settingsRepository.getOnboardingCompleted()) {
    return;
  }

  unawaited(AnalyticsService.identifySession());
}

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

class ContentSyncNotifier extends StateNotifier<ContentSyncState> {
  ContentSyncNotifier({
    required SettingsRepository settingsRepository,
    required ContentSyncService service,
  }) : _settingsRepository = settingsRepository,
       _service = service,
       super(ContentSyncState.fromRepositories(settingsRepository));

  final SettingsRepository _settingsRepository;
  final ContentSyncService _service;

  Future<void> refreshIfStale() async {
    if (state.isRefreshing) {
      return;
    }

    AnalyticsService.trackEvent(
      'content_sync_started',
      data: const <String, Object>{'trigger': 'automatic'},
      path: '/settings',
    );

    state = ContentSyncState.fromRepositories(
      _settingsRepository,
      revision: state.revision,
      isRefreshing: true,
      statusMessage: 'Checking for updated devotional content…',
    );

    final result = await _service.refreshIfStale();
    _trackContentSyncResult(result, trigger: 'automatic');
    state = ContentSyncState.fromRepositories(
      _settingsRepository,
      revision: state.revision + (result.didChange ? 1 : 0),
      isRefreshing: false,
      statusMessage: _buildStatusMessage(result),
      lastError: result.hasErrors ? result.errors.join('\n') : null,
    );
  }

  Future<void> refreshNow() async {
    if (state.isRefreshing) {
      return;
    }

    AnalyticsService.trackEvent(
      'content_sync_started',
      data: const <String, Object>{'trigger': 'manual'},
      path: '/settings',
    );

    state = ContentSyncState.fromRepositories(
      _settingsRepository,
      revision: state.revision,
      isRefreshing: true,
      statusMessage: 'Refreshing devotional content…',
    );

    final result = await _service.refreshNow();
    _trackContentSyncResult(result, trigger: 'manual');
    state = ContentSyncState.fromRepositories(
      _settingsRepository,
      revision: state.revision + (result.didChange ? 1 : 0),
      isRefreshing: false,
      statusMessage: _buildStatusMessage(result),
      lastError: result.hasErrors ? result.errors.join('\n') : null,
    );
  }

  String _buildStatusMessage(ContentRefreshResult result) {
    if (result.skipped) {
      return 'Content is already up to date.';
    }

    if (!result.hasErrors && result.festivalUpdated && result.aartiUpdated) {
      return 'Festival calendar and aarti catalog refreshed.';
    }

    if (!result.hasErrors && result.festivalUpdated) {
      return 'Festival calendar refreshed.';
    }

    if (!result.hasErrors && result.aartiUpdated) {
      return 'Aarti catalog refreshed.';
    }

    if (result.festivalUpdated || result.aartiUpdated) {
      return 'Content refreshed with partial success.';
    }

    return 'Content refresh failed.';
  }

  void _trackContentSyncResult(
    ContentRefreshResult result, {
    required String trigger,
  }) {
    final data = <String, Object>{
      'trigger': trigger,
      'aarti_updated': result.aartiUpdated,
      'festival_updated': result.festivalUpdated,
    };

    if (result.skipped) {
      AnalyticsService.trackEvent(
        'content_sync_skipped',
        data: data,
        path: '/settings',
      );
      return;
    }

    if (!result.hasErrors) {
      AnalyticsService.trackEvent(
        'content_sync_completed_success',
        data: data,
        path: '/settings',
      );
      return;
    }

    if (result.festivalUpdated || result.aartiUpdated) {
      AnalyticsService.trackEvent(
        'content_sync_completed_partial',
        data: data,
        path: '/settings',
      );
      return;
    }

    AnalyticsService.trackEvent(
      'content_sync_failed',
      data: data,
      path: '/settings',
    );
  }
}

class ContentSyncState {
  const ContentSyncState({
    required this.revision,
    required this.isRefreshing,
    required this.aartiCount,
    required this.festivalCount,
    required this.aartiVersion,
    required this.festivalVersion,
    required this.aartiSource,
    required this.festivalSource,
    required this.aartiLastSync,
    required this.festivalLastSync,
    this.statusMessage,
    this.lastError,
  });

  factory ContentSyncState.fromRepositories(
    SettingsRepository settingsRepository, {
    int revision = 0,
    bool isRefreshing = false,
    String? statusMessage,
    String? lastError,
  }) {
    return ContentSyncState(
      revision: revision,
      isRefreshing: isRefreshing,
      aartiCount: AartiRepository.instance.aartis.length,
      festivalCount: FestivalRepository.instance.festivals.length,
      aartiVersion: AartiRepository.instance.version,
      festivalVersion: FestivalRepository.instance.version,
      aartiSource: AartiRepository.instance.dataSource,
      festivalSource: FestivalRepository.instance.dataSource,
      aartiLastSync: settingsRepository.getAartiContentLastSync(),
      festivalLastSync: settingsRepository.getFestivalContentLastSync(),
      statusMessage: statusMessage,
      lastError: lastError,
    );
  }

  final int revision;
  final bool isRefreshing;
  final int aartiCount;
  final int festivalCount;
  final int aartiVersion;
  final int festivalVersion;
  final String aartiSource;
  final String festivalSource;
  final DateTime? aartiLastSync;
  final DateTime? festivalLastSync;
  final String? statusMessage;
  final String? lastError;
}

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
  final syncService = ref.watch(userSyncServiceProvider);
  return ThemeModeNotifier(repo, syncService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  ThemeModeNotifier(this._repo, this._syncService)
    : super(_repo.getThemeMode());

  void setTheme(ThemeMode mode) {
    if (state == mode) {
      return;
    }

    state = mode;
    unawaited(_persistAndSync(mode));
  }

  void cycle() {
    final modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final next = modes[(modes.indexOf(state) + 1) % modes.length];
    setTheme(next);
  }

  Future<void> _persistAndSync(ThemeMode mode) async {
    await _repo.setThemeMode(mode);
    await _syncService.sync();
  }
}

// ─── Text Scale State ───────────────────────────────────────────────────────

final textScaleProvider = StateNotifierProvider<TextScaleNotifier, double>((
  ref,
) {
  final repo = ref.watch(settingsRepoProvider);
  final syncService = ref.watch(userSyncServiceProvider);
  return TextScaleNotifier(repo, syncService);
});

class TextScaleNotifier extends StateNotifier<double> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  TextScaleNotifier(this._repo, this._syncService)
    : super(_repo.getTextScale());

  void setScale(double scale) {
    final nextScale = scale.clamp(0.8, 1.6);
    if (state == nextScale) {
      return;
    }

    state = nextScale;
    unawaited(_persistAndSync(nextScale));
  }

  void increase() => setScale(state + 0.1);
  void decrease() => setScale(state - 0.1);

  Future<void> _persistAndSync(double scale) async {
    await _repo.setTextScale(scale);
    await _syncService.sync();
  }
}

// ─── Script Mode State ──────────────────────────────────────────────────────

/// 0 = Devanagari, 1 = English, 2 = Gujarati
final scriptModeProvider = StateNotifierProvider<ScriptModeNotifier, int>((
  ref,
) {
  final repo = ref.watch(settingsRepoProvider);
  final syncService = ref.watch(userSyncServiceProvider);
  return ScriptModeNotifier(repo, syncService);
});

class ScriptModeNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  ScriptModeNotifier(this._repo, this._syncService)
    : super(_repo.getScriptMode());

  void setMode(int mode) {
    final nextMode = mode.clamp(0, 2);
    if (state == nextMode) {
      return;
    }

    state = nextMode;
    unawaited(_persistAndSync(nextMode));
  }

  void cycle() => setMode((state + 1) % 3);

  Future<void> _persistAndSync(int mode) async {
    await _repo.setScriptMode(mode);
    await _syncService.sync();
  }
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
  ref.watch(contentRevisionProvider);
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
  final syncService = ref.watch(userSyncServiceProvider);
  return UserNameNotifier(repo, syncService);
});

class UserNameNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  UserNameNotifier(this._repo, this._syncService) : super(_repo.getUserName());

  void setName(String name) {
    if (state == name) {
      return;
    }

    state = name;
    unawaited(_persistAndSync(name));
  }

  Future<void> _persistAndSync(String name) async {
    await _repo.setUserName(name);
    AnalyticsService.updateIdentity(name: name, userId: _repo.getUserId());
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}

final analyticsEnabledProvider =
    StateNotifierProvider<AnalyticsEnabledNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      return AnalyticsEnabledNotifier(repo);
    });

class AnalyticsEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  AnalyticsEnabledNotifier(this._repo) : super(_repo.getAnalyticsEnabled());

  void set(bool value) {
    if (state == value) {
      return;
    }

    state = value;
    AnalyticsService.setEnabled(value);
    unawaited(_persist(value));
  }

  Future<void> _persist(bool value) async {
    await _repo.setAnalyticsEnabled(value);
    if (value) {
      _reidentifyAnalyticsIfReady(_repo);
    }
  }
}

// ─── v1.5: Crossfade Duration ───────────────────────────────────────────────

final crossfadeProvider = StateNotifierProvider<CrossfadeNotifier, int>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  final syncService = ref.watch(userSyncServiceProvider);
  return CrossfadeNotifier(repo, syncService);
});

class CrossfadeNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  CrossfadeNotifier(this._repo, this._syncService)
    : super(_repo.getCrossfadeDuration());

  void set(int seconds) {
    final nextSeconds = seconds.clamp(0, 3);
    if (state == nextSeconds) {
      return;
    }

    state = nextSeconds;
    unawaited(_persistAndSync(nextSeconds));
  }

  Future<void> _persistAndSync(int seconds) async {
    await _repo.setCrossfadeDuration(seconds);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}

// ─── v1.5: Auto-Play ────────────────────────────────────────────────────────

final autoPlayProvider = StateNotifierProvider<AutoPlayNotifier, bool>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  final syncService = ref.watch(userSyncServiceProvider);
  return AutoPlayNotifier(repo, syncService);
});

class AutoPlayNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  AutoPlayNotifier(this._repo, this._syncService) : super(_repo.getAutoPlay());

  void toggle() {
    state = !state;
    unawaited(_persistAndSync(state));
  }

  void set(bool value) {
    if (state == value) {
      return;
    }

    state = value;
    unawaited(_persistAndSync(value));
  }

  Future<void> _persistAndSync(bool value) async {
    await _repo.setAutoPlay(value);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}

// ─── v1.5: Repeat Current ──────────────────────────────────────────────────

final repeatCurrentProvider =
    StateNotifierProvider<RepeatCurrentNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      final syncService = ref.watch(userSyncServiceProvider);
      return RepeatCurrentNotifier(repo, syncService);
    });

class RepeatCurrentNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  RepeatCurrentNotifier(this._repo, this._syncService)
    : super(_repo.getRepeatCurrent());

  void toggle() {
    state = !state;
    unawaited(_persistAndSync(state));
  }

  Future<void> _persistAndSync(bool value) async {
    await _repo.setRepeatCurrent(value);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}

// ─── v1.5: Notification Settings ────────────────────────────────────────────

final notificationEnabledProvider =
    StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      final syncService = ref.watch(userSyncServiceProvider);
      return NotificationEnabledNotifier(repo, syncService);
    });

class NotificationEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  NotificationEnabledNotifier(this._repo, this._syncService)
    : super(_repo.getNotificationEnabled());

  void set(bool value) {
    if (state == value) {
      return;
    }

    state = value;
    unawaited(_persistAndSync(value));
  }

  Future<void> _persistAndSync(bool value) async {
    await _repo.setNotificationEnabled(value);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}

final notificationTimeProvider =
    StateNotifierProvider<NotificationTimeNotifier, TimeOfDay>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      final syncService = ref.watch(userSyncServiceProvider);
      return NotificationTimeNotifier(repo, syncService);
    });

class NotificationTimeNotifier extends StateNotifier<TimeOfDay> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  NotificationTimeNotifier(this._repo, this._syncService)
    : super(_repo.getNotificationTime());

  void set(TimeOfDay time) {
    if (state == time) {
      return;
    }

    state = time;
    unawaited(_persistAndSync(time));
  }

  Future<void> _persistAndSync(TimeOfDay time) async {
    await _repo.setNotificationTime(time);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
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

  Future<void> complete() async {
    state = true;
    await _repo.completeOnboarding();
    AnalyticsService.updateIdentity(
      name: _repo.getUserName(),
      userId: _repo.getUserId(),
    );
    AnalyticsService.updateLocale(_repo.getPreferredLanguage());
    _reidentifyAnalyticsIfReady(_repo);
  }
}

// ─── v2.0: Preferred Language ──────────────────────────────────────────────

final preferredLanguageProvider =
    StateNotifierProvider<PreferredLanguageNotifier, String>((ref) {
      final repo = ref.watch(settingsRepoProvider);
      final syncService = ref.watch(userSyncServiceProvider);
      return PreferredLanguageNotifier(repo, syncService);
    });

class PreferredLanguageNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  final UserSyncService _syncService;
  PreferredLanguageNotifier(this._repo, this._syncService)
    : super(_repo.getPreferredLanguage());

  void set(String lang) {
    if (state == lang) {
      return;
    }

    state = lang;
    unawaited(_persistAndSync(lang));
  }

  Future<void> _persistAndSync(String lang) async {
    await _repo.setPreferredLanguage(lang);
    AnalyticsService.updateLocale(lang);
    await _syncService.sync();
    _reidentifyAnalyticsIfReady(_repo);
  }
}
