/// What the design fixes about the source pane.
library;

/// The numbers the editor is drawn against.
///
/// The preview's vertical rhythm, because the two sit side by side in split
/// mode and a line half a step off between them shows.
abstract final class EditorDesign {
  /// Panel top to the first line of source.
  ///
  /// **The pane carries no caption.** No board draws one over either pane —
  /// the mode control above already says which is which
  /// (`docs/design/screens/divergences.md`).
  static const double bodyTop = 8;

  /// Pane edge to the left of a gutter mark, a `TomMetrics.mark` outline
  /// (`design/screens/desktop/git-conflict/conflict-in-source-dark.svg`).
  static const double markLeft = 5;

  /// Pane edge to the tint band behind a changed block.
  ///
  /// Between the numbers and the text: the diff boards start it at 2 and
  /// `git-conflict/` at 44, and the maintainer settled on 44
  /// (`design/screens/desktop/git-conflict/conflict-in-source-dark.svg`).
  static const double bandLeft = 44;

  /// The bar in the role's own ink, at the band's left edge.
  static const double bandBar = 4;

  /// The seam a removed block leaves behind.
  ///
  /// **A removed block is a seam, not text**: it is not in the buffer, so
  /// drawing it would put characters in front of somebody that typing cannot
  /// reach (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
  static const double seam = 2;

  /// Pane edge to the *right* of the line-number column.
  ///
  /// Fixed rather than derived from the digit count, because the boards put
  /// the first character of source at one place on every screen and a
  /// document reaching line 100 must not move it
  /// (`design/screens/desktop/editor/merged-rows-dark.svg`: 300 from 268).
  static const double numbers = 32;

  /// The line-number column to the first character of source, which the
  /// boards draw at 50 from the pane's edge.
  static const double numbersToCode = 18;

  /// A line number, smaller than the source it counts.
  static const double lineNumber = 11;

  /// Source text, mono and therefore smaller than prose.
  static const double code = 12.5;

  /// The pitch between two lines of source.
  ///
  /// The boards draw 22 on every screen that shows source, which is what
  /// [codeHeight] is derived from rather than chosen.
  static const double linePitch = 22;

  /// Line height of source as a multiple of [code].
  static const double codeHeight = linePitch / code;

  /// The conflict's three choices, sans and smaller than the source
  /// (`design/screens/desktop/git-conflict/conflict-in-source-light.svg`).
  static const double lens = 11;

  /// The end of the `<<<<<<<` line to the first choice: two columns of
  /// source, so the choices read as following the marker rather than as
  /// part of it.
  static const double lensGap = 15;
}
