# Architecture

> Structural conventions, patterns, and technical decisions for Aarti Sangrah.

---

## 1. Folder Structure

```
n8n/
├── aartiapp_user_sync_workflow.json   # Import-ready n8n workflow for profile/settings sync
└── aartiapp_feedback_workflow.json    # Import-ready n8n workflow for user feedback ingestion
database/
├── aartiapp.sql                       # Combined Postgres bootstrap for workflow sinks
└── Tables/
  ├── UserProfiles.sql              # User sync table + upsert query
  └── appFeedback.sql               # Feedback table + insert query
lib/
├── main.dart                          # App entry point, repository init
├── app.dart                           # Root MaterialApp configuration
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # All colour tokens (single source of truth)
│   │   ├── app_typography.dart        # All text style factories (single source of truth)
│   │   ├── app_spacing.dart           # All spacing / radius tokens (single source of truth)
│   │   ├── app_theme.dart             # ThemeData assembly (light + dark)
│   │   └── theme_aware_colors.dart    # BuildContext extension for theme-aware colours
│   ├── constants/
│   │   ├── app_constants.dart         # App-level shared constants (log retention/file names)
│   │   ├── app_sync_config.dart       # Compile-time user sync / feedback webhook + timing config
│   │   └── haptics.dart               # AppHaptics — scoped haptic feedback
│   ├── services/
│   │   ├── activity_log_service.dart  # File-backed JSONL runtime activity log
│   │   ├── feedback_service.dart      # User-visible feedback submission to n8n
│   │   ├── notification_service.dart  # Local daily notification scheduling
│   │   ├── user_sync_service.dart     # Debounced best-effort user/settings sync to n8n
│   │   └── sharing_service.dart       # Share lyrics as text or image
│   └── utils/
│       ├── device_info_helper.dart    # Cross-platform device metadata for sync payloads
│       ├── day_deity_mapper.dart      # Weekday → deity mapping
│       └── search_engine.dart         # Full-text local search + filter
├── data/
│   ├── models/
│   │   ├── aarti_item.dart            # AartiItem data class
│   │   ├── festival.dart              # Festival data class
│   │   └── verse_data.dart            # VerseData data class
│   └── repositories/
│       ├── aarti_repository.dart      # Bundled JSON catalog loader (singleton)
│       ├── bookmark_repository.dart   # Hive-backed bookmarks
│       ├── festival_repository.dart   # Bundled festival calendar (singleton)
│       ├── puja_repository.dart       # Hive-backed puja order
│       ├── recently_played_repository.dart  # Hive-backed recent history
│       ├── settings_repository.dart   # SharedPreferences wrapper + stable sync identity metadata
│       └── user_aarti_repository.dart # Hive-backed user-created aartis
├── providers/
│   └── app_providers.dart             # All Riverpod providers & StateNotifiers
├── navigation/
│   ├── home_shell.dart                # Top-level scaffold + bottom nav + screen switcher
│   ├── app_drawer.dart                # Legacy side drawer component (not mounted)
│   └── widgets/
│       └── app_bottom_nav.dart        # Temple Dock style bottom navigation
├── shared/
│   ├── widgets/
│   │   ├── aarti_app_bar.dart         # Reusable app bar with hamburger menu
│   │   ├── focus_mode_settings_sheet.dart # Shared temporary focus-mode settings sheet
│   │   ├── gradient_divider.dart      # Saffron gradient divider
│   │   └── section_label.dart         # Uppercase tracked section label
│   ├── painters/
│   │   └── mala_painter.dart          # CustomPainter for Mala bead ring
│   ├── utils/
│   │   └── aarti_language_resolver.dart # Shared script/app-language selection rules for titles, lyrics, tabs, and fallbacks
│   ├── extensions/                    # (reserved for Dart extension methods)
│   └── models/                        # (reserved for shared DTOs)
├── features/
│   ├── discover/
│   │   ├── discover_screen.dart
│   │   └── widgets/                   # 6 feature-specific widgets
│   ├── aarti_detail/
│   │   ├── aarti_detail_screen.dart
│   │   └── widgets/                   # 6 feature-specific widgets
│   ├── my_puja/
│   │   ├── my_puja_screen.dart
│   │   ├── puja_focus_session_screen.dart
│   │   ├── puja_session_screen.dart
│   │   └── widgets/                   # 1 feature-specific widget
│   ├── contribute/
│   │   └── contribute_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── feedback_screen.dart
│       └── dev_tools_screen.dart
```

---

## 2. Design Patterns

### Feature-First Organisation

