/// Where a panel sits in the shell.
library;

/// The regions of the shell a panel can be registered into.
///
/// A closed set, on purpose. A module contributes a panel to a region the
/// layout already has; it does not invent regions, because a module that
/// could would be changing the app rather than adding to it — and **modules
/// add, they never change or degrade what the app already does**
/// ([flows](../../../../../docs/technical/flows.md#panels-are-registered-never-hardcoded)).
///
/// The regions come from the wireframe, not from this file
/// (`docs/product/workspace/mocks/shell.excalidraw`).
enum PanelPlacementEnum {
  /// The fixed-width column on the left: the file tree, and whatever else
  /// navigates the space.
  explorer,

  /// The middle, where the document is read and edited.
  ///
  /// More than one panel here sits side by side — source and preview are
  /// two panels, not one panel with a mode.
  document,

  /// The fixed-width column on the right: git, and later search results.
  aside,

  /// The strip along the bottom: branch, ahead/behind, counts.
  ///
  /// Status only. A panel here is read, never worked in.
  statusBar,
}
