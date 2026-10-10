import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_draft_widget.dart';
import 'package:tom_desktop/widgets/file_state_mark_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// No pull request on offer: the row it would draw has tests of its own.
final class _NoPullRequest extends PullRequestNotifier {
  @override
  PullRequestState build() => const PullRequestState();
}

void main() {
  late _Spaces spaces;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  SpaceEntryValueObject entry(String path, SpaceEntryTypeEnum type) =>
      SpaceEntryValueObject(
        path: SpaceRelativePathValueObject(path),
        type: type,
      );

  /// A space with a folder, a document inside it, an image and a link.
  final List<SpaceEntryValueObject> held = <SpaceEntryValueObject>[
    entry('guides', SpaceEntryTypeEnum.directory),
    entry('guides/writing.md', SpaceEntryTypeEnum.file),
    entry('logo.svg', SpaceEntryTypeEnum.file),
    entry('elsewhere', SpaceEntryTypeEnum.link),
    entry('index.md', SpaceEntryTypeEnum.file),
  ];

  late ProviderContainer container;

  setUp(() {
    spaces = _Spaces();
    // One container per test, not per mount: a second container left alive
    // is still scheduling its disposal, a timer the test framework fails on.
    container = ProviderContainer(
      overrides: <Override>[
        pullRequestProvider.overrideWith(_NoPullRequest.new),
        listSpaceEntriesProvider.overrideWithValue(
          ListSpaceEntriesUseCase(
            spaces: spaces,
            observability: const _Silent(),
          ),
        ),
        // The tree marks a drifted buffer, so opening a document is a read.
        readDocumentProvider.overrideWithValue(
          const ReadDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
        createDocumentProvider.overrideWithValue(
          const CreateDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
        gitReadingProvider.overrideWith(_Reading.new),
        createFolderProvider.overrideWithValue(
          CreateFolderUseCase(spaces: spaces, observability: const _Silent()),
        ),
        // The box above the tree is the search's, and a space that opens
        // builds its index.
        indexSpaceProvider.overrideWithValue(
          IndexSpaceUseCase(
            spaces: spaces,
            searchFor: _searchFor,
            observability: const _Silent(),
          ),
        ),
        indexDocumentProvider.overrideWithValue(
          const IndexDocumentUseCase(
            searchFor: _searchFor,
            observability: _Silent(),
          ),
        ),
        searchSpaceProvider.overrideWithValue(
          const SearchSpaceUseCase(
            searchFor: _searchFor,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the panel at the shell's width, with [space] open.
  ///
  /// At the left edge, because indentation is measured in absolute pixels.
  Future<void> pumpPanel(
    WidgetTester tester, {
    SpaceEntity? space,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          home: const Scaffold(
            body: Row(
              children: <Widget>[
                SizedBox(width: TomMetrics.explorer, child: FileTreePanel()),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The style the row showing [name] is drawn in.
  TextStyle styleOf(WidgetTester tester, String name) =>
      tester.widget<Text>(find.text(name)).style!;

  group('the panel itself', () {
    testWidgets('it names itself, and offers the search box', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('M2'), findsNothing);
    });

    testWidgets('what is typed in it is what the space is searched for', (
      WidgetTester tester,
    ) async {
      // The box is here and the results are in the aside, one conversation
      // (`docs/product/search/full-text-search/the-surface/doc.md`).
      await pumpPanel(tester, space: docs);

      await tester.enterText(find.byType(TextField), 'rendered');
      await tester.pumpAndSettle();

      expect(container.read(searchProvider).terms, 'rendered');
    });

    testWidgets('with no space open it shows nothing else at all', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester);

      expect(find.byType(ListView), findsNothing);
      expect(find.text('This folder holds nothing yet.'), findsNothing);
    });
  });

  group('with a space open', () {
    testWidgets('every entry is on screen, folders and files alike', (
      WidgetTester tester,
    ) async {
      // Everything but `.git/`
      // (docs/product/navigation/file-tree/what-is-shown/doc.md).
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

      await pumpPanel(tester, space: docs);

      expect(find.text('guides'), findsOneWidget);
      expect(find.text('writing.md'), findsOneWidget);
      expect(find.text('logo.svg'), findsOneWidget);
      expect(find.text('elsewhere'), findsOneWidget);
      expect(find.text('index.md'), findsOneWidget);
    });

    testWidgets('a row is drawn one indent in for each level', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

      await pumpPanel(tester, space: docs);

      expect(
        tester.getTopLeft(find.text('guides')).dx,
        FileTreeDesign.labelLeft,
      );
      expect(
        tester.getTopLeft(find.text('writing.md')).dx,
        FileTreeDesign.labelLeft + FileTreeDesign.indent,
      );
    });

    testWidgets('an open folder points down, a closed one points right', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

      /// Which way the tree's own chevron is pointing.
      bool pointsDown() => tester
          .widget<TomChevronWidget>(
            find.descendant(
              of: find.byType(FileTreeBodyWidget),
              matching: find.byType(TomChevronWidget),
            ),
          )
          .isOpen;

      await pumpPanel(tester, space: docs);
      expect(pointsDown(), isTrue);

      await tester.tap(find.text('guides'));
      await tester.pumpAndSettle();

      expect(pointsDown(), isFalse);
      expect(find.text('writing.md'), findsNothing);
    });

    testWidgets('a folder opens again on a second click', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);

      await tester.tap(find.text('guides'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('guides'));
      await tester.pumpAndSettle();

      expect(find.text('writing.md'), findsOneWidget);
    });

    testWidgets('a document opens, and the row says it is the current one', (
      WidgetTester tester,
    ) async {
      // Accent and weight both, since colour is never the only signal
      // (docs/design/visual-language/README.md).
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);

      await tester.tap(find.text('index.md'));
      await tester.pumpAndSettle();

      final TomColors colors = TomColors.of(
        tester.element(find.byType(FileTreePanel)),
      );
      // Said by the weight and the row's accent bar, not by the name's
      // colour: on a 1b board the open name stays `text_primary`.
      expect(styleOf(tester, 'index.md').color, colors.textPrimary);
      expect(styleOf(tester, 'index.md').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'guides').fontWeight, isNot(FontWeight.w600));
    });

    testWidgets('a document with unsaved edits is marked, and only it', (
      WidgetTester tester,
    ) async {
      // The mark belongs to the one row, not to the space.
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await tester.tap(find.text('index.md'));
      await tester.pumpAndSettle();
      expect(_dots(tester), isEmpty);

      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      final TomColors colors = TomColors.of(
        tester.element(find.byType(FileTreePanel)),
      );
      expect(_dots(tester), <Color>[colors.modified]);
    });

    testWidgets('a changed file carries git\'s letter, and its folder a dot', (
      WidgetTester tester,
    ) async {
      // The tree and the changes column share one alphabet, so a file says
      // the same thing in both (`navigation/file-tree/change-marks/doc.md`).
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      expect(find.text('M'), findsNothing);

      container
          .read(spaceSessionProvider.notifier)
          .observe(
            GitStatusValueObject(
              branch: BranchNameValueObject('main'),
              upstream: null,
              ahead: 0,
              behind: 0,
              isDetached: false,
              entries: <StatusEntryValueObject>[
                StatusEntryValueObject(
                  // Repository-relative: the space is opened at `docs/`.
                  path: RepoRelativePathValueObject('docs/guides/writing.md'),
                  state: FileStateEnum.modified,
                  isStaged: false,
                ),
              ],
            ),
          );
      await tester.pumpAndSettle();

      expect(find.text('M'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('M'),
          matching: find.byType(FileStateMarkWidget),
        ),
        findsOneWidget,
        reason: 'the letter is the component, not a Text the tree drew',
      );
    });

    testWidgets('a change outside the space marks nothing in the tree', (
      WidgetTester tester,
    ) async {
      // Git reports the whole repository; this space is `docs/` alone.
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);

      container
          .read(spaceSessionProvider.notifier)
          .observe(
            GitStatusValueObject(
              branch: BranchNameValueObject('main'),
              upstream: null,
              ahead: 0,
              behind: 0,
              isDetached: false,
              entries: <StatusEntryValueObject>[
                StatusEntryValueObject(
                  path: RepoRelativePathValueObject('lib/main.dart'),
                  state: FileStateEnum.modified,
                  isStaged: false,
                ),
              ],
            ),
          );
      await tester.pumpAndSettle();

      expect(find.byType(FileStateMarkWidget), findsNothing);
    });

    testWidgets('a file the editor cannot open is muted and does not react', (
      WidgetTester tester,
    ) async {
      // Muted and without a hover: a row that answers a click with nothing
      // reads as the app being broken.
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      final TomColors colors = TomColors.of(
        tester.element(find.byType(FileTreePanel)),
      );

      expect(styleOf(tester, 'logo.svg').color, colors.textMuted);
      expect(
        find.ancestor(
          of: find.text('logo.svg'),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.text('index.md'),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a link is drawn as itself and opens nothing', (
      WidgetTester tester,
    ) async {
      // The listing never followed it, so nothing knows what is behind it.
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      final TomColors colors = TomColors.of(
        tester.element(find.byType(FileTreePanel)),
      );

      expect(styleOf(tester, 'elsewhere').color, colors.textMuted);
      expect(
        find.ancestor(
          of: find.text('elsewhere'),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });

  group('when there is nothing to show', () {
    testWidgets('an empty space says so, instead of looking broken', (
      WidgetTester tester,
    ) async {
      spaces.answer = const Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[],
      );

      await pumpPanel(tester, space: docs);

      expect(find.text('This folder holds nothing yet.'), findsOneWidget);
    });

    testWidgets('a folder that is gone is named as that, not as an error', (
      WidgetTester tester,
    ) async {
      spaces.answer = const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
        SpaceFolderMissing('/code/app/docs'),
      );

      await pumpPanel(tester, space: docs);

      expect(find.text('This folder is no longer there.'), findsOneWidget);
    });

    testWidgets('a folder TOM may not read says which problem it is', (
      WidgetTester tester,
    ) async {
      spaces.answer = const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
        SpaceAccessDenied('/code/app/docs'),
      );

      await pumpPanel(tester, space: docs);

      expect(
        find.text('TOM is not allowed to read this folder.'),
        findsOneWidget,
      );
    });

    testWidgets('anything else is still said out loud', (
      WidgetTester tester,
    ) async {
      // Thrown rather than answered: the repository's vocabulary cannot say
      // "unexpected", so the catch-all is reached only through the use
      // case's guard, the way it really happens.
      spaces.throws = true;

      await pumpPanel(tester, space: docs);

      expect(find.text('This folder could not be read.'), findsOneWidget);
    });
  });

  group('a new document', () {
    /// The field the `+` puts in the tree.
    Finder field() => find.descendant(
      of: find.byType(FileTreeDraftWidget),
      matching: find.byType(TextField),
    );

    /// Presses the `+`.
    Future<void> pressPlus(WidgetTester tester) async {
      await tester.tap(find.byTooltip('New document'));
      await tester.pumpAndSettle();
    }

    /// Types [name] into the field and presses Enter.
    Future<void> name(WidgetTester tester, String name) async {
      await tester.enterText(field(), name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    testWidgets('the + sits at the caption\'s right, where the board has it', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      expect(
        tester.getCenter(find.byTooltip('New document')).dx,
        TomMetrics.explorer - FileTreeDesign.newCentreRight,
      );
    });

    testWidgets('the + asks for a name in the tree, untitled.md selected', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);

      await pressPlus(tester);

      final TextField typed = tester.widget<TextField>(field());
      expect(typed.controller!.text, 'untitled.md');
      expect(
        typed.controller!.selection,
        const TextSelection(baseOffset: 0, extentOffset: 8),
      );
      // Nothing is open, so it goes at the space's root, first.
      expect(
        tester.getTopLeft(find.byType(FileTreeDraftWidget)).dy,
        lessThan(tester.getTopLeft(find.text('guides')).dy),
      );
    });

    testWidgets('it goes into the open document\'s folder, one level in', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('guides/writing.md'));

      await pressPlus(tester);

      final double top = tester.getTopLeft(find.byType(FileTreeDraftWidget)).dy;
      expect(top, greaterThan(tester.getTopLeft(find.text('guides')).dy));
      expect(top, lessThan(tester.getTopLeft(find.text('writing.md')).dy));
      // The board's 22 back from where a row at that depth starts its name.
      expect(
        tester.getTopLeft(find.byType(TomFieldBoxWidget).last).dx,
        FileTreeDesign.labelLeft +
            FileTreeDesign.indent -
            FileTreeDesign.draftInset,
      );
    });

    testWidgets('Enter creates the document and opens it in source', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await pressPlus(tester);
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[
          ...held,
          entry('ideas.md', SpaceEntryTypeEnum.file),
        ],
      );

      await name(tester, 'ideas');

      expect(find.byType(FileTreeDraftWidget), findsNothing);
      expect(find.text('ideas.md'), findsOneWidget);
      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.openDocument, SpaceRelativePathValueObject('ideas.md'));
      expect(session.mode, DocumentModeEnum.source);
    });

    testWidgets('a taken name keeps the row, outlined as refused', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await pressPlus(tester);

      await name(tester, 'index');

      expect(find.byType(FileTreeDraftWidget), findsOneWidget);
      expect(
        tester.widget<TomFieldBoxWidget>(find.byType(TomFieldBoxWidget).last),
        isA<TomFieldBoxWidget>().having(
          (TomFieldBoxWidget box) => box.isRefused,
          'isRefused',
          isTrue,
        ),
      );
      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });

    testWidgets('Escape takes the row away and creates nothing', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await pressPlus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(FileTreeDraftWidget), findsNothing);
    });

    testWidgets('the + is the tree\'s, so a search takes it away', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      await tester.enterText(find.byType(TextField), 'rendered');
      await tester.pumpAndSettle();

      expect(find.byTooltip('New document'), findsNothing);
    });
  });

  group('the explorer menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Explorer menu'));
      await tester.pumpAndSettle();
    }

    testWidgets('the ⋮ offers four things, in three groups', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      await openMenu(tester);

      expect(find.text('New folder'), findsOneWidget);
      expect(find.text('Collapse all'), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
      expect(find.textContaining(RegExp('Reveal in|Show in')), findsOneWidget);
    });

    testWidgets('the ⋮ sits as far in as the git column\'s, the + 26 before', (
      WidgetTester tester,
    ) async {
      // One number for both columns, the maintainer's call of 2026-10-08.
      await pumpPanel(tester, space: docs);

      final double menu = tester.getCenter(find.byTooltip('Explorer menu')).dx;
      expect(menu, TomMetrics.explorer - ChangesDesign.menuCentreRight);
      expect(tester.getCenter(find.byTooltip('New document')).dx, menu - 26);
    });

    testWidgets('it hangs from the ⋮, its right edge past the glyph', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      await openMenu(tester);

      expect(
        tester.getTopRight(find.byType(TomMenuWidget)).dx,
        tester.getCenter(find.byTooltip('Explorer menu')).dx + 5,
      );
      expect(
        tester.getSize(find.byType(TomMenuWidget)).width,
        FileTreeDesign.menuWidth,
      );
    });

    testWidgets('Escape closes it, and so does a choice', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await openMenu(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(TomMenuWidget), findsNothing);

      await openMenu(tester);
      await tester.tap(find.text('Collapse all'));
      await tester.pumpAndSettle();
      expect(find.byType(TomMenuWidget), findsNothing);
      expect(find.text('writing.md'), findsNothing);
    });

    testWidgets('New folder asks for a name in the tree, with a folder', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await openMenu(tester);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();

      final FileTreeDraftWidget draft = tester.widget(
        find.byType(FileTreeDraftWidget),
      );
      expect(draft.isFolder, isTrue);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byType(FileTreeDraftWidget),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
        'untitled',
      );
    });

    testWidgets('a folder name already taken is refused in place', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);
      await openMenu(tester);
      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(FileTreeDraftWidget),
          matching: find.byType(TextField),
        ),
        'guides',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TomFieldBoxWidget>(find.byType(TomFieldBoxWidget).last)
            .isRefused,
        isTrue,
      );
    });
  });

  group('both modes', () {
    testWidgets('a row takes its colour from the mode it is drawn in', (
      WidgetTester tester,
    ) async {
      // The row asks for a role and never for a mode: one widget, two
      // themes, two colours (docs/design/visual-language/README.md).
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

      await pumpPanel(tester, space: docs);
      final Color light = styleOf(tester, 'guides').color!;

      await pumpPanel(tester, space: docs, brightness: Brightness.dark);

      expect(styleOf(tester, 'guides').color, isNot(light));
      expect(styleOf(tester, 'guides').color, TomColors.dark.textPrimary);
    });
  });
}

