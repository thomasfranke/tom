/// The app's own panels, registered the way anyone else's would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_ui/tom_ui.dart';

/// The built-in panels.
///
/// **The whole point of this file is that it is not special** ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)):
/// the app's own panels go through the same [PanelDescriptor] a third party
/// would use, so the mechanism cannot rot from disuse.
///
/// It has been paid for twice already — the file tree and the status bar
/// replaced their placeholders and neither touched the shell. The editor and
/// the preview go the same way.
class CoreModuleImpl implements TomModule {
  /// Creates the module.
  const CoreModuleImpl();

  @override
  String get id => 'tom.core';

  @override
  List<Override> get overrides => const <Override>[];

  @override
  List<PanelDescriptor> get panels => <PanelDescriptor>[
    PanelDescriptor(
      id: 'tom.explorer',
      title: 'Explorer',
      placement: PanelPlacementEnum.explorer,
      builder: (BuildContext context) => const FileTreePanel(),
    ),
    PanelDescriptor(
      id: 'tom.editor',
      title: 'Source',
      placement: PanelPlacementEnum.document,
      builder: (BuildContext context) => const _Placeholder(
        label: 'SOURCE',
        detail: 're_editor — M0 (Decision 18)',
      ),
    ),
    PanelDescriptor(
      id: 'tom.preview',
      title: 'Preview',
      placement: PanelPlacementEnum.document,
      order: 1,
      builder: (BuildContext context) => const PreviewPanel(),
    ),
    PanelDescriptor(
      id: 'tom.status',
      title: 'Status',
      placement: PanelPlacementEnum.statusBar,
      builder: (BuildContext context) => const StatusPanel(),
    ),
  ];
}

/// A panel that says what will be here, and nothing else.
///
/// Not a widget anyone should grow: each of these is replaced whole by the
/// panel it stands for.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(StringProperty('detail', detail));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(TomMetrics.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(detail, style: TextStyle(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
