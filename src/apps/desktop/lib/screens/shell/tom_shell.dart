/// The panel layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
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
class TomShell extends ConsumerWidget {
  /// Creates the shell.
  const TomShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PanelRegistry registry = ref.watch(panelRegistryProvider);
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
    final TomColors colors = TomColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          const ShellTopBarWidget(),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: Stack(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (showingExplorer)
                      ShellRegionWidget(
                        placement: PanelPlacementEnum.explorer,
                        registry: registry,
                        width: explorerWidth,
                      ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          // The bar belongs to the document area: the explorer
                          // and the aside are not in a mode.
                          if (registry
                              .at(PanelPlacementEnum.document)
                              .isNotEmpty) ...<Widget>[
                            // The columns' widths, because the mode control is
                            // centred on the window rather than on this bar.
                            ShellModeBarWidget(
                              leftInset:
                                  showingExplorer &&
                                      registry
                                          .at(PanelPlacementEnum.explorer)
                                          .isNotEmpty
                                  ? explorerWidth
                                  : 0,
                              rightInset:
                                  showingAside &&
                                      registry
                                          .at(PanelPlacementEnum.aside)
                                          .isNotEmpty
                                  ? TomMetrics.git
                                  : 0,
                            ),
                            Divider(height: 1, color: colors.border),
                          ],
                          // News from git spans the document area and pushes
                          // the document down, rather than living in a
                          // column (`docs/product/workspace/feedback/doc.md`).
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
                    if (showingAside)
                      ShellRegionWidget(
                        placement: PanelPlacementEnum.aside,
                        registry: registry,
                        width: TomMetrics.git,
                      ),
                  ],
                ),
                // Over the rule rather than in the row, so grabbing it costs
                // the layout nothing: the column is the board's width and
                // the hairline is still one point.
                if (showingExplorer)
                  Positioned(
                    left: explorerWidth - WorkspaceGripWidget.grip / 2,
                    top: 0,
                    bottom: 0,
                    child: WorkspaceGripWidget(width: explorerWidth),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          ShellStatusBarWidget(registry: registry),
        ],
      ),
    );
  }
}
