## [2026-05-01] — User Profile And Settings Sync

### Added
- `lib/core/constants/app_sync_config.dart` — Added compile-time config for the user sync webhook URL, debounce window, and request timeout.
- `lib/core/services/user_sync_service.dart` — Added a best-effort debounced n8n sync service for lightweight user profile and settings payloads.
- `lib/core/utils/device_info_helper.dart` — Added a cross-platform device snapshot helper used by outbound sync payloads.
- `test/user_sync_service_test.dart` — Added focused coverage for payload generation, identity backfill, debounce, force sync, and failure semantics.

### Modified
- `pubspec.yaml` — Added `http`, `device_info_plus`, `package_info_plus`, and `uuid` dependencies for the new sync flow.
- `lib/data/repositories/settings_repository.dart` — Added stable `user_id`, `registration_date`, `onboarding_date`, and sync-friendly serialization helpers.
- `lib/providers/app_providers.dart` — Wired provider-owned settings mutations to schedule debounced user sync after persistence.
- `lib/features/onboarding/onboarding_screen.dart` — Forced the first user sync immediately after onboarding completion.
- `lib/app.dart` — Added returning-user startup sync on app launch.
- `docs/FILE_REGISTRY.md` — Registered the new sync files and refreshed touched file metadata.
- `docs/ARCHITECTURE.md` — Documented the sync service, provider-owned trigger model, and added dependencies.
- `docs/FUNCTIONAL_SPEC.md` — Added the user sync feature flow and business rules.

## [2026-04-27] — Exclusive Discover Filters

### Added
- `test/discover_filter_provider_test.dart` — Added focused Riverpod coverage for exclusive Discover filter state, clear resets, and derived filtered results.

### Modified
- `lib/providers/app_providers.dart` — Replaced independent Discover filter providers with a centralized `DiscoverFilterNotifier` so search, deity, and festival selection are mutually exclusive.
- `lib/features/discover/discover_screen.dart` — Switched Discover to a controlled search field and exclusive filter interactions with deity `All` as the clear state.
- `lib/features/discover/widgets/search_bar.dart` — Added controller support so external filter changes can clear the visible search text.
- `lib/features/discover/widgets/festival_filter_chips.dart` — Removed the synthetic `All Festivals` chip so the row shows only actual festival filters.
- `lib/features/home/home_screen.dart` — Updated the festive-banner Discover handoff to reuse the centralized filter controller.
- `docs/ARCHITECTURE.md` — Documented the dedicated Discover filter controller in the Riverpod state model.
- `docs/FILE_REGISTRY.md` — Refreshed Discover-related file purposes and registered the new provider test.
- `docs/FUNCTIONAL_SPEC.md` — Documented Discover filter exclusivity, the deity `All` clear state, and the updated empty-state rule.

## [2026-04-27] — Upcoming-Only Festival Filters

### Modified
- `lib/data/models/festival.dart` — Removed the no-longer-used recent-past festival helpers after simplifying Discover festival ordering.
- `lib/data/repositories/festival_repository.dart` — Simplified Discover festival tags to return only the nearest current or upcoming festivals, capped at 5 chips.
- `test/festival_repository_test.dart` — Replaced recent-past retention coverage with focused verification for upcoming-only ordering and the 5-chip limit.
- `docs/FILE_REGISTRY.md` — Updated festival data and test file descriptions for the simplified filter behavior.
- `docs/FUNCTIONAL_SPEC.md` — Replaced the recent-past retention rule with the upcoming-only, max-5 chip rule.

## [2026-04-27] — Calendar-Ordered Festival Filters

### Added
- `test/festival_repository_test.dart` — Added focused repository coverage for active, upcoming, duplicate-tag, and recent-past festival filter ordering.

### Modified
- `lib/data/models/festival.dart` — Added recent-past date helpers so calendar relevance can retain ended festivals for a limited window.
- `lib/data/repositories/festival_repository.dart` — Added calendar-driven festival tag ordering for Discover, promoting active festivals first, upcoming festivals next, and recent past festivals for up to 5 days.
- `lib/features/discover/discover_screen.dart` — Switched festival filter chips from alphabetical catalog tags to the repository’s calendar-ordered tag list.
- `docs/FILE_REGISTRY.md` — Updated Discover and festival data file metadata and registered the new repository test.
- `docs/FUNCTIONAL_SPEC.md` — Documented the date-aware Discover festival chip ordering and 5-day recent-past retention rule.

## [2026-04-27] — Focus Settings Language-Only Surface Buttons

