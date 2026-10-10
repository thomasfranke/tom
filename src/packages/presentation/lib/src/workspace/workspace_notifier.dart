/// Drives the window's chrome: the columns, the theme, the git panel.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/src/workspace/workspace_state.dart';

part 'workspace_notifier.g.dart';

/// The three panel toggles at the right of the top bar, and the right
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

  /// Shows the panel under the document, or puts it away — ⌘J and the
  /// toggle between the two column toggles.
  void toggleBottom() =>
      state = state.copyWith(showingBottom: !state.showingBottom);

  /// Opens the panel under the document on its tab registered under [id].
  void showBottomPanel(String id) =>
      state = state.copyWith(showingBottom: true, bottomPanel: id);

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

  /// Sets the right column's width, between [asideNarrowest] and
  /// [asideWidest], clamped for the same reason as [widenExplorer].
  void widenAside(double width) => state = state.copyWith(
    asideWidth: width < asideNarrowest
        ? asideNarrowest
        : (width > asideWidest ? asideWidest : width),
  );

  /// Sets the bottom panel's height, between [bottomLowest] and [highest] —
  /// the window's to say, since what the document keeps depends on it.
  void raiseBottom(double height, {double highest = bottomHighest}) {
    final double most = highest < bottomLowest ? bottomLowest : highest;
    state = state.copyWith(
      bottomHeight: height < bottomLowest
          ? bottomLowest
          : (height > most ? most : height),
    );
  }

  /// The least the bottom panel may be dragged to: its head and two rows.
  static const double bottomLowest = 120;

  /// The most, when the window says nothing tighter.
  static const double bottomHighest = 720;

  /// The least the left column may be dragged to.
  static const double narrowest = 180;

  /// The most.
  static const double widest = 480;

  /// The least the right column may be dragged to: under it, the column's
  /// foot no longer holds `Fetch` and `Pull` side by side.
  static const double asideNarrowest = 260;

  /// The most.
  static const double asideWidest = 520;
}
