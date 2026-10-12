/// What the design fixes about the `Diff` chip.
library;

/// The numbers the chip and the base's name beside it are drawn against,
/// measured off `design/screens/desktop/git-diff/comparing-dark.svg`.
abstract final class CompareDesign {
  /// The chip at the end of the bar.
  static const double chipWidth = 62;

  /// The chip's height, which matches the mode control's track.
  static const double chipHeight = 26;

  /// The chip's corner.
  static const double chipRadius = 6;

  /// Between the base's name and the chip.
  static const double chipGap = 12;

  /// The base's name.
  static const double label = 13;
}
