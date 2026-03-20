# Aarti Sangrah — Product Strategy & Implementation Plan

**Version:** 1.0  
**Date:** March 20, 2026  
**Constraint:** Standalone application — no backend, no Firebase, no external APIs  
**Current State:** Single-file Flutter monolith (2,631 LOC), static data, simulated audio, no persistence

---

## 1. Executive Summary

This document evaluates 25+ recommendations from the feature review, classifies each by feasibility under the **standalone (no-backend) constraint**, and produces a phased implementation roadmap. Of the total recommendations, **~80% are fully implementable** without a backend using local storage, bundled assets, and client-side logic. The remaining ~20% are either deferred to a backend phase or adapted into reduced-scope local alternatives.

---

## 2. Recommendation Verdict Matrix

### Legend
| Symbol | Meaning |
|--------|---------|
| ✅ | Fully implementable standalone |
| ⚠️ | Implementable with reduced scope / adaptation |
| ❌ | Requires backend — defer entirely |
| 🔧 | Already partially exists — needs refinement |

---

### 2.1 — "Well-Conceived" Features (Current State Assessment)

| # | Feature | Status | Verdict | Notes |
|---|---------|--------|---------|-------|
| 1 | My Daily Puja (ordered bookmarks) | 🔧 Exists as `StatelessWidget`, no actual reorder | ✅ Implement | Convert to `ReorderableListView`, persist order with `SharedPreferences`/Hive |
| 2 | Aarti of the Day | 🔧 Hero card exists, hardcoded | ✅ Implement | Map day-of-week → deity using `DateTime.now().weekday`. Pure client logic |
| 3 | Transliteration & Meaning toggle | 🔧 Exists, functional | ✅ Done | Already works via `_ToggleBar` + `_viewMode`. Needs data expansion for all Aartis |
| 4 | Offline capability | 🔧 Flag exists, no implementation | ✅ Implement | Bundle all content as app assets. Everything is offline by default in standalone mode |
| 5 | Focus Mode / Teleprompter | 🔧 Exists, basic | ✅ Refine | Add auto-scroll timer, verse cycling, and make it the default during "Start Session" |
| 6 | Glassmorphic audio player | 🔧 Exists, simulated | ✅ Implement | Replace simulation with `just_audio` + bundled MP3/OGG assets |

---

### 2.2 — Corrections & Refinements

| # | Recommendation | Verdict | Standalone Strategy |
|---|---------------|---------|---------------------|
| 7 | **Auto-Play within "My Daily Puja" only** (not global library) | ✅ Implement | Scoped auto-play is pure UI logic. Add `autoPlay` and `repeatCurrent` flags to Puja session state. Crossfade duration (0–3s) stored in `SharedPreferences` |
| 8 | **Mantra Counter: configurable count** (11, 21, 27, 108, 1008) | ✅ Implement | Replace hardcoded `108` with user-selectable preset list. Add haptic burst (`HapticFeedback.heavyImpact()`) on completion. Lotus bloom Lottie animation on cycle finish |
| 9 | **Mantra Counter: Mala visualization** (circular bead string) | 🔧 Already exists | ✅ Refine | `_MalaPainter` already renders 27-bead ring. Adjust bead count proportionally to selected total (e.g., 27 visible beads for any total). Already good |
| 10 | **Festive Push / Dynamic festival highlights** | ⚠️ Partial | Use a **bundled JSON Hindu calendar** with dates pre-calculated for 2026–2028. Accept that lunar-calendar drift requires an app update every 2–3 years. Viable for standalone v1. Include Vikram Samvat calculations or use a hardcoded festival date list |
| 11 | **"Next" FAB trigger logic** (90% audio OR scroll-to-bottom) | ✅ Implement | Attach `ScrollController` to detect `maxScrollExtent` and `AnimationController` listener for audio progress ≥ 0.9. Trigger FAB on whichever fires first |
| 12 | **Haptic Feedback scoping** | ✅ Implement | `lightImpact` on page transitions, `mediumImpact` on Mantra tap, `selectionClick` on bookmark toggle. Remove end-of-scroll haptic |
| 13 | **Typography: Noto Serif Devanagari** | ✅ Implement | Add `google_fonts` package. Use `Noto Serif Devanagari` for lyrics, `Lora` or `EB Garamond` for transliteration/English text. Bundle fonts as assets for offline guarantee |
| 14 | **Design palette: concrete hex values** | ✅ Implement | Update `AppColors` with specified hex values. Already a simple constant swap |

