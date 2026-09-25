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

  /// Source text, mono and therefore smaller than prose.
  static const double code = 12.5;

  /// Line height of source as a multiple of [code]; tighter than prose.
  static const double codeHeight = 1.5;
}
