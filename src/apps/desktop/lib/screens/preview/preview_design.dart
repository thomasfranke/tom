/// What the design fixes about the preview.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers the preview is drawn against; type from
/// [components](../../../../../../docs/design/components/README.md).
///
/// The reading column is a measure, not a pane width, and there are two of
/// them because beside the source the preview is a companion and alone it
/// is the document (`docs/product/editor/markdown-preview/doc.md`).
abstract final class PreviewDesign {
  /// The reading measure, beside the source pane.
  static const double measure = 540;

  /// The reading measure with the pane to itself.
  static const double readingMeasure = 660;

  /// Prose size with the pane to itself.
  static const double readingBody = 16;

  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the first block.
  static const double bodyTop = 42;

  /// Prose size.
  static const double body = 15;

  /// Line height of prose, as a multiple of [body].
  static const double bodyHeight = 1.7;

  /// `h1` and `h2`, which the design draws at one size.
  static const double headingLarge = 24;

  /// `h3`; `h4` and below fall back to [body].
  static const double heading = 17;

  /// Code, inline and fenced alike.
  static const double code = 12.5;

  /// The panel's caption.
  static const double caption = 10;

  /// The gap between two blocks.
  static const double blockGap = 18;

  /// A fenced block's padding inside its box.
  static const double codePad = 14;

  /// The rule down the left of a quote.
  static const double quoteBar = 3;

  /// The rule down the left of a changed block; wider than a quote's because
  /// it is the second signal after the tint
  /// (`docs/design/visual-language/README.md`).
  static const double diffBar = 4;

  /// Block edge to content, inside a changed block's tint.
  static const double diffPad = 12;

  /// The corner a changed block's tint is drawn with.
  static const double diffRadius = 6;

  /// What the decoration takes around the prose: gutter, bar and padding.
  ///
  /// Taken out of the pane, never the measure, so a first keystroke does not
  /// reflow what was already on screen.
  static const double diffInset = TomMetrics.mark + diffPad * 3 + diffBar;
}
