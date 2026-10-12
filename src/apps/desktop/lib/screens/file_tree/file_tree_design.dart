/// What the design fixes about the explorer.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// The numbers of the visual design's `explorer` component, measured from
/// the top of the panel; type and radii from
/// [components](../../../../../../docs/design/components/README.md).
abstract final class FileTreeDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 12;

  /// Island edge to the caption.
  static const double captionLeft = 14;

  /// Island's right edge to the centre of the caption's `+`: the board's 26
  /// before the `⋮`
  /// (`design/screens/desktop/workspace-tree/new-document-dark.svg`).
  static const double newCentreRight = menuCentreRight + 26;

  /// Island's right edge to the centre of the caption's `⋮` — the git
  /// column's number, the maintainer's call over this board's 20.5
  /// (`design/screens/desktop/workspace-tree/explorer-menu-dark.svg`).
  static const double menuCentreRight = 15.5;

  /// The explorer menu's width.
  static const double menuWidth = 200;

  /// How far the menu's right edge runs past the `⋮`'s centre: 4.5, which
  /// puts the edge at 251 on `explorer-menu`, whole pixels.
  static const double menuOverhang = 4.5;

  /// The `⋮` box's bottom to the menu's top: none, so the board's rules
  /// (110 and 179) land on whole pixels.
  static const double menuDrop = 0;

  /// The `+`'s hover box, centred on its glyph.
  static const double captionButton = 20;

  /// The `+` glyph; its ink is the board's nine points.
  static const double newGlyph = 11;

  /// The new document's field: from the row's label back to its left edge.
  static const double draftInset = 22;

  /// The field's left edge to its document glyph.
  static const double draftGlyph = 9;

  /// The field's left edge to the name typed in it.
  static const double draftText = 24;

  /// The field's height, centred in its row.
  static const double draftHeight = 26;

  /// The field's right edge to the island's.
  static const double draftRight = 7;

  /// Panel top to the search field.
  static const double searchTop = 38;

  /// The margin each side of the column's controls.
  ///
  /// The field and the scope control both run edge to edge inside it, so
  /// they follow the column as it is dragged
  /// (`design/screens/desktop/search/searching-every-document-dark.svg`).
  static const double controlInset = 8;

  /// The search field's height.
  static const double searchHeight = 28;

  /// The pitch between rows, also the list's item extent: the rows touch.
  static const double rowPitch = 26;

  /// The row's box, as tall as the pitch.
  static const double rowHeight = 26;

  /// The row's box inset from both edges.
  static const double rowInset = 4;

  /// The open row's bar, at the box's left edge.
  static const double barWidth = 2;

  /// Its height, centred in the row.
  static const double barHeight = 16;

  /// Island edge to a mark at the right of a row.
  static const double markRight = 16;

  /// The dot against a document with unsaved edits, and on a folder that
  /// holds a change.
  static const double dirtyDot = 6;

  /// The unsaved dot's slot, clear of the change mark's.
  ///
  /// **Past the mark, not inside it.** The mark is [TomMetrics.mark] wide at
  /// [rowInset], so a dot measured from the row's edge alone lands on the
  /// letter and the row draws two things in one place.
  static const double dirtyDotRight = markRight + TomMetrics.mark + markGap;

  /// Between the change mark and whatever sits before it.
  static const double markGap = 6;

  /// One level of nesting.
  static const double indent = 14;

  /// A chevron's offset left of its label: it sits before the row's glyph.
  static const double chevronOffset = 33;

  /// A row's glyph — folder or document — and its offset left of the label.
  static const double glyph = 12;

  /// The glyph's left edge, measured back from the label.
  static const double glyphOffset = 18;

  /// Where a row's text starts at the top level.
  static const double labelLeft = 42;

  /// Corner radius: a row, and the search field.
  static const double radius = 6;

  /// The panel's caption.
  static const double caption = 10.5;

  /// The search field's placeholder.
  static const double placeholder = 12;

  /// A row's label.
  static const double row = 12.5;

  /// A folder's chevron, the box it is drawn in.
  ///
  /// 16 everywhere it appears, which is the icon set's own grid
  /// (`docs/product/navigation/file-tree/order-and-shape/doc.md`).
  static const double chevron = 10;
}

/// The row's type, centred on its own line.
///
/// `even` leading is the point: by default a 1.4 line's extra space goes
/// mostly above the glyphs, and the row reads as sitting low in its pill.
TextStyle fileTreeRowText({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
}) => TextStyle(
  fontSize: size,
  height: 1.4,
  leadingDistribution: TextLeadingDistribution.even,
  fontWeight: weight,
  color: color,
);
