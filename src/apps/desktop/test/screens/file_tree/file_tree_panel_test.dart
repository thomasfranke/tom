import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

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
    testWidgets('it names itself, and offers search as an M2 control', (
      WidgetTester tester,
    ) async {
      // Disabled rather than absent: a control that appears later moves
      // everything under it.
      await pumpPanel(tester);

      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('M2'), findsOneWidget);
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
      // Everything but `.git/` (docs/product/navigation/file-tree/doc.md).
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

      expect(tester.getTopLeft(find.text('guides')).dx, TomMetrics.pad);
      expect(
        tester.getTopLeft(find.text('writing.md')).dx,
        TomMetrics.pad + 16,
      );
    });

    testWidgets('an open folder points down, a closed one points right', (
      WidgetTester tester,
    ) async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

      await pumpPanel(tester, space: docs);
      expect(find.text('▾'), findsOneWidget);

      await tester.tap(find.text('guides'));
      await tester.pumpAndSettle();

      expect(find.text('▸'), findsOneWidget);
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
      // (docs/technical/design/visual-language.md).
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      await pumpPanel(tester, space: docs);

      await tester.tap(find.text('index.md'));
      await tester.pumpAndSettle();

      final TomColors colors = TomColors.of(
        tester.element(find.byType(FileTreePanel)),
      );
      expect(styleOf(tester, 'index.md').color, colors.accent);
      expect(styleOf(tester, 'index.md').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'guides').color, isNot(colors.accent));
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

  group('both modes', () {
    testWidgets('a row takes its colour from the mode it is drawn in', (
      WidgetTester tester,
    ) async {
      // The row asks for a role and never for a mode: one widget, two
      // themes, two colours (docs/technical/design/visual-language.md).
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

/// A repository that reads an empty document and writes nowhere.
final class _Documents implements DocumentRepository {
  const _Documents();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: ''),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
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
