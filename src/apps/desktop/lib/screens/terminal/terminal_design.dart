/// What the design fixes about the Terminal tab.
library;

/// The numbers of `22 · Screens: Commands & Terminal`, board `Terminal`
/// (`docs/product/workspace/terminal/doc.md`).
abstract final class TerminalDesign {
  /// The text, IBM Plex Mono.
  static const double fontSize = 12;

  /// One line, baseline to baseline.
  static const double lineHeight = 19;

  /// From the panel's edges to the first cell.
  static const double inset = 14;

  /// How many lines the scrollback keeps.
  static const int scrollback = 5000;

  /// The shell and its folder, after the tabs.
  static const double place = 11.5;
}
