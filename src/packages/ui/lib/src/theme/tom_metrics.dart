/// The shell's fixed dimensions.
library;

/// What the boards fix about the layout.
///
/// Every number here is measured off a screen in
/// [`docs/design/screens/`](../../../../../../docs/design/screens/README.md),
/// and **when the two disagree the board is right** — it is the design of
/// record, and this class is a transcription of it.
abstract final class TomMetrics {
  /// Height of the bar above everything: space name and global actions.
  static const double topBar = 52;

  /// Height of the bar below everything: branch, status, counts.
  static const double statusBar = 32;

  /// Height of the bar above the document area: the three modes, and
  /// whether the buffer has reached the disk.
  static const double modeBar = 36;

  /// Height of the band that carries news from git, above the document.
  ///
  /// The mode bar's height, because the two stack and a band taller than the
  /// chrome it sits under reads as a dialog
  /// (`docs/design/components/controls.md`).
  static const double noticeBand = 36;

  /// Chrome edge to the first thing written on it.
  ///
  /// The mode bar's own inset, shared so the band's sentence starts on the
  /// same column as the mode control above it.
  static const double barInset = 28;

  /// The width the left column **opens at**, not the width it keeps.
  ///
  /// The reader drags it, so this is a starting point rather than a constant
  /// (`docs/product/workspace/regions/doc.md`) — 220 is where the tree reads
  /// well, and search results are why somebody widens it.
  static const double explorer = 220;

  /// Width of the git panel.
  static const double git = 280;

  /// The least height a stacked panel is given before the column scrolls.
  ///
  /// The tallest fixed furniture a panel carries — the changes column's
  /// caption, message box and button — plus one row of its list.
  static const double minimumStackedPanel = 280;

  /// Panel edge to content.
  static const double pad = 20;

  /// Panel edge to a control that spans the panel.
  static const double padTight = 16;

  /// How much further in than the panels the chrome's own text sits.
  ///
  /// Both bars and Home's status line share it, so the space name and the
  /// status read as one column down the left edge.
  static const double chromeInset = 4;

  /// The square a diff mark is drawn in, one component for the changes
  /// column and the rendered diff (`docs/design/components/README.md`).
  static const double mark = 20;

  /// The corner radius of a mark, a checkbox, a tab indicator.
  static const double radiusTight = 4;

  /// The corner radius of everything else
  /// (`docs/design/components/radius.md`).
  ///
  /// Two steps and a shape, so a third value is drift rather than a choice.
  static const double radius = 8;

  /// The smallest window the layout still holds together in.
  ///
  /// Explorer, git panel and a document area wide enough for source beside
  /// preview; narrower, panels would have to hide each other.
  static const double minimumWindowWidth = 960;

  /// The smallest window height worth opening a document in.
  static const double minimumWindowHeight = 600;
}
