/// The panel layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_region_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_status_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_top_bar_widget.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

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
                  child: ShellRegionWidget(
                    placement: PanelPlacementEnum.document,
                    registry: registry,
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
