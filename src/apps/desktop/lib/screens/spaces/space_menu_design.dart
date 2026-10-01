/// What the design fixes about the breadcrumb's menu.
library;

/// The numbers of `closing-the-space-dark.svg`, measured from the menu's own
/// top-left; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
abstract final class SpaceMenuDesign {
  /// The menu's width.
  static const double width = 300;

  /// Its corner, rounder than a control's because it is a surface.
  static const double radius = 10;

  /// The bar's left inset to the menu's left edge — eight further out than
  /// the breadcrumb, so the rows' text lands under the breadcrumb's.
  static const double nudge = 8;

  /// The window's top to the menu's top; it hangs from just inside the bar.
  static const double top = 48;

  /// The breadcrumb's own height in the bar.
  ///
  /// Stated rather than left to the text, because the menu hangs from the
  /// control's bottom edge: a control whose height follows its font is a
  /// menu that moves when the font changes.
  static const double controlHeight = 28;

  /// Menu edge to a row.
  static const double pad = 8;

  /// A row's own padding, which is the other half of the text's inset.
  static const double rowPad = 8;

  /// A recent space's row, name over path.
  static const double rowHeight = 38;

  /// Between two of them.
  static const double rowGap = 6;

  /// A row's corner.
  static const double rowRadius = 6;

  /// Either half of the breadcrumb, in the bar.
  static const double crumb = 14;

  /// The caption over the list.
  static const double caption = 10;

  /// Menu top to the caption's box.
  static const double captionTop = 16;

  /// The caption to the first row.
  static const double captionGap = 8;

  /// A space's name.
  static const double name = 13;

  /// Where it is, under the name.
  static const double path = 10.5;

  /// The mark on the space that is already open.
  static const double check = 11;

  /// The hairline over `Close space`.
  static const double divider = 1;

  /// The list to that hairline, and the hairline to what is under it.
  static const double dividerGap = 10;

  /// `Close space` itself.
  static const double close = 13;

  /// The rule over the unsaved question, in `modified`.
  static const double warningBar = 4;

  /// Its corner.
  static const double warningRadius = 2;

  /// The question's first line.
  static const double title = 13;

  /// What it explains, under that.
  static const double note = 12;

  /// One of the three answers.
  static const double answerHeight = 32;

  /// Between two of them.
  static const double answerGap = 8;
}
