/// [DartIoGitClientImpl] staging and unstaging, at the edges, and the folders
/// it can be pointed at: a conflicted file being resolved, an ignored one, a
/// staged rename or deletion, a bare repository, a worktree, a folder whose
/// own name git could misread.
///
/// A sibling of `dart_io_git_client_impl_test.dart` (decision T3). Git runs
/// under [GitWorld]'s empty configuration.
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_world.dart';

void main() {
  late GitWorld world;
  late DartIoGitClientImpl client;

  setUp(() {
    world = GitWorld()..seed();
    client = world.client();
  });

  tearDown(() => world.dispose());

  String status() => world.git(<String>['status', '--short']).stdout as String;

  group('stage', () {
    test('a path that does not exist fails, and stages nothing', () async {
      world.write('b.md', '# B\n');

      final GitClientFailure failure = failureOf(
        await client.stage(<String>['b.md', 'ghost.md']),
      );

      expect(failure, isA<GitClientCommandFailed>());
      expect(status(), '?? b.md\n', reason: 'git adds all or none of them');
    });

    test('an ignored file fails, and says it is ignored', () async {
      world.write('.gitignore', 'secret.md\n');
      world.write('secret.md', 'x\n');

      final GitClientFailure failure = failureOf(
        await client.stage(<String>['secret.md']),
      );

      expect(failure, isA<GitClientCommandFailed>());
      expect((failure as GitClientCommandFailed).stderr, contains('ignored'));
    });

    test('no path at all is not a failure, and changes nothing', () async {
      world.write('b.md', '# B\n');

      expect(
        await client.stage(<String>[]),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(status(), '?? b.md\n');
    });

    test('a conflicted file being resolved leaves the conflict', () async {
      world.conflict();
      world.write('a.md', '# A, resolved\n');

      expect(
        await client.stage(<String>['a.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(status(), 'M  a.md\n');
    });

    test(
      'a conflicted file still holding markers is staged all the same',
      () async {
        // The refusal is the use case's, which reads the text; git has no
        // opinion, and the client is not the place to grow one.
        world.conflict();

        expect(
          await client.stage(<String>['a.md']),
          isA<Success<void, GitClientFailure>>(),
        );
        expect(
          world.git(<String>['show', ':a.md']).stdout,
          contains('<<<<<<<'),
        );
      },
    );

    test('a deletion of a name with a space is staged', () async {
      world.commitFile('with space.md', 'x\n');
      File('${world.repo}/with space.md').deleteSync();

      await client.stage(<String>['with space.md']);

      expect(status(), 'D  "with space.md"\n');
    });

    test('a file in a folder named like an option', () async {
      world.write('-dir/b.md', '# B\n');

      expect(
        await client.stage(<String>['-dir/b.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(status(), 'A  -dir/b.md\n');
    });
  });

  group('unstage', () {
    test(
      'a staged deletion puts the file back in the index, not on disk',
      () async {
        world.git(<String>['rm', '--quiet', 'a.md']);

        expect(
          await client.unstage(<String>['a.md']),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(status(), ' D a.md\n');
        expect(File('${world.repo}/a.md').existsSync(), isFalse);
      },
    );

    test('a staged rename, given both names, is two loose changes', () async {
      world.git(<String>['mv', 'a.md', 'renamed.md']);

      await client.unstage(<String>['a.md', 'renamed.md']);

      expect(status(), ' D a.md\n?? renamed.md\n');
      expect(world.read('renamed.md'), '# A\n');
    });

    test('a staged rename, given only the new name, leaves the deletion '
        'staged', () async {
      world.git(<String>['mv', 'a.md', 'renamed.md']);

      await client.unstage(<String>['renamed.md']);

      expect(status(), 'D  a.md\n?? renamed.md\n');
    });

    test('an unmerged path is not a failure, and the merge goes on', () async {
      world.conflict();

      final Result<void, GitClientFailure> result = await client.unstage(
        <String>['a.md'],
      );

      expect(result, isA<Success<void, GitClientFailure>>(), reason: '$result');
      expect(valueOf(await client.mergeInProgress()), isTrue);
    });
  });

  group('the folder the client is pointed at', () {
    test('a bare repository has no root to report', () async {
      final String bare = '${world.base}/bare.git';
      world.init(bare, bare: true);

      final GitClientFailure failure = failureOf(
        await world.client(inside: bare).repositoryRoot(),
      );

      expect(failure, isA<GitClientFailure>());
      expect(failure, isNot(isA<GitClientTimedOut>()));
    });

    test('status in a bare repository fails rather than lying', () async {
      final String bare = '${world.base}/bare.git';
      world.init(bare, bare: true);

      expect(
        await world.client(inside: bare).status(),
        isA<Failure<String, GitClientFailure>>(),
      );
    });

    test('a worktree is its own root', () async {
      final String tree = '${world.base}/tree';
      world.git(<String>['worktree', 'add', '--quiet', '-b', 'in-tree', tree]);

      expect(valueOf(await world.client(inside: tree).repositoryRoot()), tree);
    });

    test('a folder with a space and letters outside ASCII is reported as it '
        'is', () async {
      final String odd = '${world.base}/pasta com espaço é';
      world.init(odd);

      expect(valueOf(await world.client(inside: odd).repositoryRoot()), odd);
      expect(valueOf(await world.client(inside: odd).currentBranch()), 'main');
    });

    test('working in it is working: stage, commit and read back', () async {
      final String odd = '${world.base}/日本 語';
      world.init(odd);
      world.write('a.md', '# A\n', inside: odd);
      final DartIoGitClientImpl inOdd = world.client(inside: odd);

      await inOdd.stage(<String>['a.md']);
      await inOdd.commit('First');

      expect(valueOf(await inOdd.show('HEAD', 'a.md')), '# A\n');
    });
  });
}
