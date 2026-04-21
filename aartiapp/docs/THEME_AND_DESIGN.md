# Theme & Design System

> Colour palette, typography scale, spacing tokens, component styles, dark mode strategy, and accessibility requirements.

---

## 1. Colour Palette

All colours are defined in `lib/core/theme/app_colors.dart`. No colour should be used inline — always reference `AppColors.<token>`.

### Light Theme

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `stone` | `#F5F2ED` | 245, 242, 237 | Scaffold background (Temple Stone) |
| `stone2` | `#EDE8E0` | 237, 232, 224 | Card divider background |
| `stone3` | `#D8D0C4` | 216, 208, 196 | Subtle borders |
| `saffron` | `#E8820C` | 232, 130, 12 | Deep Saffron — primary CTAs (use sparingly) |
| `saffronDark` | `#C46A00` | 196, 106, 0 | Accessible saffron for text on light backgrounds |
| `saffronLight` | `#E8950F` | 232, 149, 15 | Highlights, dark theme primary |
| `saffronGlow` | `#1FE8820C` | — | Saffron at ~12 % opacity — selection backgrounds |
| `ink` | `#2C2420` | 44, 36, 32 | Warm near-black — body text, titles |
| `ink2` | `#4A4035` | 74, 64, 53 | Secondary text |
| `ink3` | `#8C8880` | 140, 136, 128 | Captions, metadata, placeholder text |
| `white` | `#FDFAF6` | 253, 250, 246 | Sacred White — card backgrounds |
| `gold` | `#B8972A` | 184, 151, 42 | Accent gold — secondary colour |

### Dark Theme

| Token | Hex | Usage |
|-------|-----|-------|
| `darkBg` | `#1A1614` | Dark scaffold background |
| `darkSurface` | `#2C2420` | Dark card backgrounds |
| `darkBorder` | `#3D3530` | Dark borders |

### Theme-Aware Colours (via `ThemeAwareColors` extension)

Access these on any `BuildContext`:

| Extension | Light | Dark |
|-----------|-------|------|
| `context.scaffoldBg` | `stone` | `darkBg` |
| `context.surface` | `white` | `darkSurface` |
| `context.textPrimary` | `ink` | `white` |
| `context.textSecondary` | `ink2` | `#A8A29E` |
| `context.textCaption` | `ink3` | `#8C8880` |
| `context.border` | `stone2` | `darkBorder` |
| `context.borderSubtle` | `stone3` | `darkBorder` |

---

## 2. Typography Scale

All text styles are defined in `lib/core/theme/app_typography.dart` as static factory methods on `AppTypography`. Never create inline `TextStyle(...)` in widgets.

| Method | Font | Size | Weight | Usage |
|--------|------|------|--------|-------|
| `displayLarge(ctx)` | Lora | 36 | w300 | Large display heading (greeting) |
| `scriptTitle(ctx)` | Lora | 28 | w400 | Aarti title on detail screen |
| `devanagari()` | Noto Serif Devanagari | 17 | w400 | Devanagari lyrics |
| `transliteration()` | Lora | 14 | italic | Roman transliteration text |
| `label()` | System | 10 | w500, 2px tracking | Section labels, metadata |
| `body()` | System | 13 | w300 | General body text |
| `serifBody()` | Lora | 16 | w400 | Serif body text for headings/names |

All methods accept optional `size` and `color` overrides.

---

## 3. Spacing Scale

All spacing tokens are defined in `lib/core/theme/app_spacing.dart` as static constants on `AppSpacing`.

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 2 px | Hairline gaps, indicator dots |
| `xs` | 4 px | Minimal icon-to-text gaps |
| `smTight` | 6 px | Tight spacing between related elements |
| `sm` | 8 px | Small internal padding, chip gaps |
| `smWide` | 10 px | Compact list item spacing |
| `md` | 12 px | Default inter-element gap |
| `mdTight` | 14 px | Medium-tight padding |
| `lg` | 16 px | Standard padding / margin |
| `lgWide` | 20 px | Generous section padding |
| `xl` | 24 px | Screen-edge horizontal padding, section gaps |
| `xxl` | 28 px | Large vertical section gaps |
| `xxxl` | 32 px | Extra-large section gaps |
| `huge` | 40 px | Hero-level spacing |
| `massive` | 48 px | Empty-state padding |
| `scrollEnd` | 60 px | Bottom-of-scroll FAB clearance |

### Semantic Aliases

| Alias | Value | Usage |
|-------|-------|-------|
| `screenHorizontal` | 24 px | Horizontal screen edge padding |
| `contentPadding` | 16 px | Card / section internal padding |
| `listItemGap` | 12 px | Gap between list items |
| `cardRadius` | 12 px | Border radius for cards |
| `buttonRadius` | 14 px | Border radius for buttons |
| `chipRadius` | 20 px | Border radius for chips/tags |
| `avatarRadius` | 19 px | Border radius for circular avatars |
| `touchTarget` | 48 px | Minimum accessible touch target |

---

## 4. Component Styles

Defined in `lib/core/theme/app_theme.dart`:

### Elevated Button
- Background: `ink` (dark), foreground: `white`
- No elevation, 14 px border radius
- Font size 14, weight w400

### Input Decoration
- Filled with `surface` colour
- 12 px border radius
- Enabled border: `cardBorder` colour
- Focused border: `primary` colour, 1.5 px width
- Content padding: 16 px horizontal, 12 px vertical

### App Bar
- Background matches scaffold
- No elevation, no scroll-under shadow
- Icon colour matches text colour

### Page Transitions
- Cupertino-style on both Android and iOS

---

## 5. Dark Mode Strategy

- Light and dark `ThemeData` are both defined in `app_theme.dart`.
- Theme mode is persisted via `SettingsRepository` and controlled by `ThemeModeNotifier`.
- Three modes: System (follows OS), Light, Dark.
- Dark theme uses `darkBg` scaffold, `darkSurface` cards, `saffronLight` as primary.
- The `ThemeAwareColors` extension provides easy context-based colour access.

---

## 6. Accessibility Requirements

| Requirement | Status | Notes |
|-------------|--------|-------|
| Minimum 48×48 touch targets | ✅ Implemented | All interactive elements checked |
| WCAG AA text contrast (4.5:1 normal, 3:1 large) | ✅ Implemented | `saffronDark` (#C46A00) used for text-on-light |
| `Semantics` / `semanticLabel` on interactive elements | ✅ Implemented | Back button, bookmark, puja add all labeled |
| Text scaling (0.8×–1.6×) | ✅ Implemented | User-controllable via Settings |
| Saffron on white — contrast risk | ⚠️ Mitigated | Saffron used only on dark backgrounds or as fills, never as text on white |
