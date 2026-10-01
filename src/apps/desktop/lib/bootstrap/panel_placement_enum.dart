/// Where a panel sits in the shell.
library;

/// The regions of the shell a panel can be registered into.
///
/// A closed set: a module adds to a region the wireframe already has and
/// never invents one, because modules add and never change the app
/// ([composition](../../../../../docs/technical/runtime/composition.md)).
enum PanelPlacementEnum {
  /// The fixed-width column on the left, where the space is navigated.
  explorer,

  /// The middle, where the document is read and edited.
  ///
  /// More than one panel here sits side by side — source and preview are
  /// two panels, not one panel with a mode.
  document,

  /// The fixed-width column on the right: git, and later search results.
  aside,

  /// The strip along the bottom, read and never worked in.
  statusBar,
}
