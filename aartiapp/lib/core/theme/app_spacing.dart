/// Centralised spacing tokens for consistent padding, margin, and gap values.
///
/// Usage:
/// ```dart
/// EdgeInsets.all(AppSpacing.md)
/// SizedBox(height: AppSpacing.sm)
/// ```
///
/// Never use raw numeric literals for spacing — always reference these tokens.
class AppSpacing {
  AppSpacing._();

  // ── Base scale ────────────────────────────────────────────────────────────

  /// 2 px — hairline gaps (e.g., indicator dots, thin separators).
  static const double xxs = 2;

  /// 4 px — minimal gaps (e.g., icon-to-text in compact rows).
  static const double xs = 4;

  /// 6 px — tight spacing between closely related elements.
  static const double smTight = 6;

  /// 8 px — small internal padding, chip gaps.
  static const double sm = 8;

  /// 10 px — compact list item spacing.
  static const double smWide = 10;

  /// 12 px — default inter-element gap, compact padding.
  static const double md = 12;

  /// 14 px — medium-tight padding (e.g., list tile internal).
  static const double mdTight = 14;

  /// 16 px — standard padding / margin (most common).
  static const double lg = 16;

  /// 20 px — generous section padding.
  static const double lgWide = 20;

  /// 24 px — screen-edge horizontal padding, section gaps.
  static const double xl = 24;

  /// 28 px — large vertical section gaps.
  static const double xxl = 28;

  /// 32 px — extra-large vertical gaps between major sections.
  static const double xxxl = 32;

  /// 40 px — hero-level spacing (e.g., puja session controls).
  static const double huge = 40;

  /// 48 px — empty-state padding, large gaps.
  static const double massive = 48;

  /// 60 px — bottom-of-scroll padding for FAB clearance.
  static const double scrollEnd = 60;

  // ── Semantic aliases ──────────────────────────────────────────────────────

  /// Standard horizontal screen padding (24 px).
  static const double screenHorizontal = xl;

  /// Standard content padding around cards / sections (16 px).
  static const double contentPadding = lg;

  /// Gap between list items (12 px).
  static const double listItemGap = md;

  /// Border radius for cards (12 px).
  static const double cardRadius = 12;

  /// Border radius for buttons (14 px).
  static const double buttonRadius = 14;

  /// Border radius for chips / tags (20 px).
  static const double chipRadius = 20;

  /// Border radius for circular avatars / indicators (19 px).
  static const double avatarRadius = 19;

  /// Minimum touch target size per accessibility guidelines (48 px).
  static const double touchTarget = 48;
}