Each feature lives under `lib/features/<feature_name>/` with optional `data/`, `domain/`, and `presentation/` sub-folders when complexity warrants it. Currently, most features have a screen + widgets structure.

### Singleton Repositories

`AartiRepository` and `FestivalRepository` use the singleton pattern because they load immutable bundled data once at startup. Mutable repositories (`BookmarkRepository`, `PujaRepository`, etc.) are instantiated in `main()` and injected via Riverpod `Provider.overrideWithValue`.

### Widget Composition

Screens are composed from small, focused widgets. Feature-specific widgets live in `features/<name>/widgets/`. Cross-feature reusable widgets live in `shared/widgets/`.

The focus-reading surface is intentionally reused across both `AartiDetailScreen` and `PujaFocusSessionScreen` through `features/aarti_detail/widgets/focus_mode_overlay.dart` so verse navigation, balancing, and completion CTA rules stay consistent.

Temporary focus-mode controls that are shared across those flows live in `shared/widgets/focus_mode_settings_sheet.dart`, which keeps the modal chrome and script/text-size override behavior aligned while leaving the actual focus-session state in the owning screen.

### Shared Language Resolution

Script-language and app-language display rules are centralized in `shared/utils/aarti_language_resolver.dart`. Reading surfaces should resolve titles, lyric lines, derived secondary-script surfaces, and meaning fallbacks through that utility instead of duplicating `scriptMode` or `preferredLanguage` branching locally.

---

## 3. State Management

**Library:** `flutter_riverpod` (v2.6.1)

### Provider Types Used

| Provider Type | Purpose | Example |
|---------------|---------|---------|
| `Provider<T>` | Expose singleton repos and services | `sharedPrefsProvider`, `settingsRepoProvider`, `feedbackServiceProvider` |
| `StateNotifierProvider<N, T>` | Mutable state with business logic | `themeModeProvider`, `bookmarkProvider`, `pujaOrderProvider`, `discoverFilterProvider` |
| `StateProvider<T>` | Simple mutable state | transient UI values with no coordination rules |
| `Provider<T>` (computed) | Derived/filtered data | `filteredAartisProvider` |

Discover filtering is coordinated through a dedicated `DiscoverFilterNotifier` instead of three independent mutable providers. This keeps search, deity, and festival selection mutually exclusive, ensures the default deity `All` state behaves as the clear-filter state, and lets cross-screen entry points such as Home preselect Discover state without leaving stale search text behind.

User reading preferences are split into two persisted provider-backed settings:
- `scriptModeProvider` controls the script used for lyric surfaces: Devanagari, English, or Gujarati.
- `preferredLanguageProvider` controls the app language used for translated meaning surfaces and tab visibility decisions.

The app also derives a non-persisted secondary script from those two settings. Secondary-script surfaces use the app-language reading script by default, and fall back to Devanagari when the selected lyric script already matches that app-language script.

### Injection Strategy

Repositories that require async initialisation are created in `main()` and injected via `ProviderScope.overrides`. This avoids `FutureProvider` complexity at the root level.

```dart
ProviderScope(
  overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    pujaRepoProvider.overrideWithValue(pujaRepo),
    bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
    // ...
  ],
  child: const AartiSangrahApp(),
)
```

### Provider-Owned Sync Triggers

Best-effort user sync is intentionally attached to provider-backed setting mutators rather than individual widgets. Each notifier persists the new value first and then asks `UserSyncService` to schedule a debounced sync. This keeps the sync trigger surface aligned with the state ownership model and avoids duplicate widget-level callbacks.

### Service-Backed Feedback Submission

The feedback flow uses a dedicated `FeedbackService` exposed through Riverpod. Unlike user sync, feedback is a user-visible action, so the service throws `FeedbackSubmissionException` on non-2xx responses, timeouts, or transport failures after logging the error via `ActivityLogService`. The screen owns validation, loading state, and success-state rendering while the service owns payload construction and transport.

### n8n + Database Contracts

The app-to-automation contracts are versioned in-repo under `n8n/` and `database/`. The workflow JSON files mirror the exact payloads emitted by `UserSyncService` and `FeedbackService`, using n8n DataTables as the primary response path and optional Postgres nodes as a secondary sink. DataTable IDs and Postgres credentials are instance-specific, so those bindings must be selected after import even though the field mappings, SQL, webhook paths, and response payloads are already prepared.

---

## 4. Error Handling

