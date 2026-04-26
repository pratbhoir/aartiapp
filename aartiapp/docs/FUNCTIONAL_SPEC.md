# Functional Specification

> Feature list, user flows, acceptance criteria, and business rules for Aarti Sangrah.

---

## 1. Feature Status

| Feature | Status | Version | Screen |
|---------|--------|---------|--------|
| Discover — browse & search Aartis | ✅ Done | v1.0 | `DiscoverScreen` |
| Aarti of the Day (day → deity mapping) | ✅ Done | v1.0 | `TodayHeroCard` |
| Deity filter chips | ✅ Done | v1.0 | `DiscoverScreen` |
| Full-text search (title, deity, devanagari, tags) | ✅ Done | v1.0 | `SearchEngine` |
| Aarti Detail — lyrics with Devanagari / Transliteration / Meaning | ✅ Done | v1.0 | `AartiDetailScreen` |
| Bookmark toggle | ✅ Done | v1.0 | `AartiDetailScreen`, `AartiCard` |
| My Daily Puja — ordered playlist with drag-to-reorder | ✅ Done | v1.0 | `MyPujaScreen` |
| My Daily Puja — Focus Session | ✅ Done | v2.3 | `PujaFocusSessionScreen` |
| Focus Mode (Sadhana Mode) | ✅ Done | v1.0 | `FocusModeOverlay` |
| Mantra Counter (configurable count, Mala bead ring) | ✅ Done | v1.0 | `MantraCounterOverlay` |
| Text size control (A–/A+) | ✅ Done | v1.0 | `SettingsScreen` |
| Dark / Light / System theme | ✅ Done | v1.0 | `SettingsScreen` |
| Script language setting (Devanagari / English / Gujarati) | ✅ Done | v1.0 | `SettingsScreen` |
| Derived secondary script surface | ✅ Done | v2.4 | `SettingsScreen`, `AartiDetailScreen`, `FocusModeOverlay` |
| App language setting (English / Hindi / Gujarati) | ✅ Done | v2.2 | `SettingsScreen` |
| Verse progress indicator | ✅ Done | v1.0 | `AartiDetailScreen` |
| Haptic feedback (scoped) | ✅ Done | v1.0 | `AppHaptics` |
| Onboarding flow (name, language, notification, deity) | ✅ Done | v2.0 | `OnboardingScreen` |
| Audio playback (`just_audio`) | ✅ Done | v1.5 | `AudioPlayerWidget` |
| Auto-play in Puja session | ✅ Done | v1.5 | `PujaSessionScreen` |
| Crossfade duration (0–3s) | ✅ Done | v1.5 | `SettingsScreen` |
| Sharing (text + image) | ✅ Done | v1.5 | `SharingService` |
| Daily notification reminder | ✅ Done | v1.5 | `NotificationService` |
| Festival banner (bundled calendar 2026–2028) | ✅ Done | v1.5 | `FestiveBanner` |
| Festival tag filtering | ✅ Done | v1.5 | `FestivalFilterChips` |
| "Next" FAB for My Puja sequence (90% audio or scroll-to-bottom) | ✅ Done | v2.2 | `AartiDetailScreen` |
| Personal Collection (local private aartis) | ✅ Done | v2.0 | `ContributeScreen` |
| Recently played section | ✅ Done | v2.0 | `DiscoverScreen` |
| Gujarati script support | ✅ Done | v2.0 | Data + `VerseBlock` |
| Activity Log diagnostics (local JSONL, view/share/clear) | ✅ Done | v2.1 | `SettingsScreen` + `ActivityLogService` |
| Community contributor moderation | 🔮 Planned | v3.0 (backend) | — |
| Report incorrect lyrics | 🔮 Planned | v3.0 (backend) | — |
| User authentication + cloud sync | 🔮 Planned | v3.0 (backend) | — |

---

## 2. User Flows

### 2.0 Primary Navigation

1. User navigates between Home, Discover, My Daily Puja, My Collection, and Settings via the bottom navigation dock.
2. Active tab state is visually highlighted and preserved in `HomeShell`.
3. Section transitions use shell-level fade + slight upward motion.

