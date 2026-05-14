# Functional Specification

> Feature list, user flows, acceptance criteria, and business rules for Aarti Sangrah.

---

## 1. Feature Status

| Feature | Status | Version | Screen |
|---------|--------|---------|--------|
| Discover — browse & search Aartis | ✅ Done | v1.0 | `DiscoverScreen` |
| Aarti of the Day (day → deity mapping) | ✅ Done | v1.0 | `TodayHeroCard` |
| Deity filter chips | ✅ Done | v1.0 | `DiscoverScreen` |
| Deity Detail — dedicated browse page with devotional tabs | ✅ Done | v2.8 | `DeityDetailScreen` |
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
| Onboarding flow (name, language, notification) | ✅ Done | v2.0 | `OnboardingScreen` |
| Audio playback (`just_audio`) | ✅ Done | v1.5 | `AudioPlayerWidget` |
| Auto-play in Puja session | ✅ Done | v1.5 | `PujaSessionScreen` |
| Crossfade duration (0–3s) | ✅ Done | v1.5 | `SettingsScreen` |
| Sharing (text + image) | ✅ Done | v1.5 | `SharingService` |
| Daily notification reminder | ✅ Done | v1.5 | `NotificationService` |
| Lightweight user profile/settings sync | ✅ Done | v2.5 | `UserSyncService` |
| Direct Umami analytics with Settings opt-out | ✅ Done | v2.7 | `AnalyticsService` |
| In-app feedback submission | ✅ Done | v2.5 | `FeedbackScreen` |
| Remote content cache sync (n8n-backed festivals + aartis) | ✅ Done | v2.6 | `SettingsScreen`, app bootstrap |
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
6. User can skip from any non-welcome step, which persists the current selections and finishes onboarding immediately.
7. Onboarding marked complete → `HomeShell` displayed with Home tab active.

### 2.2 Discover

1. User opens Discover to find prayers using deity chips, search, and festival filters.
2. User can search by title, deity, Devanagari text, or festival tags.
3. Discover allows only one active filter mode at a time: search, deity, or festival.
4. Entering search text clears any selected deity or festival filter.
5. Selecting a deity clears the search text and any selected festival filter.
6. Selecting a festival clears the search text and resets deity selection to `All`.
7. The deity `All` chip is selected by default and acts as the clear-filter state.
8. Tapping a non-`All` deity chip opens `DeityDetailScreen` for that deity.
9. Festival filter chips show only the next 5 current or upcoming festivals, ordered by nearest date.
10. User taps an Aarti card → navigates to `AartiDetailScreen`.

### 2.2.1 Deity Detail

1. User enters the page from a non-`All` deity chip in Discover.
2. User sees a deity hero with emoji identity, devotional count, related festival context when available, and a consistent shared background treatment across all deity pages.
3. The page groups devotional content into `Aartis`, `Shlokas`, and `Chalisas` tabs using the same segmented control styling as Aarti Detail.
4. The `Shlokas` tab may also include other reading-first devotional types such as stotras, mantras, chants, vandanas, abhangs, and bhajans until a richer taxonomy is introduced.
5. User can switch tabs without losing access to bookmark state or script-aware title rendering.
6. Deity-page devotional cards use the same compact visual language as Discover: saffron top accent, simplified bookmark affordance, optional audio chip, and a footer metadata row for time, verses, and type.
7. User taps a devotional item → navigates to `AartiDetailScreen`.
8. User can bookmark directly from the deity page and the existing bookmark-to-puja sync rule still applies.

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
2. Usage analytics toggle (enabled by default, opt-out persisted locally).
2. Text scale (0.8×–1.6×).
3. App language (English / Hindi / Gujarati).
4. Primary script language (Devanagari / English / Gujarati).
5. Derived secondary script preview driven by app language and primary script.
6. Notification toggle + time picker.
7. Crossfade duration (0–3s).
8. User name edit.
9. Support action opens a dedicated feedback form for devotional corrections, bugs, feature requests, and general feedback.
10. Diagnostics actions: view Activity Log, share log export, and clear log.
11. Content tile shows content counts/source metadata and triggers an immediate content refresh when tapped.
12. DevTools button opens a dedicated diagnostics page with the same Activity Log actions as Settings.

### 2.10 Analytics

