# Changelog

All notable changes to the Aarti Sangrah project are documented here.

---

## [2026-04-26] — Activity Log Diagnostics

### Added
- `lib/core/constants/app_constants.dart` — Added cross-cutting app constants for Activity Log retention and JSONL file naming.
- `lib/core/services/activity_log_service.dart` — Added static file-backed JSONL activity log service with init, info/warn/error, read, clear, and share APIs.

### Modified
- `pubspec.yaml` — Added `path_provider` dependency for Activity Log file persistence/export paths.
- `lib/main.dart` — Added Activity Log initialization plus global Flutter/Zone error capture hooks.
- `lib/core/services/sharing_service.dart` — Added Activity Log success/failure reporting for share actions.
- `lib/features/aarti_detail/aarti_detail_screen.dart` — Added warning logging for audio initialization failures.
- `lib/features/settings/settings_screen.dart` — Added diagnostics section with Activity Log viewer, share export, and clear actions.
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
