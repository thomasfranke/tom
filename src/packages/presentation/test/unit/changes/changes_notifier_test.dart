import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final RepoRelativePathValueObject writing = RepoRelativePathValueObject(
    'docs/guides/writing.md',
  );
  final RepoRelativePathValueObject index = RepoRelativePathValueObject(
    'docs/index.md',
  );

  StatusEntryValueObject entry(
    RepoRelativePathValueObject path, {
    required bool isStaged,
  }) => StatusEntryValueObject(
    path: path,
    state: FileStateEnum.modified,
    isStaged: isStaged,
  );

  GitStatusValueObject statusOf(List<StatusEntryValueObject> entries) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: BranchNameValueObject('origin/main'),
        ahead: 0,
        behind: 0,
        entries: entries,
        isDetached: false,
      );

  setUp(() {
    git = _Git()
      ..reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: false),
        entry(index, isStaged: false),
      ]);
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
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the panel, and answers its first state.
  ChangesState start() {
    container.listen<ChangesState>(changesProvider, (_, _) {});
    return container.read(changesProvider);
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// What the whole window knows about git.
  GitStatusValueObject? observed() => container.read(spaceSessionProvider)?.git;

  ChangesReady ready() => container.read(changesProvider) as ChangesReady;

  test('with no space open there is nothing to report on', () async {
    expect(start(), isA<ChangesInitial>());
    await settle();

    expect(git.asked, 0);
  });

  test('opening a space asks git, and the session gets the answer', () async {
    // The reading is the session's, not the panel's: the status bar says
    // the branch and the counts from the same one.
    start();
    container.read(spaceSessionProvider.notifier).open(docs);

    expect(container.read(changesProvider), isA<ChangesLoading>());
    await settle();

    expect(container.read(changesProvider), isA<ChangesReady>());
    expect(observed()?.branch, BranchNameValueObject('main'));
    expect(observed()?.entries, hasLength(2));
  });

  test('a repository that will not answer clears the session too', () async {
    // A stale branch name beside a failure would be the status bar lying.
    git.statusFailure = const GitNotARepository('/code/app');
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    expect(
      (container.read(changesProvider) as ChangesFailed).failure,
      const GitNotARepository('/code/app'),
    );
    expect(observed(), isNull);
  });

  group('staging', () {
    test('a row goes into the index, and git is read again', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: true),
        entry(index, isStaged: false),
      ]);

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(git.staged, <RepoRelativePathValueObject>[writing]);
      expect(observed()?.entries.first.isStaged, isTrue);
    });

    test('and comes back out again', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await container.read(changesProvider.notifier).setStaged(writing, false);

      expect(git.unstaged, <RepoRelativePathValueObject>[writing]);
    });

    test('all stages only what is not staged yet', () async {
      // Built from the status rather than from `git add -A`, so what it acts
      // on is exactly the list that was on screen.
      git.reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: true),
        entry(index, isStaged: false),
      ]);
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await container.read(changesProvider.notifier).setAllStaged(staged: true);

      expect(git.staged, <RepoRelativePathValueObject>[index]);
    });

    test('a refusal keeps the panel usable and says what happened', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitOperationFailed();

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(ready().failure, const GitOperationFailed());
      expect(ready().isBusy, isFalse);
    });

    test('the message being typed survives the re-read', () async {
      // A reload after staging must not empty a box somebody is typing into.
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      container.read(changesProvider.notifier).describe('docs: rewrite');

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(ready().message, 'docs: rewrite');
    });

    test('a message typed while git was busy is not thrown away', () async {
      // Git is another process: a sentence written during the round trip
      // would otherwise be overwritten by the answer coming back.
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      final Future<void> staging = container
          .read(changesProvider.notifier)
          .setStaged(writing, true);
      container.read(changesProvider.notifier).describe('docs: typed during');
      await staging;

      expect(ready().message, 'docs: typed during');
    });
  });

  group('committing', () {
    Future<void> describeAndCommit(String message) async {
      container.read(changesProvider.notifier).describe(message);
      await container.read(changesProvider.notifier).commit();
    }

    test('it records the message and empties the box', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.reported = statusOf(const <StatusEntryValueObject>[]);

      await describeAndCommit('docs: say what changed');

      expect(git.messages, <String>['docs: say what changed']);
      expect(ready().message, '');
      // After a commit the list reflects a clean tree
      // (docs/product/git-workflow/commit/doc.md).
      expect(observed()?.entries, isEmpty);
    });

    test('a blank message commits nothing', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await describeAndCommit('   ');

      expect(git.messages, isEmpty);
    });

    test('the message is trimmed on its way to git', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await describeAndCommit('  docs: say what changed\n');

      expect(git.messages, <String>['docs: say what changed']);
    });

    test('a commit that failed keeps the sentence somebody wrote', () async {
      // It is the only copy of it.
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitOperationFailed();

      await describeAndCommit('docs: say what changed');

      expect(ready().message, 'docs: say what changed');
      expect(ready().failure, const GitOperationFailed());
    });
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  GitStatusValueObject? reported;
  GitFailure? statusFailure;
  GitFailure? writeFailure;

  int asked = 0;
  final List<RepoRelativePathValueObject> staged =
      <RepoRelativePathValueObject>[];
  final List<RepoRelativePathValueObject> unstaged =
      <RepoRelativePathValueObject>[];
  final List<String> messages = <String>[];

  Result<void, GitFailure> _done() => writeFailure == null
      ? const Success<void, GitFailure>(null)
      : Failure<void, GitFailure>(writeFailure!);

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async {
    asked++;
    return statusFailure == null
        ? Success<GitStatusValueObject, GitFailure>(reported!)
        : Failure<GitStatusValueObject, GitFailure>(statusFailure!);
  }

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
  ) async {
    unstaged.addAll(paths);
    return _done();
  }

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
  Future<Result<void, GitFailure>> pull() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> push() async => throw UnimplementedError();
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
