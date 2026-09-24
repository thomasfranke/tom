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

/// The window: explorer, document area, aside and status bar, all at once.
///
/// **There is no full-screen takeover.** The explorer does not disappear
/// while editing and the status bar does not hide while reading
/// (`docs/product/workspace/doc.md`). A new panel is added to this layout,
/// never bolted on as a separate window or a new top-level mode.
///
/// This widget names no panel. It asks [PanelRegistry] what belongs in each
/// region and builds what it is told, which is the same answer it gives for
/// a third party's panel and for the app's own.
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
    // A version being read draws as preview whatever the bar last said —
    // **nothing types into the past**. The choice itself is untouched, so
    // coming back to now comes back to the mode that was being worked in
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
                      // The bar belongs to the document area and stops
                      // where it stops: the explorer and the git panel are
                      // not in a mode.
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