**Palette to implement:**

| Token | Hex | Use |
|-------|-----|-----|
| Temple Stone (bg) | `#F5F2ED` | Scaffold background |
| Temple Stone (secondary text) | `#8C8880` | Captions, metadata |
| Deep Saffron | `#E8820C` | Primary CTAs only — sparingly |
| Sacred White | `#FDFAF6` | Card backgrounds |
| Text Primary (warm near-black) | `#2C2420` | Body text, titles |

---

### 2.3 — Missing Features (New)

| # | Recommendation | Verdict | Standalone Strategy |
|---|---------------|---------|---------------------|
| 15 | **Language / Script Selection** | ⚠️ Partial | Support **Devanagari** and **Roman transliteration** in v1 (data already exists). Gujarati/Telugu/Tamil requires new data authoring — defer to v2. Store preference in `SharedPreferences`. UI: dropdown in Settings screen |
| 16 | **Text Size / Readability Controls (A–/A+)** | ✅ Implement | Add a `textScaleFactor` slider on Aarti Detail screen (range 0.8–1.6). Persist in `SharedPreferences`. Critical for elderly demographic. Simple `MediaQuery` override or `Transform.scale` |
| 17 | **Verse Progress Indicator ("Verse 2 of 6")** | ✅ Implement | Display current verse index based on scroll position (`ScrollController` offset mapped to verse boundaries). No audio sync needed for v1 — scroll-based only |
| 18 | **Smart Search (title, deity, lyrics, festival)** | ✅ Implement | Full-text search on local `kAartis` data: match against `title`, `deity`, `devanagari`, and lyrics content. Use `String.contains()` with case-insensitive matching. Add festival tags to `AartiItem` model |
| 19 | **Sharing** | ✅ Implement | Add `share_plus` package. Share options: (a) lyrics as formatted text, (b) lyrics as shareable image (using `screenshot` or `widgets_to_image` package). Especially valuable during festivals for WhatsApp sharing |
| 20 | **Daily notification at user-set puja time** | ✅ Implement | `flutter_local_notifications` + `timezone` packages. User sets time in Settings. Notification triggers daily with "Today's Aarti" title. Pure local scheduling — no backend needed |
| 21 | **Contributor Screen — local persistence only** | ⚠️ Adapted | Without a backend, community moderation is impossible. **Adaptation:** Allow users to save private Aartis locally (Hive/SQLite). Remove "Submit for Review" option entirely in v1. Label as "My Personal Collection." The moderation flow, flagging, and admin queue are **deferred to backend phase** |
| 22 | **Accessibility: screen reader support** | ✅ Implement | Add `Semantics` widgets, `semanticLabel` on all icons, ensure 44×44dp touch targets. Check saffron-on-white contrast ratio (WCAG AA minimum 4.5:1) — Deep Saffron `#E8820C` on white is ~3.4:1 which **fails**. Use `#C46A00` (darker saffron) for text-on-white contexts |
| 23 | **Accessibility: contrast ratio fix** | ✅ Implement | Audit all color pairings. Saffron accent should only be used on dark backgrounds or as fills (buttons), never as text on light backgrounds |

---

### 2.4 — Features Requiring Backend (Deferred)

