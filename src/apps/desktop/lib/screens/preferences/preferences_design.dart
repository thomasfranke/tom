/// What the design fixes about the preferences popover.
library;

/// The numbers the popover is drawn against
/// (`design/screens/desktop/preferences/preferences-dark.svg`), each measured
/// from a render of the export.
abstract final class PreferencesDesign {
  /// The card.
  static const double width = 280;

  /// What it keeps around its contents, from the card's outer edge.
  static const double inset = 13;

  /// The content's width, which every control in it shares.
  static const double content = width - inset * 2;

  /// Card top to the first caption.
  static const double captionTop = 13;

  /// What a caption is drawn at.
  static const double captionSize = 10;

  /// A caption to the control under it.
  static const double captionToControl = 4;

  /// The two-way theme control.
  static const double switchHeight = 28;

  /// The raised half's inset inside it.
  static const double switchInset = 2;

  /// The theme control to the language caption.
  static const double afterSwitch = 14;

  /// Between one setting and the next: the select to the first checkbox, the
  /// second checkbox to the git caption.
  static const double settingGap = 15;

  /// The language select.
  static const double selectHeight = 32;

  /// The `Open …json` buttons.
  static const double buttonHeight = 34;

  /// A checkbox's row, and the gap to the next.
  static const double checkRow = 18;

  /// The gap between the two checkboxes' rows.
  static const double checkGap = 8;

  /// The checkbox to its label.
  static const double boxToLabel = 7;

  /// The git control to the sentence under it.
  static const double switchToWhy = 10;

  /// The sentence to the first button.
  static const double whyToButton = 8;

  /// A button to the rule under it.
  static const double ruleAbove = 15;

  /// A rule to what follows it.
  static const double ruleBelow = 16;

  /// The `About` row.
  static const double aboutHeight = 27;

  /// The `About` row to the card's foot, which the boards leave a little
  /// roomier than the top.
  static const double footer = 5;

  /// The sentence under the git commands control.
  static const double why = 11.5;

  /// What every label in the popover is drawn at — the size whose ink is as
  /// wide as the board's, which declares 12.5 over narrower metrics.
  static const double label = 12;

  /// The words of a segmented control, whose ink the board draws at 85 % of
  /// the app's former 13.
  static const double segment = 11;

  /// The glyph before a button's label, and its gap to the label.
  static const double fileGlyph = 10;

  /// The `Open …json` buttons' label: 137 of ink on `preferences-light` for
  /// `Open git-approvals.json` against the 133 of 11.5.
  static const double buttonLabel = 11.8;

  /// The gap from the document glyph to the button's label: 8 of paper
  /// between the inks on the board, 9 at 8.
  static const double glyphToLabel = 7;
}
