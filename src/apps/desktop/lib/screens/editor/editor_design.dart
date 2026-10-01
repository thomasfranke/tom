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

  /// Pane edge to the line-number column.
  ///
  /// What the gutter holds is the letter of a changed block, the way the
  /// preview's does (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`);
  /// the source pane does not draw it yet, and the room is the board's either
  /// way (`design/screens/desktop/git-diff/comparing-dark.svg`).
  static const double gutter = 56;

  /// Pane edge to the left of a gutter mark.
  ///
  /// The boards draw the letter itself at 18; the mark is a twenty square and
  /// sits centred on it
  /// (`design/screens/desktop/git-diff/comparing-light.svg`).
  static const double markLeft = 12;

  /// Pane edge to the tint band behind a changed block.
  ///
  /// It starts **before** the line numbers and runs under them, which is
  /// what the diff boards draw — `git-conflict/` puts it at 80 instead, and
  /// the maintainer settled on 44
  /// (`design/screens/desktop/git-diff/comparing-light.svg`).
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
  /// document reaching line 100 must not move it.
  static const double numbers = 78;

  /// The line-number column to the first character of source.
  static const double numbersToCode = 10;

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
}
