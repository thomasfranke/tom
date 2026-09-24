/// The app's own panels, registered the way anyone else's would be.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The built-in panels.
///
/// **The whole point of this file is that it is not special** ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)):
/// the app's own panels go through the same [PanelDescriptor] a third party
/// would use, so the mechanism cannot rot from disuse.
///
/// It has been paid for six times already — the file tree, the status bar,
/// the preview, the editor, the changes column and now history each arrived
/// through this list, and none of them touched the shell.
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
      // Which modes a panel belongs to is the panel's own answer, which is
      // how the mode bar hides one without the shell knowing what it is.
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.source,
        DocumentModeEnum.split,
      ],
      builder: (BuildContext context) => const EditorPanel(),
    ),
    PanelDescriptor(
      id: 'tom.preview',
      title: 'Preview',
      placement: PanelPlacementEnum.document,
      order: 1,
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.split,
        DocumentModeEnum.preview,
      ],
      builder: (BuildContext context) => const PreviewPanel(),
    ),
    PanelDescriptor(
      id: 'tom.changes',
      title: 'Changes',
      placement: PanelPlacementEnum.aside,
      builder: (BuildContext context) => const ChangesPanel(),
    ),
    PanelDescriptor(
      id: 'tom.history',
      title: 'History',
      placement: PanelPlacementEnum.aside,
      order: 1,
      builder: (BuildContext context) => const HistoryPanel(),
    ),
    PanelDescriptor(
      id: 'tom.status',
      title: 'Status',
      placement: PanelPlacementEnum.statusBar,
      builder: (BuildContext context) => const StatusPanel(),
    ),
  ];
}
