/// What the design fixes about the changes panel.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers of the `committing` board's git column
/// ([committing-light.svg](../../../../../../docs/design/screens/desktop/git-commit/committing-light.svg)),
/// measured from the top of the panel; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
abstract final class ChangesDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the first row.
  static const double rowsTop = 48;

  /// The pitch between rows, also the list's item extent.
  ///
  /// A row is two lines — the name and the folder it is in — so it is taller
  /// than a row that only names a file.
  static const double rowPitch = 48;

  /// The row's box, shorter than the pitch.
  static const double rowHeight = 34;

  /// Corner radius: a row, the message box, the button.
  static const double radius = 6;

  /// The mark's square, which the checkbox and the caption line up with.
  static const double mark = TomMetrics.mark;

  /// The message box.
  static const double messageHeight = 84;

  /// The commit button, and each of the three remote controls under it.
  static const double buttonHeight = 40;

  /// The gap above the message box and above the button.
  static const double stackGap = 12;

  /// The panel's caption.
  static const double caption = 10;

  /// A row's first line: the file's own name.
  static const double row = 12.5;

  /// A row's second line: the folder that name is in.
  static const double folder = 10.5;

  /// The "All" beside the caption, which is not a row and not its size.
  static const double all = 12;

  /// The message box's text.
  static const double message = 13;

  /// The commit button's label, which carries a branch name.
  static const double button = 12.5;

  /// The line under the button, counting what is staged.
  static const double staged = 11;

  /// The button to the line under it.
  static const double buttonToStaged = 10;
}
