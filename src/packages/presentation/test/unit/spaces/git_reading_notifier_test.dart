/// The space's git reading, alive whether or not the git column is.
library;

import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Locator locator;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceEntity site = SpaceEntity(
    root: '/code/site',
    repositoryRoot: '/code/site',
    name: 'site',
  );

  GitStatusValueObject statusOf(String branch, {int changed = 1}) =>
      GitStatusValueObject(
        branch: BranchNameValueObject(branch),
        upstream: null,
        ahead: 0,
        behind: 0,
        entries: <StatusEntryValueObject>[
          for (int i = 0; i < changed; i++)
            StatusEntryValueObject(
              path: RepoRelativePathValueObject('docs/$i.md'),
              state: FileStateEnum.modified,
              isStaged: false,
            ),
        ],
        isDetached: false,
      );

  setUp(() {
    git = _Git()..reported = statusOf('main');
    locator = _Locator();
    container = ProviderContainer(
      overrides: <Override>[
        openSpaceProvider.overrideWithValue(
          OpenSpaceUseCase(
            spaces: _NoSpaces(),
            locator: locator,
            recents: _NoRecents(),
            observability: const _Silent(),
          ),
        ),
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
      ],
    );
    addTearDown(container.dispose);
  });

  /// What the shell does: make it exist, and keep it.
  void start() => container.listen<GitReadingState>(
    gitReadingProvider,
    (GitReadingState? _, GitReadingState _) {},
  );

  /// Everything scheduled, run.
  Future<void> settle() async {
    for (int i = 0; i < 3; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  SpaceSessionState? session() => container.read(spaceSessionProvider);

  test('with no space open nothing is asked', () async {
    start();
    await settle();

    expect(container.read(gitReadingProvider), isA<GitReadingInitial>());
    expect(git.asked, 0);
  });

  test('a space with no repository is never asked about', () async {
    // What opening it found is the whole answer
    // (`docs/product/workspace/without-a-repository/doc.md`).
    start();
    container
        .read(spaceSessionProvider.notifier)
        .open(SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'));
    await settle();
    await container.read(gitReadingProvider.notifier).refresh();
    await settle();

    expect(container.read(gitReadingProvider), isA<GitReadingInitial>());
    expect(git.asked, 0);
    expect(session()?.git, isNull);
  });

  test('opening a space reads git with no git column at all', () async {
    // Nothing but the reading is listened to: the column is shut.
    start();
    container.read(spaceSessionProvider.notifier).open(docs);

    expect(container.read(gitReadingProvider), isA<GitReadingLoading>());
    await settle();

    expect(container.read(gitReadingProvider), isA<GitReadingReady>());
    expect(container.exists(changesProvider), isFalse);
    expect(session()?.git?.branch, BranchNameValueObject('main'));
    expect(session()?.git?.entries, hasLength(1));
  });

  test('the merge lands on the session beside the status', () async {
    git.merge = const MergeStateValueObject(
      inProgress: true,
      message: "Merge branch 'main'",
    );
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    expect(session()?.merge?.inProgress, isTrue);
    expect(session()?.isResolvingMerge, isFalse, reason: 'nothing is C');
  });

  test('a repository that will not answer clears the session', () async {
    git.statusFailure = const GitNotARepository('/code/app');
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    expect(
      (container.read(gitReadingProvider) as GitReadingFailed).failure,
      const GitNotARepository('/code/app'),
    );
    expect(session()?.git, isNull);
  });

  test('refresh asks git again and the session follows', () async {
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();
    git.reported = statusOf('main', changed: 3);

    await container.read(gitReadingProvider.notifier).refresh();

    expect(git.asked, 2);
    expect(session()?.git?.entries, hasLength(3));
  });

  test('every reading is news, even one equal to the last', () async {
    // The git column stops being busy on it.
    final List<GitReadingState> heard = <GitReadingState>[];
    container.listen<GitReadingState>(
      gitReadingProvider,
      (GitReadingState? _, GitReadingState next) => heard.add(next),
    );
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    await container.read(gitReadingProvider.notifier).refresh();

    expect(heard.whereType<GitReadingReady>(), hasLength(2));
  });

  test('an answer about the space just left does not land', () async {
    start();
    final Completer<void> slow = Completer<void>();
    git.gate = slow;
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    git
      ..gate = null
      ..reported = statusOf('site-main');
    container.read(spaceSessionProvider.notifier).open(site);
    await settle();
    slow.complete();
    await settle();

    expect(session()?.space, site);
    expect(session()?.git?.branch, BranchNameValueObject('site-main'));
  });

  test('the status and the merge are read as one action', () async {
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    expect(git.actions, <CommandActionEnum?>[
      CommandActionEnum.readRepository,
      CommandActionEnum.readRepository,
    ]);
  });

  group('a reading the person refuses', () {
    test('leaves the last one on the session, and says it is stale', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git
        ..statusFailure = const GitCommandDenied()
        ..reported = statusOf('main', changed: 3);

      await container.read(gitReadingProvider.notifier).refresh();

      expect(container.read(gitReadingProvider), isA<GitReadingStale>());
      expect(session()?.git?.entries, hasLength(1), reason: 'the one before');
    });

    test('with none before it there is none, and it is no failure', () async {
      git.statusFailure = const GitCommandDenied();
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      expect(container.read(gitReadingProvider), isA<GitReadingStale>());
      expect(session()?.git, isNull);
    });

    test('is not asked again until somebody asks', () async {
      git.statusFailure = const GitCommandDenied();
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      await settle();

      expect(git.asked, 1);
    });

    test('Reload asks again, and the reading is whole once more', () async {
      git.statusFailure = const GitCommandDenied();
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.statusFailure = null;

      await container.read(gitReadingProvider.notifier).refresh();

      expect(container.read(gitReadingProvider), isA<GitReadingReady>());
      expect(session()?.git?.branch, BranchNameValueObject('main'));
    });

    test('the merge refused keeps the merge that was known', () async {
      git.merge = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.mergeFailure = const GitCommandDenied();

      await container.read(gitReadingProvider.notifier).refresh();

      expect(container.read(gitReadingProvider), isA<GitReadingStale>());
      expect(session()?.merge?.inProgress, isTrue);
    });
  });

  group('a folder opened before git said where its repository is', () {
    final SpaceEntity folder = SpaceEntity(
      root: docs.root,
      repositoryRoot: null,
      name: 'docs',
    );

    void openFolder() => container
        .read(spaceSessionProvider.notifier)
        .open(folder, locating: true);

    test('shows its folder at once, finds the repository behind it, then '
        'reads it in the same plan', () async {
      locator.found = docs;
      start();
      openFolder();

      expect(session()?.space, folder, reason: 'the files show first');
      expect(container.read(gitReadingProvider), isA<GitReadingLoading>());
      await settle();

      expect(session()?.locatingRepository, isFalse);
      expect(session()?.space, docs);
      expect(container.read(gitReadingProvider), isA<GitReadingReady>());
      expect(git.asked, 1);
      expect(locator.scopes.single, isNotNull);
      expect(
        git.scopes.single,
        same(locator.scopes.single),
        reason: 'opening and its first reading are one plan',
      );
    });

    test('a folder git knows nothing about is never read', () async {
      locator.found = folder;
      start();
      openFolder();
      await settle();

      expect(session()?.locatingRepository, isFalse);
      expect(container.read(gitReadingProvider), isA<GitReadingInitial>());
      expect(git.asked, 0);
    });

    test('a denial keeps the folder, says out of date, and Reload asks '
        'again', () async {
      locator.refusal = const GitCommandDenied();
      start();
      openFolder();
      await settle();

      expect(session()?.space, folder);
      expect(session()?.locatingRepository, isTrue);
      expect(container.read(gitReadingProvider), isA<GitReadingStale>());

      locator
        ..refusal = null
        ..found = docs;
      await container.read(gitReadingProvider.notifier).refresh();
      await settle();

      expect(locator.asked, 2);
      expect(session()?.space, docs);
      expect(container.read(gitReadingProvider), isA<GitReadingReady>());
    });

    test('an older git is a failed reading, the files stay', () async {
      locator.refusal = const GitTooOld('2.30');
      start();
      openFolder();
      await settle();

      expect(container.read(gitReadingProvider), isA<GitReadingFailed>());
      expect(session()?.space, folder);
    });
  });
}

/// Opens nothing itself: the locator is what these tests are about.
final class _NoSpaces implements SpaceRepository {
  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw UnimplementedError();
}

/// Finds a repository the way the test says, noting the plan it asked in.
final class _Locator implements SpaceLocationRepository {
  SpaceEntity? found;
  AppFailure? refusal;
  int asked = 0;
  final List<Object?> scopes = <Object?>[];

  @override
  Future<Result<SpaceEntity, AppFailure>> openFolder(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<SpaceEntity, AppFailure>> locate(SpaceEntity space) async {
    asked++;
    scopes.add(CommandScope.current);
    final AppFailure? refused = refusal;
    return refused != null
        ? Failure<SpaceEntity, AppFailure>(refused)
        : Success<SpaceEntity, AppFailure>(found!);
  }
}

/// The recent list, which these tests never read.
final class _NoRecents implements RecentSpacesRepository {
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

/// Git, answering what the test set and counting the times it was asked.
final class _Git implements GitRepository {
  GitStatusValueObject? reported;
  GitFailure? statusFailure;
  MergeStateValueObject merge = MergeStateValueObject.none;
  GitFailure? mergeFailure;

  /// Holds the next status back until it completes, when set.
  Completer<void>? gate;
  int asked = 0;

  /// The action each question was asked inside, in order.
  final List<CommandActionEnum?> actions = <CommandActionEnum?>[];

  /// The run each status question was asked inside, in order.
  final List<CommandScope?> scopes = <CommandScope?>[];

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async {
    asked++;
    scopes.add(CommandScope.current);
    actions.add(CommandScope.current?.action);
    // Captured now: the answer is the one git had when it was asked.
    final GitStatusValueObject? answer = reported;
    final GitFailure? failure = statusFailure;
    await gate?.future;
    return failure == null
        ? Success<GitStatusValueObject, GitFailure>(answer!)
        : Failure<GitStatusValueObject, GitFailure>(failure);
  }

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async {
    actions.add(CommandScope.current?.action);
    return switch (mergeFailure) {
      final GitFailure failure => Failure<MergeStateValueObject, GitFailure>(
        failure,
      ),
      null => Success<MergeStateValueObject, GitFailure>(merge),
    };
  }

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