- **Repository layer:** Catches exceptions internally; methods return empty collections on failure rather than throwing.
- **Audio playback:** `try/catch` around URL loading; silently degrades if network unreachable.
- **Notifications:** Fail-silent on permission denial or scheduling errors.
- **Feedback submission:** `FeedbackService` logs failures and rethrows a user-facing exception so the UI can show a snackbar without swallowing the error silently.
- **User sync:** `UserSyncService` treats n8n sync as best-effort telemetry. Non-2xx responses, timeouts, and transport failures are logged through `ActivityLogService` and never block UX.
- **JSON parsing:** Null-safe with fallback defaults in `fromJson` factories.
- **Global uncaught failures:** `main.dart` wires `FlutterError.onError` and `runZonedGuarded` to `ActivityLogService.error(...)` for persistent diagnostics.
- **Activity diagnostics:** Recoverable warnings (e.g., audio init/share failures) are captured by `ActivityLogService.warn(...)` for local inspection and export.

No formal `Result<T, E>` or `Either` pattern is used. Consider adopting one as complexity grows.

---

## 5. Navigation

**Approach:** Imperative `Navigator.push()` / `Navigator.pop()` for in-flow pages, plus index-based shell navigation for top-level sections.

The `HomeShell` widget acts as a shell around the 5 top-level screens (Home, Discover, My Puja, My Collection, Settings). Screen switching uses `AnimatedSwitcher` with combined Fade + Slide transitions. Primary navigation is handled by `AppBottomNav` (Temple Dock style) at the bottom of the screen.

No declarative router (e.g., `go_router`) is currently used. Consider adopting one if deep linking or web navigation is needed.

---

## 6. Theming Rules

1. **All colours** come from `lib/core/theme/app_colors.dart`. Never use inline `Color(0xFF...)`.
2. **All text styles** come from `lib/core/theme/app_typography.dart`. Never use inline `TextStyle(...)`.
3. **All spacing** values come from `lib/core/theme/app_spacing.dart`. Prefer `AppSpacing.xl` over raw `24`.
4. **Component themes** are defined in `lib/core/theme/app_theme.dart`.
5. **Theme-aware colours** are accessed via the `ThemeAwareColors` extension: `context.surface`, `context.textPrimary`, etc.

See [THEME_AND_DESIGN.md](THEME_AND_DESIGN.md) for the full token catalogue.

---

## 7. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case.dart` | `aarti_detail_screen.dart` |
| Classes | `PascalCase` | `AartiDetailScreen` |
| Variables / methods | `camelCase` | `todayDeity()` |
| Constants | `camelCase` | `saffronGlow` |
| Private members | `_` prefix | `_currentIndex` |
| Providers | descriptive `camelCase` + suffix | `bookmarkProvider`, `filteredAartisProvider` |

---

## 8. Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `hive` / `hive_flutter` | ^2.2.3 | Local NoSQL storage (bookmarks, puja, user aartis) |
| `shared_preferences` | ^2.5.0 | Key-value settings persistence |
| `google_fonts` | ^6.2.1 | Lora + Noto Serif Devanagari typography |
| `just_audio` | ^0.9.42 | Audio playback |
| `share_plus` | ^10.1.4 | Share lyrics as text / image |
| `path_provider` | ^2.1.5 | Resolve app document/temp directories for Activity Log persistence/export |
| `flutter_local_notifications` | ^18.0.1 | Daily puja reminder notifications |
| `timezone` | ^0.10.0 | Timezone-aware notification scheduling |
| `http` | ^1.4.0 | JSON POST transport for n8n user sync and feedback submission |
| `device_info_plus` | ^11.5.0 | Cross-platform device metadata for sync payloads |
| `package_info_plus` | ^8.3.1 | Runtime app version lookup for sync and feedback payloads |
| `uuid` | ^4.5.1 | Stable local `user_id` generation and feedback submission ids |
| `screenshot` | ^3.0.0 | Widget-to-image capture for sharing |

---

## 9. Testing Conventions

- Tests live in `test/` mirroring the `lib/` structure.
- Widget tests use `WidgetTester` + `ProviderScope`.
- Repository tests use `loadFromJsonString()` to avoid `rootBundle` dependency.
- Currently minimal test coverage — expansion planned.

---

## 10. Build & Run

```bash
# Get dependencies
flutter pub get

# Run debug build
flutter run --dart-define=AARTI_USER_SYNC_WEBHOOK_URL=https://example.com/user-sync --dart-define=AARTI_FEEDBACK_WEBHOOK_URL=https://example.com/feedback

# Run tests
flutter test

# Build release APK
flutter build apk --release --dart-define=AARTI_USER_SYNC_WEBHOOK_URL=https://example.com/user-sync --dart-define=AARTI_FEEDBACK_WEBHOOK_URL=https://example.com/feedback
```
