/// One region of the shell, holding whatever was registered into it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_ui/tom_ui.dart';

/// One region of the shell, holding whatever was registered into it.
///
/// A fixed [width] for the columns that must not move between screens, and
/// null for the document area, which takes what is left.
class ShellRegionWidget extends StatelessWidget {
  /// Creates the region for [placement], reading [registry].
  const ShellRegionWidget({
    required this.placement,
    required this.registry,
    this.width,
    super.key,
  });

  /// Which region this is.
  final PanelPlacementEnum placement;

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  /// Its fixed width, or null to take what is left.
  final double? width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PanelPlacementEnum>('placement', placement))
      ..add(DiagnosticsProperty<PanelRegistry>('registry', registry))
      ..add(DoubleProperty('width', width));
  }

  @override
  Widget build(BuildContext context) {
    final List<PanelDescriptor> panels = registry.at(placement);
    if (panels.isEmpty) {
      // Nothing registered: the region takes no space at all rather than
      // reserving an empty column. A fixed-width gap nobody put anything in
      // reads as a bug in the layout.
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < panels.length; i++) ...<Widget>[
          if (i > 0) VerticalDivider(width: 1, color: colors.border),
          Expanded(child: Builder(builder: panels[i].builder)),
        ],
      ],
    );
    // The divider belongs to the fixed column, on the side facing the
    // document area — so the explorer's own width stays exactly what the
    // wireframe says and the rule sits beside it.
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
