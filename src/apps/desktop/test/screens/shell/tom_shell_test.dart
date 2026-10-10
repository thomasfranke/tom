import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/core_module_impl.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_desktop/screens/shell/tom_shell.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_grip_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_desktop/screens/workspace/workspace_grip_widget.dart';
import 'package:tom_desktop/widgets/file_state_mark_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// No pull request on offer: the row it would draw has tests of its own.
final class _NoPullRequest extends PullRequestNotifier {
  @override
  PullRequestState build() => const PullRequestState();
}

/// No account read: the button has tests of its own, and reading one runs
/// `gh`, git and `ssh`.
final class _NoAccount extends AccountNotifier {
  @override
  AccountState build() => const AccountState();
}

/// No base read: the shell only makes it exist, and what it reads has tests
/// of its own (`diff_base_notifier_test`).
final class _NoBase extends DiffBaseNotifier {
  @override
  void build() {}
}

void main() {
  /// What the registry is built from, read when the shell first asks — a
  /// variable because the container is made once per test ([pumpShell]).
  List<TomModule> registered = const <TomModule>[CoreModuleImpl()];
  late _Preferences preferences;
  late ProviderContainer container;
  late _Changed git;
  late _Listed listing;

  setUp(() {
    registered = const <TomModule>[CoreModuleImpl()];
    git = _Changed();
    listing = _Listed();
    // One container per test, not per mount: a second container left alive
    // is still scheduling its disposal, a timer the test framework fails on.
    preferences = _Preferences();
    container = ProviderContainer(
      overrides: <Override>[
        pullRequestProvider.overrideWith(_NoPullRequest.new),
        accountProvider.overrideWith(_NoAccount.new),
        diffBaseProvider.overrideWith(_NoBase.new),
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: preferences,
            observability: const _Silent(),
          ),
        ),
        panelRegistryProvider.overrideWith(
          (Ref ref) => PanelRegistry(registered),
        ),
        listSpaceEntriesProvider.overrideWithValue(
          ListSpaceEntriesUseCase(
            spaces: listing,
            observability: const _Silent(),
          ),
        ),
        // The breadcrumb in the top bar is the menu of recent spaces, so the
        // shell reads that list as soon as it is on screen
        // (`test/screens/spaces/` has the menu itself).
        listRecentSpacesProvider.overrideWithValue(
          const ListRecentSpacesUseCase(
            recents: _NoRecents(),
            observability: _Silent(),
          ),
        ),
        // The shell reads git once a space is open; a clean tree keeps these
        // tests about the chrome, unless one says otherwise
        // (`test/screens/changes/changes_panel_test.dart` has the panel).
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: const _Silent(),
          ),
        ),
        readMergeStateProvider.overrideWithValue(
          ReadMergeStateUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: const _Silent(),
          ),
        ),
        // The aside's search panel reads the space into its index as soon as
        // one is open (`test/screens/search/` has the panel itself).
        indexSpaceProvider.overrideWithValue(
          const IndexSpaceUseCase(
            spaces: _NothingInIt(),
            searchFor: _emptyIndex,
            observability: _Silent(),
          ),
        ),
        indexDocumentProvider.overrideWithValue(
          const IndexDocumentUseCase(
            searchFor: _emptyIndex,
            observability: _Silent(),
          ),
        ),
        searchSpaceProvider.overrideWithValue(
          const SearchSpaceUseCase(
            searchFor: _emptyIndex,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the shell with [modules] registered, in a window of [size], with
  /// [space] open when one is given.
  ///
  /// [modules] is read when the registry is first built, so a second pump in
  /// the same test is the same shell in another theme, never other panels.
  Future<void> pumpShell(
    WidgetTester tester, {
    List<TomModule> modules = const <TomModule>[CoreModuleImpl()],
    Size size = const Size(1280, 800),
    Brightness brightness = Brightness.light,
    SpaceEntity? space,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    registered = modules;
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: tomTheme(brightness), home: const TomShell()),
      ),
    );
    // `MaterialApp` animates a theme change, so a single frame reads a
    // colour halfway between the two modes.
    await tester.pumpAndSettle();
  }

  PanelDescriptor panelSaying(
    String text, {
    required PanelPlacementEnum placement,
    int order = 0,
  }) => PanelDescriptor(
    id: 'test.$text',
    title: (BuildContext context) => text,
    placement: placement,
    order: order,
    builder: (BuildContext context) => Text(text),
  );

  group('the built-in panels go through the registry', () {
    testWidgets('the core module puts a panel in every region it claims', (
      WidgetTester tester,
    ) async {
      // Decision 12: the app's own panels are registered, not wired in.
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
      expect(find.byType(PreviewPanel), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('the shell draws no panel of its own', (
      WidgetTester tester,
    ) async {
      // Anything on screen beyond the chrome is a panel the shell hardcoded.
      await pumpShell(tester, modules: const <TomModule>[]);

      expect(find.text('EXPLORER'), findsNothing);
      expect(find.byType(EditorPanel), findsNothing);
      expect(find.text('no space open'), findsNothing);
    });
  });

  /// Drags the rule beside the left column by [dx].
  ///
  /// A gesture by hand rather than `tester.drag`, which compensates for the
  /// touch slop on behalf of a widget that starts on recognition; the grip
  /// starts on the pointer going down, and the compensation would land it
  /// twenty points short.
  Future<void> dragGrip(WidgetTester tester, double dx) async {
    // The first of the two: the right column has a gutter of its own, and
    // only the left one is the reader's to drag.
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(WorkspaceGripWidget).first),
    );
    await gesture.moveBy(Offset(dx, 0));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  group('the left column is the reader’s width', () {
    testWidgets('it opens at the width the tree reads well at', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      expect(
        tester.getSize(find.byType(FileTreePanel)).width,
        TomMetrics.explorer,
      );
    });

    testWidgets('dragging the rule beside it widens it', (
      WidgetTester tester,
    ) async {
      // Somebody reading search results widens it
      // (`docs/product/workspace/regions/doc.md`).
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      await dragGrip(tester, 60);

      expect(
        tester.getSize(find.byType(FileTreePanel)).width,
        TomMetrics.explorer + 60,
      );
    });

    testWidgets('and it cannot be dragged narrower than it can be read', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      await dragGrip(tester, -400);

      expect(
        tester.getSize(find.byType(FileTreePanel)).width,
        WorkspaceNotifier.narrowest,
      );
    });
  });

  group('the panel under the document', () {
    // `docs/product/workspace/commands/doc.md`.
    const TargetPlatformVariant platforms = TargetPlatformVariant(
      <TargetPlatform>{TargetPlatform.macOS, TargetPlatform.linux},
    );

    Future<void> pressJ(WidgetTester tester) async {
      final LogicalKeyboardKey held =
          defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(held);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyUpEvent(held);
      await tester.pumpAndSettle();
    }

    Finder islandOf(Type panel) => find
        .ancestor(
          of: find.byType(panel),
          matching: find.byType(TomColumnBoxWidget),
        )
        .first;

    /// Drags the gutter above the panel by [dy], by hand for the reason
    /// [dragGrip] gives.
    Future<void> dragBottom(WidgetTester tester, double dy) async {
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(WorkspaceBottomGripWidget)),
      );
      await gesture.moveBy(Offset(0, dy));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('dragging the gutter above it raises it, the document giving '
        'way', (WidgetTester tester) async {
      await pumpShell(tester, size: const Size(1440, 900));
      container.read(workspaceProvider.notifier).toggleBottom();
      await tester.pumpAndSettle();

      await dragBottom(tester, -100);

      final Rect panel = tester.getRect(islandOf(CommandsPanel));
      final Rect document = tester.getRect(islandOf(EditorPanel));
      expect(panel.height, 360);
      expect(panel.top - document.bottom, TomMetrics.gutter);
      expect(panel.bottom, 900 - TomMetrics.statusBar);
    });

    testWidgets('and never so high that the document loses its room', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, size: const Size(1440, 900));
      container.read(workspaceProvider.notifier).toggleBottom();
      await tester.pumpAndSettle();

      await dragBottom(tester, -2000);

      expect(
        tester.getRect(islandOf(EditorPanel)).height,
        WorkspaceDesign.documentLeast,
      );

      await dragBottom(tester, 2000);

      expect(
        tester.getRect(islandOf(CommandsPanel)).height,
        WorkspaceNotifier.bottomLowest,
      );
    });

    testWidgets('it is closed until somebody opens it', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, size: const Size(1440, 900));

      expect(find.byType(CommandsPanel), findsNothing);
    });

    testWidgets(
      'its keys open it under the document only, and close it again',
      (WidgetTester tester) async {
        await pumpShell(tester, size: const Size(1440, 900));

        await pressJ(tester);

        final Rect panel = tester.getRect(islandOf(CommandsPanel));
        final Rect document = tester.getRect(islandOf(EditorPanel));
        expect(panel.height, 260);
        expect(panel.left, document.left);
        expect(panel.right, document.right);
        expect(panel.top - document.bottom, TomMetrics.gutter);
        expect(panel.bottom, 900 - TomMetrics.statusBar);
        // The columns keep their full height.
        expect(
          tester.getRect(islandOf(FileTreePanel)).bottom,
          900 - TomMetrics.statusBar,
        );

        await pressJ(tester);

        expect(find.byType(CommandsPanel), findsNothing);
      },
      variant: platforms,
    );

    testWidgets('its head is two tabs, Commands then Terminal, and a count', (
      WidgetTester tester,
    ) async {
      container.read(workspaceProvider.notifier).toggleBottom();
      await pumpShell(tester);

      expect(find.text('Commands'), findsOneWidget);
      expect(find.text('Terminal'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Commands')).dx,
        lessThan(tester.getTopLeft(find.text('Terminal')).dx),
      );
      expect(find.text('0 this session'), findsOneWidget);
    });

    testWidgets('its × puts it away', (WidgetTester tester) async {
      container.read(workspaceProvider.notifier).toggleBottom();
      await pumpShell(tester);

      await tester.tap(find.byTooltip('Close the panel'));
      await tester.pumpAndSettle();

      expect(find.byType(CommandsPanel), findsNothing);
      expect(container.read(workspaceProvider).showingBottom, isFalse);
    });

    testWidgets('a module panel there is a second tab', (
      WidgetTester tester,
    ) async {
      container.read(workspaceProvider.notifier).toggleBottom();
      await pumpShell(
        tester,
        modules: <TomModule>[
          const CoreModuleImpl(),
          _Module(<PanelDescriptor>[
            // Not `Terminal`: the core module registers that tab itself.
            panelSaying('Tasks', placement: PanelPlacementEnum.bottom),
          ]),
        ],
      );
      expect(find.byType(CommandsPanel), findsOneWidget);

      // The title is the tab, and the panel draws the same word.
      await tester.tap(find.text('Tasks').first);
      await tester.pumpAndSettle();

      expect(find.byType(CommandsPanel), findsNothing);
      expect(find.text('Tasks'), findsNWidgets(2));
    });
  });

  group('the right column shows one panel at a time', () {
    testWidgets('the switch names every panel registered into it', (
      WidgetTester tester,
    ) async {
      // It names none of them itself: the segments are the registered
      // titles, so a third module is a third segment
      // (`docs/product/workspace/columns/doc.md`).
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      expect(find.text('Git'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('the first is showing, and the other one is not', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      expect(find.text('No space is open.'), findsOneWidget);
      expect(
        find.text('Open a document to see what changed it.'),
        findsNothing,
      );
    });

    testWidgets('choosing the other one puts it on screen instead', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, modules: <TomModule>[const CoreModuleImpl()]);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(
        find.text('Open a document to see what changed it.'),
        findsOneWidget,
      );
      expect(find.text('No space is open.'), findsNothing);
    });

    testWidgets('one panel alone needs no switch', (WidgetTester tester) async {
      await pumpShell(
        tester,
        modules: <TomModule>[
          _Module(<PanelDescriptor>[
            panelSaying('TASKS', placement: PanelPlacementEnum.aside),
          ]),
        ],
      );

      // The panel is drawn; its title is not, because a control with one
      // choice says nothing the panel does not already say.
      expect(find.text('TASKS'), findsOneWidget);
    });
  });

  group('a folder with no repository', () {
    // The column says so and nothing else, and git is never asked
    // (`docs/product/workspace/without-a-repository/doc.md`).
    final SpaceEntity loose = SpaceEntity(
      root: '/notes',
      repositoryRoot: null,
      name: 'notes',
    );

    testWidgets('the right column says only that', (WidgetTester tester) async {
      await pumpShell(tester, space: loose);

      expect(
        find.text('This folder is not inside a Git repository.'),
        findsOneWidget,
      );
      expect(find.text('Reading and editing work as usual.'), findsOneWidget);
      expect(find.text('Nothing here is versioned.'), findsOneWidget);
      // No switch, no changes list, no commit, no remote.
      expect(find.text('History'), findsNothing);
      expect(find.byType(ChangesPanel), findsNothing);
      expect(find.text('Fetch'), findsNothing);
    });

    testWidgets('git is never read for it', (WidgetTester tester) async {
      await pumpShell(tester, space: loose);

      expect(git.statuses, 0);
      expect(container.read(spaceSessionProvider)?.git, isNull);
    });

    testWidgets('the breadcrumb names the folder alone', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, space: loose);

      expect(find.text('notes'), findsWidgets);
      expect(find.text('/'), findsNothing);
    });

    testWidgets('a space inside a repository still gets git', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        space: SpaceEntity(
          root: '/code/notes',
          repositoryRoot: '/code/notes',
          name: 'notes',
        ),
      );

      expect(
        find.text('This folder is not inside a Git repository.'),
        findsNothing,
      );
      expect(find.text('History'), findsOneWidget);
      expect(git.statuses, greaterThan(0));
    });
  });

  group('a module contributes the same way', () {
    testWidgets('a stranger panel appears in the region it asked for', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        modules: <TomModule>[
          const CoreModuleImpl(),
          _Module(<PanelDescriptor>[
            panelSaying('TASKS', placement: PanelPlacementEnum.aside),
          ]),
        ],
      );

      expect(find.text('TASKS'), findsOneWidget);
      // Modules add; it displaced nothing.
      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
    });

    testWidgets('two panels in the document area sit side by side', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        modules: <TomModule>[
          _Module(<PanelDescriptor>[
            panelSaying('LEFT', placement: PanelPlacementEnum.document),
            panelSaying(
              'RIGHT',
              placement: PanelPlacementEnum.document,
              order: 1,
            ),
          ]),
        ],
      );

      expect(
        tester.getCenter(find.text('LEFT')).dx,
        lessThan(tester.getCenter(find.text('RIGHT')).dx),
      );
      // Same row, not stacked: two panels, never one panel with a mode.
      expect(
        tester.getCenter(find.text('LEFT')).dy,
        tester.getCenter(find.text('RIGHT')).dy,
      );
    });
  });

  group('the layout', () {
    testWidgets('the explorer is exactly as wide as the wireframe says', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);

      // Exactly the width, with no pixel for a rule: the line lives in the
      // gutter the column's own box carries
      // (`docs/design/screens/measurements.md`).
      final Size region = tester.getSize(
        find
            .ancestor(
              of: find.text('EXPLORER'),
              matching: find.byType(SizedBox),
            )
            .last,
      );
      expect(region.width, TomMetrics.explorer);
    });

    testWidgets('explorer, document and status bar are on screen at once', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('the layout holds at the smallest window it allows', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        size: const Size(
          TomMetrics.minimumWindowWidth,
          TomMetrics.minimumWindowHeight,
        ),
      );

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the chrome', () {
    testWidgets('the top bar names the repository, then the folder', (
      WidgetTester tester,
    ) async {
      // A space is a folder, not a repository (rule 12), and three checkouts
      // all have a `docs/`.
      await pumpShell(
        tester,
        space: SpaceEntity(
          root: '/code/app/docs',
          repositoryRoot: '/code/app',
          name: 'docs',
        ),
      );

      expect(find.text('app'), findsOneWidget);
      expect(find.text('docs'), findsOneWidget);
      expect(
        tester.getCenter(find.text('app')).dx,
        lessThan(tester.getCenter(find.text('docs')).dx),
      );
    });

    testWidgets('a repository opened at its own root says so once', (
      WidgetTester tester,
    ) async {
      // `notes / notes` is the honest answer; hiding one half would make the
      // bar mean two different things.
      await pumpShell(
        tester,
        space: SpaceEntity(
          root: '/code/notes',
          repositoryRoot: '/code/notes',
          name: 'notes',
        ),
      );

      expect(find.text('notes'), findsNWidgets(2));
    });

    testWidgets('with no space open the top bar carries no name', (
      WidgetTester tester,
    ) async {
      // A name for this state would name a window nobody can reach.
      await pumpShell(tester);

      expect(find.text('/'), findsNothing);
      expect(find.text('no space open'), findsOneWidget);
    });
  });

  group('the mode bar', () {
    /// A space, because the bar writes the mode into a session and there is
    /// no session without one.
    final SpaceEntity open = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    testWidgets('a space opens with source and preview side by side', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, space: open);

      expect(find.text('Split'), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
      expect(find.byType(PreviewPanel), findsOneWidget);
    });

    testWidgets('preview-only leaves the preview the whole area', (
      WidgetTester tester,
    ) async {
      // Reading is not a lesser mode.
      await pumpShell(tester, space: open);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.byType(EditorPanel), findsNothing);
      expect(find.byType(PreviewPanel), findsOneWidget);
    });

    testWidgets('source-only leaves the source the whole area', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, space: open);

      await tester.tap(find.text('Source'));
      await tester.pumpAndSettle();

      expect(find.byType(EditorPanel), findsOneWidget);
      expect(find.byType(PreviewPanel), findsNothing);
    });

    testWidgets('a module panel that names no mode is in all of them', (
      WidgetTester tester,
    ) async {
      // A module never has to learn about a mode that arrived after it.
      await pumpShell(
        tester,
        space: open,
        modules: <TomModule>[
          _Module(<PanelDescriptor>[
            panelSaying('TASKS', placement: PanelPlacementEnum.document),
          ]),
        ],
      );

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.text('TASKS'), findsOneWidget);
    });

    testWidgets('with nothing in the document area there is no bar', (
      WidgetTester tester,
    ) async {
      // A region with nothing in it has nothing to offer three modes of.
      await pumpShell(tester, modules: const <TomModule>[]);

      expect(find.text('Split'), findsNothing);
    });
  });

  group('the theme', () {
    testWidgets('both modes render, and differ', (WidgetTester tester) async {
      // Both modes ship together (docs/design/visual-language/README.md).
      await pumpShell(tester);
      final TomColors light = TomColors.of(
        tester.element(find.byType(TomShell)),
      );

      await pumpShell(tester, brightness: Brightness.dark);
      final TomColors dark = TomColors.of(
        tester.element(find.byType(TomShell)),
      );

      expect(light.surface, isNot(dark.surface));
      expect(light.accent, isNot(dark.accent));
    });
  });

  group('git is read whether or not its column is showing', () {
    final SpaceEntity docs = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    testWidgets('a space opened with the column shut still marks the tree', (
      WidgetTester tester,
    ) async {
      // The shell makes the reading exist, never the column: the column is
      // built only while it shows (`file-tree/change-marks/doc.md`).
      listing.held = <SpaceEntryValueObject>[
        SpaceEntryValueObject(
          path: SpaceRelativePathValueObject('index.md'),
          type: SpaceEntryTypeEnum.file,
        ),
      ];
      git.changed = <StatusEntryValueObject>[
        StatusEntryValueObject(
          path: RepoRelativePathValueObject('docs/index.md'),
          state: FileStateEnum.modified,
          isStaged: false,
        ),
      ];
      container.read(workspaceProvider.notifier).toggleAside();

      await pumpShell(tester, space: docs);

      expect(find.byType(ChangesPanel), findsNothing);
      expect(container.exists(changesProvider), isFalse);
      expect(container.read(spaceSessionProvider)?.git?.entries, hasLength(1));
      final Finder mark = find.descendant(
        of: find.byType(FileTreePanel),
        matching: find.byType(FileStateMarkWidget),
      );
      expect(
        tester.widget<FileStateMarkWidget>(mark).state,
        FileStateEnum.modified,
      );
    });
  });

  group('replacing opens by its keys', () {
    // ⌥⌘F on macOS, Ctrl+H elsewhere — VS Code's keys, and no chevron
    // (`docs/product/search/replacing/doc.md`).
    const TargetPlatformVariant platforms = TargetPlatformVariant(
      <TargetPlatform>{TargetPlatform.macOS, TargetPlatform.linux},
    );
    final SpaceEntity docs = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    Future<void> pressReplace(WidgetTester tester) async {
      final bool mac = defaultTargetPlatform == TargetPlatform.macOS;
      final List<LogicalKeyboardKey> held = mac
          ? <LogicalKeyboardKey>[
              LogicalKeyboardKey.metaLeft,
              LogicalKeyboardKey.altLeft,
            ]
          : <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft];
      for (final LogicalKeyboardKey key in held) {
        await tester.sendKeyDownEvent(key);
      }
      await tester.sendKeyEvent(
        mac ? LogicalKeyboardKey.keyF : LogicalKeyboardKey.keyH,
      );
      for (final LogicalKeyboardKey key in held.reversed) {
        await tester.sendKeyUpEvent(key);
      }
      await tester.pumpAndSettle();
    }

    String? focused() => FocusManager.instance.primaryFocus?.debugLabel;

    testWidgets(
      'they open the box on This file, and the same keys put it away',
      (WidgetTester tester) async {
        await pumpShell(tester, space: docs);
        expect(find.text('Replace with'), findsNothing);

        await pressReplace(tester);

        expect(find.text('Replace with'), findsOneWidget);
        expect(
          (container.read(searchProvider) as SearchReady).scope,
          SearchScopeEnum.thisFile,
        );
        // Nothing typed yet, so the words come first.
        expect(focused(), 'search');

        await pressReplace(tester);

        expect(find.text('Replace with'), findsNothing);
      },
      variant: platforms,
    );

    testWidgets(
      'with words in the search box, the keyboard goes to the replacement',
      (WidgetTester tester) async {
        await pumpShell(tester, space: docs);
        await container.read(searchProvider.notifier).type('palette');
        await tester.pumpAndSettle();

        await pressReplace(tester);

        expect(focused(), 'replace');

        await pressReplace(tester);

        expect(find.text('Replace with'), findsNothing);
        expect(focused(), 'search', reason: 'not dropped with the box');
      },
      variant: platforms,
    );

    testWidgets('a click that took the keyboard out of the field', (
      WidgetTester tester,
    ) async {
      // The field lets go to its nearest focus scope on a desktop click; the
      // route's is outside the shortcuts, so the shell keeps one of its own.
      await pumpShell(tester, space: docs);
      final Finder field = find.descendant(
        of: find.byType(SearchFieldWidget),
        matching: find.byType(TextField),
      );
      await tester.tap(field);
      await tester.enterText(field, 'palette');
      await tester.pumpAndSettle();
      await tester.tap(find.text('This file'));
      await tester.pumpAndSettle();
      expect(focused(), isNot('search'), reason: 'the click took it');

      await pressReplace(tester);

      expect(find.text('Replace with'), findsOneWidget);
    }, variant: platforms);

    testWidgets('a shut explorer opens first, as for ⌘K', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, space: docs);
      container.read(workspaceProvider.notifier).toggleExplorer();
      await tester.pumpAndSettle();
      expect(find.byType(FileTreePanel), findsNothing);

      await pressReplace(tester);

      expect(find.byType(FileTreePanel), findsOneWidget);
      expect(find.text('Replace with'), findsOneWidget);
    }, variant: platforms);

    testWidgets('with no space open they do nothing', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester);

      await pressReplace(tester);

      expect(find.text('Replace with'), findsNothing);
    }, variant: platforms);
  });
}

