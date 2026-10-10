/// The panel layout.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_page_enum.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/screens/editor/editor_disk_band_widget.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/editor/editor_tabs_widget.dart';
import 'package:tom_desktop/screens/export/export_band_widget.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_status_row_widget.dart';
import 'package:tom_desktop/screens/remote/remote_band_widget.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_focus.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_region_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_status_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_top_bar_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_grip_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_desktop/screens/workspace/workspace_grip_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The window: explorer, document area, aside and status bar, all at once
/// and never taken over (`docs/product/workspace/regions/doc.md`).
///
/// Names no panel: it asks [PanelRegistry] what belongs in each region and
/// builds what it is told.
class TomShell extends ConsumerStatefulWidget {
  /// Creates the shell.
  const TomShell({super.key});

  @override
  ConsumerState<TomShell> createState() => _TomShellState();
}

class _TomShellState extends ConsumerState<TomShell> {
  /// Where the source pane leaves the way to `re_editor`'s own undo.
  ///
  /// Here because the two ends are in different regions: the pane is in the
  /// document area and the buttons are in the row above it, so the nearest
  /// thing that holds both is the shell ([EditorHistory]).
  final EditorHistory _history = EditorHistory();

  /// The search box's focus, so ⌘K reaches a field in another region.
  final FocusNode _search = FocusNode(debugLabel: 'search');

  /// The replace box's, so ⌥⌘F can put the keyboard there.
  final FocusNode _replace = FocusNode(debugLabel: 'replace');

  /// Holds the search alive while ⌥⌘F waits for its index to be ready.
  ProviderSubscription<SearchState>? _waiting;

  @override
  void dispose() {
    _waiting?.close();
    _history.dispose();
    _search.dispose();
    _replace.dispose();
    super.dispose();
  }

  /// ⌥⌘F (Ctrl+H off macOS): shows the replace box, or puts it away.
  ///
  /// A shut explorer opens first, as for ⌘K. The search lives and dies with
  /// that column, so a fresh one is still indexing — the press is held until
  /// it is ready rather than lost (`docs/product/search/replacing/doc.md`).
  void _toggleReplace() {
    if (!ref.read(workspaceProvider).showingExplorer) {
      ref.read(workspaceProvider.notifier).toggleExplorer();
    }
    _waiting?.close();
    final ProviderSubscription<SearchState> waiting = ref
        .listenManual<SearchState>(
          searchProvider,
          (_, SearchState next) => _searchMoved(next),
        );
    switch (waiting.read()) {
      case final SearchReady ready:
        _flipReplace(ready);
        _letGo(waiting);
      case SearchIndexing():
        _waiting = waiting;
      case SearchIdle() || SearchFailed():
        waiting.close();
    }
  }

  /// The held press, answered once the search it waited for is ready and
  /// dropped if that search fails or the space closes.
  void _searchMoved(SearchState next) {
    final ProviderSubscription<SearchState>? waiting = _waiting;
    if (waiting == null || next is SearchIndexing) {
      return;
    }
    _waiting = null;
    if (next is SearchReady) {
      _flipReplace(next);
    }
    _letGo(waiting);
  }

