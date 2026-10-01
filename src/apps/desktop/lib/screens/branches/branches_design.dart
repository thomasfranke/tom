/// What the design fixes about the branch switcher.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers of the `branch-switcher` board
/// ([branch-switcher-light.svg](../../../../../../docs/design/screens/desktop/git-branches/branch-switcher-light.svg)).
///
/// **The control is centred on the window, not on what precedes it.** Every
/// board draws it at `615,11 210×30`, and 615 + 105 is 720 — so a longer
/// space name pushes nothing, and the control lines up with the modes in the
/// row below (`docs/design/screens/measurements.md`).
abstract final class BranchesDesign {
  /// The control in the top bar.
  static const double controlWidth = 210;

  /// The control's box, inside the 52 of the bar.
  static const double controlHeight = 30;

  /// The popover, wider than the control it hangs from.
  static const double popoverWidth = 260;

  /// The list's height before it scrolls; the other two faces are as tall as
  /// what they say and must not be clipped.
  static const double popoverMaxHeight = 254;

  /// Top bar to the popover, clearing the rule under it.
  static const double popoverTop = 4;

  /// Popover edge to the field.
  static const double padding = TomMetrics.padTight;

  /// The filter, and the box a new branch is named in.
  static const double fieldHeight = 28;

  /// The pitch between branches, also the list's item extent.
  static const double rowPitch = 32;

  /// A row's box, shorter than the pitch.
  static const double rowHeight = 26;

  /// Popover edge to a row's box.
  static const double rowInset = 8;

  /// Corner radius: the control, the popover, a row, the field.
  static const double radius = 6;

  /// A branch's name, in the control and in the list.
  static const double label = 14;

  /// What the surface says about itself: a refusal, a question, a hint.
  static const double note = 12;
}
