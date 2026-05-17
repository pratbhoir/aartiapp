# File Registry

> Single source of truth for every file in the project and its purpose.
> Updated on every code change.

---

## Core

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/main.dart` | App entry point — initialises Activity Log, seeds first-launch app language from supported device locales, performs cache-first devotional content bootstrap, repositories, notifications, global error hooks, and configures analytics before `runApp` | 2026-05-17 |
| `lib/app.dart` | Root `AartiSangrahApp` — configures localized `MaterialApp`, the onboarding gate, returning-user startup sync, startup analytics identify, and lifecycle-driven content refresh checks | 2026-05-14 |

## Core / Localization

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/l10n/app_locale.dart` | Supported app-locale definitions and persisted language-code → `Locale` mapping helpers | 2026-05-14 |
| `lib/core/l10n/app_localizations_ext.dart` | `BuildContext` extension for concise generated localization access | 2026-05-14 |

## Core / Theme

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/theme/app_colors.dart` | All colour tokens (light + dark) — single source of truth for the palette, including semantic snackbar feedback fills | 2026-05-01 |
| `lib/core/theme/app_typography.dart` | All text style factory methods (`AppTypography`) — Lora, Noto Serif Devanagari, system sans | 2026-04-20 |
| `lib/core/theme/app_spacing.dart` | All spacing / padding / margin / radius tokens (`AppSpacing`) | 2026-04-20 |
| `lib/core/theme/app_theme.dart` | `ThemeData` assembly for light and dark modes, including shared floating snackbar defaults | 2026-05-01 |
| `lib/core/theme/theme_aware_colors.dart` | `BuildContext` extension resolving colours by brightness | 2026-04-20 |

## Core / Constants

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/constants/app_constants.dart` | App-level constants for cross-cutting services (including Activity Log retention + file name) | 2026-04-26 |
| `lib/core/constants/app_analytics_config.dart` | Compile-time config for the direct Umami analytics endpoint, website ID, hostname, timeout, and User-Agent | 2026-05-01 |
| `lib/core/constants/app_sync_config.dart` | Compile-time config for user sync, feedback, and content refresh webhook URLs plus request timing values | 2026-05-01 |
| `lib/core/constants/haptics.dart` | `AppHaptics` — scoped haptic feedback definitions (light, medium, selection, completion) | 2026-04-20 |

## Core / Services

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/services/activity_log_service.dart` | `ActivityLogService` static utility — JSONL-backed runtime log with init/write/read/clear/share APIs | 2026-04-26 |
| `lib/core/services/analytics_service.dart` | `AnalyticsService` static utility — direct Umami-over-HTTP event transport with screen dedupe, identify payloads, enablement gating, and 5xx retry handling | 2026-05-01 |
| `lib/core/services/content_cache_service.dart` | `ContentCacheService` — application-documents JSON cache for the aarti catalog and festival calendar payloads | 2026-05-01 |
| `lib/core/services/content_sync_service.dart` | `ContentSyncService` — n8n-backed refresh service for festival and aarti content with per-dataset caching, timestamps, and partial-failure tolerance | 2026-05-01 |
| `lib/core/services/feedback_service.dart` | `FeedbackService` — user-visible feedback submission service that posts devotional issues and suggestions to n8n with device and identity context while emitting analytics success/failure events | 2026-05-01 |
| `lib/core/services/notification_service.dart` | `NotificationService` singleton — daily puja reminder scheduling via `flutter_local_notifications` | 2026-04-20 |
| `lib/core/services/user_profile_snapshot.dart` | `UserProfileSnapshot` — shared lightweight identity, app, and device metadata snapshot reused by user sync and analytics identify payloads | 2026-05-01 |
| `lib/core/services/user_sync_service.dart` | `UserSyncService` — debounced best-effort sync of lightweight user profile and settings data to a configured n8n webhook | 2026-05-01 |
| `lib/core/services/sharing_service.dart` | `SharingService` singleton — share Aarti as text or rendered image via `share_plus`, with Activity Log failure reporting | 2026-04-26 |

## Core / Utils

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/utils/device_info_helper.dart` | `DeviceInfoHelper` — normalized cross-platform device snapshot builder for outbound sync payloads | 2026-05-01 |
| `lib/core/utils/day_deity_mapper.dart` | `DayDeityMapper` — maps weekday → deity for "Aarti of the Day" and exposes localized home subtitle and day-special helpers | 2026-05-17 |
| `lib/core/utils/search_engine.dart` | `SearchEngine` — full-text local search + deity/festival filtering | 2026-04-20 |
| `lib/core/utils/snackbar_helper.dart` | `SnackBarHelper` — centralized semantic snackbar utility with replace-current behavior and theme-aligned severity mapping | 2026-05-01 |

