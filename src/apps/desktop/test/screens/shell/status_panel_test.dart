import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// The container the last mount used, for the tests that write to it.
  late ProviderContainer container;

  /// Mounts the panel with [space] open, showing [document].
  Future<void> pumpStatus(
    WidgetTester tester, {
    SpaceEntity? space,
    String? document,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          const ReadDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
        readPreferencesFileProvider.overrideWithValue(
          const ReadDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
      if (document != null) {
        container
            .read(spaceSessionProvider.notifier)
            .show(SpaceRelativePathValueObject(document));
      }
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: StatusPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with nothing open it says so, in Home\'s own words', (
    WidgetTester tester,
  ) async {
    // The two bars are one piece of chrome, so one wording.
    await pumpStatus(tester);

    expect(find.text('no space open'), findsOneWidget);
  });

  testWidgets('the space and the document are left to the bar and the tab', (
    WidgetTester tester,
  ) async {
    // The breadcrumb names the space and the tab the document, so the strip
    // says neither (`docs/design/screens/not-drawn-yet.md`).
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
      document: 'guides/writing.md',
    );

    expect(find.textContaining('/code/app'), findsNothing);
    expect(find.textContaining('writing.md'), findsNothing);
    expect(find.text('no space open'), findsNothing);
  });

  testWidgets('no document, nothing at the right', (WidgetTester tester) async {
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
    );

    expect(find.text('UTF-8'), findsNothing);
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets(
    'an open document says where the caret is, and that it is saved',
    (WidgetTester tester) async {
      await pumpStatus(
        tester,
        space: SpaceEntity(
          root: '/code/app/docs',
          repositoryRoot: '/code/app',
          name: 'docs',
        ),
        document: 'guides/writing.md',
      );

      expect(find.text('Ln 1, Col 1'), findsOneWidget);
      expect(find.text('UTF-8'), findsOneWidget);
      expect(find.text('Markdown'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    },
  );

  testWidgets('the preferences file is JSON, not Markdown', (
    WidgetTester tester,
  ) async {
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
    );

    container
        .read(spaceSessionProvider.notifier)
        .openPreferencesFile(SpaceRelativePathValueObject('preferences.json'));
    await tester.pumpAndSettle();

    expect(find.text('JSON'), findsOneWidget);
    expect(find.text('Markdown'), findsNothing);
  });

  testWidgets('an unsaved document says so, in place of saved', (
    WidgetTester tester,
  ) async {
    // Said in words here, with a dot above the document: work is never lost
    // quietly.
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
      document: 'guides/writing.md',
    );

    container.read(editorProvider.notifier).edit('# changed\n');
    await tester.pumpAndSettle();

    expect(find.text('Unsaved'), findsOneWidget);
    expect(find.text('Saved'), findsNothing);
  });

  group('a change that is not a document', () {
    /// Mounts the bar over an editor holding [state].
    Future<void> pumpHolding(WidgetTester tester, EditorState state) async {
      container = ProviderContainer(
        overrides: <Override>[
          editorProvider.overrideWith(() => _Holding(state)),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(spaceSessionProvider.notifier)
          .open(
            SpaceEntity(
              root: '/code/app/docs',
              repositoryRoot: '/code/app',
              name: 'docs',
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: tomTheme(Brightness.light),
            home: const Scaffold(body: StatusPanel()),
          ),
        ),
      );
      await tester.pump();
    }

    EditorState holding(String path, {bool deleted = false}) =>
        EditorState.ready(
          saved: DocumentEntity(
            path: SpaceRelativePathValueObject(path),
            content: 'site_name: docs\n',
          ),
          source: 'site_name: docs\n',
          isDeleted: deleted,
        );

    testWidgets('the kind is named from the extension', (
      WidgetTester tester,
    ) async {
      await pumpHolding(tester, holding('mkdocs.yml'));

      expect(find.text('YAML'), findsOneWidget);
      expect(find.text('Markdown'), findsNothing);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('a file of no kind TOM names is plain text', (
      WidgetTester tester,
    ) async {
      await pumpHolding(tester, holding('LICENSE'));

      expect(find.text('Plain text'), findsOneWidget);
    });

    testWidgets('a deleted file is read-only, not saved', (
      WidgetTester tester,
    ) async {
      await pumpHolding(tester, holding('docs.yml', deleted: true));

      expect(find.text('Read-only'), findsOneWidget);
      expect(find.text('Saved'), findsNothing);
      // No check beside it: the check would say the file is on disk.
      expect(find.byType(TomGlyphWidget), findsNothing);
      expect(find.text('Ln 1, Col 1'), findsOneWidget);
      expect(find.text('UTF-8'), findsOneWidget);
    });

    testWidgets('a binary file names no line, no encoding, and its kind', (
      WidgetTester tester,
    ) async {
      await pumpHolding(
        tester,
        EditorState.ready(
          saved: DocumentEntity(
            path: SpaceRelativePathValueObject('logo.png'),
            content: '',
          ),
          source: '',
          isBinary: true,
        ),
      );

      expect(find.text('Binary'), findsOneWidget);
      expect(find.text('Read-only'), findsOneWidget);
      expect(find.textContaining('Ln '), findsNothing);
      expect(find.text('UTF-8'), findsNothing);
      expect(find.text('Plain text'), findsNothing);
    });
  });

  group('what git says', () {
    final SpaceEntity docs = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    /// Mounts the bar with [git] as the whole window's reading.
    Future<void> pumpWith(WidgetTester tester, GitStatusValueObject git) async {
      await pumpStatus(tester, space: docs);
      container.read(spaceSessionProvider.notifier).observe(git);
      await tester.pumpAndSettle();
    }

    testWidgets('the branch is named as soon as git has been asked', (
      WidgetTester tester,
    ) async {
      await pumpWith(tester, _status(branch: 'feat/rendered-diff'));

      expect(find.text('feat/rendered-diff'), findsOneWidget);
    });

    testWidgets('a clean tree counts nothing, and says nothing', (
      WidgetTester tester,
    ) async {
      // A counter with nothing to count is chrome read twice to be ignored.
      await pumpWith(tester, _status(branch: 'main'));

      expect(find.textContaining('change'), findsNothing);
      expect(find.textContaining('ahead'), findsNothing);
      expect(find.textContaining('behind'), findsNothing);
    });

    testWidgets('one change is singular and three are not', (
      WidgetTester tester,
    ) async {
      await pumpWith(tester, _status(branch: 'main', changes: 1));
      expect(find.text('1 change'), findsOneWidget);

      await pumpWith(tester, _status(branch: 'main', changes: 3));
      expect(find.text('3 changes'), findsOneWidget);
    });

    testWidgets('ahead and behind are both said, as numbers', (
      WidgetTester tester,
    ) async {
      // Both always, as every 1b board draws them: a zero beside the arrow
      // is the answer to "is there anything to pull".
      await pumpWith(tester, _status(branch: 'main', ahead: 2));

      expect(find.text('2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('a repository on no branch says so, in the product\'s words', (
      WidgetTester tester,
    ) async {
      // A state to get out of, not a missing value — and never git's
      // `detached` (`docs/product/workspace/status-bar/doc.md`).
      await pumpWith(tester, _status(isDetached: true));

      expect(find.text('Not on a branch'), findsOneWidget);
      expect(find.textContaining('etached'), findsNothing);
    });
  });
}

/// What git would say, with everything the bar could show set.
GitStatusValueObject _status({
  String? branch,
  int changes = 0,
  int ahead = 0,
  int behind = 0,
  bool isDetached = false,
}) => GitStatusValueObject(
  branch: branch == null ? null : BranchNameValueObject(branch),
  upstream: null,
  ahead: ahead,
  behind: behind,
  entries: <StatusEntryValueObject>[
    for (int i = 0; i < changes; i++)
      StatusEntryValueObject(
        path: RepoRelativePathValueObject('docs/$i.md'),
        state: FileStateEnum.modified,
        isStaged: false,
      ),
  ],
  isDetached: isDetached,
);

/// An editor that holds the one buffer it was given.
final class _Holding extends EditorNotifier {
  _Holding(this._state);

  final EditorState _state;

  @override
  EditorState build() => _state;
}

/// A repository for any space, answering with a document that holds nothing.
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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
