/// Drives the window's chrome: the columns, the theme, the git panel.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/src/workspace/workspace_state.dart';

part 'workspace_notifier.g.dart';

/// The two column toggles at the right of the top bar, and the right
/// column's switch (`docs/product/workspace/columns/doc.md`).
///
/// Kept alive because the columns are read above the shell: a provider
/// nobody in the shell listened to would be disposed between screens and
/// the choice would go with it.
@Riverpod(keepAlive: true)
class WorkspaceNotifier extends _$WorkspaceNotifier {
  @override
  WorkspaceState build() => const WorkspaceState();

  /// Shows the left column, or puts it away.
  void toggleExplorer() =>
      state = state.copyWith(showingExplorer: !state.showingExplorer);

  /// Shows the right column, or puts it away.
  void toggleAside() =>
      state = state.copyWith(showingAside: !state.showingAside);

  /// Shows the right column's panel registered under [id].
  void showAsidePanel(String id) => state = state.copyWith(asidePanel: id);

  /// Sets the left column's width, between [narrowest] and [widest].
  ///
  /// Clamped here rather than by the divider, so a drag that runs past the
  /// window cannot leave a column too narrow to read or wide enough to take
  /// the document's place.
  void widenExplorer(double width) => state = state.copyWith(
    explorerWidth: width < narrowest
        ? narrowest
        : (width > widest ? widest : width),
  );

  /// The least the left column may be dragged to.
  static const double narrowest = 180;

  /// The most.
  static const double widest = 480;
}
