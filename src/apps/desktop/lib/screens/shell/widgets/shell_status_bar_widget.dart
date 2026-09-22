/// The strip below everything: branch, ahead/behind, counts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// The strip below everything: branch, ahead/behind, counts.
///
/// It draws none of those itself — whatever is registered into
/// [PanelPlacementEnum.statusBar] is what appears, the built-in status line
/// included.
class ShellStatusBarWidget extends StatelessWidget {
  /// Creates the status bar, reading [registry].
  const ShellStatusBarWidget({required this.registry, super.key});

  /// Where to ask what belongs in it.
  final PanelRegistry registry;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PanelRegistry>('registry', registry));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: TomMetrics.statusBar,
      child: ColoredBox(
        color: colors.surfaceSunken,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TomMetrics.pad + TomMetrics.chromeInset,
          ),
          child: Row(
            children: <Widget>[
              for (final PanelDescriptor panel in registry.at(
                PanelPlacementEnum.statusBar,
              ))
                Builder(builder: panel.builder),
            ],
          ),
        ),
      ),
    );
  }
}
