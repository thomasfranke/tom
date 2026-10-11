/// The colour roles, and nothing else.
library;

import 'package:flutter/material.dart';

/// The app's colours, by role.
///
/// Roles rather than shades, so a palette change touches no widget ([visual
/// language](../../../../../../docs/design/visual-language/README.md)); a
/// [ThemeExtension] rather than constants, so no widget asks which mode it
/// is in.
@immutable
class TomColors extends ThemeExtension<TomColors> {
  /// Creates a palette.
  const TomColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.control,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentMuted,
    required this.added,
    required this.addedSoft,
    required this.removed,
    required this.removedSoft,
    required this.modified,
    required this.modifiedSoft,
  });

  /// The window the columns sit on.
  final Color surface;

  /// Panels, popovers, cards — anything *above* the page.
  ///
  /// Lighter than [surface] in both modes, because elevation reads as
  /// nearness to the light in both.
  final Color surfaceRaised;

  /// Inputs, code blocks, the inactive pane.
  final Color surfaceSunken;

  /// A control's own fill: the chosen segment, a button that is not the
  /// primary one.
  ///
  /// A step off the island it sits on, so a control reads as something to
  /// press without needing an outline.
  final Color control;

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

  /// The accent turned down: the ink of a glyph that is part of the
  /// furniture rather than the current thing, such as a folder in the tree.
  ///
  /// The accent mixed over [surfaceRaised] — 65 % in dark, 85 % in light,
  /// where less would fall under the 3:1 a glyph needs.
  final Color accentMuted;

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
    surface: Color(0xFFE8E6E1),
    surfaceRaised: Color(0xFFF6F5F1),
    surfaceSunken: Color(0xFFECEAE5),
    control: Color(0xFFE2E0DA),
    border: Color(0xFFDAD7D1),
    borderStrong: Color(0xFFC4C0B8),
    textPrimary: Color(0xFF1F2328),
    textSecondary: Color(0xFF4E5561),
    textMuted: Color(0xFF7E7A72),
    accent: Color(0xFF178F71),
    accentSoft: Color(0xFFD4EDE2),
    accentMuted: Color(0xFF389E84),
    added: Color(0xFF558F27),
    addedSoft: Color(0xFFE5EED5),
    removed: Color(0xFFCF222E),
    removedSoft: Color(0xFFF8E3DE),
    modified: Color(0xFF9A6700),
    modifiedSoft: Color(0xFFF7EECC),
  );

  /// The dark palette.
  ///
  /// The same islands as [light]: the window darker than the columns on it,
  /// so a column is told apart by its fill rather than by a line.
  static const TomColors dark = TomColors(
    surface: Color(0xFF131416),
    surfaceRaised: Color(0xFF1E1F22),
    surfaceSunken: Color(0xFF191A1D),
    control: Color(0xFF2A2C31),
    border: Color(0xFF2B2D31),
    borderStrong: Color(0xFF3E4148),
    textPrimary: Color(0xFFDFE1E5),
    textSecondary: Color(0xFFA8ADB6),
    textMuted: Color(0xFF6E737C),
    accent: Color(0xFF4FD1B0),
    accentSoft: Color(0xFF15302A),
    accentMuted: Color(0xFF3E937E),
    added: Color(0xFF9BCB5E),
    addedSoft: Color(0xFF1E2A17),
    removed: Color(0xFFEF7B76),
    removedSoft: Color(0xFF301C1C),
    modified: Color(0xFFE2B45C),
    modifiedSoft: Color(0xFF2C2516),
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
    Color? control,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? accentMuted,
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
    control: control ?? this.control,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    accentMuted: accentMuted ?? this.accentMuted,
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
      control: Color.lerp(control, other.control, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      added: Color.lerp(added, other.added, t)!,
      addedSoft: Color.lerp(addedSoft, other.addedSoft, t)!,
      removed: Color.lerp(removed, other.removed, t)!,
      removedSoft: Color.lerp(removedSoft, other.removedSoft, t)!,
      modified: Color.lerp(modified, other.modified, t)!,
      modifiedSoft: Color.lerp(modifiedSoft, other.modifiedSoft, t)!,
    );
  }
}
