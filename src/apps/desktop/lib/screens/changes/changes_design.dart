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
  static const double rowPitch = 42;

  /// The row's box, shorter than the pitch.
  static const double rowHeight = 34;

  /// Corner radius: a row, the message box, the button.
  static const double radius = 6;

  /// The mark's square, which the checkbox and the caption line up with.
  static const double mark = TomMetrics.mark;

  /// The message box.
  static const double messageHeight = 96;

  /// The commit button.
  static const double buttonHeight = 44;

  /// The gap above the message box and above the button.
  static const double stackGap = 16;

  /// The panel's caption.
  static const double caption = 10;

  /// A row's label, and the "All" beside the caption.
  static const double row = 13;

  /// The message box's text.
  static const double message = 13;
}
