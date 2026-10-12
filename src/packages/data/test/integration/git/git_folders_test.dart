/// The folders a person points TOM at, in every shape git keeps them: a
/// worktree, a bare repository, a clone into a folder that was waiting, a
/// remote with nothing in it — read through the space, clone and recent
/// branch repositories.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late _Observability observability;

  setUp(() {
    world = GitWorld();
    observability = _Observability();
  });

  tearDown(() => world.dispose());

  SpaceRepositoryImpl spaces() => SpaceRepositoryImpl(
    spaces: SpaceDataSource(
      filesystem: const DartIoFilesystemImpl(),
      gitClientFor: (String folder) => world.client(folder),
    ),
  );

  GitCloneRepositoryImpl cloner({
    Duration networkTimeout = const Duration(seconds: 30),
  }) => GitCloneRepositoryImpl(
    git: GitCloneDataSource(
      gitClientFor: (String folder) =>
          world.client(folder, networkTimeout: networkTimeout),
      filesystem: const DartIoFilesystemImpl(),
    ),
  );

  RecentBranchRepositoryImpl recent({String? executable, Duration? timeout}) =>
      RecentBranchRepositoryImpl(
        branches: RecentBranchDataSource(
          gitClientFor: (String folder) => world.client(
            folder,
            executable: executable,
            timeout: timeout ?? const Duration(seconds: 30),
          ),
        ),
        observability: observability,
      );

  Future<BranchNameValueObject?> branchOf(
    RecentBranchRepositoryImpl repository,
    String folder,
  ) async => valueOf(
    await repository.branchOf(
      RecentSpaceEntity(
        root: folder,
        name: 'docs',
        lastOpened: DateTime.utc(2026, 10, 10),
      ),
    ),
  );

  group('a worktree picked as the folder', () {
    late String repo;
    late String wt;

    setUp(() {
      repo = world.init('${world.base}/repo');
      world.commitFile(repo, 'docs/a.md', '# A\n');
      wt = '${world.base}/wt';
      world.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        wt,
      ], inside: repo);
    });

    test('is a space whose repository is the worktree', () async {
      final SpaceEntity space = valueOf(await spaces().open(wt));

      expect(space.root, wt);
      expect(space.repositoryRoot, wt);
      expect(space.hasRepository, isTrue);
    });

    test('a folder below it keeps its place in the worktree', () async {
      final SpaceEntity space = valueOf(await spaces().open('$wt/docs'));

      expect(space.repositoryRoot, wt);
      expect(space.rootWithinRepository?.value, 'docs');
    });

    test('its branch is the one the worktree is on', () async {
      expect(
        await branchOf(recent(), '$wt/docs'),
        BranchNameValueObject('feat/wt'),
      );
      expect(await branchOf(recent(), repo), BranchNameValueObject('main'));
    });
  });

  group('a bare repository picked as the folder', () {
    late String bare;

    setUp(() {
      final ({String remote, String work}) made = world.remoteWithClone();
      bare = made.remote;
    });

    // A folder with no working tree is, to TOM, a folder outside any
    // repository (`without-a-repository/doc.md`): it opens, git unasked.
    test('opens as a space with no repository to work in', () async {
      final SpaceEntity space = valueOf(await spaces().open(bare));

      expect(space.root, bare);
      expect(space.hasRepository, isFalse);
    });
  });

  group('cloning into', () {
    late String remote;

    setUp(() => remote = world.remoteWithClone().remote);

    test('a folder that was waiting empty fills it', () async {
      Directory('${world.base}/docs').createSync();

      final Result<void, GitFailure> cloned = await cloner().clone(
        url: 'file://$remote',
        destination: '${world.base}/docs',
      );

      expect(cloned, isA<Success<void, GitFailure>>());
      expect(world.read('${world.base}/docs', 'index.md'), '# Index\n');
      expect(Directory('${world.base}/docs/.git').existsSync(), isTrue);
    });

    test('a folder whose name holds spaces and accents', () async {
      final String destination = '${world.base}/my docs é/clone here';

      final Result<void, GitFailure> cloned = await cloner().clone(
        url: 'file://$remote',
        destination: destination,
      );

      expect(cloned, isA<Success<void, GitFailure>>());
      final SpaceEntity space = valueOf(await spaces().open(destination));
      expect(space.repositoryRoot, destination);
    });

    test('a path that is a file is a taken destination, and the file is '
        'untouched', () async {
      File('${world.base}/docs').writeAsStringSync('mine');

      final Result<void, GitFailure> cloned = await cloner().clone(
        url: 'file://$remote',
        destination: '${world.base}/docs',
      );

      expect(
        failureOf(cloned),
        anyOf(isA<GitCloneDestinationTaken>(), isA<GitOperationFailed>()),
      );
      expect(File('${world.base}/docs').readAsStringSync(), 'mine');
    });

    test('a remote with nothing in it clones, opens, and has a branch to '
        'name', () async {
      final String empty = world.bare('${world.base}/empty.git');

      final Result<void, GitFailure> cloned = await cloner().clone(
        url: 'file://$empty',
        destination: '${world.base}/docs',
      );

      expect(cloned, isA<Success<void, GitFailure>>());
      final SpaceEntity space = valueOf(
        await spaces().open('${world.base}/docs'),
      );
      expect(space.hasRepository, isTrue);
      expect(
        await branchOf(recent(), '${world.base}/docs'),
        BranchNameValueObject('main'),
      );
    });

    test('then opened and remembered by its branch: the whole chain', () async {
      final Result<void, GitFailure> cloned = await cloner().clone(
        url: 'file://$remote',
        destination: '${world.base}/docs',
      );
      valueOf(cloned);

      final SpaceEntity space = valueOf(
        await spaces().open('${world.base}/docs'),
      );

      expect(space.name, 'docs');
      expect(space.repositoryRoot, space.root);
      expect(
        await branchOf(recent(), space.root),
        BranchNameValueObject('main'),
      );
    });
  });

  group('a recent entry\'s branch when git does not answer', () {
    test('a git that hangs is recorded and the branch is none', () async {
      final String repo = world.init('${world.base}/repo');
      world.commitFile(repo, 'a.md', '# A\n');
      final String hanging = world.fakeGit('git-slow', 'exec sleep 30');

      final BranchNameValueObject? named = await branchOf(
        recent(executable: hanging, timeout: const Duration(seconds: 1)),
        repo,
      );

      expect(named, isNull);
      expect(observability.captured, hasLength(1));
      expect(observability.captured.single, isA<GitClientTimedOut>());
    });

    test('a git that is not installed is recorded and the branch is '
        'none', () async {
      final String repo = world.init('${world.base}/repo');

      final BranchNameValueObject? named = await branchOf(
        recent(executable: '${world.base}/bin/no-such-git'),
        repo,
      );

      expect(named, isNull);
      expect(observability.captured.single, isA<GitClientExecutableNotFound>());
    });
  });
}

final class _Observability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