1. Analytics is configured during app bootstrap using a stable local analytics session/install ID and the existing stable `user_id`.
2. The app tracks shell tab pageviews centrally from `HomeShell` and tracks pushed pages from their owning screen state.
3. Onboarding, discover, detail, puja, contribute, settings, feedback, and diagnostics actions emit structured analytics events defined in `docs/ANALYTICS_EVENTS.md`, including bookmark saves and explicit My Puja adds.
4. Analytics errors are never shown to the user.
5. Disabling analytics from Settings suppresses future sends on that device.

### 2.7 User Sync

1. Once onboarding is complete, the app maintains a stable local `user_id`, a durable `registration_date`, and a latest `onboarding_date` in `SettingsRepository`.
2. On app startup, returning users trigger an immediate best-effort sync to the configured n8n webhook.
3. Completing onboarding triggers the first forced sync immediately after the identity metadata is written.
4. Updating display name, appearance, text scale, script language, app language, reminder settings, crossfade duration, auto-play, or repeat-current state schedules a trailing debounced sync.
5. Sync payloads include lightweight profile, app-version, device, and settings context only; devotional content, bookmarks, puja lists, and verse data are not exported.
6. Sync failures are logged locally and do not interrupt the user.

### 2.8 Feedback

1. User opens the feedback form from Settings.
2. User chooses a category from Incorrect Lyrics, Translation Issue, Feature Request, Bug Report, or General Feedback using compact selectable chips arranged in an efficient stacked layout.
3. User can optionally provide a contact email for follow-up.
4. User must enter a message and the message must stay within 1000 characters.
5. Submitting feedback sends a payload with `feedback_id`, stable user identity, registration metadata, device context, app version, category, and message to the configured n8n webhook.
6. While the request is in flight, the submit button shows a loading state and prevents duplicate submissions.
7. The message field expands to use the remaining available vertical space in the form instead of leaving empty space below the textbox.
8. When the keyboard opens, the feedback page becomes scrollable above the keyboard so the active input remains reachable without compressing the full form.
9. On success, the screen shows a dedicated success state rather than only a snackbar.
10. On failure, the screen shows an error snackbar and keeps the form contents intact for retry.

### 2.9 Content Refresh

