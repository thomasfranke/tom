/// What the design fixes about the source pane.
library;

/// The numbers the editor is drawn against.
///
/// The same vertical rhythm the preview uses, because the two sit side by
/// side in split mode and a caption half a line off between them is the kind
/// of thing nobody can unsee.
///
/// Public and beside the panel rather than private inside it: the panel and
/// its widgets are separate files, and two copies of a number would drift.
abstract final class EditorDesign {
  /// Panel top to the caption's baseline box.
  static const double captionTop = 18;

  /// Panel top to the first line of source.
  static const double bodyTop = 42;

  /// The panel's own caption.
  static const double caption = 10;

  /// Source text, which is mono and therefore smaller than prose.
  static const double code = 12.5;

  /// Line height of source, as a multiple of [code].
  ///
  /// Tighter than prose: a source line is scanned, not read.
  static const double codeHeight = 1.5;
}
