/// The app's own panels, registered the way anyone else's would be.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_page_enum.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_menu_widget.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/changes/changes_tab_count_widget.dart';
import 'package:tom_desktop/screens/commands/commands_count_widget.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_overview_panel.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_desktop/screens/terminal/terminal_panel.dart';
import 'package:tom_desktop/screens/terminal/terminal_place_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_no_repository_panel.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The built-in panels.
///
/// Not special on purpose: the app's own panels go through the same
/// [PanelDescriptor] a third party would use, so the mechanism cannot rot
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
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
      title: (BuildContext context) => context.l10n.panelExplorer,
      placement: PanelPlacementEnum.explorer,
      builder: (BuildContext context) => const FileTreePanel(),
    ),
    PanelDescriptor(
      id: 'tom.editor',
      title: (BuildContext context) => context.l10n.modeSource,
      placement: PanelPlacementEnum.document,
      // Which modes a panel belongs to is the panel's own answer; the shell
      // only filters.
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.source,
        DocumentModeEnum.split,
      ],
      // Mounted, unseen, in preview: undo and redo stay live there, and the
      // history is the editor's (`editor/formatting-shortcuts/doc.md`).
      isKeptAlive: true,
      builder: (BuildContext context) => const EditorPanel(),
    ),
    PanelDescriptor(
      id: 'tom.preview',
      title: (BuildContext context) => context.l10n.modePreview,
      placement: PanelPlacementEnum.document,
      order: 1,
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.split,
        DocumentModeEnum.preview,
      ],
      builder: (BuildContext context) => const PreviewPanel(),
    ),
    // No `tom.search`: the results belong to the left column, under the box
    // that produced them, so the explorer panel draws them
    // (`docs/product/workspace/regions/doc.md`). The right column is git's.
    PanelDescriptor(
      id: 'tom.changes',
      // `Git`, not `Changes`: the list is the first thing the panel shows and
      // no longer the only thing it holds — the message, the commit and the
      // remote are in there too (`docs/product/workspace/regions/doc.md`).
      title: (BuildContext context) => context.l10n.panelGit,
      placement: PanelPlacementEnum.aside,
      pages: const <PanelPageEnum>[PanelPageEnum.workspace],
      builder: (BuildContext context) => const ChangesPanel(),
      actions: (BuildContext context) => const ChangesMenuWidget(),
      badge: (BuildContext context) => const ChangesTabCountWidget(),
    ),
    PanelDescriptor(
      id: 'tom.history',
      title: (BuildContext context) => context.l10n.panelHistory,
      placement: PanelPlacementEnum.aside,
      order: 1,
      pages: const <PanelPageEnum>[PanelPageEnum.workspace],
      builder: (BuildContext context) => const HistoryPanel(),
    ),
    // A folder with no repository: the column says so and nothing else, so
    // neither panel above is on that page
    // (`docs/product/workspace/without-a-repository/doc.md`).
    PanelDescriptor(
      id: 'tom.no_repository',
      title: (BuildContext context) => context.l10n.panelGit,
      placement: PanelPlacementEnum.aside,
      pages: const <PanelPageEnum>[PanelPageEnum.noRepository],
      builder: (BuildContext context) => const WorkspaceNoRepositoryPanel(),
    ),
    // The pull request's column replaces git's while its page is up: neither
    // panel `Git · History` offers is on that screen
    // (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
    PanelDescriptor(
      id: 'tom.pull_request',
      title: (BuildContext context) => context.l10n.panelPullRequest,
      placement: PanelPlacementEnum.aside,
      pages: const <PanelPageEnum>[PanelPageEnum.pullRequest],
      builder: (BuildContext context) => const PullRequestPanel(),
    ),
    PanelDescriptor(
      id: 'tom.pull_request.overview',
      title: (BuildContext context) => context.l10n.panelOverview,
      placement: PanelPlacementEnum.aside,
      order: 1,
      pages: const <PanelPageEnum>[PanelPageEnum.pullRequest],
      builder: (BuildContext context) => const PullRequestOverviewPanel(),
    ),
    // The panel under the document, read-only: what the app ran, as it ran
    // it (`docs/product/workspace/commands/doc.md`).
    PanelDescriptor(
      id: CommandsPanel.id,
      title: (BuildContext context) => context.l10n.panelCommands,
      placement: PanelPlacementEnum.bottom,
      builder: (BuildContext context) => const CommandsPanel(),
      summary: (BuildContext context) => const CommandsCountWidget(),
    ),
    // The person's own shell, beside what the app ran — and never written
    // into it (`docs/product/workspace/terminal/doc.md`).
    PanelDescriptor(
      id: TerminalPanel.id,
      title: (BuildContext context) => context.l10n.panelTerminal,
      placement: PanelPlacementEnum.bottom,
      order: 1,
      builder: (BuildContext context) => const TerminalPanel(),
      summary: (BuildContext context) => const TerminalPlaceWidget(),
    ),
    PanelDescriptor(
      id: 'tom.status',
      title: (BuildContext context) => context.l10n.panelStatus,
      placement: PanelPlacementEnum.statusBar,
      builder: (BuildContext context) => const StatusPanel(),
    ),
  ];
}