### Modified
- `lib/shared/widgets/focus_mode_settings_sheet.dart` — Removed the separate Primary Script selector, reduced the Reading Surface buttons to language-only labels, and tightened the text-size layout.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Removed now-unused focus-settings primary-script plumbing from standalone Focus Mode.
- `lib/features/my_puja/puja_focus_session_screen.dart` — Removed now-unused focus-settings primary-script plumbing from My Puja Focus Session.
- `docs/FILE_REGISTRY.md` — Updated focus-settings file purposes for the language-only Reading Surface controls.
- `docs/FUNCTIONAL_SPEC.md` — Replaced primary-script selector wording with the simplified language-only Reading Surface behavior.

## [2026-04-27] — Focus Settings Primary/Secondary Script Controls

### Modified
- `lib/shared/widgets/focus_mode_settings_sheet.dart` — Replaced the secondary-script toggle with explicit Primary Script and Secondary Script selectors and compacted the text-size control layout.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Updated standalone Focus Mode to use the new shared script-surface selection model.
- `lib/features/my_puja/puja_focus_session_screen.dart` — Updated My Puja Focus Session to use the same Primary Script / Secondary Script selection model as standalone Focus Mode.
- `docs/FILE_REGISTRY.md` — Refreshed focus-settings file purposes for the explicit script-surface controls.
- `docs/FUNCTIONAL_SPEC.md` — Replaced secondary-script toggle wording with explicit Primary Script / Secondary Script settings behavior.

## [2026-04-27] — Standalone Focus Mode Header And Temporary Settings

### Added
- `lib/shared/widgets/focus_mode_settings_sheet.dart` — Added a shared temporary reading-settings bottom sheet reused by standalone Focus Mode and My Puja Focus Session.

### Modified
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Aligned standalone Focus Mode with the puja-session header chrome and added session-local script, secondary-script, and text-size overrides that reset when the overlay is reopened.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Extended the centered header layout to show verse progress so the same header works for both standalone and puja focus flows.
- `lib/features/my_puja/puja_focus_session_screen.dart` — Reused the shared focus settings sheet to keep temporary reading controls aligned with standalone Focus Mode.
- `docs/FILE_REGISTRY.md` — Registered the shared focus settings sheet and refreshed focus-mode file purposes.
- `docs/ARCHITECTURE.md` — Documented the shared focus settings sheet pattern alongside the reused focus-reading surface.
- `docs/FUNCTIONAL_SPEC.md` — Added the standalone Focus Mode temporary-settings behavior and centered-header parity with the puja focus session.

## [2026-04-27] — Derived Secondary Script Reading Mode

### Modified
- `lib/shared/utils/aarti_language_resolver.dart` — Added shared secondary-script derivation and line/title resolution based on app language with a Devanagari fallback when the selected lyric script already matches.
- `lib/features/settings/settings_screen.dart` — Renamed the existing script selector to primary script and added a derived secondary-script summary used by reading and focus mode.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Switched the dynamic second reader tab from a fixed Transliteration label to the derived secondary-script label.
- `lib/features/aarti_detail/widgets/verse_block.dart` — Updated the second reading surface to render the derived secondary-script lines instead of Roman-only transliteration.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Made focus reading render the derived secondary script and use the matching dynamic label in fallback content.
- `lib/features/my_puja/puja_focus_session_screen.dart` — Updated focus-session reading controls to use the same derived secondary-script rule and copy as the detail screen.
- `docs/FILE_REGISTRY.md` — Refreshed file purposes and last-updated dates for the derived secondary-script feature.
- `docs/ARCHITECTURE.md` — Documented the shared derived secondary-script rule in the language-resolution architecture.
- `docs/FUNCTIONAL_SPEC.md` — Updated the detail, settings, and focus-session flows to reflect the derived secondary-script behavior.

## [2026-04-26] — My Puja Focus Session

### Added
- `lib/features/my_puja/puja_focus_session_screen.dart` — Added a dedicated full-screen reading session for the My Daily Puja order with in-session controls for reading mode, script, and text size.

### Modified
- `lib/features/my_puja/my_puja_screen.dart` — Added a second `Focus Session` launcher alongside the existing audio session CTA.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Generalized the focus-reading surface to support lyrics, transliteration, and meaning plus puja-session progress and completion CTAs.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Passed the current reading mode, app language, and text scale into Focus Mode so the overlay matches the active detail-screen reading surface.
- `docs/FILE_REGISTRY.md` — Registered the new My Puja focus-session screen and refreshed related file purposes.
- `docs/ARCHITECTURE.md` — Documented the new My Puja screen and the reuse of the focus-reading surface across flows.
- `docs/FUNCTIONAL_SPEC.md` — Added the My Puja Focus Session flow, business rules, and edge case coverage.
- `docs/ANALYTICS_EVENTS.md` — Added planned event definitions for focus-session start, mode changes, completion, and exit.