/// A space repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  Result<List<SpaceEntryValueObject>, SpaceFailure> answer =
      const Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[],
      );

  /// Whether it breaks its contract instead of answering.
  bool throws = false;

  /// Creates any folder but `guides`, which the space already holds.
  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => path.value == 'guides'
      ? const Failure<void, SpaceFailure>(SpaceEntryExists('guides'))
      : const Success<void, SpaceFailure>(null);

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throws ? throw StateError('the disk caught fire') : answer;
}

/// The colour of every round mark the tree is drawing, found by shape
/// because a key would let the test pass on a square.
List<Color> _dots(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((DecoratedBox box) => box.decoration as BoxDecoration)
    .where((BoxDecoration decoration) => decoration.shape == BoxShape.circle)
    .map((BoxDecoration decoration) => decoration.color!)
    .toList();

/// A repository for any space, since the tree only needs one to exist.
DocumentRepository _documentsFor(SpaceEntity space) => const _Documents();

/// The index of a space, which this panel only ever types into.
SearchRepository _searchFor(SpaceEntity space) => const _Search();

/// An index that files everything and finds nothing.
final class _Search implements SearchRepository {
  const _Search();

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

/// A repository that reads an empty document and writes nowhere.
final class _Documents implements DocumentRepository {
  const _Documents();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: ''),
  );

  /// Creates anything but `index.md`, which the space already holds.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      document.path.value == 'index.md'
      ? const Failure<void, DocumentFailure>(DocumentAlreadyExists('index.md'))
      : const Success<void, DocumentFailure>(null);

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
}

/// The git reading, which this panel only asks to re-read.
final class _Reading extends GitReadingNotifier {
  @override
  GitReadingState build() => const GitReadingState.initial();

  @override
  Future<void> refresh() async {}
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