1. App startup restores devotional content from local cache when available, otherwise bundled assets are used.
2. After startup, the app checks whether festival and aarti content are stale using a 24-hour refresh window.
3. When the app resumes from the background, it repeats the same stale check.
4. If either dataset is stale, the app fetches the corresponding n8n GET endpoint and replaces only the successful datasets in memory.
5. Successful responses are cached locally as raw JSON and reused on the next launch.
6. User can open Settings and tap the Content tile to force an immediate refresh regardless of the stale window.
7. The Content tile shows counts, whether the app is using bundled or cached/remote data, and the last refresh time when one exists.

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
| Discover filter exclusivity | Discover applies only one filter mode at a time. Search clears deity and festival state, deity clears search and festival state, and festival clears search while resetting deity to `All`. |
| Discover clear state | The deity `All` chip is the default Discover selection and returns the full catalog when selected. |
| Deity chip destination | Discover deity chips keep `All` as the local clear state, while non-`All` chips open the nested deity detail destination. |
| Deity page devotional grouping | `DeityDetailScreen` shows `Aartis`, `Shlokas`, and `Chalisas`; the `Shlokas` tab temporarily absorbs reading-first devotional types such as stotra, mantra, chant, vandana, abhang, and bhajan until the catalog gains a richer surfaced taxonomy. |
| Discover festival filter ordering | Festival chips show only the next 5 current or upcoming festivals, ordered by nearest date, with duplicate yearly tags collapsed to one chip. |
| Audio default | All aartis share a default audio URL if no specific URL is provided. |
| Puja session auto-play | Plays next Aarti automatically after current finishes (configurable crossfade). |
| Script language default | First-run script language defaults to Devanagari. |
| App language default | First-run app language defaults to English. |
| User sync debounce | Settings-driven sync uses a trailing debounce of 5 seconds. |
| User sync startup refresh | Returning users trigger a forced sync on app launch after onboarding is already complete. |
| User sync privacy boundary | Sync exports lightweight profile and setting state only; it excludes aarti content and personal devotional collections. |
| Analytics enablement | Analytics is enabled by default and can be disabled from Settings via a persisted opt-out toggle. |
| Analytics navigation model | Bottom-nav pageviews are emitted from `HomeShell`, while pushed pages track themselves from their owning screen state. |
| Analytics failure policy | Analytics transport is best-effort only and never surfaces user-facing errors. |
| Content refresh cadence | Festival and aarti content refresh on startup or resume only when the last successful dataset refresh is at least 24 hours old, unless the user manually forces refresh from Settings. |
| Content refresh scope | Festival and aarti payloads refresh independently; one dataset can succeed and replace local content even when the other request fails. |
| Content cache fallback | The app prefers last-good cached content at startup and falls back to bundled assets when cache is missing or invalid. |
| Feedback categories | Feedback categories are devotional-content aware and include Incorrect Lyrics, Translation Issue, Feature Request, Bug Report, and General Feedback. |
| Feedback contact email | Contact email is optional and validated only when the user enters a value. |
| Feedback failure policy | Feedback submission failures are surfaced to the user; they are not treated as silent telemetry. |
| Feedback success state | Successful feedback clears the form and replaces it with a dedicated success surface. |
| Snackbar feedback contract | User-facing transient feedback uses a centralized snackbar helper with semantic success/error/info/warning variants and replace-current behavior. |
| Secondary script rule | Secondary-script surfaces use the app-language reading script; if that script already matches the selected lyric script, they fall back to Devanagari. |
| Meaning fallback | English meanings are shown as the fallback until localized Hindi/Gujarati meaning data exists. |
| Focus Mode progression | Manual focus mode navigation advances and highlights one full verse at a time, not individual lines; taps above the highlighted verse move to the previous verse, and taps on or below it move to the next verse. |
| Focus Mode next CTA | The last-verse "Next Aarti" CTA is only visible when the current Aarti is in My Daily Puja and has a following item in that ordered sequence. |
| Aarti Detail Focus Mode settings | Standalone Focus Mode initializes from the current app reading settings, and the in-focus settings sheet lets the user temporarily switch between the active primary-script language and the derived secondary-script language while adjusting text size for that overlay session only. |
| Puja Focus Session display modes | Puja Focus Session always shows lyrics in the selected script and can optionally switch to the derived secondary script using the same app-language-plus-fallback rule as the detail screen. |
| Puja Focus Session progression | In Puja Focus Session, reaching the first verse can offer a `Previous Aarti` handoff when a prior puja item exists, and reaching the final verse shows `Next Aarti` for intermediate items or `Complete Session` for the final puja item. |
| Puja Focus Session settings | Active script surface and text size are local to the active Focus Session only. Each new Focus Session starts from the current main app settings, the Reading Surface row labels each button with the resolved language name, and the secondary-script surface continues to follow the same derived-script fallback rule. |
| Repeat mode | Loops current Aarti's audio indefinitely until toggled off. |
| Offline | The app works offline with bundled content and last-good cached remote content when available. |
| Theme-aware chrome | Settings controls, My Puja list controls, and Home recently played cards resolve neutral fills, borders, and captions from the current theme instead of fixed light-only tokens. |

---

## 4. Edge Cases

| Scenario | Handling |
|----------|----------|
| No aartis match the active Discover filter | Empty state shown with message |
| Audio URL unreachable | Fail silently — player shows but audio doesn't play |
| Festival calendar exhausted (after 2028) | Festival features degrade gracefully — no banner shown |
| Festival or aarti content webhook unavailable | The failing dataset keeps the last good cached or bundled content while the successful dataset can still update |
| Cached content JSON becomes invalid | The app falls back to bundled assets for that dataset and logs the failure locally |
| Feedback webhook unavailable or returns non-2xx | Form remains visible, snackbar explains the failure, and the user can retry without retyping from scratch |
| Invalid contact email entered in feedback form | Submission is blocked until the email is valid or cleared |
| User hasn't completed onboarding | Redirect to `OnboardingScreen` before `HomeShell` |
| Bookmark an already-bookmarked aarti | Toggles off — removes from bookmarks and puja list |
| Puja list empty | Empty state with CTA to discover aartis |
| Selected reading mode unavailable for the next aarti | Puja Focus Session falls back to the first valid display mode for the new aarti |
| Mantra counter at completion | Heavy haptic burst + visual feedback |
