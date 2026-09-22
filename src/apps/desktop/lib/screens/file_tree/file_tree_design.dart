/// What the design fixes about the explorer.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// The numbers the explorer is drawn against.
///
/// The `explorer` component of the visual design, which every screen with a
/// space open places — that is what keeps the tree identical across all of
/// them. Type and radii come from
/// [components.md](../../../../../../docs/technical/design/components.md).
///
/// Every vertical number is measured from the top of the panel, which is
/// where the design measures from: the shell is what puts it under the top
/// bar.
///
/// Public and beside the panel rather than private inside it: the panel and
/// its rows are separate files now, and two copies of 34 would drift.
abstract final class FileTreeDesign {
  /// Panel top to the caption's baseline box.
  static const double captionTop = 18;

  /// Panel top to the search field.
  static const double searchTop = 48;

  /// The search field's own box.
  static const double searchWidth = 148;

  /// Height of the search field.
  static const double searchHeight = 28;

  /// The milestone chip beside the search field.
  static const double chipLeft = TomMetrics.padTight + 158;

  /// Panel top to the first row.
  static const double rowsTop = 108;

  /// The pitch between rows, which is also the list's item extent.
  static const double rowPitch = 34;

  /// The row's own box, shorter than the pitch.
  static const double rowHeight = 26;

  /// How far the row's box is inset from both edges.
  static const double rowInset = 12;

  /// One level of nesting.
  static const double indent = 16;

  /// How far left of its label a chevron sits.
  static const double chevronOffset = 12;

  /// Where a row's text starts, at the top level.
  static const double labelLeft = TomMetrics.pad;

  /// Corner radius: a row, and the search field.
  static const double radius = 6;

  /// The panel's own caption.
  static const double caption = 10;

  /// The search field's placeholder.
  static const double placeholder = 12;

  /// A row's label.
  static const double row = 13;

  /// A folder's chevron.
  static const double chevron = 9;
}

/// The row's type, centred on its own line.
///
/// `even` leading is the whole point: by default the extra space of a 1.4
/// line goes mostly above the glyphs, which is what made a row read as
/// sitting low inside the open document's pill.
///
/// A function beside the constants rather than a static on them, so
/// [FileTreeDesign] stays what its name says: numbers, and nothing that
/// behaves.
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
