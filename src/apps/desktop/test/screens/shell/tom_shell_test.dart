import 'package:flutter/material.dart';
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
import 'package:tom_desktop/screens/shell/tom_shell.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// What the registry is built from, read when the shell first asks.
  ///
  /// A variable rather than an argument baked into an override, because the
  /// container is made once per test: see [pumpShell].
  List<TomModule> registered = const <TomModule>[CoreModuleImpl()];
  late ProviderContainer container;

  setUp(() {
    registered = const <TomModule>[CoreModuleImpl()];
    // One container per test, not one per mount: a test that pumps twice —
    // the same shell in the other mode — would otherwise leave the first
    // one alive, and a provider still scheduling its own disposal is a
    // timer the test framework fails on.
    container = ProviderContainer(
      overrides: <Override>[
        panelRegistryProvider.overrideWith(
          (Ref ref) => PanelRegistry(registered),
        ),
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
        // The aside holds the changes panel now, and a space open means it
        // asks git. These tests are about the layout and the chrome, so it
        // is answered by a repository with nothing in it
        // (`test/screens/changes/changes_panel_test.dart` is where the panel
        // lives).
        readGitStatusProvider.overrideWithValue(
          const ReadGitStatusUseCase(
            gitFor: _cleanTree,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the shell with [modules] registered, in a window of [size].
  ///
  /// With [space] open when one is given, over a space that holds nothing:
  /// these tests are about the layout and the chrome, and a tree with
  /// content in it would make them about the tree
  /// (`test/screens/file_tree/file_tree_panel_test.dart` is where that
  /// lives).
  ///
  /// [modules] is read when the registry is first built, which is the first
  /// mount — a second pump in the same test is the same shell in another
  /// theme, never another set of panels.
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
    // colour halfway between the two modes. Settling is what makes the
    // assertion about the theme rather than about the animation.
    await tester.pumpAndSettle();
  }

  PanelDescriptor panelSaying(
    String text, {
    required PanelPlacementEnum placement,
    int order = 0,
  }) => PanelDescriptor(
    id: 'test.$text',
    title: text,
    placement: placement,
    order: order,
    builder: (BuildContext context) => Text(text),
  );

  group('the built-in panels go through the registry', () {
    testWidgets('the core module puts a panel in every region it claims', (
      WidgetTester tester,
    ) async {
      // The claim Decision 12 makes: the app's own panels are registered,
      // not wired into the shell. If this passes with CoreModuleImpl and the
      // next group passes with a stranger's module, the extension point is
      // real rather than decorative.
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('PREVIEW'), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('the shell draws no panel of its own', (
      WidgetTester tester,
    ) async {
      // With no modules at all the regions collapse. Anything still on
      // screen beyond the chrome would be a panel the shell hardcoded.
      await pumpShell(tester, modules: const <TomModule>[]);

      expect(find.text('EXPLORER'), findsNothing);
      expect(find.text('SOURCE'), findsNothing);
      expect(find.text('no space open'), findsNothing);
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
      // And it displaced nothing: modules add.
      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
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
      // Same row, not stacked: source and preview are two panels, never one
      // panel with a mode.
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

      // A panel narrower on one screen than another is a bug, not a
      // variant (docs/product/workspace/doc.md). The extra pixel is the
      // rule between the explorer and the document area.
      final Size region = tester.getSize(
        find
            .ancestor(
              of: find.text('EXPLORER'),
              matching: find.byType(SizedBox),
            )
            .last,
      );
      expect(region.width, TomMetrics.explorer + 1);
    });

    testWidgets('explorer, document and status bar are on screen at once', (
      WidgetTester tester,
    ) async {
      // There is no full-screen takeover that hides the tree while editing.
      await pumpShell(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('SOURCE'), findsOneWidget);
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
      expect(find.text('SOURCE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the chrome', () {
    testWidgets('the top bar names the repository, then the folder', (
      WidgetTester tester,
    ) async {
      // A space is a folder, not a repository (rule 12), and the folder alone
      // is ambiguous: three checkouts all have a `docs/`.
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
      // Root and repositoryRoot are the same folder, and the design draws
      // both halves anyway: `notes / notes` is the honest answer, and hiding
      // one would make the bar mean two different things.
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
      // The shell only shows with a space open; a name invented for this
      // state would be a name for a window nobody can reach.
      await pumpShell(tester);

      expect(find.text('/'), findsNothing);
      expect(find.text('no space open'), findsOneWidget);
    });
  });

  group('the mode bar', () {
    /// A space, because the bar writes the mode into the session and there
    /// is no session without one — and no shell either.
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
      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('PREVIEW'), findsOneWidget);
    });

    testWidgets('preview-only leaves the preview the whole area', (
      WidgetTester tester,
    ) async {
      // Reading is not a lesser mode: for anyone who does not write
      // markdown by hand, this is the product.
      await pumpShell(tester, space: open);

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.text('SOURCE'), findsNothing);
      expect(find.text('PREVIEW'), findsOneWidget);
    });

    testWidgets('source-only leaves the source the whole area', (
      WidgetTester tester,
    ) async {
      await pumpShell(tester, space: open);

      await tester.tap(find.text('Source'));
      await tester.pumpAndSettle();

      expect(find.text('SOURCE'), findsOneWidget);
      expect(find.text('PREVIEW'), findsNothing);
    });

    testWidgets('a module panel that names no mode is in all of them', (
      WidgetTester tester,
    ) async {
      // Modules add; they never have to learn about a mode that arrived
      // after they were written.
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
      // The bar governs the document region, so a region with nothing in it
      // has nothing to offer three modes of.
      await pumpShell(tester, modules: const <TomModule>[]);

      expect(find.text('Split'), findsNothing);
    });
  });

  group('the theme', () {
    testWidgets('both modes render, and differ', (WidgetTester tester) async {
      // A colour added in one mode without its counterpart is a bug, not a
      // follow-up (docs/technical/design/visual-language.md).
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
}

/// Git for any space, reporting a tree with nothing changed in it.
GitRepository _cleanTree(SpaceEntity space) => const _Clean();

/// A repository whose working tree is clean and which does nothing else.
final class _Clean implements GitRepository {
  const _Clean();

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      Success<GitStatusValueObject, GitFailure>(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: const <StatusEntryValueObject>[],
          isDetached: false,
        ),
      );

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
}

/// A space that holds nothing, so the explorer has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

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
