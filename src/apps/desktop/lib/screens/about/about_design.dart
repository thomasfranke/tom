/// What the design fixes about the About dialog.
library;

/// The numbers the dialog is drawn against
/// (`design/screens/desktop/about-updates/about-the-update-states-dark.svg`),
/// each measured from a render of the export and counted from the card's top
/// edge.
abstract final class AboutDesign {
  /// The card's height with its update line in any state — the buttons keep
  /// their place whatever the line says.
  static const double height = 432;

  /// The brand icon's side.
  static const double icon = 56;

  /// The icon to the name beside it.
  static const double iconToName = 16;

  /// The name's size.
  static const double nameSize = 22;

  /// The header to the first fact.
  static const double headerToFacts = 20;

  /// One fact's row, label to label.
  static const double factRow = 24;

  /// A fact row's text, down from the row's top: it sits a little above the
  /// middle so the three baselines land where the board's do.
  static const double factInset = 1;

  /// Where a fact's value starts, from the content's left edge — the card's
  /// own 120 less its 24 inset.
  static const double valueColumn = 96;

  /// The line under the name.
  static const double taglineSize = 12.5;

  /// A fact's label.
  ///
  /// **The sizes here are the ones whose ink is as wide as the board's**, not
  /// the ones its text boxes declare (12, 12.5, 13): the export measures with
  /// narrower metrics than the face the app draws, so a declared size lands 4
  /// to 8 % wide.
  static const double labelSize = 11.5;

  /// A fact's value, and the links and the update sentence under it.
  static const double valueSize = 12.25;

  /// The last fact to the links.
  static const double factsToLinks = 12;

  /// The gap between two links.
  static const double linkGap = 24;

  /// The links to the rule.
  static const double linksToRule = 17.7;

  /// The rule to the `UPDATES` caption.
  static const double ruleToCaption = 14;

  /// The caption's size.
  static const double captionSize = 10;

  /// The caption to the update line.
  static const double captionToLine = 6.6;

  /// What the update line keeps, from its top to the button: one sentence and
  /// the line under it fit, and the button never moves.
  static const double lineHeight = 48.7;

  /// The line's second sentence, down from the first.
  static const double sentenceGap = 0.5;

  /// A button's height.
  static const double button = 48;

  /// The gap between the two buttons.
  static const double buttonGap = 8;

  /// A button's label.
  static const double buttonSize = 14;
}
