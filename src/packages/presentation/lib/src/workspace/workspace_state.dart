/// What the window's chrome is showing.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_state.freezed.dart';

/// Which columns are on screen, and which git panel the right one shows
/// (`docs/product/workspace/columns/doc.md`).
///
/// ~~Which theme is drawn~~ moved out: the theme is a **preference**, kept
/// on the machine rather than in the window
/// (`docs/product/preferences/what-it-holds/doc.md`).
///
/// A hidden column is a column, not a mode: what was on screen comes back
/// unchanged, so this carries whether it is shown and nothing about what is
/// in it.
@freezed
abstract class WorkspaceState with _$WorkspaceState {
  /// Creates the state.
  const factory WorkspaceState({
    /// Whether the left column is on screen.
    @Default(true) bool showingExplorer,

    /// Whether the right column is.
    @Default(true) bool showingAside,

    /// How wide the left column is, or null for the width it opens at.
    ///
    /// The reader's, dragged from the divider beside it: it opens at a width
    /// the tree reads well at, and somebody reading search results widens it
    /// (`docs/product/workspace/regions/doc.md`).
    double? explorerWidth,

    /// How wide the right column is, or null for the width it opens at —
    /// dragged from its own divider, the same way as the left one.
    double? asideWidth,

    /// Which of the right column's panels is showing, by the id the module
    /// registered it under; null means the first one.
    ///
    /// The column's own state, not the document's — opening another file
    /// does not change it.
    String? asidePanel,

    /// Whether the panel under the document is on screen — closed until
    /// somebody opens it, and never opened by the app itself
    /// (`docs/product/workspace/commands/doc.md`).
    @Default(false) bool showingBottom,

    /// Which of its tabs is showing, by id; null means the first one.
    String? bottomPanel,

    /// How tall the panel under the document is, or null for the height it
    /// opens at — dragged from the gutter above it, as the columns are.
    double? bottomHeight,
  }) = _WorkspaceState;
}
