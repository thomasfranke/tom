/// What the design fixes about the branch switcher.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers the branch control and its popover are drawn against.
///
/// The `branch-switcher` wireframe
/// (`docs/product/git-workflow/branch-switch/mocks/branch-switcher.excalidraw`),
/// with the popover's own measurements taken from its top-left corner — the
/// control is what puts it on screen.
///
/// **One number is not the wireframe's**, and it is the control's x. The
/// kit draws it at a fixed 392 on a 1040-wide canvas, which is a position
/// and not a rule; a window that resizes has to anchor it to something, so
/// it sits [gap] after the space's name and the whole left group moves
/// together. Everything else is the wireframe's to the pixel.
abstract final class BranchesDesign {
  /// The control in the top bar: the branch's name and what opens the list.
  static const double controlWidth = 190;

  /// The control's own box, inside the 52 of the bar.
  static const double controlHeight = 28;

  /// Space name to the control.
  static const double gap = 32;

  /// The popover, which is wider than the control it hangs from.
  static const double popoverWidth = 260;

  /// As tall as the *list* may get before it starts scrolling.
  ///
  /// A repository with forty branches must not draw a panel taller than the
  /// window; four is what the mock shows and is not a limit. The other two
  /// faces — naming a branch, answering for an unsaved buffer — are as tall
  /// as what they have to say, which is shorter and must not be clipped.
  static const double popoverMaxHeight = 254;

  /// Top bar to the popover, clearing the rule under it.
  static const double popoverTop = 4;

  /// Popover edge to the field, which spans it.
  static const double padding = TomMetrics.padTight;

  /// The filter, and the box a new branch is named in.
  static const double fieldHeight = 28;

  /// The pitch between branches, which is also the list's item extent.
  static const double rowPitch = 32;

  /// A row's own box, shorter than the pitch.
  static const double rowHeight = 26;

  /// Popover edge to a row's box, so the highlight is inset from the panel.
  static const double rowInset = 8;

  /// Corner radius: the control, the popover, a row, the field.
  static const double radius = 6;

  /// A branch's name, in the control and in the list.
  static const double label = 14;

  /// What the surface says about itself — a refusal, a question, a hint.
  static const double note = 12;
}
