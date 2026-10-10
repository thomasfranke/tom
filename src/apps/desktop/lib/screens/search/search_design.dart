/// What the design fixes about the search panel.
library;

/// The numbers of the three search boards, measured from the top of the left
/// column; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
///
/// Taken off `searching-every-document-dark.svg` for the whole-space list and
/// `searching-open-file-dark.svg` / `searching-replace-dark.svg` for the one
/// in the open document, which are the same list with the second box open.
abstract final class SearchDesign {
  /// A hit's box above its name.
  static const double hitTop = 10;

  /// A hit's box under its excerpt — the rest of the board's 86-point pitch
  /// is the name, the folder, two lines of excerpt and the hairline.
  static const double hitBottom = 8;

  /// The name to the folder under it.
  static const double nameGap = 4;

  /// Panel edge to a hit's row, which is the hairline's own inset: the
  /// whole-space list draws its text against that edge rather than inside a
  /// pill (`searching-every-document-dark.svg`).
  static const double hitInset = 4;

  /// The padding inside an occurrence's pill, which is what puts its text
  /// eight points further in than a hit's.
  static const double hitPad = 6;

  /// The folder to the excerpt under it.
  static const double excerptGap = 5;

  /// How much of an excerpt is drawn before it is cut.
  static const int excerptLines = 2;

  /// Corner radius of a hovered hit.
  static const double radius = 6;

  /// The hairline between two whole-space hits: that list separates, the
  /// one in the open document pills instead.
  static const double divider = 1;

  /// The row of an occurrence, pill included.
  static const double rowHeight = 54;

  /// Between two of them.
  static const double rowGap = 8;

  /// An occurrence's heading, above the text it was found in.
  static const double heading = 11;

  /// How much of an occurrence's excerpt is drawn.
  static const int occurrenceLines = 2;

  /// The heading to the excerpt under it.
  static const double headingGap = 5;

  /// A row's pill above the heading — the rest of [rowHeight] is the two
  /// lines of excerpt, which end flush with the pill the way the board
  /// draws them.
  static const double rowTop = 7;

  /// The row that counts what matched, whether or not it carries a button.
  static const double countRow = 24;

  /// That row to the first of them.
  static const double countGap = 4;

  /// The `Replace all` button at the right of the count.
  static const double replaceAllWidth = 92;

  /// Its label.
  static const double replaceAll = 11;

  /// Either box: the one that asks and the one that replaces.
  static const double boxHeight = 28;

  /// The text inside it, and its placeholder.
  static const double boxText = 12.5;

  /// Its own left and right padding.
  static const double boxPad = 12;

  /// The `Field clear` disc at the box's right end.
  static const double clearGlyph = 16;

  /// The `⇄` beside the clear: the room it takes in the row, so its centre
  /// lands 30 left of the clear's (`search/searching-replace-dark.svg`: 208
  /// against 238). Narrower than its fill, which overhangs into the field.
  static const double replaceToggleBox = 12;

  /// The fill it wears while the replace box is open.
  static const double replaceToggleFill = 20;

  /// That fill's corner.
  static const double replaceToggleRadius = 4;

  /// Its glyph.
  static const double replaceToggleGlyph = 11;

  /// Column edge to either box, on both sides — the inset everything else in
  /// the column takes (`Explorer` master: 14..254 in an island at 6).
  static const double controlInset = 8;

  /// The scope control under the box, measured off
  /// `design/screens/desktop/search/searching-every-document-dark.svg`.
  static const double scopeHeight = 26;

  /// The control's corner.
  static const double scopeRadius = 6;

  /// How far a segment's tile sits inside the control's outer edge.
  ///
  /// The padding that produces it is a point less, because Flutter draws a
  /// border *inside* the box while the board measures from the outside.
  static const double scopeInset = 3;

  /// The control's outline.
  static const double scopeStroke = 1;

  /// The tile's corner, tighter than the control's.
  static const double scopeTileRadius = 4;

  /// Either segment's label, a point under the count beside it.
  static const double scopeLabel = 11.5;

  /// Box to scope control, and scope control to what is under it.
  static const double scopeGap = 6;

  /// Between the two boxes, and between the second and the scope control.
  static const double boxGap = 6;

  /// The glyph of an action on an occurrence's row.
  static const double rowAction = 16;

  /// Its tap target.
  static const double rowActionBox = 24;

  /// The panel's caption.
  static const double caption = 10.5;

  /// The line under it, counting what matched.
  static const double count = 12;

  /// A hit's file name.
  static const double name = 13;

  /// The folder it is in, under the name.
  static const double path = 11;

  /// The stretch of text that matched.
  static const double excerpt = 12;

  /// The `⌘K` keycap at the box's right end
  /// (`design/screens/desktop/workspace-tree/new-document-dark.svg`).
  static const double keycapWidth = 32;

  /// Its height, centred in the box.
  static const double keycapHeight = 18;

  /// Its corner.
  static const double keycapRadius = 4;

  /// Its right edge to the box's.
  static const double keycapRight = 8;

  /// Its two characters.
  static const double keycapText = 10;
}
