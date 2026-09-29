/// What the design fixes about the source pane.
library;

/// The numbers the editor is drawn against.
///
/// The preview's vertical rhythm, because the two sit side by side in split
/// mode and a caption half a line off between them shows.
abstract final class EditorDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the first line of source.
  static const double bodyTop = 42;

  /// The panel's caption.
  static const double caption = 10;

  /// Pane edge to the line-number column, which the caption lines up with.
  ///
  /// What the gutter holds is the letter of a changed block, the way the
  /// preview's does (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`);
  /// the source pane does not draw it yet, and the room is the board's either
  /// way (`design/screens/desktop/git-diff/comparing-dark.svg`).
  static const double gutter = 56;

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

  /// Line height of source as a multiple of [code]; tighter than prose.
  static const double codeHeight = 1.5;
}
