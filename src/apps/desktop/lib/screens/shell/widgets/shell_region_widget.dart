/// One region of the shell, holding whatever was registered into it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/workspace/workspace_aside_switch_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One region of the shell, holding whatever was registered into it.
///
/// It draws the panels and nothing around them: the width of a fixed column
/// and the container it sits on are the shell's, because the document's
/// container holds the row above the document too.
class ShellRegionWidget extends ConsumerWidget {
  /// Creates the region for [placement], reading [registry].
  const ShellRegionWidget({
    required this.placement,
    required this.registry,
    this.mode,
    super.key,
  });

  /// Which region this is.
  final PanelPlacementEnum placement;

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  /// Which document mode to draw, or null for a region the bar does not
  /// govern; passed through to the registry, never read here.
  final DocumentModeEnum? mode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PanelPlacementEnum>('placement', placement))
      ..add(DiagnosticsProperty<PanelRegistry>('registry', registry))
      ..add(EnumProperty<DocumentModeEnum?>('mode', mode));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PanelDescriptor> panels = registry.at(placement, mode: mode);
    if (panels.isEmpty) {
      // Nothing registered takes no space: an empty fixed column reads as a
      // bug in the layout.
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    final List<Widget> children = <Widget>[
      for (int i = 0; i < panels.length; i++) ...<Widget>[
        if (i > 0) VerticalDivider(width: 1, color: colors.border),
        Expanded(child: Builder(builder: panels[i].builder)),
      ],
    ];
    // The aside shows one panel at a time and the document area splits:
    // stacking does not survive a third panel, since a share of the height
    // is not always enough panel to read
    // (`docs/product/workspace/columns/doc.md`).
    final Widget content = placement == PanelPlacementEnum.aside
        ? _SwitchedWidget(panels: panels, chosen: _chosenOf(panels, ref))
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
    // The container is the shell's, not a region's: the document column's
    // runs from under the top bar to under the status bar and the row above
    // the document is **inside** it, which a box drawn here could not reach
    // (`docs/design/screens/measurements.md`).
    return content;
  }
}

/// Which panel the column is showing.
///
/// The one the reader chose, or the first: a saved choice outlives the panel
/// it named only until a module stops registering it, and falling back keeps
/// the column from going blank.
PanelDescriptor _chosenOf(List<PanelDescriptor> panels, WidgetRef ref) {
  final String? id = ref.watch(
    workspaceProvider.select((WorkspaceState it) => it.asidePanel),
  );
  return panels.firstWhere(
    (PanelDescriptor it) => it.id == id,
    orElse: () => panels.first,
  );
}

/// One panel at a time, with the switch that chooses it above.
class _SwitchedWidget extends StatelessWidget {
  const _SwitchedWidget({required this.panels, required this.chosen});

  final List<PanelDescriptor> panels;
  final PanelDescriptor chosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('panels', panels))
      ..add(DiagnosticsProperty<PanelDescriptor>('chosen', chosen));
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // One panel needs no switch: a control with a single choice says
          // nothing the panel does not already say.
          if (panels.length > 1)
            WorkspaceAsideSwitchWidget(panels: panels, chosen: chosen),
          Expanded(child: Builder(builder: chosen.builder)),
        ],
      ),
      // **Over** the column rather than above it: the boards draw the bar
      // across the column's own top edge, and a row reserved for it would
      // push everything under it down by three whether or not a request is
      // out (`docs/product/git-workflow/push-pull/while-a-request-runs/doc.md`).
      const Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: _RemoteProgressWidget(),
      ),
    ],
  );
}

/// The bar, while git is talking to a remote.
///
/// Watched here rather than inside a panel because **committing is not
/// touched**: staging and committing reach no remote, and the bar is what
/// teaches that it is about the network and not about the app being busy.
class _RemoteProgressWidget extends ConsumerWidget {
  const _RemoteProgressWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool working = ref.watch(
      remoteProvider.select((RemoteState state) => state.isBusy),
    );
    return working ? const TomProgressBarWidget() : const SizedBox.shrink();
  }
}
