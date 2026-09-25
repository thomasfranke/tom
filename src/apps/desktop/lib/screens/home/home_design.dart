/// What the design fixes about Home.
library;

import 'package:tom_ui/tom_ui.dart';

/// The numbers of the drawing that generates `docs/product/home/mocks/`, a
/// 1440×900 window; when code and drawing disagree the drawing is right.
///
/// Everything here is centred or a gap between two things, so the layout
/// holds at any size.
abstract final class HomeDesign {
  /// The width the ways in share.
  static const double column = 440;

  /// A button, and the field that is not one yet.
  static const double control = 48;

  /// Corner radius of a control.
  static const double controlRadius = 8;

  /// Corner radius of a card or a pill.
  static const double cardRadius = 10;

  /// The gutter that keeps the column centred despite the milestone chip,
  /// which the design hangs outside the column.
  static const double chipGutter = 30 + TomMetrics.padTight;

  /// One row of the recent list.
  static const double row = 60;

  /// Row edge to its content.
  static const double rowPad = 20;

  /// Card edge to the rule between two rows.
  static const double rulePad = 16;

  /// Wordmark to the expansion of the name.
  static const double wordmarkToExpansion = 11.2;

  /// Expansion to the tagline.
  static const double expansionToTagline = 5.6;

  /// Tagline to the first control.
  static const double taglineToChoose = 51.5;

  /// The gap between the two controls.
  static const double chooseToClone = 12;

  /// Controls to the recent list's caption.
  static const double cloneToRecent = 38;

  /// Caption to the card under it.
  static const double recentToCard = 8;

  /// Refusal heading to the quoted path.
  static const double headingToPath = 18.3;

  /// Quoted path to the explanation.
  static const double pathToBody = 26;

  /// Explanation to the retry.
  static const double bodyToRetry = 38.5;

  /// Retry to the line about repositories.
  static const double retryToHint = 20;

  /// The quoted path's box.
  static const double pathBox = 30;

  /// The quoted path's line height, in pixels.
  static const double pathLine = 16;

  /// The measure the explanation is set to.
  static const double body = 560;

  /// The retry button, which is narrower than the column.
  static const double retry = 280;
}