  /// Lets go of [waiting] after the frame: a column opened just now has not
  /// started listening yet, and the search must not be dropped meanwhile.
  void _letGo(ProviderSubscription<SearchState> waiting) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => waiting.close());

  /// Opens the replace box over [ready], or closes it, and moves the keyboard.
  ///
  /// Opening focuses the replace box once there is something to replace,
  /// and the search box while it is empty — the words come first. Closing
  /// hands the keyboard back to the search box only if it was in the one
  /// going away.
  void _flipReplace(SearchReady ready) {
    final bool showing = SearchBoxes.isReplacing(ready);
    final bool wasReplacing = _replace.hasFocus;
    ref.read(searchProvider.notifier).showReplacing(showing: !showing);
    final FocusNode? next = showing
        ? (wasReplacing ? _search : null)
        : (ready.terms.trim().isEmpty ? _search : _replace);
    if (next != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          next.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PanelRegistry registry = ref.watch(panelRegistryProvider);
    // The app's one reader of git, made to exist here and not by the git
    // column, which is built only while it shows. `keepAlive` keeps it once
    // it exists; the diff's base follows that reading, and nothing else
    // would make it exist either.
    ref
      ..watch(gitReadingProvider)
      ..watch(diffBaseProvider);
    final bool readingVersion = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion != null,
      ),
    );
    // Drawn rather than chosen: the preferences file is source only.
    final DocumentModeEnum chosen =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.drawnMode,
          ),
        ) ??
        DocumentModeEnum.split;
    // A version being read draws as preview, since nothing types into the
    // past; the choice itself is untouched so coming back comes back to it
    // (`docs/product/git-workflow/file-history/doc.md`).
    final DocumentModeEnum mode = readingVersion
        ? DocumentModeEnum.preview
        : chosen;
    // A hidden column is a column, not a mode: the document area takes the
    // room and nothing else moves (`docs/product/workspace/columns/doc.md`).
    final bool showingExplorer = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingExplorer),
    );
    final bool showingAside = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingAside),
    );
    final double explorerWidth =
        ref.watch(
          workspaceProvider.select((WorkspaceState it) => it.explorerWidth),
        ) ??
        TomMetrics.explorer;
    final double asideWidth =
        ref.watch(
          workspaceProvider.select((WorkspaceState it) => it.asideWidth),
        ) ??
        TomMetrics.git;
    // A column nobody registered a panel into takes no room: a fixed column
    // drawn empty reads as a bug in the layout, and its container would
    // frame nothing.
    final bool hasDocument = registry
        .at(PanelPlacementEnum.document)
        .isNotEmpty;
    final bool hasTabs = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) =>
            (session?.tabs.isNotEmpty ?? false) ||
            session?.preferencesFile != null,
      ),
    );
    // The pull request is a page of its own: the status row takes the tabs'
    // place and the right column is the branch's (Decision 33). A folder
    // with no repository is another, whose column only says so.
    final PanelPageEnum page = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => switch (session) {
          SpaceSessionState(pullRequest: _?) => PanelPageEnum.pullRequest,
          SpaceSessionState(space: SpaceEntity(hasRepository: false)) =>
            PanelPageEnum.noRepository,
          _ => PanelPageEnum.workspace,
        },
      ),
    );
    final bool proposing = page == PanelPageEnum.pullRequest;
    final bool openExplorer =
        showingExplorer && registry.at(PanelPlacementEnum.explorer).isNotEmpty;
    final bool openAside =
        showingAside && registry.at(PanelPlacementEnum.aside).isNotEmpty;
    final double? bottomHeight = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.bottomHeight),
    );
    final bool openBottom =
        ref.watch(
          workspaceProvider.select((WorkspaceState it) => it.showingBottom),
        ) &&
        registry.at(PanelPlacementEnum.bottom).isNotEmpty;
    final TomColors colors = TomColors.of(context);
    // The columns are islands on the window, between the two bars and a
    // gutter in from either side; each gutter is grabbable, and nothing is
    // drawn in it (`docs/design/visual-language/rationale.md`).
    // ⌘W closes the tab on screen, and asks first when it holds edits — the
    // keyboard's way to close the one tab the strip draws no close for.
    void closeTab() {
      // On the pull request it closes the page, which has no tab of its own.
      if (ref.read(spaceSessionProvider)?.pullRequest != null) {
        ref.read(pullRequestProvider.notifier).leave();
        return;
      }
      final SpaceSessionState? session = ref.read(spaceSessionProvider);
      final DocumentTab? open = (session?.isShowingPreferencesFile ?? false)
          ? session!.preferencesTab
          : session?.onScreen;
      if (open != null) {
        unawaited(EditorTabsWidget.close(context, ref, open));
      }
    }

    // ⌘K puts the keyboard in the search box, opening the explorer first when
    // it is shut, because the box lives there.
    void search() {
      if (!ref.read(workspaceProvider).showingExplorer) {
        ref.read(workspaceProvider.notifier).toggleExplorer();
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _search.requestFocus(),
      );
    }

    // The island holds the row above the document as well as the panes: the
    // boards draw it as one container.
    final Widget document = TomColumnBoxWidget(
      child: Column(
        children: <Widget>[
          // The bar belongs to the document area: the explorer and the aside
          // are not in a mode. The tabs are the first row: the tools below
          // act on the one chosen (`editor/tabs/doc.md`).
          if (hasDocument && proposing)
            const PullRequestStatusRowWidget()
          else if (hasDocument && hasTabs)
            const EditorTabsWidget(),
          if (hasDocument) ...<Widget>[
            ShellModeBarWidget(
              leftInset: openExplorer ? explorerWidth : 0,
              rightInset: openAside ? asideWidth : 0,
            ),
            Divider(height: 1, color: colors.border),
          ],
          // News from git spans the document area and pushes the document
          // down, rather than living in a column
          // (`docs/product/workspace/feedback/doc.md`).
          const RemoteBandWidget(),
          const ExportBandWidget(),
          const EditorDiskBandWidget(),
          Expanded(
            child: ShellRegionWidget(
              placement: PanelPlacementEnum.document,
              registry: registry,
              mode: mode,
            ),
          ),
        ],
      ),
    );

    // ⌘J opens the panel under the document and closes it again — the
    // keyboard's way to the toggle between the two column toggles.
    void toggleBottom() => ref.read(workspaceProvider.notifier).toggleBottom();

    return _ShortcutsWidget(
      history: _history,
      // As the buttons: not over a version being read, which is not the
      // buffer the history walks.
      isHearingHistory: !readingVersion && chosen == DocumentModeEnum.preview,
      search: _search,
      replace: _replace,
      toggleReplace: _toggleReplace,
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyW, meta: true): closeTab,
        const SingleActivator(LogicalKeyboardKey.keyW, control: true): closeTab,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): search,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): search,
        if (defaultTargetPlatform == TargetPlatform.macOS)
          const SingleActivator(LogicalKeyboardKey.keyJ, meta: true):
              toggleBottom
        else
          const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
              toggleBottom,
        // VS Code's keys, one per platform: Ctrl+H on macOS is a text field's
        // delete-backward, and taking it would break typing.
        if (defaultTargetPlatform == TargetPlatform.macOS)
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true, alt: true):
              _toggleReplace
        else
          const SingleActivator(LogicalKeyboardKey.keyH, control: true):
              _toggleReplace,
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: TomMetrics.topBar,
              bottom: TomMetrics.statusBar,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A closed column leaves its gutter behind, which is where
                  // the way to open it again lives.
                  if (openExplorer) ...<Widget>[
                    const SizedBox(width: TomMetrics.gutter),
                    SizedBox(
                      width: explorerWidth,
                      child: TomColumnBoxWidget(
                        child: ShellRegionWidget(
                          placement: PanelPlacementEnum.explorer,
                          registry: registry,
                        ),
                      ),
                    ),
                  ],
                  WorkspaceGripWidget(width: explorerWidth),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints room) {
                        // The panel is dragged from the gutter above it, and
                        // never so high that the document loses its room.
                        final double highest =
                            room.maxHeight -
                            TomMetrics.gutter -
                            WorkspaceDesign.documentLeast;
                        final double raised =
                            bottomHeight ?? WorkspaceDesign.bottomHeight;
                        final double height = raised > highest
                            ? highest.clamp(
                                WorkspaceNotifier.bottomLowest,
                                raised,
                              )
                            : raised;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(child: document),
                            // Under the document column only, a gutter below
                            // it: the columns keep their full height
                            // (`docs/product/workspace/commands/doc.md`).
                            if (openBottom) ...<Widget>[
                              WorkspaceBottomGripWidget(
                                height: height,
                                highest: highest,
                              ),
                              SizedBox(
                                height: height,
                                child: TomColumnBoxWidget(
                                  child: ShellRegionWidget(
                                    placement: PanelPlacementEnum.bottom,
                                    registry: registry,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  WorkspaceGripWidget(
                    width: asideWidth,
                    edge: TomColumnEdgeEnum.right,
                  ),
                  if (openAside) ...<Widget>[
                    SizedBox(
                      width: asideWidth,
                      child: TomColumnBoxWidget(
                        child: ShellRegionWidget(
                          placement: PanelPlacementEnum.aside,
                          registry: registry,
                          page: page,
                        ),
                      ),
                    ),
                    const SizedBox(width: TomMetrics.gutter),
                  ],
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ShellTopBarWidget(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ShellStatusBarWidget(registry: registry),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the shell puts around the window: the editor's history, the search
/// boxes' focus, and the keyboard shortcuts that reach them.
class _ShortcutsWidget extends StatelessWidget {
  const _ShortcutsWidget({
    required this.history,
    required this.search,
    required this.replace,
    required this.toggleReplace,
    required this.bindings,
    required this.isHearingHistory,
    required this.child,
  });

  /// Whether ⌘Z reaches the history from here: only in preview, where the
  /// source pane is off screen and cannot answer it itself.
  final bool isHearingHistory;
  final EditorHistory history;
  final FocusNode search;
  final FocusNode replace;
  final VoidCallback toggleReplace;
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EditorHistory>('history', history))
      ..add(DiagnosticsProperty<bool>('isHearingHistory', isHearingHistory))
      ..add(DiagnosticsProperty<FocusNode>('search', search))
      ..add(DiagnosticsProperty<FocusNode>('replace', replace))
      ..add(
        ObjectFlagProperty<VoidCallback>.has('toggleReplace', toggleReplace),
      )
      ..add(
        DiagnosticsProperty<Map<ShortcutActivator, VoidCallback>>(
          'bindings',
          bindings,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => EditorHistoryScope(
    history: history,
    child: SearchFocusScope(
      node: search,
      replace: replace,
      toggleReplace: toggleReplace,
      // The shortcuts only hear keys from focus inside them. A scope, not a
      // node: a field that loses the keyboard to a click elsewhere hands it
      // to its nearest scope, and the route's is outside — deaf to them all.
      child: EditorHistoryKeys(
        isActive: isHearingHistory,
        child: CallbackShortcuts(
          bindings: bindings,
          child: FocusScope(autofocus: true, child: child),
        ),
      ),
    ),
  );
}
