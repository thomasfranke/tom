/// What the design fixes about the preferences popover.
library;

/// The numbers the popover is drawn against
/// (`design/screens/desktop/preferences/preferences-light.svg`).
abstract final class PreferencesDesign {
  /// The card.
  static const double width = 280;

  /// What it keeps around its contents.
  static const double inset = 16;

  /// The content's width, which every control in it shares.
  static const double content = width - inset * 2;

  /// Card top to the first caption.
  static const double captionTop = 20;

  /// What a caption is drawn at.
  static const double captionSize = 10;

  /// A caption to the control under it.
  static const double captionToControl = 6;

  /// The two-way theme control.
  static const double switchHeight = 28;

  /// The raised half's inset inside it.
  static const double switchInset = 2;

  /// Between one setting and the next caption.
  static const double settingGap = 24;

  /// The language select, and the button at the foot.
  static const double rowHeight = 40;

  /// The checkbox.
  static const double box = 18;

  /// The checkbox to its label.
  static const double boxToLabel = 8;

  /// Above and below the rule that separates the button from the settings.
  static const double ruleGap = 16;

  /// What every label in the popover is drawn at.
  static const double label = 13;
}
