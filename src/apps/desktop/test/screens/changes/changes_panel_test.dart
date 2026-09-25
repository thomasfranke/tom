import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Git git;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  StatusEntryValueObject entry(
    String path,
    FileStateEnum state, {
    required bool isStaged,
  }) => StatusEntryValueObject(
    path: RepoRelativePathValueObject(path),
    state: state,
    isStaged: isStaged,
  );

  GitStatusValueObject statusOf(
    List<StatusEntryValueObject> entries, {
    int behind = 0,
  }) => GitStatusValueObject(
    branch: BranchNameValueObject('main'),
    upstream: null,
    ahead: 0,
    behind: behind,
    entries: entries,
    isDetached: false,
  );

  setUp(() {
    git = _Git()..reported = statusOf(const <StatusEntryValueObject>[]);
    container = ProviderContainer(
      overrides: <Override>[
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        stageChangesProvider.overrideWithValue(
          StageChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        commitChangesProvider.overrideWithValue(
          CommitChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A refused push puts its remedy on this column, so the remote
        // actions are wired though the panel offers none of them.
        pushRemoteProvider.overrideWithValue(
          PushRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        pullRemoteProvider.overrideWithValue(
          PullRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A pull rewrites the working tree and walks it again, so a test
        // that pulls needs a folder to walk.
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the panel at the shell's width with [space] open, at [height]
  /// when it shares the aside with another.
  Future<void> pumpPanel(
    WidgetTester tester, {
    SpaceEntity? space,
    double? height,
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
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: Row(
              children: <Widget>[
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: TomMetrics.git,
                  height: height,
                  child: const ChangesPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it names itself, and says so when nothing is open', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester);

    expect(find.text('CHANGES'), findsOneWidget);
    expect(find.text('No space is open.'), findsOneWidget);
  });

  testWidgets('a clean tree says so rather than looking broken', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, space: docs);

    expect(
      find.text('Nothing has changed since the last commit.'),
      findsOneWidget,
    );
  });

  testWidgets('every change git reports is a row', (WidgetTester tester) async {
    // The repository's changes, not the space's: a commit records the index.
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: true),
      entry('lib/main.dart', FileStateEnum.added, isStaged: false),
      entry('notes.md', FileStateEnum.untracked, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('index.md'), findsOneWidget);
    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('notes.md'), findsOneWidget);
  });

  testWidgets('each row says what happened with a letter, not a colour only', (
    WidgetTester tester,
  ) async {
    // Colour is never the only signal
    // (docs/technical/design/visual-language.md).
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('a.md', FileStateEnum.modified, isStaged: false),
      entry('b.md', FileStateEnum.added, isStaged: false),
      entry('c.md', FileStateEnum.deleted, isStaged: false),
      entry('d.md', FileStateEnum.untracked, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('M'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
  });

  testWidgets('ticking a row stages it, one file at a time', (
    WidgetTester tester,
  ) async {
    // Whole files, no hunks (docs/product/git-workflow/commit/doc.md).
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    expect(git.staged.single.value, 'docs/index.md');
  });

  group('the commit button', () {
    setUp(
      () => git.reported = statusOf(<StatusEntryValueObject>[
        entry('docs/index.md', FileStateEnum.modified, isStaged: true),
      ]),
    );

    /// Whether *Commit* can be pressed.
    bool isEnabled(WidgetTester tester) =>
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed !=
        null;

    testWidgets('is disabled until there is a message', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      expect(isEnabled(tester), isFalse);
    });

    testWidgets('is disabled with nothing staged, however good the message', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(<StatusEntryValueObject>[
        entry('docs/index.md', FileStateEnum.modified, isStaged: false),
      ]);
      await pumpPanel(tester, space: docs);

      await tester.enterText(find.byType(TextField), 'docs: say it');
      await tester.pumpAndSettle();

      expect(isEnabled(tester), isFalse);
    });

    testWidgets('commits what is staged, and empties the box', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);
      await tester.enterText(find.byType(TextField), 'docs: say it');
      await tester.pumpAndSettle();
      expect(isEnabled(tester), isTrue);
      git.reported = statusOf(const <StatusEntryValueObject>[]);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(git.messages, <String>['docs: say it']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(
        find.text('Nothing has changed since the last commit.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('a refused operation says so without losing the list', (
    WidgetTester tester,
  ) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);
    git.writeFailure = const GitOperationFailed();

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    expect(find.text('Git could not do that.'), findsOneWidget);
    expect(find.text('index.md'), findsOneWidget);
  });

  testWidgets('a folder outside a repository is named as that', (
    WidgetTester tester,
  ) async {
    git.statusFailure = const GitNotARepository('/code/app');

    await pumpPanel(tester, space: docs);

    expect(
      find.text('That folder is not inside a Git repository.'),
      findsOneWidget,
    );
  });

  group('a push the remote refused', () {
    /// Pushes, having git refuse it, and lets the panel settle.
    Future<void> pushAndBeRefused(WidgetTester tester) async {
      git.writeFailure = const GitPushRejected();
      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();
    }

    testWidgets('says who got there first, and that nothing was lost', (
      WidgetTester tester,
    ) async {
      // The wording is the product's
      // (docs/product/git-workflow/push-pull/doc.md).
      git.reported = statusOf(const <StatusEntryValueObject>[], behind: 3);
      await pumpPanel(tester, space: docs);

      await pushAndBeRefused(tester);

      expect(find.text('Someone pushed 3 commits first.'), findsOneWidget);
      expect(
        find.text(
          'Pull them, then push again. Nothing you committed has been lost.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers Pull as the remedy, right there', (
      WidgetTester tester,
    ) async {
      // Not a fourth button in the chrome: it belongs beside the news.
      await pumpPanel(tester, space: docs);
      await pushAndBeRefused(tester);

      await tester.tap(find.text('Pull'));
      await tester.pumpAndSettle();

      expect(git.pulled, 1);
    });

    testWidgets('is absent until there is one', (WidgetTester tester) async {
      await pumpPanel(tester, space: docs);

      expect(find.text('Pull'), findsNothing);
      expect(find.textContaining('pushed'), findsNothing);
    });

    testWidgets('and the panel still fits the height it shares', (
      WidgetTester tester,
    ) async {
      // About half the window when the aside stacks two panels, and the
      // banner is tall: the box and the button give way rather than overflow.
      git.reported = statusOf(const <StatusEntryValueObject>[], behind: 3);
      await pumpPanel(tester, space: docs, height: 378);

      await pushAndBeRefused(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Someone pushed 3 commits first.'), findsOneWidget);
    });
  });

  testWidgets('both modes render, and differ', (WidgetTester tester) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);
    final TomColors light = TomColors.of(
      tester.element(find.byType(ChangesPanel)),
    );

    expect(light.modified, isNot(light.added));
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  GitStatusValueObject? reported;
  GitFailure? statusFailure;
  GitFailure? writeFailure;

  final List<RepoRelativePathValueObject> staged =
      <RepoRelativePathValueObject>[];
  final List<String> messages = <String>[];

  /// How many times the rejection's remedy was taken.
  int pulled = 0;

  Result<void, GitFailure> _done() => writeFailure == null
      ? const Success<void, GitFailure>(null)
      : Failure<void, GitFailure>(writeFailure!);

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      statusFailure == null
      ? Success<GitStatusValueObject, GitFailure>(reported!)
      : Failure<GitStatusValueObject, GitFailure>(statusFailure!);

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    staged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async => _done();

  @override
  Future<Result<void, GitFailure>> commit(String message) async {
    messages.add(message);
    return _done();
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
  Future<Result<void, GitFailure>> pull() async {
    pulled++;
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<void, GitFailure>> push() async => _done();
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