| # | Feature | Why It Needs Backend | Standalone Alternative |
|---|---------|---------------------|----------------------|
| 24 | **Festive Push — real-time dynamic updates** | Lunar calendar dates float; hardcoded dates go stale | Bundled 3-year calendar JSON + app update cycle |
| 25 | **Contributor moderation (community review queue)** | Requires server-side admin panel, multi-user access | Local private storage only — no community sharing |
| 26 | **"Report incorrect lyrics" flagging** | Requires server-side collection of flags | Defer entirely |
| 27 | **Firebase Remote Config for festival banners** | Requires Firebase | Hardcoded banner logic based on local date |
| 28 | **User authentication** | Requires auth service | Hardcoded local profile / onboarding name input stored in SharedPreferences |

---

## 3. Revised Phasing (Standalone-First Strategy)

### v1.0 — Core Experience (4–6 weeks)

> **Goal:** A polished, functional Aarti reader that works fully offline with real content.

| Priority | Feature | Effort | Dependencies |
|----------|---------|--------|-------------|
| P0 | **Codebase restructure** — split monolith into feature folders (see Section 5) | 3–4 days | None |
| P0 | **State management** — adopt Riverpod or Provider | 2–3 days | Restructure |
| P0 | **Local persistence** — Hive or SharedPreferences for bookmarks, settings, puja order | 2 days | State mgmt |
| P0 | **My Daily Puja** — `ReorderableListView`, drag-to-reorder, persist order, "Start Session" flow | 3 days | Persistence |
| P0 | **Search** — full-text on title, deity, devanagari, lyrics | 2 days | Restructure |
| P0 | **Deity filter** — wire `_activeDeity` to actually filter the Aarti grid | 0.5 days | Restructure |
| P0 | **Design palette** — implement hex values from Section 2.2 | 1 day | None |
| P0 | **Typography** — integrate `google_fonts`, bundle Noto Serif Devanagari + Lora | 1 day | None |
| P1 | **Text Size control** — A–/A+ on Aarti detail, persist preference | 1 day | Persistence |
| P1 | **Focus Mode refinement** — auto-scroll, verse cycling, default in session | 2 days | None |
| P1 | **Aarti of the Day** — deterministic day→deity mapping using `DateTime.weekday` | 1 day | None |
| P1 | **Dark/Light/System theme** — proper `ThemeData` with `ThemeMode` toggle in settings | 2 days | Persistence |
| P1 | **Accessibility pass** — Semantics, touch targets, contrast audit | 2 days | Palette |
| P1 | **Settings screen** — script preference, text size, theme, storage info | 2 days | Persistence |
| P2 | **Script toggle** — Devanagari / Roman transliteration preference in settings | 1 day | Persistence |
| P2 | **Verse progress indicator** — "Verse X of Y" based on scroll position | 1 day | None |
| P2 | **Haptic feedback** — scope correctly per recommendation | 0.5 days | None |

**v1.0 Estimated Effort: ~26–30 dev-days**

---

### v1.5 — Audio & Engagement (3–4 weeks)

> **Goal:** Real audio playback, daily engagement hook, and social sharing.

| Priority | Feature | Effort | Dependencies |
|----------|---------|--------|-------------|
| P0 | **Real audio playback** — `just_audio` with bundled MP3 assets | 3–4 days | Audio assets |
| P0 | **Audio player refinement** — glassmorphic bottom sheet, play/pause/skip/repeat with actual controls | 2 days | Audio |
| P0 | **Auto-play in Puja session** — sequential playback within "My Daily Puja" only | 2 days | Audio + Puja |
| P0 | **Repeat current** option alongside auto-play | 1 day | Auto-play |
| P0 | **Crossfade setting** (0–3s) for session transitions | 1 day | Auto-play |
| P1 | **"Next" FAB** — trigger at 90% audio progress OR scroll-to-bottom | 1 day | Audio |
| P1 | **Sharing** — `share_plus`, share lyrics as text + as image | 2 days | None |
| P1 | **Daily notification** — `flutter_local_notifications`, user-set puja time | 2 days | None |
| P1 | **Mantra Counter refinement** — configurable count, completion animation, haptic burst | 2 days | None |
| P2 | **Festive banner** — bundled JSON calendar (2026–2028), date-based hero card highlight | 2–3 days | None |
| P2 | **Offline download indicator** — since all content is bundled, show storage usage in settings | 1 day | Persistence |

