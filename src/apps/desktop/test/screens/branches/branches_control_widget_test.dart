import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Git git;
  late _Documents documents;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );

  BranchEntity branch(String name, {bool isCurrent = false}) =>
      BranchEntity(name: BranchNameValueObject(name), isCurrent: isCurrent);

  GitStatusValueObject statusOf({String? branch, bool isDetached = false}) =>
      GitStatusValueObject(
        branch: branch == null ? null : BranchNameValueObject(branch),
        upstream: null,
        ahead: 0,
        behind: 0,
        entries: const <StatusEntryValueObject>[],
        isDetached: isDetached,
      );

  setUp(() {
    git = _Git()
      ..reported = <BranchEntity>[
        branch('feat/one'),
        branch('main', isCurrent: true),
        branch('fix/two'),
      ];
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        listBranchesProvider.overrideWithValue(
          ListBranchesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        switchBranchProvider.overrideWithValue(
          SwitchBranchUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A switch rewrites the working tree, so all three readers of it are
        // asked again — a test that switches needs every one of them wired.
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the control in a bar, with [status] written straight onto the
  /// session — going through the changes panel would test that panel.
  Future<void> pumpControl(
    WidgetTester tester, {
    GitStatusValueObject? status,
    bool withDocument = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier).open(docs);
    if (withDocument) {
      container.read(spaceSessionProvider.notifier).show(note);
    }
    if (status != null) {
      container.read(spaceSessionProvider.notifier).observe(status);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: TomMetrics.topBar,
                child: Row(children: <Widget>[BranchesControlWidget()]),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the popover.
  Future<void> openIt(WidgetTester tester) async {
    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();
  }

  testWidgets('nothing is drawn before git has answered', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);

    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('it says which branch is checked out', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, status: statusOf(branch: 'main'));

    expect(find.text('main'), findsOneWidget);
  });

  testWidgets('a detached HEAD is named as that, not left blank', (
    WidgetTester tester,
  ) async {
    // A state to get out of, not a missing value
    // (`docs/product/git-workflow/branch-switch/doc.md`).
    await pumpControl(tester, status: statusOf(isDetached: true));

    expect(find.text('detached HEAD'), findsOneWidget);
  });

  group('the popover', () {
    testWidgets('it lists the branches, the current one first', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));

      await openIt(tester);

      expect(find.text('feat/one'), findsOneWidget);
      expect(find.text('fix/two'), findsOneWidget);
      // Twice: once in the control, once as the row saying where you are.
      expect(find.text('main'), findsNWidgets(2));
    });

    testWidgets('typing narrows the list', (WidgetTester tester) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));
      await openIt(tester);

      await tester.enterText(find.byType(TextField), 'fix');
      await tester.pumpAndSettle();

      expect(find.text('fix/two'), findsOneWidget);
      expect(find.text('feat/one'), findsNothing);
    });

    testWidgets('choosing a branch checks it out', (WidgetTester tester) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));
      await openIt(tester);

      await tester.tap(find.text('feat/one'));
      await tester.pumpAndSettle();

      expect(git.switched, <String>['feat/one']);
    });

    testWidgets('Escape puts it away', (WidgetTester tester) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));
      await openIt(tester);
      expect(find.text('Create branch…'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Create branch…'), findsNothing);
    });
  });

  group('starting a branch', () {
    testWidgets('it says what the new branch starts from', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));
      await openIt(tester);

      await tester.tap(find.text('Create branch…'));
      await tester.pumpAndSettle();

      expect(
        find.text('Starts from main, and switches to it.'),
        findsOneWidget,
      );
      expect(find.text('Create branch'), findsOneWidget);
    });

    testWidgets('a name already taken is refused in words, before pressing', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, status: statusOf(branch: 'main'));
      await openIt(tester);
      await tester.tap(find.text('Create branch…'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'fix/two');
      await tester.pumpAndSettle();

      expect(
        find.text('There is already a branch called that'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
        reason: 'the button offered to create a branch that exists',
      );
    });
  });

  testWidgets('an unsaved document is named before anything is lost', (
    WidgetTester tester,
  ) async {
    await pumpControl(
      tester,
      status: statusOf(branch: 'main'),
      withDocument: true,
    );
    // Nothing on screen is the editor, so the buffer needs a listener before
    // it reads anything, and is typed into only once it has.
    container.listen<EditorState>(editorProvider, (_, _) {});
    await tester.pumpAndSettle();
    container.read(editorProvider.notifier).edit('changed');
    await openIt(tester);

    await tester.tap(find.text('feat/one'));
    await tester.pumpAndSettle();

    expect(find.text('note.md has unsaved changes.'), findsOneWidget);
    expect(find.text('Save and switch'), findsOneWidget);
    expect(find.text('Discard and switch'), findsOneWidget);
    expect(git.switched, isEmpty, reason: 'it switched without asking');
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  List<BranchEntity> reported = <BranchEntity>[];
  final List<String> switched = <String>[];
  final List<String> created = <String>[];

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      Success<List<BranchEntity>, GitFailure>(reported);

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async {
    switched.add(name.value);
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async {
    created.add(name.value);
    return const Success<void, GitFailure>(null);
  }

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// One document on disk, which always reads back as what was written.
final class _Documents implements DocumentRepository {
  String content = 'on the disk';

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    content = document.content;
    return const Success<void, DocumentFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A space that holds nothing, so the tree has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
