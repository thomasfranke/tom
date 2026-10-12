/// What the design fixes about the window's chrome.
library;

/// The numbers of `workspace-shell/shell-dark.svg` and
/// `git-commit/committing-dark.svg`.
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

  /// How far up from the bottom toggle's own edge its divider sits: the
  /// strip it fills is the panel under the document.
  static const double toggleStripBottom = 6;

  /// Between two toggles.
  static const double toggleGap = 10;

  /// The theme control, a circle half filled.
  static const double themeBox = 16;

  /// The preferences gear, outlined: a 16 glyph draws the boards' 15 × 16
  /// ink, and the breadcrumb's house is sized to match it.
  static const double gear = 16;

  /// The gear's box, which the 1b boards draw at 24.
  static const double gearBox = 24;

  /// The second toggle to the gear's box: the toggles' own gap, so the three
  /// read as one set.
  static const double themeGap = 10;

  /// The gear's box to the account button's, which ends the bar: the boards
  /// put the gear at 1368 and the account at 1402 on a 1440 window.
  static const double accountGap = 10;

  /// The tabs at the head of the right column: the row, rule included.
  static const double tabsHeight = 37;

  /// Column edge to the first tab.
  static const double tabsInset = 14;

  /// Between two tabs.
  static const double tabsGap = 16;

  /// A tab's name.
  static const double tabsLabel = 12.5;

  /// A tab's name to the badge beside it
  /// (`design/screens/desktop/git-commit/committing-dark.svg`).
  static const double tabsBadgeGap = 11;

  /// The chosen tab's underline.
  static const double tabsUnderline = 2;

  /// The underline's distance above the rule.
  static const double tabsUnderlineBottom = 3;

  /// The panel under the document, from `22 · Screens: Commands & Terminal`
  /// (`docs/product/workspace/commands/doc.md`): its height.
  static const double bottomHeight = 260;

  /// What the document keeps however high the panel is dragged: the tabs,
  /// the row of tools and a few lines of text.
  static const double documentLeast = 200;

  /// Its head, above the rule.
  static const double bottomHead = 34;

  /// Panel edge to the first tab.
  static const double bottomTabsInset = 14;

  /// The bottom tabs' label: 12, where the boards' `Commands` is 65 wide and
  /// 12.5 makes it 67.
  static const double bottomTabsLabel = 12;

  /// Between two tabs: 14 between the inks on `The bottom panel — its
  /// states`, which a label's own side bearing makes 15 of box.
  static const double bottomTabsGap = 15;

  /// The `×`'s left edge, from the panel's right edge.
  static const double bottomClose = 25;
}