**v1.5 Estimated Effort: ~20–24 dev-days**

---

### v2.0 — Discovery & Personalization (3–4 weeks)

> **Goal:** Rich discovery, regional scripts, and personal collection.

| Priority | Feature | Effort | Dependencies |
|----------|---------|--------|-------------|
| P1 | **Search enhancements** — filter chips (Deity, Festival, Duration) | 2 days | Search |
| P1 | **Festival tag system** — tag Aartis with festival associations for searchability | 2 days | Data model |
| P1 | **Gujarati script support** — add Gujarati transliteration data, script selector | 3–4 days | Data authoring |
| P1 | **Transliteration + Meaning toggle** — ensure all Aartis have complete data | 3–4 days | Data authoring |
| P1 | **Personal Collection (adapted Contributor)** — save private Aartis to local DB (Hive) | 3 days | Persistence |
| P2 | **Recently played section** on Discover screen | 1 day | Persistence |
| P2 | **Onboarding flow** — name input, preferred language, notification time setup | 2 days | Persistence |
| P2 | **Basic karaoke-style verse highlight** — if audio timestamps are bundled per verse | 3–4 days | Audio + Data |

**v2.0 Estimated Effort: ~22–28 dev-days**

---

### v3.0 — Backend Phase (Future — Out of Scope for Standalone)

> **Requires Firebase/Supabase/custom backend**

- Community Contributor flow with moderation queue
- "Report incorrect lyrics" flagging
- Real-time festival calendar updates via Remote Config
- User authentication and cloud sync of bookmarks/puja order
- Admin panel for content management
- Analytics (usage, popular Aartis, retention)
- Push notifications (server-triggered)

---

## 4. Data Strategy (Standalone)

Since there is no backend, data management is critical:

### 4.1 Content Storage

| Data Type | Storage | Format |
|-----------|---------|--------|
| Aarti catalog (titles, metadata) | Bundled Dart constants → migrate to JSON assets | `assets/data/aartis.json` |
| Verse lyrics (Devanagari, transliteration, meaning) | Bundled JSON per Aarti | `assets/data/verses/{aarti_id}.json` |
| Audio files | Bundled assets | `assets/audio/{aarti_id}.mp3` |
| Deity images | Bundled assets | `assets/images/deities/{deity}.webp` |
| Festival calendar | Bundled JSON | `assets/data/festivals_2026_2028.json` |

### 4.2 User Data Persistence

| Data Type | Storage | Package |
|-----------|---------|---------|
| Bookmarks / My Daily Puja order | Hive (NoSQL local DB) | `hive`, `hive_flutter` |
| Settings (theme, text size, script, notification time) | SharedPreferences | `shared_preferences` |
| Mantra counter history | Hive | `hive` |
| Personal Aarti collection | Hive | `hive` |
| Recently played | Hive (last 20 items) | `hive` |

### 4.3 Content Expansion Requirement

The current app has only **6 sample Aartis** with **3 verses** (for one Aarti only). For a viable v1:

| Target | Count |
|--------|-------|
| Aartis in catalog | 40–60 minimum |
| Full verse data (Devanagari + transliteration + meaning) | All Aartis |
| Audio files | 20–30 Aartis minimum for v1.5 |
| Deity categories | 8 (already defined) |

**Content authoring is the biggest bottleneck** — not engineering. Plan for a dedicated content sprint.

---

## 5. Technical Architecture (Target for v1.0)

### 5.1 Package Dependencies to Add

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.5.0
  # Local Storage
  hive: ^4.0.0
  hive_flutter: ^2.0.0
  shared_preferences: ^2.2.0
  # Typography
  google_fonts: ^6.2.0
  # Audio (v1.5)
  just_audio: ^0.9.40
  # Sharing (v1.5)
  share_plus: ^9.0.0
  # Notifications (v1.5)
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.4
  # UI
  lottie: ^3.1.0  # For completion animations
