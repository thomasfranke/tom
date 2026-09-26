/// What the design fixes about the search panel.
library;

/// The numbers of the retired `searching` board, measured from the top of the
/// panel; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
///
/// **The board these were taken from no longer exists.** It was replaced by
/// three that put the search whole in the left column, so this panel's place
/// on screen is a known divergence — the numbers are still right, the column
/// is not (`docs/product/search/full-text-search/known-divergence/doc.md`).
abstract final class SearchDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the line that says how many documents matched.
  static const double countTop = 37;

  /// Panel top to the list.
  static const double hitsTop = 54;

  /// A hit's box above its name.
  static const double hitTop = 13;

  /// A hit's box under its excerpt.
  static const double hitBottom = 14;

  /// Panel edge to a hit's pill, which is narrower than the text inset so
  /// the pill's own padding puts the text where the board draws it.
  static const double hitInset = 8;

  /// The pill's padding, which is the other half of that inset.
  static const double hitPad = 8;

  /// The name to the excerpt under the path.
  static const double excerptGap = 3;

  /// How much of an excerpt is drawn before it is cut.
  static const int excerptLines = 3;

  /// Corner radius of a hovered hit.
  static const double radius = 6;

  /// The panel's caption.
  static const double caption = 10;

  /// The line under it, counting what matched.
  static const double count = 12;

  /// A hit's file name.
  static const double name = 13;

  /// The folder it is in, under the name.
  static const double path = 11;

  /// The stretch of text that matched.
  static const double excerpt = 11;
}