## Data / Models

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/data/models/aarti_item.dart` | `AartiItem` data class — title, deity, verses, tags, audio URL | 2026-04-20 |
| `lib/data/models/festival.dart` | `Festival` data class — date-range Hindu festival with deity and aarti tag linking plus active/upcoming date helpers | 2026-04-27 |
| `lib/data/models/verse_data.dart` | `VerseData` data class — Devanagari lines, transliteration, meanings, Gujarati | 2026-04-20 |

## Data / Repositories

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/data/repositories/aarti_repository.dart` | `AartiRepository` singleton — loads bundled, cached, or remote `aarti_catalog.json`, tracks content version/source, and provides deity, festival, and ID-based query accessors | 2026-05-02 |
| `lib/data/repositories/bookmark_repository.dart` | `BookmarkRepository` — Hive-backed bookmark toggle/query | 2026-04-20 |
| `lib/data/repositories/festival_repository.dart` | `FestivalRepository` singleton — loads bundled, cached, or remote Hindu calendar JSON (2026–2028), tracks content version/source, and returns up to 5 Discover festival tags in nearest current/upcoming order | 2026-05-01 |
| `lib/data/repositories/puja_repository.dart` | `PujaRepository` — Hive-backed ordered puja list persistence | 2026-04-20 |
| `lib/data/repositories/recently_played_repository.dart` | `RecentlyPlayedRepository` — Hive-backed recently-viewed aarti tracking (max 20) | 2026-04-20 |
| `lib/data/repositories/settings_repository.dart` | `SettingsRepository` — SharedPreferences wrapper for theme, text scale, localized app-language persistence plus first-launch device-locale seeding, notifications, onboarding completion, analytics enablement, and stable sync/analytics identity metadata | 2026-05-17 |
| `lib/data/repositories/user_aarti_repository.dart` | `UserAartiRepository` — Hive-backed CRUD for user-created private Aartis | 2026-04-20 |

## Providers

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/providers/app_providers.dart` | All Riverpod providers and `StateNotifier` classes — theme, language, notifications, analytics enablement, bookmarks, puja order, Discover filters, deity-detail computed families, provider-owned user sync and analytics re-identify triggers, feedback service, and content sync state/revision invalidation | 2026-05-02 |

## Navigation

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/navigation/home_shell.dart` | `HomeShell` — top-level `Scaffold` with localized Temple Dock bottom navigation, `AnimatedSwitcher` screen transitions, and tab-level screen analytics | 2026-05-14 |
| `lib/navigation/app_drawer.dart` | `AppDrawer` — dark-themed side navigation drawer component (legacy, currently not mounted by `HomeShell`) | 2026-04-25 |
| `lib/navigation/widgets/app_bottom_nav.dart` | `AppBottomNav` — Temple Dock style bottom navigation used for primary app sections with localized tab semantics | 2026-05-14 |

