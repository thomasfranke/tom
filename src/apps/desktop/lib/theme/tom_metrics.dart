/// The shell's fixed dimensions.
library;

/// What the wireframes fix about the layout.
///
/// These are not taste. They come from
/// [the drawing kit](../../../../../docs/technical/design/tools/kit.py),
/// which is what every wireframe is drawn against, and **when the two
/// disagree the wireframe is right** (`docs/technical/design/README.md`).
/// Copied rather than generated because four numbers do not earn a build
/// step; the names are the kit's own, so a mismatch is visible by reading.
abstract final class TomMetrics {
  /// Height of the bar above everything: space name and global actions.
  static const double topBar = 52;

  /// Height of the bar below everything: branch, status, counts.
  static const double statusBar = 32;

  /// Width of the explorer.
  ///
  /// **Constant across every screen.** The explorer never moves and never
  /// changes width — a panel narrower on one screen than another is a bug,
  /// not a variant (`docs/product/workspace/doc.md`).
  static const double explorer = 220;

  /// Width of the git panel, which arrives in M1.
  static const double git = 280;

  /// Panel edge to content.
  static const double pad = 20;

  /// Panel edge to a control that spans the panel.
  static const double padTight = 16;

  /// The smallest window the layout still holds together in.
  ///
  /// Explorer plus git panel plus a document area wide enough to read a
  /// source line and its preview side by side. Below this the panels would
  /// have to start hiding each other, and the product's first rule is that
  /// they are all on screen at once.
  static const double minimumWindowWidth = 960;

  /// The smallest window height worth opening a document in.
  static const double minimumWindowHeight = 600;
}
