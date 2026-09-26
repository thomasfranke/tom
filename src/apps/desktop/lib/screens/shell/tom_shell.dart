/// The panel layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_region_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_status_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_top_bar_widget.dart';
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
    final TomColors colors = TomColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          const ShellTopBarWidget(),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ShellRegionWidget(
                  placement: PanelPlacementEnum.explorer,
                  registry: registry,
                  width: TomMetrics.explorer,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      // The bar belongs to the document area: the explorer
                      // and the aside are not in a mode.
                      if (registry
                          .at(PanelPlacementEnum.document)
                          .isNotEmpty) ...<Widget>[
                        const ShellModeBarWidget(),
                        Divider(height: 1, color: colors.border),
                      ],
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
                ShellRegionWidget(
                  placement: PanelPlacementEnum.aside,
                  registry: registry,
                  width: TomMetrics.git,
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
