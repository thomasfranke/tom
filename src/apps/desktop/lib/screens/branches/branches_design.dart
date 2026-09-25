/// What the design fixes about the branch switcher.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers of the `branch-switcher` wireframe
/// (`docs/product/git-workflow/branch-switch/mocks/branch-switcher.excalidraw`).
///
/// The control's x is the one number that is not the wireframe's: the kit
/// fixes it at 392 on a 1040 canvas, so here it sits [gap] after the space's
/// name and moves with the left group.
abstract final class BranchesDesign {
  /// The control in the top bar.
  static const double controlWidth = 190;

  /// The control's box, inside the 52 of the bar.
  static const double controlHeight = 28;

  /// Space name to the control.
  static const double gap = 32;

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
