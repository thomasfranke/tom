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
/// A fixed [width] for the columns that must not move between screens, and
/// null for the document area, which takes what is left.
class ShellRegionWidget extends ConsumerWidget {
  /// Creates the region for [placement], reading [registry].
  const ShellRegionWidget({
    required this.placement,
    required this.registry,
    this.width,
    this.mode,
    super.key,
  });

  /// Which region this is.
  final PanelPlacementEnum placement;

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  /// Its fixed width, or null to take what is left.
  final double? width;

  /// Which document mode to draw, or null for a region the bar does not
  /// govern; passed through to the registry, never read here.
  final DocumentModeEnum? mode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PanelPlacementEnum>('placement', placement))
      ..add(DiagnosticsProperty<PanelRegistry>('registry', registry))
      ..add(DoubleProperty('width', width))
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
    // The divider belongs to the fixed column, on the side facing the
    // document area, so the column's width stays the wireframe's.
    final Widget bordered = switch (placement) {
      PanelPlacementEnum.explorer => Row(
        children: <Widget>[
          Expanded(child: content),
          VerticalDivider(width: 1, color: colors.border),
        ],
      ),
      PanelPlacementEnum.aside => Row(
        children: <Widget>[
          VerticalDivider(width: 1, color: colors.border),
          Expanded(child: content),
        ],
      ),
      PanelPlacementEnum.document || PanelPlacementEnum.statusBar => content,
    };
    final double? total = width;
    return total == null
        ? bordered
        : SizedBox(width: total + 1, child: bordered);
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      // One panel needs no switch: a control with a single choice says
      // nothing the panel does not already say.
      if (panels.length > 1)
        WorkspaceAsideSwitchWidget(panels: panels, chosen: chosen),
      Expanded(child: Builder(builder: chosen.builder)),
    ],
  );
}