### 2.1 First Launch (Onboarding)

1. User opens app → `OnboardingScreen` displayed.
2. **Step 1 — Welcome:** App title, description, "Begin" button.
3. **Step 2 — Name:** User enters their name (stored in `SettingsRepository`).
4. **Step 3 — Language:** User selects preferred script (Devanagari / English / Gujarati) and app language (English / Hindi / Gujarati).
5. **Step 4 — Notification:** User sets daily puja reminder time (optional).
6. **Step 5 — Deity:** User selects favourite deity (sets initial filter).
7. Onboarding marked complete → `HomeShell` displayed with Home tab active.

### 2.2 Discover

1. User opens Discover to find prayers using deity chips, search, and festival filters.
2. User can search by title, deity, Devanagari text, or festival tags.
3. User can filter by deity chips (horizontal scroll) or festival tags.
4. Festival filter chips show only the next 5 current or upcoming festivals, ordered by nearest date.
5. User taps an Aarti card → navigates to `AartiDetailScreen`.

### 2.3 Aarti Detail

1. User sees title, deity, and a script-aware subtitle when the selected script differs from the English title.
2. User toggles between Lyrics / Secondary Script / Meaning views.
3. `Lyrics` always uses the global Script Language preference.
4. `Secondary Script` always uses the derived secondary script: it follows the app-language reading script, and falls back to Devanagari when that would otherwise match the selected lyric script.
5. `Meaning` uses the app language translation surface, with English meaning as the fallback until localized Hindi/Gujarati meaning data exists.
6. User can:
   - **Bookmark** the Aarti (auto-adds to puja list).
   - **Add to Puja** directly.
   - **Play audio** via sticky bottom player.
   - **Enter Focus Mode** for distraction-free verse-by-verse reading with tap-above for previous and tap-on-or-below for next navigation.
   - **Open Mantra Counter** for Japa meditation.
   - **Share** lyrics as text or image.
7. Audio player shows progress, seek ±10s, repeat toggle.
8. When the current Aarti belongs to My Daily Puja and has a following item in that ordered sequence, a "Next" FAB appears at 90% audio progress or scroll-to-bottom.
9. Tapping "Next" opens the next Aarti detail screen in the user's current My Daily Puja order.
10. In Focus Mode, reaching the last verse shows a dark-mode-consistent "Next Aarti" CTA only when the current Aarti has a following item in the user's My Daily Puja order.
11. Standalone Focus Mode uses the same centered header chrome as My Daily Puja Focus Session, including a temporary settings sheet with language-only reading-surface buttons for the active primary and derived secondary scripts plus a compact text-size control that resets when Focus Mode is reopened.

### 2.4 My Daily Puja

1. User sees their ordered puja list.
2. User can drag-to-reorder entries.
3. User can remove entries.
4. User taps `Start Session` → `PujaSessionScreen` for audio-led playback.
5. User taps `Focus Session` → `PujaFocusSessionScreen` for verse-by-verse reading.
6. Audio session plays through aartis sequentially with auto-play and crossfade.
7. Focus Session reuses the Focus Mode interaction model with a full-screen reading surface, verse progression, a session-style centered header, puja-level progress dots, and boundary CTAs for previous/next aarti handoff.
8. Focus Session exposes in-session reading controls for a compact text-size stepper and a language-only Reading Surface selector that switches between the active primary script and the derived secondary script using the same fallback rule as detail reading.
9. Focus Session settings are temporary for the active session only; reopening Focus Session re-initializes them from the main app settings.

### 2.5 Personal Collection (Contribute)

1. User can create a new private Aarti with title, deity, and verses.
2. Saved locally via `UserAartiRepository`.
3. User's aartis appear in their collection and can be added to puja.

### 2.6 Settings