## [2026-04-26] — Puja Focus Session Header And Reader Controls Refinement

### Modified
- `lib/features/my_puja/puja_focus_session_screen.dart` — Aligned the focus-session header with the audio session layout, replaced the reading-surface selector with script plus optional transliteration controls, and fixed the live text-size percentage display in the settings sheet.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Added an optional session-style centered header layout so the shared reading surface can match the puja session chrome without changing detail-screen Focus Mode.
- `docs/FILE_REGISTRY.md` — Refreshed file purposes for the focus-session header and settings refinement.
- `docs/FUNCTIONAL_SPEC.md` — Updated the Focus Session flow and business rules to reflect script-first controls with optional transliteration.

## [2026-04-27] — Puja Focus Session Sequence Controls

### Modified
- `lib/features/my_puja/puja_focus_session_screen.dart` — Added puja-level progress dots, previous-aarti handoff, and a two-option script selector that always offers English plus the preferred non-English script with a Devanagari fallback.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Extended the shared reading surface to render session progress dots and a previous-aarti CTA at the start of an aarti when the puja sequence has a predecessor.
- `docs/FILE_REGISTRY.md` — Updated the Focus Session and overlay file purposes for the puja-sequence refinement.
- `docs/FUNCTIONAL_SPEC.md` — Documented the puja-level progress dots, previous-aarti handoff, and two-option script rule.

## [2026-04-27] — Temporary Focus Session Settings

### Modified
- `lib/features/my_puja/puja_focus_session_screen.dart` — Switched Focus Session script and text-size controls from global provider writes to session-local state initialized from the main settings when the session opens.
- `docs/FILE_REGISTRY.md` — Refreshed the Focus Session file purpose to reflect temporary in-session overrides.
- `docs/FUNCTIONAL_SPEC.md` — Clarified that Focus Session settings are temporary and rehydrate from the main settings on each new launch.

## [2026-04-26] — Focus Mode Tap Zones + Puja Next CTA

### Modified
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Changed focus-mode tap behavior so taps above the highlighted verse go to the previous verse, taps on or below it go forward, and the last verse can show a dark-mode-consistent next-aarti CTA when a puja-sequence successor exists.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Reused the detail-screen puja navigation callback for both the floating next FAB and the focus-mode last-verse CTA.
- `docs/FILE_REGISTRY.md` — Refreshed Aarti Detail metadata for the focus-mode interaction and sequence handoff updates.
- `docs/FUNCTIONAL_SPEC.md` — Documented the new focus-mode tap-zone rule and the last-verse next-aarti CTA visibility rule.

## [2026-04-26] — Settings, My Puja, and Home Theme Contrast Fix

### Modified
- `lib/features/settings/settings_screen.dart` — Reworked settings controls, diagnostics sheet, and selector chrome to use theme-aware neutral surfaces and captions in dark mode.
- `lib/features/my_puja/widgets/puja_list_item.dart` — Updated the sequence badge, drag handle, duration text, play affordance, and remove button to use theme-aware neutral styling.
- `lib/features/home/home_screen.dart` — Updated the Recently Played card surface, border, and text colors to resolve from the current theme.
- `docs/FILE_REGISTRY.md` — Refreshed metadata for the touched Settings, My Puja, and Home files.
- `docs/FUNCTIONAL_SPEC.md` — Added a business rule clarifying theme-aware chrome across these surfaces.

## [2026-04-26] — Aarti Detail Theme Contrast Fix

### Modified
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Replaced remaining light-only reader surfaces with theme-aware colors for the back row, bookmark affordance, script subtitle, verse progress pill, share sheet, and next FAB.
- `lib/features/aarti_detail/widgets/action_chip.dart` — Switched neutral chip fill, border, and text colors to theme-aware values and tuned the primary chip for dark mode.
- `lib/features/aarti_detail/widgets/toggle_bar.dart` — Made the tab track and active pill resolve from theme-aware surfaces instead of fixed light-theme tokens.
- `lib/features/aarti_detail/widgets/verse_block.dart` — Fixed dark-mode lyric, transliteration, meaning, and divider contrast by using theme-aware text and border colors.
- `lib/features/aarti_detail/widgets/audio_player_widget.dart` — Updated the sticky player glass surface, controls, and text colors for dark-mode readability.
- `lib/features/aarti_detail/widgets/mantra_counter_overlay.dart` — Updated the counter modal, preset chips, and primary action button to respect light and dark themes.
- `docs/FILE_REGISTRY.md` — Refreshed Aarti Detail file metadata to reflect the theme-aware surface updates.
# Changelog