/// A repository that reports [changed] — clean unless a test says
/// otherwise — and does nothing else.
final class _Changed implements GitRepository {
  List<StatusEntryValueObject> changed = const <StatusEntryValueObject>[];

  /// How many times the status was read.
  int statuses = 0;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async {
    statuses++;
    return Success<GitStatusValueObject, GitFailure>(
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: null,
        ahead: 0,
        behind: 0,
        entries: changed,
        isDetached: false,
      ),
    );
  }

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      throw UnimplementedError();

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> commit(String message) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> fetch() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> pull() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> push() async => throw UnimplementedError();

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> discardAll() async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> abortMerge() async =>
      throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The index of a space, which these tests only ever fill with nothing.
SearchRepository _emptyIndex(SpaceEntity space) => const _Empty();

/// An index that files everything and finds nothing.
final class _Empty implements SearchRepository {
  const _Empty();

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async => const Success<void, SearchFailure>(null);

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async =>
      const Success<void, SearchFailure>(null);

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async => const Success<List<SearchHitValueObject>, SearchFailure>(
    <SearchHitValueObject>[],
  );
}

/// A recent list with nothing in it; these tests are about the chrome.
final class _NoRecents implements RecentSpacesRepository {
  const _NoRecents();

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// A space that holds nothing, so the explorer has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );
}

/// A space that holds [held] — nothing unless a test says otherwise.
final class _Listed extends _NothingInIt {
  List<SpaceEntryValueObject> held = const <SpaceEntryValueObject>[];

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// A module that contributes exactly what it was given.
class _Module implements TomModule {
  const _Module(this.panels);

  @override
  String get id => 'test.module';

  @override
  final List<PanelDescriptor> panels;

  @override
  List<Override> get overrides => const <Override>[];
}

/// Preferences in memory, so a widget test needs no disk.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}
