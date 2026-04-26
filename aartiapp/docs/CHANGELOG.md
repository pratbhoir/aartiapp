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