## Shared / Widgets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/widgets/aarti_app_bar.dart` | `AartiAppBar` — reusable app bar with optional menu affordance and trailing action area | 2026-04-25 |
| `lib/shared/widgets/focus_mode_settings_sheet.dart` | Shared temporary focus-mode settings bottom sheet used by standalone focus mode and My Puja focus sessions, now localized with resolved script labels, scroll-safe modal content, and a compact text-size control | 2026-05-17 |
| `lib/shared/widgets/gradient_divider.dart` | `GradientDivider` — saffron-to-transparent horizontal divider | 2026-04-20 |
| `lib/shared/widgets/section_label.dart` | `SectionLabel` — uppercase tracked section header text | 2026-04-20 |
| `lib/shared/widgets/toggle_bar.dart` | `ToggleBar` — shared segmented control used by Aarti Detail and Deity Detail with theme-aware surfaces | 2026-05-02 |

## Shared / Utils

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/utils/aarti_language_resolver.dart` | `AartiLanguageResolver` — central script/app-language resolver for aarti titles, lyric lines, derived secondary-script surfaces, and English meaning fallback | 2026-04-27 |

## Shared / Painters

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/painters/mala_painter.dart` | `MalaPainter` — `CustomPainter` rendering the circular Japa Mala bead ring | 2026-04-20 |

## Features / Discover

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/discover/discover_screen.dart` | `DiscoverScreen` — localized prayer discovery screen with mutually exclusive search, festival filters, localized section chrome, and a script-aware aarti grid, where non-`All` deity chips now open the dedicated deity page | 2026-05-17 |
| `lib/features/discover/widgets/aarti_card.dart` | `AartiCard` — grid card showing deity, title, script-aware subtitle, duration, bookmark | 2026-04-26 |
| `lib/features/discover/widgets/deity_chip.dart` | `DeityChip` — emoji deity filter chip with active-state glow | 2026-04-20 |
| `lib/features/discover/widgets/festival_filter_chips.dart` | `FestivalFilterChips` — horizontal scrollable Discover festival tag chips showing only actual festival entries | 2026-04-27 |
| `lib/features/discover/widgets/festive_banner.dart` | `FestiveBanner` — seasonal festival banner card with emoji plus localized today and countdown badges | 2026-05-17 |
| `lib/features/discover/widgets/search_bar.dart` | `AartiSearchBar` — localized text input with parent-controlled value support for Discover filter resets and an embedded Material ancestor | 2026-05-17 |
| `lib/features/discover/widgets/today_hero_card.dart` | `TodayHeroCard` — dark pulsing hero card for "Aarti of the Day" with script-aware subtitle preview and a localized day-special badge | 2026-05-17 |

## Features / Deity Detail

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/deity_detail/deity_detail_screen.dart` | `DeityDetailScreen` — dedicated deity destination with shared segmented tabs, a consistent hero backdrop, polished section framing, and deity-page analytics | 2026-05-02 |
| `lib/features/deity_detail/widgets/deity_header.dart` | `DeityHeader` — deity hero surface with a fixed cross-deity backdrop, mantra emphasis, related-festival chips, and warm-material styling | 2026-05-02 |
| `lib/features/deity_detail/widgets/deity_prayer_card.dart` | `DeityPrayerCard` — deity-page devotional list card using the Discover card language with a saffron top accent row, title-first compact layout, bottom-right audio chip, and simplified metadata row | 2026-05-02 |

