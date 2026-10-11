/// The Commands panel over the foot of Home.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_head_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The Commands panel, at its 260, over Home's foot when the person opened
/// it or a command started waiting (`docs/product/workspace/commands/doc.md`).
///
/// Drawn over Home rather than inside its column, so Home does not move; with
/// no space open the panel is the only one, since a terminal needs a
/// repository. Closing it never cancels what waits.
class HomeCommandsWidget extends ConsumerWidget {
  /// Creates the overlay.
  const HomeCommandsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOpen = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingBottom),
    );
    // The registry is read only once the panel is wanted, so a Home that
    // never opens it needs none in scope.
    if (!isOpen) {
      return const SizedBox.shrink();
    }
    final PanelDescriptor? commands = ref
        .watch(panelRegistryProvider)
        .at(PanelPlacementEnum.bottom)
        .where((PanelDescriptor it) => it.id == CommandsNotifier.panel)
        .firstOrNull;
    if (commands == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TomMetrics.gutter,
        0,
        TomMetrics.gutter,
        TomMetrics.gutter,
      ),
      child: SizedBox(
        height: WorkspaceDesign.bottomHeight,
        child: TomColumnBoxWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              WorkspaceBottomHeadWidget(
                panels: <PanelDescriptor>[commands],
                chosen: commands,
              ),
              Expanded(child: Builder(builder: commands.builder)),
            ],
          ),
        ),
      ),
    );
  }
}
