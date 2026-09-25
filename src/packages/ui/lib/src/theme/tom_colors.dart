/// The colour roles, and nothing else.
library;

import 'package:flutter/material.dart';

/// The app's colours, by role.
///
/// Roles rather than shades, so a palette change touches no widget ([visual
/// language](../../../../../../docs/technical/design/visual-language.md)); a
/// [ThemeExtension] rather than constants, so no widget asks which mode it
/// is in.
@immutable
class TomColors extends ThemeExtension<TomColors> {
  /// Creates a palette.
  const TomColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.added,
    required this.addedSoft,
    required this.removed,
    required this.removedSoft,
    required this.modified,
    required this.modifiedSoft,
  });

  /// The page.
  final Color surface;

  /// Panels, popovers, cards — anything *above* the page.
  ///
  /// Lighter than [surface] in both modes, because elevation reads as
  /// nearness to the light in both.
  final Color surfaceRaised;

  /// Inputs, code blocks, the inactive pane.
  final Color surfaceSunken;

  /// Dividers between regions.
  final Color border;

  /// Control outlines and focus.
  final Color borderStrong;

  /// Body and headings.
  ///
  /// Never pure black: the highest-contrast pairing there is also the least
  /// comfortable one for continuous reading.
  final Color textPrimary;

  /// Metadata and secondary labels.
  final Color textSecondary;

  /// Captions and placeholders.
  final Color textMuted;

  /// The current thing — the open document, the checked-out branch, the
  /// focused control — and never a meaning, which is the diff roles' job.
  final Color accent;

  /// The fill behind an active row.
  final Color accentSoft;

  /// Diff: a block that appeared.
  final Color added;

  /// Diff: the fill behind a block that appeared.
  final Color addedSoft;

  /// Diff: a block that went.
  final Color removed;

  /// Diff: the fill behind a block that went.
  final Color removedSoft;

  /// Diff: a block that changed.
  final Color modified;

  /// Diff: the fill behind a block that changed.
  final Color modifiedSoft;

  /// The light palette.
  static const TomColors light = TomColors(
    surface: Color(0xFFFAF9F6),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF0EEE9),
    border: Color(0xFFE2DFD8),
    borderStrong: Color(0xFFC9C5BB),
    textPrimary: Color(0xFF26251F),
    textSecondary: Color(0xFF57544C),
    textMuted: Color(0xFF8B877D),
    accent: Color(0xFF4C7D6E),
    accentSoft: Color(0xFFE4EEEA),
    added: Color(0xFF3D7A52),
    addedSoft: Color(0xFFE6F0E8),
    removed: Color(0xFFA24F46),
    removedSoft: Color(0xFFF6E8E6),
    modified: Color(0xFF8F6F2E),
    modifiedSoft: Color(0xFFF4EDDF),
  );

  /// The dark palette.
  ///
  /// The same temperature as [light] — every surface carries a little yellow
  /// — so switching reads as the same product at another hour.
  static const TomColors dark = TomColors(
    surface: Color(0xFF1A1917),
    surfaceRaised: Color(0xFF232220),
    surfaceSunken: Color(0xFF131211),
    border: Color(0xFF34322D),
    borderStrong: Color(0xFF4C4942),
    textPrimary: Color(0xFFECEAE4),
    textSecondary: Color(0xFFADA9A0),
    textMuted: Color(0xFF807C74),
    accent: Color(0xFF84B5A5),
    accentSoft: Color(0xFF1E2C28),
    added: Color(0xFF86BC98),
    addedSoft: Color(0xFF1B2820),
    removed: Color(0xFFDA9A92),
    removedSoft: Color(0xFF2C1E1C),
    modified: Color(0xFFD2B274),
    modifiedSoft: Color(0xFF2A2418),
  );

  /// The palette in scope.
  ///
  /// Asserts rather than falling back: a missing extension is a widget
  /// outside the app's theme, and a silent default would ship wrong colours.
  static TomColors of(BuildContext context) {
    final TomColors? colors = Theme.of(context).extension<TomColors>();
    assert(colors != null, 'TomColors is not in scope — is this under TomApp?');
    return colors ?? light;
  }

  @override
  TomColors copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? added,
    Color? addedSoft,
    Color? removed,
    Color? removedSoft,
    Color? modified,
    Color? modifiedSoft,
  }) => TomColors(
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    added: added ?? this.added,
    addedSoft: addedSoft ?? this.addedSoft,
    removed: removed ?? this.removed,
    removedSoft: removedSoft ?? this.removedSoft,
    modified: modified ?? this.modified,
    modifiedSoft: modifiedSoft ?? this.modifiedSoft,
  );

  @override
  TomColors lerp(ThemeExtension<TomColors>? other, double t) {
    if (other is! TomColors) {
      return this;
    }
    return TomColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      added: Color.lerp(added, other.added, t)!,
      addedSoft: Color.lerp(addedSoft, other.addedSoft, t)!,
      removed: Color.lerp(removed, other.removed, t)!,
      removedSoft: Color.lerp(removedSoft, other.removedSoft, t)!,
      modified: Color.lerp(modified, other.modified, t)!,
      modifiedSoft: Color.lerp(modifiedSoft, other.modifiedSoft, t)!,
    );
  }
}