## Features / Aarti Detail

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/aarti_detail/aarti_detail_screen.dart` | `AartiDetailScreen` — localized full detail view with script-aware lyrics, derived secondary-script tabs, theme-aware reader surfaces, localized action chrome, share sheet, puja-aware next navigation, and temporary focus settings | 2026-05-17 |
| `lib/features/aarti_detail/widgets/action_chip.dart` | `ActionChip` — tappable chip button for Focus Mode, Share, etc., with theme-aware neutral styling | 2026-04-26 |
| `lib/features/aarti_detail/widgets/audio_player_widget.dart` | `AudioPlayerWidget` — sticky bottom audio player with scrub, play/pause, skip, repeat, and theme-aware glass styling | 2026-04-26 |
| `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` | `FocusModeOverlay` — reusable full-screen dark reading surface with localized footer instructions, puja boundary handoff CTAs, derived secondary-script rendering, centered session-style header support, and balanced line splits | 2026-05-17 |
| `lib/features/aarti_detail/widgets/mantra_counter_overlay.dart` | `MantraCounterOverlay` — modal Japa Mala counter with haptics, configurable count, completion callback, and theme-aware modal chrome | 2026-05-01 |
| `lib/features/aarti_detail/widgets/verse_block.dart` | `VerseBlock` — renders lyrics, derived secondary-script lines, and meaning using the shared resolver with theme-aware reading contrast | 2026-04-27 |

## Features / My Puja

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/my_puja/my_puja_screen.dart` | `MyPujaScreen` — daily puja playlist with drag-to-reorder, audio/focus session launchers, script-aware preview items, and puja list analytics | 2026-05-01 |
| `lib/features/my_puja/puja_focus_session_screen.dart` | `PujaFocusSessionScreen` — sequential full-screen reading session for the My Daily Puja order with localized shared focus chrome, session-local reading-surface and text-size overrides, progress dots, previous/next handoff, and focus-session lifecycle analytics | 2026-05-17 |
| `lib/features/my_puja/puja_session_screen.dart` | `PujaSessionScreen` — sequential audio puja session with auto-play, crossfade, controls, script-aware verse preview, and session completion/exit analytics | 2026-05-01 |
| `lib/features/my_puja/widgets/puja_list_item.dart` | `PujaListItem` — reorderable puja entry with deity badge, script-aware subtitle, and theme-aware sequence/remove controls | 2026-04-26 |

## Features / Contribute

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/contribute/contribute_screen.dart` | `ContributeScreen` — form to create and save personal Aartis locally with centralized validation, success snackbar feedback, and collection analytics including explicit My Puja adds | 2026-05-01 |

## Features / Home

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/home/home_screen.dart` | `HomeScreen` — devotional home with localized greeting and section copy, Aarti of the Day, festive banner, Discover handoff, and hero-card analytics | 2026-05-14 |

## Features / Onboarding

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/onboarding/onboarding_screen.dart` | `OnboardingScreen` — four-step welcome flow with generated localized copy that initializes from the persisted app language, persists identity metadata, emits onboarding analytics milestones, and triggers the first forced user sync on completion | 2026-05-17 |

## Localization Assets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/l10n/app_en.arb` | English source-of-truth UI string catalog for the generated localization layer | 2026-05-14 |
| `lib/l10n/app_hi.arb` | Hindi UI string catalog for the generated localization layer | 2026-05-14 |
| `lib/l10n/app_gu.arb` | Gujarati UI string catalog for the generated localization layer | 2026-05-14 |