All notable changes to the Aarti Sangrah project are documented here.

---

## [2026-04-26] — Puja-Aware Detail Next Navigation

### Modified
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Restricted the detail-screen "Next" FAB to Aartis that are part of My Daily Puja and wired it to open the next Aarti in puja order instead of popping the current screen.
- `docs/FILE_REGISTRY.md` — Updated the detail-screen file purpose to include puja-aware next navigation.
- `docs/FUNCTIONAL_SPEC.md` — Documented the My Puja-only visibility rule and sequential navigation behavior for the detail-screen "Next" FAB.

## [2026-04-26] — App Language + Script Language Unification

### Added
- `lib/shared/utils/aarti_language_resolver.dart` — Added a shared resolver for script-aware titles, lyric lines, transliteration tab visibility, and English meaning fallback.

### Modified
- `lib/data/repositories/settings_repository.dart` — Changed the default app language to English while keeping Devanagari as the default script language.
- `lib/providers/app_providers.dart` — Clarified provider-backed script language semantics alongside the existing app language preference.
- `lib/features/settings/settings_screen.dart` — Added a dedicated App Language selector and renamed script wording to English / Devanagari / Gujarati.
- `lib/features/onboarding/onboarding_screen.dart` — Defaulted app language to English and aligned script labels with the new wording.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Refactored detail tabs to dynamic Lyrics / Transliteration / Meaning content driven by global app-language and script-language settings.
- `lib/features/aarti_detail/widgets/verse_block.dart` — Switched verse rendering to the shared resolver for lyrics, transliteration, and English meaning fallback.
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Made Focus Mode respect the selected script language while preserving verse-based progression and balanced line splitting.
- `lib/features/discover/discover_screen.dart` — Passed the selected script language into discovery card previews.
- `lib/features/discover/widgets/aarti_card.dart` — Rendered script-aware aarti subtitle previews.
- `lib/features/discover/widgets/today_hero_card.dart` — Rendered script-aware subtitle previews for the Aarti of the Day card.
- `lib/features/home/home_screen.dart` — Applied script-aware recent and hero preview wiring.
- `lib/features/my_puja/my_puja_screen.dart` — Passed the selected script language into puja list items.
- `lib/features/my_puja/widgets/puja_list_item.dart` — Rendered script-aware aarti subtitle previews.
- `lib/features/my_puja/puja_session_screen.dart` — Rendered script-aware title subtitles and verse previews during puja sessions.
- `docs/FILE_REGISTRY.md` — Registered the shared resolver and updated touched file metadata.
- `docs/ARCHITECTURE.md` — Documented the shared language resolver pattern and the split app-language/script-language state model.
- `docs/FUNCTIONAL_SPEC.md` — Documented the new settings, defaults, dynamic transliteration rule, and English meaning fallback.

## [2026-04-26] — Verse-Based Focus Mode

### Modified
- `lib/features/aarti_detail/widgets/focus_mode_overlay.dart` — Changed Sadhana Mode navigation and highlighting from line-by-line to verse-by-verse, including grouped verse rendering, verse-wide balanced splits when any line in a verse needs wrapping, configurable spacing between verse lines, and single-verse progress.
- `docs/FILE_REGISTRY.md` — Refreshed Focus Mode widget metadata for the verse-by-verse behavior.
- `docs/FUNCTIONAL_SPEC.md` — Documented verse-based Focus Mode progression in the detail flow and business rules.

## [2026-04-26] — Activity Log Diagnostics

### Added
- `lib/core/constants/app_constants.dart` — Added cross-cutting app constants for Activity Log retention and JSONL file naming.
- `lib/core/services/activity_log_service.dart` — Added static file-backed JSONL activity log service with init, info/warn/error, read, clear, and share APIs.

