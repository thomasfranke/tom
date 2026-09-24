/// What the design fixes about the preview.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers the preview is drawn against.
///
/// The reading column is a *measure*, not a pane width: prose is set to a
/// line length, and the pane is whatever is left around it. Type comes from
/// the table in
/// [components.md](../../../../../../docs/technical/design/components.md).
///
/// Two sets of them, because the preview has two jobs: beside the source it
/// is a companion, and alone it is the document — which is the whole claim
/// of preview-only reading (`docs/product/editor/markdown-preview/doc.md`).
///
/// Public and beside the panel rather than private inside it: the panel and
/// its widgets are separate files now, and three copies of 540 would drift.
abstract final class PreviewDesign {
  /// The reading measure, beside the source pane.
  static const double measure = 540;

  /// The reading measure with the pane to itself.
  ///
  /// Wider *and* set larger: nothing is competing for the width, and this is
  /// the mode somebody reads a whole document in.
  static const double readingMeasure = 660;

  /// Prose size with the pane to itself.
  static const double readingBody = 16;

  /// Panel top to the caption's baseline box.
  static const double captionTop = 18;

  /// Panel top to the first block.
  static const double bodyTop = 42;

  /// Prose size, and the line height it is set at.
  static const double body = 15;

  /// Line height of prose, as a multiple of [body].
  static const double bodyHeight = 1.7;

  /// `h1` and `h2`, which the design draws at one size.
  static const double headingLarge = 24;

  /// `h3`; `h4` and below fall back to [body].
  static const double heading = 17;

  /// Code, inline and fenced alike.
  static const double code = 12.5;

  /// The panel's own caption.
  static const double caption = 10;

  /// The gap between two blocks.
  static const double blockGap = 18;

  /// A fenced block's padding inside its box.
  static const double codePad = 14;

  /// The rule down the left of a quote.
  static const double quoteBar = 3;

  /// The rule down the left of a changed block.
  ///
  /// Wider than a quote's, because this one is the *second* signal after the
  /// tint and has to survive being glanced at
  /// (`docs/technical/design/visual-language.md`).
  static const double diffBar = 4;

  /// Block edge to content, inside a changed block's tint.
  static const double diffPad = 12;

  /// The corner a changed block's tint is drawn with.
  static const double diffRadius = 6;

  /// What the decoration takes around the prose: gutter, bar and padding.
  ///
  /// Taken out of the **pane**, never out of the measure — a document keeps
  /// its line length whether or not anything changed in it, so a first
  /// keystroke does not reflow everything that was already on screen.
  static const double diffInset = TomMetrics.mark + diffPad * 3 + diffBar;
}
