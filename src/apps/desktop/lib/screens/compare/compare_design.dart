/// What the design fixes about the compare surface.
library;

import 'package:tom_desktop/screens/branches/branches_design.dart';

/// The numbers the compare control and its popover are drawn against.
///
/// The branch switcher's, deliberately: this is the same kind of surface —
/// a popover hanging off a control, filtering a list of revisions — and two
/// sets of numbers for one pattern is how they drift apart.
abstract final class CompareDesign {
  /// The popover, wider than the switcher's because a commit's line carries
  /// a subject, a sha, an author and an age.
  static const double popoverWidth = 320;

  /// As tall as the *lists* may get before they scroll.
  static const double popoverMaxHeight = BranchesDesign.popoverMaxHeight;

  /// Mode bar to the popover, clearing the rule under it.
  static const double popoverTop = 2;

  /// Popover edge to the field, which spans it.
  static const double padding = BranchesDesign.padding;

  /// The filter.
  static const double fieldHeight = BranchesDesign.fieldHeight;

  /// Popover edge to a row's box, so the highlight is inset from the panel.
  static const double rowInset = BranchesDesign.rowInset;

  /// Corner radius: the popover, a row, the field.
  static const double radius = BranchesDesign.radius;

  /// A branch's name, and a commit's subject.
  static const double label = 13;

  /// What the surface says about itself, and a commit's second line.
  static const double note = BranchesDesign.note;

  /// The pitch between two branches, which is also that list's item extent.
  static const double branchPitch = BranchesDesign.rowPitch;

  /// A branch row's own box, shorter than the pitch.
  static const double branchHeight = BranchesDesign.rowHeight;

  /// The pitch between two commits, which carry two lines.
  static const double commitPitch = 48;

  /// A commit row's own box, shorter than the pitch.
  static const double commitHeight = 42;

  /// Subject to the line under it.
  static const double metaGap = 2;
}