### Modified
- `pubspec.yaml` — Added `path_provider` dependency for Activity Log file persistence/export paths.
- `lib/main.dart` — Added Activity Log initialization plus global Flutter/Zone error capture hooks.
- `lib/core/services/sharing_service.dart` — Added Activity Log success/failure reporting for share actions.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Added warning logging for audio initialization failures.
- `lib/features/settings/settings_screen.dart` — Added diagnostics section with Activity Log viewer, share export, clear actions, and visible DevTools navigation.
- `lib/features/settings/dev_tools_screen.dart` — Added dedicated DevTools diagnostics hub with Activity Log and Share Activity Log actions.
- `docs/FILE_REGISTRY.md` — Registered Activity Log files and updated touched-file metadata.
- `docs/ARCHITECTURE.md` — Documented Activity Log service, global error hooks, and new dependency.
- `docs/FUNCTIONAL_SPEC.md` — Added Activity Log diagnostics feature and Settings flow update.
- `docs/ANALYTICS_EVENTS.md` — Added planned diagnostics interaction events.

## [2026-04-25] — Home/Discover Split + Temple Dock Navigation

### Added
- `lib/features/home/home_screen.dart` — New Home screen with greeting, Aarti of the Day, festive banner, and recently played sections.
- `lib/navigation/widgets/app_bottom_nav.dart` — Temple Dock style bottom navigation used as the primary top-level navigation.

### Modified
- `lib/navigation/home_shell.dart` — Switched from drawer-mounted navigation to bottom-nav-only shell with shared tab selection logic.
- `lib/features/discover/discover_screen.dart` — Focused Discover on search/browse/filter/grid flows only.
- `lib/features/home/home_screen.dart` — Added optional callback to jump from festive banner to Discover with deity preselected.
- `lib/shared/widgets/aarti_app_bar.dart` — Added `showMenu` option so top bars can hide menu affordance in bottom-nav mode.
- `lib/features/my_puja/my_puja_screen.dart` — Updated top app bar usage to bottom-nav-only layout.
- `lib/features/contribute/contribute_screen.dart` — Updated top app bar usage to bottom-nav-only layout.
- `lib/features/settings/settings_screen.dart` — Updated top app bar usage to bottom-nav-only layout.
- `lib/navigation/app_drawer.dart` — Kept as legacy component; no longer mounted by `HomeShell`.
- `docs/FILE_REGISTRY.md` — Registered new files and refreshed purposes/last-updated entries.
- `docs/ARCHITECTURE.md` — Updated navigation architecture to bottom-nav-first model.
- `docs/FUNCTIONAL_SPEC.md` — Updated user flows for primary navigation and Discover scope.

## [2026-04-20] — Project Standardisation

### Added
- `lib/core/theme/app_spacing.dart` — Centralised spacing tokens (`AppSpacing`) for consistent padding, margin, gap, and radius values across the entire app.
- `lib/shared/` — New shared directory structure with `widgets/`, `painters/`, `utils/`, `extensions/`, `models/` sub-folders.
- `docs/FILE_REGISTRY.md` — Complete file inventory with purpose and last-updated date.
- `docs/ARCHITECTURE.md` — Folder structure, patterns, state management, naming conventions, and dependency documentation.
- `docs/THEME_AND_DESIGN.md` — Full design system documentation: colour palette, typography scale, spacing tokens, component styles, dark mode strategy, accessibility.
- `docs/FUNCTIONAL_SPEC.md` — Feature list with status, user flows, acceptance criteria, business rules, and edge cases.
- `docs/ANALYTICS_EVENTS.md` — Event registry with naming conventions for future analytics integration.
- `docs/CHANGELOG.md` — This file.

### Modified
- `lib/core/theme/app_typography.dart` — Renamed class from `AppTextStyles` to `AppTypography` to match file name convention.
- `lib/shared/widgets/aarti_app_bar.dart` — Moved from `lib/widgets/`; updated import paths.
- `lib/shared/widgets/gradient_divider.dart` — Moved from `lib/widgets/`; updated import paths.
- `lib/shared/widgets/section_label.dart` — Moved from `lib/widgets/`; updated import paths and class reference.
- `lib/shared/painters/mala_painter.dart` — Moved from `lib/painters/`; updated import paths.
- All 21 files importing `app_text_styles.dart` — Updated to `app_typography.dart`.
- All 21 files referencing `AppTextStyles` — Updated to `AppTypography`.
- All 6 files importing from `widgets/` — Updated to `shared/widgets/`.
- 1 file importing from `painters/` — Updated to `shared/painters/`.

### Removed
- `lib/widgets/` — Empty directory removed (contents moved to `lib/shared/widgets/`).
- `lib/painters/` — Empty directory removed (contents moved to `lib/shared/painters/`).
