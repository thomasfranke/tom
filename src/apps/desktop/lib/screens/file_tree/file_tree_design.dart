/// What the design fixes about the explorer.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// The numbers of the visual design's `explorer` component, measured from
/// the top of the panel; type and radii from
/// [components.md](../../../../../../docs/technical/design/components.md).
abstract final class FileTreeDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the search field.
  static const double searchTop = 48;

  /// The search field's width.
  static const double searchWidth = 148;

  /// The search field's height.
  static const double searchHeight = 28;

  /// Panel edge to the milestone chip beside the search field.
  static const double chipLeft = TomMetrics.padTight + 158;

  /// Panel top to the first row.
  static const double rowsTop = 108;

  /// The pitch between rows, also the list's item extent.
  static const double rowPitch = 34;

  /// The row's box, shorter than the pitch.
  static const double rowHeight = 26;

  /// The row's box inset from both edges.
  static const double rowInset = 12;

  /// The dot against a document with unsaved edits.
  static const double dirtyDot = 8;

  /// The dot's right edge from the panel's.
  static const double dirtyDotRight = 26;

  /// One level of nesting.
  static const double indent = 16;

  /// A chevron's offset left of its label.
  static const double chevronOffset = 12;

  /// Where a row's text starts at the top level.
  static const double labelLeft = TomMetrics.pad;

  /// Corner radius: a row, and the search field.
  static const double radius = 6;

  /// The panel's caption.
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
