/// What the design fixes about the changes panel.
library;

/// The numbers of the 1b `Git panel` master
/// ([committing-dark.svg](../../../../../../docs/design/screens/desktop/git-commit/committing-dark.svg)),
/// measured from the top of the panel under the tabs; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
abstract final class ChangesDesign {
  /// The column's edge to everything in it: list, message, buttons.
  static const double inset = 14;

  /// Island's right edge to the centre of the column's `⋮`
  /// (`design/screens/desktop/git-commit/git-menu-dark.svg`).
  static const double menuCentreRight = 15.5;

  /// The git menu's width.
  static const double menuWidth = 220;

  /// How far the menu runs past the `⋮`'s centre — 6.5 on this board, where
  /// the explorer's draws 5.
  static const double menuOverhang = 6.5;

  /// The column's edge to a section's action, which hangs further out.
  static const double actionInset = 6;

  /// Under the tabs to the first section's head.
  static const double sectionTop = 10;

  /// A section's head, centred on its line.
  static const double sectionHeight = 16;

  /// The last row of one section to the head of the next.
  static const double sectionGap = 16;

  /// The pitch between rows: one line, the folder beside the name.
  static const double rowPitch = 28;

  /// Corner radius: the message box, the buttons.
  static const double radius = 6;

  /// The mark's square.
  static const double mark = 16;

  /// The checkbox to the mark, and the mark to the name.
  static const double rowGap = 8;

  /// The name to the folder after it.
  static const double folderGap = 6;

  /// The ↶ at the row's end, its right edge [inset] from the panel's
  /// (the `Git panel` master, 2026-10-08; not exported yet).
  static const double discard = 12;

  /// The message box: the summary's line and the description's under it.
  static const double messageHeight = 86;

  /// The box's edge to its text, sideways: the board's 14 less a point of
  /// side bearing.
  static const double messagePad = 13;

  /// The box's edge to the summary's line, and the description's line to the
  /// box's foot.
  static const double messageTop = 10;

  /// The summary's line to the description's.
  static const double descriptionGap = 3.5;

  /// The description's text, a step under the summary's.
  static const double description = 12;

  /// The commit button.
  static const double buttonHeight = 32;

  /// The list to the message box, and the message box to the button.
  static const double stackGap = 10;

  /// A section's head.
  static const double caption = 10.5;

  /// A section's action.
  static const double action = 11;

  /// A row's name.
  static const double row = 12.5;

  /// The folder after it.
  static const double folder = 11;

  /// The message box's text.
  static const double message = 12.5;

  /// The commit button's label, which carries a branch name.
  static const double button = 12.5;

  /// The line under the button, counting what is staged.
  static const double staged = 11;

  /// The button to the line under it.
  static const double buttonToStaged = 8;
}
