# Analytics Events

> Event registry and naming conventions for Aarti Sangrah.
> No analytics SDK is currently integrated. This document defines the event schema for future implementation.

---

## 1. Naming Convention

| Element | Convention | Example |
|---------|-----------|---------|
| Event name | `snake_case` | `aarti_detail_viewed` |
| Category prefix | feature name | `discover_`, `puja_`, `detail_` |
| Action verbs | `viewed`, `tapped`, `toggled`, `completed`, `shared` | — |
| Parameter keys | `snake_case` | `aarti_id`, `deity_name` |

---

## 2. Event Registry

### Discover

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `discover_screen_viewed` | Screen loaded | — | Discover |
| `discover_search_performed` | User types in search bar | `query` | Discover |
| `discover_deity_filter_tapped` | User taps deity chip | `deity_name`, `index` | Discover |
| `discover_festival_filter_tapped` | User taps festival tag chip | `festival_tag` | Discover |
| `discover_aarti_card_tapped` | User taps an aarti card | `aarti_id`, `deity_name` | Discover |
| `discover_hero_card_tapped` | User taps "Aarti of the Day" | `aarti_id`, `deity_name` | Discover |

### Aarti Detail

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `detail_screen_viewed` | Screen loaded | `aarti_id`, `deity_name` | Aarti Detail |
| `detail_view_mode_toggled` | User switches lyrics/transliteration/meaning | `mode` (0/1/2) | Aarti Detail |
| `detail_bookmark_toggled` | User taps bookmark | `aarti_id`, `is_bookmarked` | Aarti Detail |
| `detail_puja_toggled` | User taps add/remove puja | `aarti_id`, `is_in_puja` | Aarti Detail |
| `detail_audio_play_tapped` | User taps play | `aarti_id` | Aarti Detail |
| `detail_audio_pause_tapped` | User taps pause | `aarti_id`, `position_ms` | Aarti Detail |
| `detail_focus_mode_entered` | User enters focus mode | `aarti_id` | Aarti Detail |
| `detail_mantra_counter_opened` | User opens mantra counter | `aarti_id`, `target_count` | Aarti Detail |
| `detail_mantra_counter_completed` | User completes a mantra cycle | `aarti_id`, `count` | Aarti Detail |
| `detail_share_tapped` | User taps share | `aarti_id`, `share_type` (text/image) | Aarti Detail |
| `detail_next_fab_tapped` | User taps "Next" FAB | `aarti_id` | Aarti Detail |

### My Puja

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `puja_screen_viewed` | Screen loaded | `puja_count` | My Puja |
| `puja_session_started` | User taps "Start Session" | `puja_count` | My Puja |
| `puja_focus_session_started` | User taps "Focus Session" | `puja_count` | My Puja |
| `puja_item_reordered` | User drags to reorder | `aarti_id`, `old_index`, `new_index` | My Puja |
| `puja_item_removed` | User removes an aarti | `aarti_id` | My Puja |
| `puja_session_completed` | All aartis in session played | `total_count`, `duration_s` | Puja Session |
| `puja_session_exited` | User exits session early | `current_index`, `total_count` | Puja Session |
| `puja_focus_mode_changed` | User changes reading surface in Focus Session | `mode` (lyrics/transliteration/meaning), `aarti_id` | Puja Focus Session |
| `puja_focus_session_completed` | User finishes the final puja item in Focus Session | `total_count` | Puja Focus Session |
| `puja_focus_session_exited` | User exits Focus Session early | `current_index`, `total_count` | Puja Focus Session |

### Contribute

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `contribute_screen_viewed` | Screen loaded | — | Contribute |
| `contribute_aarti_saved` | User saves a private aarti | `aarti_id`, `verse_count` | Contribute |
| `contribute_aarti_deleted` | User deletes a private aarti | `aarti_id` | Contribute |

### Settings

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `settings_screen_viewed` | Screen loaded | — | Settings |
| `settings_theme_changed` | User changes theme | `theme_mode` (system/light/dark) | Settings |
| `settings_text_scale_changed` | User adjusts text scale | `scale` | Settings |
| `settings_script_mode_changed` | User changes script | `mode` (0/1/2) | Settings |
| `settings_notification_toggled` | User enables/disables notification | `enabled`, `hour`, `minute` | Settings |
| `settings_crossfade_changed` | User changes crossfade duration | `duration_s` | Settings |
| `settings_activity_log_opened` | User opens Activity Log viewer | `entry_count` | Settings |
| `settings_activity_log_shared` | User exports Activity Log | `entry_count` | Settings |
| `settings_activity_log_cleared` | User clears Activity Log | `entry_count_before` | Settings |

### Onboarding

| Event Name | Trigger | Parameters | Screen |
|------------|---------|------------|--------|
| `onboarding_started` | Onboarding screen shown | — | Onboarding |
| `onboarding_step_completed` | User completes a step | `step` (1–5) | Onboarding |
| `onboarding_completed` | User finishes all steps | `preferred_language`, `notification_enabled` | Onboarding |
| `onboarding_skipped` | User skips onboarding | `last_step` | Onboarding |
