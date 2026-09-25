/// The shell's fixed dimensions.
library;

/// What the wireframes fix about the layout.
///
/// Copied under the kit's own names from
/// [the drawing kit](../../../../../../docs/technical/design/tools/kit.py),
/// and **when the two disagree the wireframe is right**
/// (`docs/technical/design/README.md`).
abstract final class TomMetrics {
  /// Height of the bar above everything: space name and global actions.
  static const double topBar = 52;

  /// Height of the bar below everything: branch, status, counts.
  static const double statusBar = 32;

  /// Height of the bar above the document area: the three modes, and
  /// whether the buffer has reached the disk.
  static const double modeBar = 36;

  /// Width of the explorer, **constant across every screen**
  /// (`docs/product/workspace/doc.md`).
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
  /// column and the rendered diff (`docs/technical/design/components.md`).
  static const double mark = 20;

  /// The corner radius of a mark, a checkbox, a tab indicator.
  static const double radiusTight = 4;

  /// The smallest window the layout still holds together in.
  ///
  /// Explorer, git panel and a document area wide enough for source beside
  /// preview; narrower, panels would have to hide each other.
  static const double minimumWindowWidth = 960;

  /// The smallest window height worth opening a document in.
  static const double minimumWindowHeight = 600;
}