```

### 5.2 Folder Structure

```
lib/
├── main.dart                      # Entry point only
├── app.dart                       # MaterialApp + theme config
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Hex palette from strategy
│   │   ├── app_text_styles.dart   # Google Fonts integration
│   │   └── app_theme.dart         # ThemeData builder
│   ├── constants/
│   │   └── haptics.dart           # Scoped haptic definitions
│   └── utils/
│       ├── day_deity_mapper.dart   # Weekday → deity mapping
│       └── search_engine.dart     # Full-text local search
├── data/
│   ├── models/
│   │   ├── aarti_item.dart
│   │   ├── verse_data.dart
│   │   └── festival.dart
│   ├── repositories/
│   │   ├── aarti_repository.dart   # Load from JSON assets
│   │   ├── puja_repository.dart    # Hive CRUD for puja order
│   │   └── settings_repository.dart
│   └── sources/
│       └── asset_data_source.dart  # JSON asset loader
├── features/
│   ├── discover/
│   │   ├── discover_screen.dart
│   │   ├── widgets/
│   │   │   ├── search_bar.dart
│   │   │   ├── today_hero_card.dart
│   │   │   ├── deity_chip.dart
│   │   │   └── aarti_card.dart
│   │   └── discover_controller.dart  # Riverpod notifier
│   ├── aarti_detail/
│   │   ├── aarti_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── toggle_bar.dart
│   │   │   ├── verse_block.dart
│   │   │   ├── audio_player.dart
│   │   │   ├── focus_mode_overlay.dart
│   │   │   └── mantra_counter_overlay.dart
│   │   └── aarti_detail_controller.dart
│   ├── my_puja/
│   │   ├── my_puja_screen.dart
│   │   ├── widgets/
│   │   │   └── puja_list_item.dart
│   │   └── my_puja_controller.dart
│   ├── contribute/
│   │   ├── contribute_screen.dart   # Renamed: "My Collection"
│   │   └── contribute_controller.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── settings_controller.dart
├── navigation/
│   ├── home_shell.dart
│   └── app_drawer.dart
└── painters/
    └── mala_painter.dart
```

---

## 6. Revised App Map (Standalone Scope)

### Home (Discover)
- Search bar (searches title, deity, lyrics substring, festival tag)
- "Today's Aarti" hero card (daily rotation by weekday → deity)
- Horizontal deity category chips (functional filter)
- Festive banner (date-based from bundled JSON, when applicable)
- "My Daily Puja" quick-start button (if puja list is non-empty)
- Recently played section (from Hive)

### Aarti Detail Screen
- Image header (bundled deity illustration)
- Script / transliteration / meaning toggle bar (sticky)
- Lyrics with adjustable text size (A–/A+ control)
- Verse progress indicator ("Verse 2 of 6" — scroll-based)
- Mantra counter (slide-in panel, configurable count: 11/21/27/108/1008)
- Focus Mode toggle (hides chrome, auto-scroll)
- Share button (text + image via `share_plus`)
- Glassmorphic audio player (sticky bottom sheet, real audio in v1.5)
- "Next in Puja" FAB (scroll-to-bottom OR 90% audio)

### My Daily Puja Screen
- Ordered, drag-to-reorder list (`ReorderableListView`)
- Auto-play toggle (scoped to this session only)
- Repeat current toggle
- Crossfade duration setting (0–3s)
- Per-item remove button
- "Start Session" button → enters Focus Mode with auto-advance
- Persist order in Hive

### Discover / Search
- Full-text search results
- Filter chips: Deity | Festival | Duration
- *(No Language filter until v2)*

### My Collection (adapted from Contribute)
- Add private Aarti: Deity, Title, Devanagari lyrics, Script
- Saved locally to Hive
- List of saved Aartis with edit/delete
- **No "Submit for Review"** — deferred to backend phase
- **No moderation flow** — deferred

### Settings
- Script preference (Devanagari / Roman transliteration)
- Default text size (slider)
- Notification time for daily Aarti (time picker)
- Theme (Light / Dark / System)
- Storage info (bundled content size)
- About / Version

---

## 7. Key Product Decisions

| Decision | Rationale |
|----------|-----------|
| **Drop "Submit for Review" in v1** | No backend = no moderation = reputational risk. Users can save Aartis privately for personal use |
| **Use bundled JSON for festival calendar** | Avoids backend dependency. Accept 2–3 year refresh cycle with app updates |
| **Bundle all content as app assets** | "Offline download" becomes moot — everything is always offline. Removes complexity |
| **Audio is a v1.5 feature, not v1.0** | Audio asset sourcing/licensing is a separate workstream. Ship readable app first |
| **Riverpod over Bloc/Provider** | Modern, compile-safe, good for repository pattern. Less boilerplate than Bloc |
| **Hive over SQLite** | NoSQL is sufficient for key-value and small collections. No relational queries needed |
| **User is "local" — no auth** | Name captured during optional onboarding, stored in SharedPreferences. No login flow |
| **Saffron accent: use darker variant for accessibility** | `#E8820C` fails WCAG AA on white. Use `#C46A00` for text, keep `#E8820C` for filled buttons/icons only |

