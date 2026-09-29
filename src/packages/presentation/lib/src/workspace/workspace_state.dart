/// What the window's chrome is showing.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_presentation/src/workspace/theme_choice_enum.dart';

part 'workspace_state.freezed.dart';

/// Which columns are on screen, which git panel the right one shows, and
/// which theme is drawn (`docs/product/workspace/columns/doc.md`).
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

    /// Which theme the window draws.
    @Default(ThemeChoiceEnum.system) ThemeChoiceEnum theme,

    /// Which of the right column's panels is showing, by the id the module
    /// registered it under; null means the first one.
    ///
    /// The column's own state, not the document's — opening another file
    /// does not change it.
    String? asidePanel,
  }) = _WorkspaceState;
}
