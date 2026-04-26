# File Registry

> Single source of truth for every file in the project and its purpose.
> Updated on every code change.

---

## Core

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/main.dart` | App entry point — initialises Activity Log, Hive, repositories, notifications, global error hooks, and runs `ProviderScope` | 2026-04-26 |
| `lib/app.dart` | Root `AartiSangrahApp` `ConsumerWidget` — configures `MaterialApp` with light/dark theme and onboarding gate | 2026-04-20 |

## Core / Theme

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/theme/app_colors.dart` | All colour tokens (light + dark) — single source of truth for the palette | 2026-04-20 |
| `lib/core/theme/app_typography.dart` | All text style factory methods (`AppTypography`) — Lora, Noto Serif Devanagari, system sans | 2026-04-20 |
| `lib/core/theme/app_spacing.dart` | All spacing / padding / margin / radius tokens (`AppSpacing`) | 2026-04-20 |
| `lib/core/theme/app_theme.dart` | `ThemeData` assembly for light and dark modes | 2026-04-20 |
| `lib/core/theme/theme_aware_colors.dart` | `BuildContext` extension resolving colours by brightness | 2026-04-20 |

## Core / Constants

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/constants/app_constants.dart` | App-level constants for cross-cutting services (including Activity Log retention + file name) | 2026-04-26 |
| `lib/core/constants/haptics.dart` | `AppHaptics` — scoped haptic feedback definitions (light, medium, selection, completion) | 2026-04-20 |

## Core / Services

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/services/activity_log_service.dart` | `ActivityLogService` static utility — JSONL-backed runtime log with init/write/read/clear/share APIs | 2026-04-26 |
| `lib/core/services/notification_service.dart` | `NotificationService` singleton — daily puja reminder scheduling via `flutter_local_notifications` | 2026-04-20 |
| `lib/core/services/sharing_service.dart` | `SharingService` singleton — share Aarti as text or rendered image via `share_plus`, with Activity Log failure reporting | 2026-04-26 |

## Core / Utils

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/core/utils/day_deity_mapper.dart` | `DayDeityMapper` — maps weekday → deity for "Aarti of the Day" | 2026-04-20 |
| `lib/core/utils/search_engine.dart` | `SearchEngine` — full-text local search + deity/festival filtering | 2026-04-20 |

## Data / Models

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/data/models/aarti_item.dart` | `AartiItem` data class — title, deity, verses, tags, audio URL | 2026-04-20 |
| `lib/data/models/festival.dart` | `Festival` data class — date-range Hindu festival with deity and aarti tag linking | 2026-04-20 |
| `lib/data/models/verse_data.dart` | `VerseData` data class — Devanagari lines, transliteration, meanings, Gujarati | 2026-04-20 |

## Data / Repositories

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/data/repositories/aarti_repository.dart` | `AartiRepository` singleton — loads bundled `aarti_catalog.json`, provides query accessors | 2026-04-20 |
| `lib/data/repositories/bookmark_repository.dart` | `BookmarkRepository` — Hive-backed bookmark toggle/query | 2026-04-20 |
| `lib/data/repositories/festival_repository.dart` | `FestivalRepository` singleton — loads bundled Hindu calendar JSON (2026–2028) | 2026-04-20 |
| `lib/data/repositories/puja_repository.dart` | `PujaRepository` — Hive-backed ordered puja list persistence | 2026-04-20 |
| `lib/data/repositories/recently_played_repository.dart` | `RecentlyPlayedRepository` — Hive-backed recently-viewed aarti tracking (max 20) | 2026-04-20 |
| `lib/data/repositories/settings_repository.dart` | `SettingsRepository` — SharedPreferences wrapper for theme, text scale, script language, app language, and other user settings | 2026-04-26 |
| `lib/data/repositories/user_aarti_repository.dart` | `UserAartiRepository` — Hive-backed CRUD for user-created private Aartis | 2026-04-20 |

## Providers

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/providers/app_providers.dart` | All Riverpod providers and `StateNotifier` classes — theme, script language, app language, bookmarks, puja order, search, etc. | 2026-04-26 |

## Navigation

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/navigation/home_shell.dart` | `HomeShell` — top-level `Scaffold` with Temple Dock bottom navigation and `AnimatedSwitcher` screen transitions | 2026-04-25 |
| `lib/navigation/app_drawer.dart` | `AppDrawer` — dark-themed side navigation drawer component (legacy, currently not mounted by `HomeShell`) | 2026-04-25 |
| `lib/navigation/widgets/app_bottom_nav.dart` | `AppBottomNav` — Temple Dock style bottom navigation used for primary app sections | 2026-04-25 |

## Shared / Widgets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/widgets/aarti_app_bar.dart` | `AartiAppBar` — reusable app bar with optional menu affordance and trailing action area | 2026-04-25 |
| `lib/shared/widgets/gradient_divider.dart` | `GradientDivider` — saffron-to-transparent horizontal divider | 2026-04-20 |
| `lib/shared/widgets/section_label.dart` | `SectionLabel` — uppercase tracked section header text | 2026-04-20 |

## Shared / Utils

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/utils/aarti_language_resolver.dart` | `AartiLanguageResolver` — central script/app-language resolver for aarti titles, verse lines, tab visibility, and English meaning fallback | 2026-04-26 |

## Shared / Painters

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/shared/painters/mala_painter.dart` | `MalaPainter` — `CustomPainter` rendering the circular Japa Mala bead ring | 2026-04-20 |