---

## 8. Risk Register

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Content bottleneck** — only 6 Aartis exist | High (app feels empty) | High | Dedicate a content sprint before v1 release. Source 40+ Aartis with full Devanagari + transliteration + meaning |
| **Audio asset licensing** | Medium (blocks v1.5) | Medium | Identify royalty-free sources or record original audio |
| **Festival date drift** | Low (affects banner accuracy in year 3+) | Medium | Include 3-year window. Plan annual data update release |
| **Monolith refactor scope** | Medium (delays everything) | Medium | Refactor incrementally, screen-by-screen. Don't attempt big-bang rewrite |
| **App size with bundled audio** | Medium (50–100MB+ with audio) | Medium | Use compressed OGG format. Consider lazy asset loading |
| **Single developer** | High (velocity) | Unknown | Phase aggressively. Ship v1.0 without audio to get user feedback early |

---

## 9. Success Metrics (v1.0)

Since there is no backend analytics, track success qualitatively:

| Metric | Target | How to Verify |
|--------|--------|---------------|
| All 8 deity categories have content | ≥5 Aartis per deity | Content audit |
| Search returns relevant results | Top-3 result matches intent | Manual QA |
| My Daily Puja order persists across restarts | 100% | Device testing |
| App loads under 2s on mid-tier device | Cold start <2s | Profiling |
| Accessibility: all interactive elements labeled | 100% | TalkBack/VoiceOver audit |
| Text is readable at 1.6x scale without overflow | No clipping | Visual QA |

---

## 10. Immediate Next Steps (Sprint 0)

| # | Action | Owner | Deadline |
|---|--------|-------|----------|
| 1 | **Split monolith** — extract into folder structure (Section 5.2) | Dev | Week 1 |
| 2 | **Add Riverpod** — wire up basic state management | Dev | Week 1 |
| 3 | **Add Hive + SharedPreferences** — persistence layer | Dev | Week 1 |
| 4 | **Update `AppColors`** with final hex palette | Dev | Week 1 |
| 5 | **Content Sprint** — author 40+ Aartis with full data | Content | Weeks 1–3 |
| 6 | **Integrate `google_fonts`** — Noto Serif Devanagari + Lora | Dev | Week 2 |
| 7 | **Implement functional search** | Dev | Week 2 |
| 8 | **Wire deity filter** | Dev | Week 2 |
| 9 | **Build Settings screen** | Dev | Week 2 |
| 10 | **Implement `ReorderableListView`** for My Daily Puja | Dev | Week 3 |

---

*This strategy ensures the app delivers a complete, polished devotional experience without backend dependencies, while laying clean architectural foundations for the eventual backend integration in v3.*
