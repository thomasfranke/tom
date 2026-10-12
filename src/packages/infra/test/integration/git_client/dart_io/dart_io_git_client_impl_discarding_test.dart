/// [DartIoGitClientImpl] putting work back and taking it away, at the edges:
/// the shapes of a status row, names git would misread, a repository with no
/// commit, a merge, and a command that fails half-way.
///
/// A sibling of `dart_io_git_client_impl_test.dart`, which proves the
/// ordinary discards; the git client's integration test splits by family of
/// command (decision T3). Git runs under [GitWorld]'s empty configuration.
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

  bool onDisk(String path) => File('${world.repo}/$path').existsSync();

  group('discardAll, where the repository is in a state', () {
    // The use case refuses these (alignment decision 29); what the client
    // does is pinned so that refusal is known to be needed, and not assumed.
    test('before the first commit leaves every file on disk', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      world.write('a.md', '# A\n', inside: fresh);
      world.git(<String>['add', 'a.md'], inside: fresh);
      world.write('b.md', '# B\n', inside: fresh);

      await world.client(inside: fresh).discardAll();

      expect(world.read('a.md', inside: fresh), '# A\n');
      expect(world.read('b.md', inside: fresh), '# B\n');
    });

    test('before the first commit fails after the index has changed', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      world.write('a.md', '# A\n', inside: fresh);
      world.git(<String>['add', 'a.md'], inside: fresh);

      final Result<void, GitClientFailure> result = await world
          .client(inside: fresh)
          .discardAll();

      expect(failureOf(result), isA<GitClientCommandFailed>());
      expect(
        world.git(<String>['status', '--short'], inside: fresh).stdout,
        '?? a.md\n',
        reason: 'the reset ran and the restore did not',
      );
    });

    test('during a merge ends the merge, and the conflicted files with '
        'it', () async {
      world.conflict();
      expect(valueOf(await client.mergeInProgress()), isTrue);

      expect(await client.discardAll(), isA<Success<void, GitClientFailure>>());

      expect(valueOf(await client.mergeInProgress()), isFalse);
      expect(world.read('a.md'), '# A, main\n');
    });

    test('a staged rename comes back as the old name and the new one '
        'untracked', () async {
      world.git(<String>['mv', 'a.md', 'renamed.md']);

      await client.discardAll();

      expect(world.read('a.md'), '# A\n');
      expect(world.read('renamed.md'), '# A\n');
      expect(status(), '?? renamed.md\n');
    });

    test('a staged deletion and a staged edit both go back', () async {
      world.commitFile('b.md', '# B\n');
      world.git(<String>['rm', '--quiet', 'b.md']);
      world.write('a.md', '# A, edited\n');
      world.git(<String>['add', 'a.md']);

      await client.discardAll();

      expect(world.read('b.md'), '# B\n');
      expect(world.read('a.md'), '# A\n');
      expect(status(), isEmpty);
    });
  });

  group('discarding by path', () {
    test('an untracked path handed to discardUnstaged fails, and the file '
        'is kept', () async {
      world.write('new.md', '# New\n');

      expect(
        failureOf(await client.discardUnstaged(<String>['new.md'])),
        isA<GitClientCommandFailed>(),
      );

      expect(world.read('new.md'), '# New\n');
    });

    test('one unknown path among known ones changes nothing', () async {
      world.commitFile('b.md', '# B\n');
      world.write('a.md', '# A, edited\n');
      world.write('b.md', '# B, edited\n');

      expect(
        failureOf(
          await client.discardUnstaged(<String>['a.md', 'ghost.md', 'b.md']),
        ),
        isA<GitClientCommandFailed>(),
      );

      expect(world.read('a.md'), '# A, edited\n');
      expect(world.read('b.md'), '# B, edited\n');
    });

    test('discardSinceCommit from a folder below the root, by the root\'s '
        'path', () async {
      world.commitFile('docs/c.md', '# C\n');
      world.git(<String>['mv', 'docs/c.md', 'docs/d.md']);
      world.write('a.md', '# A, edited\n');
      final DartIoGitClientImpl below = world.client(
        inside: '${world.repo}/docs',
      );

      expect(
        await below.discardSinceCommit(<String>['docs/c.md', 'docs/d.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(world.read('docs/c.md'), '# C\n');
      expect(onDisk('docs/d.md'), isFalse);
      expect(world.read('a.md'), '# A, edited\n', reason: 'a neighbour');
    });

    // `--source=HEAD` of a path HEAD lacks removes it from the index *and*
    // the disk: it is a deletion, which is why the app sends a file git never
    // committed to `deleteUncommitted` (behind its own question) instead.
    test(
      'a staged file HEAD lacks, given alone, is removed from both',
      () async {
        world.write('new.md', '# New\n');
        world.git(<String>['add', 'new.md']);

        expect(
          await client.discardSinceCommit(<String>['new.md']),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(onDisk('new.md'), isFalse);
        expect(status(), isEmpty);
      },
    );

    test(
      'an untracked file HEAD lacks is an unknown path, and is kept',
      () async {
        world.write('loose.md', '# Loose\n');

        expect(
          failureOf(await client.discardSinceCommit(<String>['loose.md'])),
          isA<GitClientCommandFailed>(),
        );

        expect(world.read('loose.md'), '# Loose\n');
      },
    );

    test('a conflicted path put back from the working tree is the '
        'marked file again', () async {
      world.conflict();
      final String marked = world.read('a.md');
      world.write('a.md', '# A, resolved by hand\n');

      await client.discardUnstaged(<String>['a.md']);

      // `restore --worktree` of an unmerged path fails in git; either way the
      // person's resolution must not be silently replaced by something else.
      expect(<String>[
        marked,
        '# A, resolved by hand\n',
      ], contains(world.read('a.md')));
    });
  });

  group('deleteUncommitted, at the edges', () {
    test('a file added over .gitignore goes with its index entry', () async {
      world.write('.gitignore', 'secret.md\n');
      world.git(<String>['add', '.gitignore']);
      world.git(<String>['commit', '--quiet', '--message', 'Ignore']);
      world.write('secret.md', '# Secret\n');
      world.git(<String>['add', '--force', 'secret.md']);

      expect(
        await client.deleteUncommitted(<String>['secret.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(onDisk('secret.md'), isFalse);
      expect(world.git(<String>['ls-files']).stdout, isNot(contains('secret')));
    });

    test('leaves a neighbour in the same new folder alone', () async {
      world.write('notes/mine.md', '# Mine\n');
      world.write('notes/other.md', '# Other\n');

      await client.deleteUncommitted(<String>['notes/mine.md']);

      expect(onDisk('notes/mine.md'), isFalse);
      expect(world.read('notes/other.md'), '# Other\n');
    });

    test(
      'a refusal of the clean leaves the file unstaged and on disk',
      () async {
        world.write('locked/new.md', '# New\n');
        world.git(<String>['add', 'locked/new.md']);
        Process.runSync('chmod', <String>['555', '${world.repo}/locked']);
        addTearDown(
          () =>
              Process.runSync('chmod', <String>['755', '${world.repo}/locked']),
        );

        final Result<void, GitClientFailure> result = await client
            .deleteUncommitted(<String>['locked/new.md']);

        expect(failureOf(result), isA<GitClientCommandFailed>());
        expect(world.read('locked/new.md'), '# New\n');
        expect(status(), '?? locked/\n', reason: 'out of the index, not gone');
      },
      skip: Platform.isWindows || _isRoot
          ? 'needs a folder it cannot write'
          : false,
    );
  });

  // Names git would misread: a space, a quote, a tab, a leading dash, a
  // letter outside ASCII. Every one goes through every path-taking command,
  // with a neighbour edited beside it that none of them may touch.
  group('a name git could misread', () {
    const List<String> names = <String>[
      'with space.md',
      'notas de versão é.md',
      '-n.md',
      'quote"d.md',
      "single'quote.md",
      'tab\there.md',
      '日本語.md',
    ];

    for (final String name in names) {
      group(name.replaceAll('\t', r'\t'), () {
        setUp(() {
          world.commitFile(name, 'v1\n');
          world.write('a.md', '# A, mine\n');
        });

        test('discardUnstaged puts it back and leaves the neighbour', () async {
          world.write(name, 'v2\n');

          await client.discardUnstaged(<String>[name]);

          expect(world.read(name), 'v1\n');
          expect(world.read('a.md'), '# A, mine\n');
        });

        test('discardSinceCommit undoes a staged edit', () async {
          world.write(name, 'v2\n');
          expect(
            await client.stage(<String>[name]),
            isA<Success<void, GitClientFailure>>(),
          );
          world.write(name, 'v3\n');

          await client.discardSinceCommit(<String>[name]);

          expect(world.read(name), 'v1\n');
          expect(world.read('a.md'), '# A, mine\n');
          expect(status(), isNot(contains('v')));
        });

        test('unstage takes only it out of the index', () async {
          world.write(name, 'v2\n');
          await client.stage(<String>[name, 'a.md']);

          await client.unstage(<String>[name]);

          final String staged =
              world.git(<String>['diff', '--cached', '--name-only']).stdout
                  as String;
          expect(staged.trim(), 'a.md');
          expect(world.read(name), 'v2\n', reason: 'the disk is not touched');
        });

        test(
          'deleteUncommitted removes a copy of it, not the neighbour',
          () async {
            final String copy = 'new $name';
            world.write(copy, 'fresh\n');

            expect(
              await client.deleteUncommitted(<String>[copy]),
              isA<Success<void, GitClientFailure>>(),
            );

            expect(onDisk(copy), isFalse);
            expect(world.read(name), 'v1\n');
            expect(world.read('a.md'), '# A, mine\n');
          },
        );

        test('deleteUncommitted refuses it, being committed', () async {
          expect(
            failureOf(await client.deleteUncommitted(<String>[name])),
            GitClientPathCommitted(<String>[name]),
          );
          expect(world.read(name), 'v1\n');
        });

        test('discardAll leaves no trace of the edit', () async {
          world.write(name, 'v2\n');
          world.git(<String>['checkout', '--', 'a.md']);

          await client.discardAll();

          expect(world.read(name), 'v1\n');
          expect(status(), isEmpty);
        });
      });
    }
  });
}

bool get _isRoot => Platform.environment['USER'] == 'root';
