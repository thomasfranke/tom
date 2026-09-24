/// One region of the shell, holding whatever was registered into it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_presentation/tom_presentation.dart';
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
  /// govern.
  ///
  /// Passed through to the registry rather than read here: what a mode
  /// includes is the descriptor's answer, and a region that read it would
  /// be a region that knows what a panel is for.
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
  Widget build(BuildContext context) {
    final List<PanelDescriptor> panels = registry.at(placement, mode: mode);
    if (panels.isEmpty) {
      // Nothing registered: the region takes no space at all rather than
      // reserving an empty column. A fixed-width gap nobody put anything in
      // reads as a bug in the layout.
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    // **A fixed column stacks; the document area splits.** Source beside
    // preview is the point of split mode, and two 140-point columns in the
    // aside would be two lists nobody can read — so which way a region
    // divides follows from how wide it is, not from what is in it.
    final bool stacks = placement == PanelPlacementEnum.aside;
    final List<Widget> children = <Widget>[
      for (int i = 0; i < panels.length; i++) ...<Widget>[
        if (i > 0) VerticalDivider(width: 1, color: colors.border),
        Expanded(child: Builder(builder: panels[i].builder)),
      ],
    ];
    final Widget content = stacks
        ? _StackedWidget(panels: panels, colour: colors.border)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
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

/// Panels one under another, scrolling rather than squeezing.
///
/// A fixed column divides the height it has between whatever was registered
/// into it — but **a share is not always a panel**. The changes column alone
/// carries some two hundred points of caption, message box and button before
/// its list starts, so a third panel in a short window would push all of it
/// off the bottom.
///
/// So each gets its share or [TomMetrics.minimumStackedPanel], whichever is
/// larger, and the column scrolls when the sum no longer fits. Scrolling is
/// the one answer that costs nothing when it is not needed: with two panels
/// in a normal window the geometry is exactly what it was.
class _StackedWidget extends StatelessWidget {
  const _StackedWidget({required this.panels, required this.colour});

  final List<PanelDescriptor> panels;
  final Color colour;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('panels', panels))
      ..add(ColorProperty('colour', colour));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      // The dividers come out of the height before it is divided, or the
      // last panel is short by one point per rule above it.
      final double rules = panels.length - 1;
      final double share = (constraints.maxHeight - rules) / panels.length;
      final double each = share > TomMetrics.minimumStackedPanel
          ? share
          : TomMetrics.minimumStackedPanel;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < panels.length; i++) ...<Widget>[
              if (i > 0) Divider(height: 1, color: colour),
              SizedBox(
                height: each,
                child: Builder(builder: panels[i].builder),
              ),
            ],
          ],
        ),
      );
    },
  );
}
