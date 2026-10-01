/// The panel layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/remote/remote_band_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_region_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_status_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_top_bar_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_grip_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The window: explorer, document area, aside and status bar, all at once
/// and never taken over (`docs/product/workspace/regions/doc.md`).
///
/// Names no panel: it asks [PanelRegistry] what belongs in each region and
/// builds what it is told.
class TomShell extends ConsumerStatefulWidget {
  /// Creates the shell.
  const TomShell({super.key});

  @override
  ConsumerState<TomShell> createState() => _TomShellState();
}

class _TomShellState extends ConsumerState<TomShell> {
  /// Where the source pane leaves the way to `re_editor`'s own undo.
  ///
  /// Here because the two ends are in different regions: the pane is in the
  /// document area and the buttons are in the row above it, so the nearest
  /// thing that holds both is the shell ([EditorHistory]).
  final EditorHistory _history = EditorHistory();

  @override
  void dispose() {
    _history.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PanelRegistry registry = ref.watch(panelRegistryProvider);
    // Read here and not only inside the git column, because the column is
    // built under a flag and this notifier is the app's one reader of git:
    // with it shut from the start nothing would ever ask, and the band above
    // the document could not say a pull had stopped. `keepAlive` keeps it
    // once it exists; this is what makes it exist.
    ref.watch(changesProvider);
    final bool readingVersion = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion != null,
      ),
    );
    final DocumentModeEnum chosen =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.mode,
          ),
        ) ??
        DocumentModeEnum.split;
    // A version being read draws as preview, since nothing types into the
    // past; the choice itself is untouched so coming back comes back to it
    // (`docs/product/git-workflow/file-history/doc.md`).
    final DocumentModeEnum mode = readingVersion
        ? DocumentModeEnum.preview
        : chosen;
    // A hidden column is a column, not a mode: the document area takes the
    // room and nothing else moves (`docs/product/workspace/columns/doc.md`).
    final bool showingExplorer = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingExplorer),
    );
    final bool showingAside = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingAside),
    );
    final double explorerWidth =
        ref.watch(
          workspaceProvider.select((WorkspaceState it) => it.explorerWidth),
        ) ??
        TomMetrics.explorer;
    // A column nobody registered a panel into takes no room: a fixed column
    // drawn empty reads as a bug in the layout, and its container would
    // frame nothing.
    final bool hasDocument = registry
        .at(PanelPlacementEnum.document)
        .isNotEmpty;
    final bool openExplorer =
        showingExplorer && registry.at(PanelPlacementEnum.explorer).isNotEmpty;
    final bool openAside =
        showingAside && registry.at(PanelPlacementEnum.aside).isNotEmpty;
    final TomColors colors = TomColors.of(context);
    // A stack, not a column: the containers run **under** the two bars and
    // off both sides of the window, so the bars are drawn over them and no
    // edge of a column frames the window
    // (`docs/design/screens/measurements.md`).
    return EditorHistoryScope(
      history: _history,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: TomMetrics.topBar,
              bottom: TomMetrics.statusBar,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (openExplorer)
                        SizedBox(
                          width: explorerWidth,
                          child: TomColumnBoxWidget(
                            edge: TomColumnEdgeEnum.left,
                            child: ShellRegionWidget(
                              placement: PanelPlacementEnum.explorer,
                              registry: registry,
                            ),
                          ),
                        )
                      else
                        // A closed column leaves its gutter behind, which is
                        // where the way to open it again lives.
                        const SizedBox(width: TomMetrics.gutter),
                      Expanded(
                        // The container holds the row above the document as
                        // well as the panes: the boards draw one rect from
                        // under the top bar to under the status bar.
                        child: TomColumnBoxWidget(
                          edge: TomColumnEdgeEnum.neither,
                          child: Column(
                            children: <Widget>[
                              // The bar belongs to the document area: the
                              // explorer and the aside are not in a mode.
                              if (hasDocument) ...<Widget>[
                                // The columns' widths, kept although nothing
                                // in the row is measured against the window.
                                ShellModeBarWidget(
                                  leftInset: openExplorer ? explorerWidth : 0,
                                  rightInset: openAside ? TomMetrics.git : 0,
                                ),
                                Divider(height: 1, color: colors.border),
                              ],
                              // News from git spans the document area and
                              // pushes the document down, rather than living
                              // in a column
                              // (`docs/product/workspace/feedback/doc.md`).
                              const RemoteBandWidget(),
                              Expanded(
                                child: ShellRegionWidget(
                                  placement: PanelPlacementEnum.document,
                                  registry: registry,
                                  mode: mode,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Always: the gutter before the right column stays
                      // when that column closes.
                      const SizedBox(width: TomMetrics.gutter),
                      if (openAside)
                        SizedBox(
                          width: TomMetrics.git,
                          child: TomColumnBoxWidget(
                            edge: TomColumnEdgeEnum.right,
                            child: ShellRegionWidget(
                              placement: PanelPlacementEnum.aside,
                              registry: registry,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Over the gutter rather than in the row, so grabbing it
                  // costs the layout nothing.
                  Positioned(
                    left: openExplorer ? explorerWidth - TomMetrics.gutter : 0,
                    top: 0,
                    bottom: 0,
                    child: WorkspaceGripWidget(width: explorerWidth),
                  ),
                  Positioned(
                    right: openAside ? TomMetrics.git : 0,
                    top: 0,
                    bottom: 0,
                    // Not yet: the right column's width is fixed, and dots
                    // over a width nobody can drag are a promise the app
                    // does not keep (`docs/design/screens/divergences.md`).
                    child: const WorkspaceGripWidget(
                      width: TomMetrics.git,
                      isDraggable: false,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ShellTopBarWidget(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ShellStatusBarWidget(registry: registry),
            ),
          ],
        ),
      ),
    );
  }
}
