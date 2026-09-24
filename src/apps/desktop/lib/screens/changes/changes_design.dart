/// What the design fixes about the changes panel.
library;

/// The numbers the changes panel is drawn against.
///
/// The `committing` wireframe's git column
/// (`docs/product/git-workflow/commit/mocks/committing-desktop.excalidraw`),
/// measured from the top of the panel — the shell is what puts it under the
/// top bar. Type and radii come from
/// [components.md](../../../../../../docs/technical/design/components.md).
///
/// Public and beside the panel rather than private inside it: the panel and
/// its widgets are separate files, and two copies of 42 would drift.
abstract final class ChangesDesign {
  /// Panel top to the caption's baseline box.
  static const double captionTop = 18;

  /// Panel top to the first row.
  static const double rowsTop = 48;

  /// The pitch between rows, which is also the list's item extent.
  static const double rowPitch = 42;

  /// The row's own box, shorter than the pitch.
  static const double rowHeight = 34;

  /// Corner radius: a row, the message box, the button.
  static const double radius = 6;

  /// The mark that says what happened to a file.
  ///
  /// Twenty square with a letter in it, because **colour is never the only
  /// signal** — roughly one in twelve men cannot separate the red from the
  /// green (`docs/technical/design/components.md`).
  static const double mark = 20;

  /// The message box, which is as tall as the design draws it.
  static const double messageHeight = 96;

  /// The commit button.
  static const double buttonHeight = 44;

  /// The gap above the message box and above the button.
  static const double stackGap = 16;

  /// The panel's own caption.
  static const double caption = 10;

  /// A row's label, and the "All" beside the caption.
  static const double row = 13;

  /// The message box's own text.
  static const double message = 13;
}