## Features / Discover

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/discover/discover_screen.dart` | `DiscoverScreen` — prayer discovery screen with deity filter, search, festival filters, and script-aware aarti grid | 2026-04-26 |
| `lib/features/discover/widgets/aarti_card.dart` | `AartiCard` — grid card showing deity, title, script-aware subtitle, duration, bookmark | 2026-04-26 |
| `lib/features/discover/widgets/deity_chip.dart` | `DeityChip` — emoji deity filter chip with active-state glow | 2026-04-20 |
| `lib/features/discover/widgets/festival_filter_chips.dart` | `FestivalFilterChips` — horizontal scrollable festival tag chips | 2026-04-20 |
| `lib/features/discover/widgets/festive_banner.dart` | `FestiveBanner` — seasonal festival banner card with emoji and countdown | 2026-04-20 |
| `lib/features/discover/widgets/search_bar.dart` | `AartiSearchBar` — text input with search icon and clear button | 2026-04-20 |
| `lib/features/discover/widgets/today_hero_card.dart` | `TodayHeroCard` — dark pulsing hero card for "Aarti of the Day" with script-aware subtitle preview | 2026-04-26 |

## Features / Aarti Detail

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/aarti_detail/aarti_detail_screen.dart` | `AartiDetailScreen` — full detail view with script-aware lyrics, dynamic tabs, theme-aware reader surfaces, audio player, bookmark, puja-aware next navigation, and audio init warning logging | 2026-04-26 |
| `lib/features/aarti_detail/widgets/action_chip.dart` | `ActionChip` — tappable chip button for Focus Mode, Share, etc., with theme-aware neutral styling | 2026-04-26 |
| `lib/features/aarti_detail/widgets/audio_player_widget.dart` | `AudioPlayerWidget` — sticky bottom audio player with scrub, play/pause, skip, repeat, and theme-aware glass styling | 2026-04-26 |
| `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` | `FocusModeOverlay` — full-screen dark overlay for distraction-free verse-by-verse reading using the selected script, verse-wide balanced line splits, and configurable separated line blocks | 2026-04-26 |
| `lib/features/aarti_detail/widgets/mantra_counter_overlay.dart` | `MantraCounterOverlay` — modal Japa Mala counter with haptics, configurable count, and theme-aware modal chrome | 2026-04-26 |
| `lib/features/aarti_detail/widgets/toggle_bar.dart` | `ToggleBar` — segmented control switching Lyrics / Transliteration / Meaning views with theme-aware surfaces | 2026-04-26 |
| `lib/features/aarti_detail/widgets/verse_block.dart` | `VerseBlock` — renders lyrics, transliteration, and meaning using the shared resolver with theme-aware reading contrast | 2026-04-26 |

## Features / My Puja

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/my_puja/my_puja_screen.dart` | `MyPujaScreen` — daily puja playlist with drag-to-reorder, session launcher, and script-aware preview items | 2026-04-26 |
| `lib/features/my_puja/puja_session_screen.dart` | `PujaSessionScreen` — sequential audio puja session with auto-play, crossfade, controls, and script-aware verse preview | 2026-04-26 |
| `lib/features/my_puja/widgets/puja_list_item.dart` | `PujaListItem` — reorderable puja entry with deity badge, script-aware subtitle, and theme-aware sequence/remove controls | 2026-04-26 |

## Features / Contribute

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/contribute/contribute_screen.dart` | `ContributeScreen` — form to create and save personal Aartis locally | 2026-04-25 |

## Features / Home

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/home/home_screen.dart` | `HomeScreen` — devotional home with greeting, Aarti of the Day, festive banner, and theme-aware script-aware recently played previews | 2026-04-26 |

## Features / Onboarding

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/onboarding/onboarding_screen.dart` | `OnboardingScreen` — multi-step welcome flow with default English app language and Devanagari script selection | 2026-04-26 |

## Features / Settings

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `lib/features/settings/settings_screen.dart` | `SettingsScreen` — theme, app language, script language, notification, session settings, diagnostics entries, and theme-aware control chrome | 2026-04-26 |
| `lib/features/settings/dev_tools_screen.dart` | `DevToolsScreen` — diagnostics hub page with Activity Log and Share Activity Log actions | 2026-04-26 |

## Assets

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `assets/data/aarti_catalog.json` | Bundled aarti catalog with all metadata, verses, and tags | 2026-04-20 |
| `assets/data/festivals/hindu_calendar_2026_2028.json` | Bundled Hindu festival calendar (2026–2028) | 2026-04-20 |

## Documentation

| File Path | Purpose | Last Updated |
|-----------|---------|--------------|
| `docs/FILE_REGISTRY.md` | This file — complete file inventory | 2026-04-26 |
| `docs/ARCHITECTURE.md` | Folder structure, patterns, state management, conventions | 2026-04-26 |
| `docs/THEME_AND_DESIGN.md` | Design tokens, colour palette, typography, spacing | 2026-04-20 |
| `docs/FUNCTIONAL_SPEC.md` | Feature list, user flows, acceptance criteria | 2026-04-26 |
| `docs/ANALYTICS_EVENTS.md` | Analytics event registry and naming conventions | 2026-04-26 |
| `docs/CHANGELOG.md` | Chronological log of all changes | 2026-04-26 |
