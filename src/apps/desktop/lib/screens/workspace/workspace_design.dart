/// What the design fixes about the window's chrome.
library;

/// The numbers of `workspace/shell-dark.svg` and `git-commit/committing-dark.svg`.
///
/// **The board is the record and it disagrees with
/// [controls.md](../../../../../../docs/design/components/controls.md) about
/// the toggles**: the table says 28 × 22 with a `border_strong` hairline, the
/// board draws 20 × 16 in `text_secondary`. The board wins
/// ([metrics](../../../../../packages/ui/lib/src/theme/tom_metrics.dart)).
abstract final class WorkspaceDesign {
  /// A panel toggle.
  static const double toggleWidth = 20;

  /// Its height.
  static const double toggleHeight = 16;

  /// Its corner.
  static const double toggleRadius = 3;

  /// The outline, and the strip and the divider drawn in it.
  static const double toggleStroke = 1.5;

  /// How far in from the toggle's own edge the divider sits — the strip is
  /// what falls between the two.
  static const double toggleStrip = 7;

  /// Between the two toggles.
  static const double toggleGap = 10;

  /// The theme control, a circle half filled.
  static const double themeBox = 16;

  /// The preferences gear, the bar's last control.
  ///
  /// The toggles' own weight, so the three still read as one set
  /// (`design/components/controls.md`).
  static const double gear = 20;

  /// Theme control to the first toggle, wider than the gap between the
  /// toggles because the three are one set of two kinds.
  static const double themeGap = 18;

  /// The switch at the head of the right column.
  static const double switchHeight = 28;

  /// Its corner.
  static const double switchRadius = 7;

  /// How far a segment's tile sits inside the control's outer edge.
  ///
  /// Three, so the tile is 22 in a 28 control, which is what the boards draw.
  static const double switchInset = 3;

  /// The control's outline.
  static const double switchStroke = 1;

  /// The tile's corner, tighter than the control's.
  static const double switchTileRadius = 5;

  /// Column edge to the switch, either side.
  static const double switchInsetX = 16;

  /// The top bar to the switch, and the switch to what is under it.
  static const double switchTop = 12;

  /// Either segment's label.
  static const double switchLabel = 11;
}