## Features / Settings

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/settings/settings_screen.dart` | `SettingsScreen` — fully localized settings hub for theme, analytics opt-out, app language, primary/secondary script overview, notification, session settings, manual content refresh, feedback entrypoint, diagnostics actions, and settings analytics instrumentation | 2026-05-17 |
| `lib/features/settings/feedback_screen.dart` | `FeedbackScreen` — devotional feedback form with efficient stacked category chips, keyboard-aware submission UX, success state, snackbar failures, and feedback analytics hooks | 2026-05-01 |
| `lib/features/settings/dev_tools_screen.dart` | `DevToolsScreen` — diagnostics hub page with Activity Log open/share/clear actions and analytics instrumentation for those diagnostics flows | 2026-05-01 |

## Assets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `assets/data/aarti_catalog.json` | Bundled aarti catalog with all metadata, verses, and tags | 2026-04-20 |
| `assets/data/festivals/hindu_calendar_2026_2028.json` | Bundled Hindu festival calendar (2026–2028) | 2026-04-20 |

## Integration Assets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `n8n/aartiapp_user_sync_workflow.json` | Import-ready n8n workflow for AartiApp user profile/settings sync with DataTable primary storage and optional Postgres sink | 2026-05-01 |
| `n8n/aartiapp_feedback_workflow.json` | Import-ready n8n workflow for AartiApp feedback submission with DataTable primary storage and optional Postgres sink | 2026-05-01 |
| `n8n/aartiapp_festival_content_workflow.json` | Import-ready n8n workflow serving the festival calendar JSON directly from a local file over a GET webhook | 2026-05-01 |
| `n8n/aartiapp_aarti_content_workflow.json` | Import-ready n8n workflow serving the aarti catalog JSON directly from a local file over a GET webhook | 2026-05-01 |

## Database

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `database/aartiapp.sql` | Combined SQL bootstrap for the AartiApp user-sync and feedback tables plus helpful indexes and query references | 2026-05-01 |
| `database/Tables/UserProfiles.sql` | SQL schema and Postgres upsert query for the AartiApp user-sync storage table | 2026-05-01 |
| `database/Tables/appFeedback.sql` | SQL schema, indexes, and insert query for the AartiApp feedback storage table | 2026-05-01 |

## Documentation

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `docs/FILE_REGISTRY.md` | This file — complete file inventory | 2026-05-17 |
| `docs/ARCHITECTURE.md` | Folder structure, patterns, state management, conventions, runtime integration guidance, and localization architecture notes | 2026-05-17 |
| `docs/THEME_AND_DESIGN.md` | Design tokens, colour palette, typography, spacing, and component feedback styling | 2026-05-01 |
| `docs/FUNCTIONAL_SPEC.md` | Feature list, user flows, acceptance criteria, and rollout notes for in-progress app localization | 2026-05-17 |
| `docs/ANALYTICS_EVENTS.md` | Analytics event registry and naming conventions for the implemented direct Umami event surface | 2026-05-02 |
| `docs/CHANGELOG.md` | Chronological log of all changes | 2026-05-17 |

## Testing

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `test/content_sync_service_test.dart` | Focused service tests for content refresh, stale-skip behavior, cache writes, and per-dataset partial success | 2026-05-01 |
| `test/analytics_service_test.dart` | Focused service tests for Umami payload shaping, send gating, screen dedupe, and retry behavior | 2026-05-01 |
| `test/aarti_repository_test.dart` | Focused repository tests for deity metadata lookup and deity-specific devotional filtering | 2026-05-02 |
| `test/aarti_detail_screen_test.dart` | Focused widget test for localized Aarti Detail labels, focus overlay, and focus settings sheet | 2026-05-17 |
| `test/deity_detail_screen_test.dart` | Focused widget tests for Discover-to-deity navigation and deity tab behavior | 2026-05-02 |
| `test/discover_filter_provider_test.dart` | Focused provider tests for Discover filter exclusivity, clear-state behavior, and derived result lists | 2026-04-27 |
| `test/discover_screen_test.dart` | Focused widget tests for localized Discover labels, result count, and empty-state behavior | 2026-05-17 |
| `test/feedback_service_test.dart` | Focused service tests for feedback payload generation, identity backfill, and failure semantics | 2026-05-01 |
| `test/feedback_screen_test.dart` | Focused widget tests for feedback form validation and success-state behavior | 2026-05-01 |
| `test/festival_repository_test.dart` | Focused repository tests for upcoming-only festival filter ordering, duplicate-tag collapsing, and the 5-chip limit | 2026-04-27 |
| `test/settings_repository_test.dart` | Focused repository tests for first-launch preferred-language seeding from supported device locales | 2026-05-17 |
| `test/settings_screen_test.dart` | Focused widget tests for localized Settings labels | 2026-05-17 |
| `test/snackbar_helper_test.dart` | Focused widget tests for semantic snackbar severity rendering, action support, and replace-current behavior | 2026-05-01 |
| `test/user_sync_service_test.dart` | Focused service tests for sync payload generation, identity backfill, debounce, force sync, and failure semantics | 2026-05-01 |
| `test/widget_test.dart` | Focused widget tests for root locale selection and runtime locale switching | 2026-05-14 |