1. Theme mode (System / Light / Dark).
2. Text scale (0.8×–1.6×).
3. App language (English / Hindi / Gujarati).
4. Primary script language (Devanagari / English / Gujarati).
5. Derived secondary script preview driven by app language and primary script.
6. Notification toggle + time picker.
7. Crossfade duration (0–3s).
8. User name edit.
9. Diagnostics actions: view Activity Log, share log export, and clear log.
10. DevTools button opens a dedicated diagnostics page with the same Activity Log actions as Settings.

---

## 3. Business Rules

| Rule | Description |
|------|-------------|
| Bookmark ↔ Puja sync | Bookmarking an Aarti auto-adds it to the puja list. Unbookmarking removes it. |
| Aarti detail next navigation | The detail-screen "Next" FAB is only available for Aartis that are currently in My Daily Puja and are not the final item in the puja order. |
| Aarti of the Day | Deterministic: `DateTime.now().weekday` → deity → first matching Aarti in catalog. |
| Recently played | Max 20 items, most recent first, duplicates removed on re-add. |
| Mantra counter presets | 11, 21, 27, 108, 1008 — user selects before starting. |
| Festival calendar | Pre-calculated dates for 2026–2028. Supports single-day and multi-day ranges. |
| Discover festival filter ordering | Festival chips show only the next 5 current or upcoming festivals, ordered by nearest date, with duplicate yearly tags collapsed to one chip. |
| Audio default | All aartis share a default audio URL if no specific URL is provided. |
| Puja session auto-play | Plays next Aarti automatically after current finishes (configurable crossfade). |
| Script language default | First-run script language defaults to Devanagari. |
| App language default | First-run app language defaults to English. |
| Secondary script rule | Secondary-script surfaces use the app-language reading script; if that script already matches the selected lyric script, they fall back to Devanagari. |
| Meaning fallback | English meanings are shown as the fallback until localized Hindi/Gujarati meaning data exists. |
| Focus Mode progression | Manual focus mode navigation advances and highlights one full verse at a time, not individual lines; taps above the highlighted verse move to the previous verse, and taps on or below it move to the next verse. |
| Focus Mode next CTA | The last-verse "Next Aarti" CTA is only visible when the current Aarti is in My Daily Puja and has a following item in that ordered sequence. |
| Aarti Detail Focus Mode settings | Standalone Focus Mode initializes from the current app reading settings, and the in-focus settings sheet lets the user temporarily switch between the active primary-script language and the derived secondary-script language while adjusting text size for that overlay session only. |
| Puja Focus Session display modes | Puja Focus Session always shows lyrics in the selected script and can optionally switch to the derived secondary script using the same app-language-plus-fallback rule as the detail screen. |
| Puja Focus Session progression | In Puja Focus Session, reaching the first verse can offer a `Previous Aarti` handoff when a prior puja item exists, and reaching the final verse shows `Next Aarti` for intermediate items or `Complete Session` for the final puja item. |
| Puja Focus Session settings | Active script surface and text size are local to the active Focus Session only. Each new Focus Session starts from the current main app settings, the Reading Surface row labels each button with the resolved language name, and the secondary-script surface continues to follow the same derived-script fallback rule. |
| Repeat mode | Loops current Aarti's audio indefinitely until toggled off. |
| Offline | All content is bundled — the app works fully offline. |
| Theme-aware chrome | Settings controls, My Puja list controls, and Home recently played cards resolve neutral fills, borders, and captions from the current theme instead of fixed light-only tokens. |

---

## 4. Edge Cases

| Scenario | Handling |
|----------|----------|
| No aartis match deity + search + festival filter | Empty state shown with message |
| Audio URL unreachable | Fail silently — player shows but audio doesn't play |
| Festival calendar exhausted (after 2028) | Festival features degrade gracefully — no banner shown |
| User hasn't completed onboarding | Redirect to `OnboardingScreen` before `HomeShell` |
| Bookmark an already-bookmarked aarti | Toggles off — removes from bookmarks and puja list |
| Puja list empty | Empty state with CTA to discover aartis |
| Selected reading mode unavailable for the next aarti | Puja Focus Session falls back to the first valid display mode for the new aarti |
| Mantra counter at completion | Heavy haptic burst + visual feedback |
