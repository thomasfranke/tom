/// The app's own panels, registered the way anyone else's would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// The built-in panels.
///
/// **The whole point of this file is that it is not special**
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)):
/// the explorer, the editor, the diff and the git panel are registered by a
/// module, not wired into the shell, and they go through the same
/// [PanelDescriptor] a third party would use. One path for everything, so
/// the mechanism cannot rot from disuse — it is exercised on every run.
///
/// What is here now is placeholders. They are registered rather than drawn
/// in the shell precisely so that replacing them with the real file tree and
/// the real editor is a change to *this* list and to nothing else.
class CoreModule implements TomModule {
  /// Creates the module.
  const CoreModule();

  @override
  String get id => 'tom.core';

  @override
  List<Override> get overrides => const <Override>[];

  @override
  List<PanelDescriptor> get panels => <PanelDescriptor>[
    PanelDescriptor(
      id: 'tom.explorer',
      title: 'Explorer',
      placement: PanelPlacement.explorer,
      builder: (BuildContext context) =>
          const _Placeholder(label: 'EXPLORER', detail: 'File tree — M0'),
    ),
    PanelDescriptor(
      id: 'tom.editor',
      title: 'Source',
      placement: PanelPlacement.document,
      builder: (BuildContext context) => const _Placeholder(
        label: 'SOURCE',
        detail: 're_editor — M0 (Decision 18)',
      ),
    ),
    PanelDescriptor(
      id: 'tom.preview',
      title: 'Preview',
      placement: PanelPlacement.document,
      order: 1,
      builder: (BuildContext context) => const _Placeholder(
        label: 'PREVIEW',
        detail: 'Blocks from the markdown package — M0 (Decision 19)',
      ),
    ),
    PanelDescriptor(
      id: 'tom.status',
      title: 'Status',
      placement: PanelPlacement.statusBar,
      builder: (BuildContext context) => const _StatusPlaceholder(),
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

/// The status bar's placeholder.
class _StatusPlaceholder extends StatelessWidget {
  const _StatusPlaceholder();

  @override
  Widget build(BuildContext context) => Text(
    'no space open',
    style: TextStyle(color: TomColors.of(context).textMuted, fontSize: 12),
  );
}
