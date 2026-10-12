/// Discarding through [GitRepositoryImpl], from a row a real `status` read:
/// the chain the list walks — row, [DiscardKindEnum.of], the command — over a
/// real repository, with the space at its root and below it.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late String repo;

  setUp(() {
    world = GitWorld();
    repo = world.init('${world.base}/repo');
  });

  tearDown(() => world.dispose());

  /// The committed files every group starts from: two in the space, one
  /// beside it, and three with names a path can trip on.
  void commitBase() {
    world.write(repo, 'docs/a.md', '# A\n');
    world.write(repo, 'docs/b.md', '# B\n');
    world.write(repo, 'notes/c.md', '# C\n');
    world.write(repo, 'docs/my notes.md', '# Spaced\n');
    world.write(repo, 'docs/versão é.md', '# Unicode\n');
    world.write(repo, 'docs/-dash.md', '# Dash\n');
    world.commitAll(repo, 'Start');
  }

  /// Reads the status, finds [path], and discards the row the way the list
  /// does: the kind from the row, a rename with its old name.
  Future<Result<void, GitFailure>> discardRow(
    GitRepositoryImpl repository,
    String path,
  ) async {
    final StatusEntryValueObject row = valueOf(
      await repository.status(),
    ).entries.firstWhere((StatusEntryValueObject e) => e.path.value == path);
    return repository.discard(
      DiscardKindEnum.of(row)!,
      <RepoRelativePathValueObject>[row.path, ?row.previousPath],
    );
  }

  /// Everything git lists, as `path` strings, sorted.
  List<String> listed(GitStatusValueObject status) =>
      status.entries.map((StatusEntryValueObject e) => e.path.value).toList()
        ..sort();

  // Once at the root and once from the space below it: the paths are
  // always the repository's, wherever the client runs.
  for (final String below in const <String>['', 'docs']) {
    group(
      'a row put back, the client in ${below.isEmpty ? 'the root' : '$below/'}',
      () {
        late GitRepositoryImpl repository;

        setUp(() {
          commitBase();
          repository = world.repository(below.isEmpty ? repo : '$repo/$below');
        });

        test('an edit not staged goes back to the index', () async {
          world.write(repo, 'docs/a.md', '# A, edited\n');

          valueOf(await discardRow(repository, 'docs/a.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('an edit not staged keeps what is staged', () async {
          world.write(repo, 'docs/a.md', '# A, staged\n');
          world.git(<String>['add', 'docs/a.md'], inside: repo);
          world.write(repo, 'docs/b.md', '# B, edited\n');

          valueOf(
            await repository.discard(
              DiscardKindEnum.toStaged,
              <RepoRelativePathValueObject>[rel('docs/b.md')],
            ),
          );

          expect(world.read(repo, 'docs/b.md'), '# B\n');
          expect(world.read(repo, 'docs/a.md'), '# A, staged\n');
          expect(listed(valueOf(await repository.status())), <String>[
            'docs/a.md',
          ]);
        });

        test('a staged edit goes back to the last commit', () async {
          world.write(repo, 'docs/a.md', '# A, staged\n');
          world.git(<String>['add', 'docs/a.md'], inside: repo);

          valueOf(await discardRow(repository, 'docs/a.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a staged edit edited again goes back whole', () async {
          world.write(repo, 'docs/a.md', '# A, staged\n');
          world.git(<String>['add', 'docs/a.md'], inside: repo);
          world.write(repo, 'docs/a.md', '# A, staged and typed since\n');

          valueOf(await discardRow(repository, 'docs/a.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a file deleted from the disk returns', () async {
          File('$repo/docs/a.md').deleteSync();

          valueOf(await discardRow(repository, 'docs/a.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a deletion staged returns, and is unstaged', () async {
          world.git(<String>['rm', '--quiet', 'docs/a.md'], inside: repo);

          valueOf(await discardRow(repository, 'docs/a.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a file git never had is deleted, its neighbour kept', () async {
          world.write(repo, 'docs/new/draft.md', '# Draft\n');
          world.write(repo, 'docs/new/kept.md', '# Kept\n');

          valueOf(await discardRow(repository, 'docs/new/draft.md'));

          expect(File('$repo/docs/new/draft.md').existsSync(), isFalse);
          expect(world.read(repo, 'docs/new/kept.md'), '# Kept\n');
          expect(listed(valueOf(await repository.status())), <String>[
            'docs/new/kept.md',
          ]);
        });

        test(
          'a file staged for the first time is deleted and unstaged',
          () async {
            world.write(repo, 'docs/fresh.md', '# Fresh\n');
            world.git(<String>['add', 'docs/fresh.md'], inside: repo);

            valueOf(await discardRow(repository, 'docs/fresh.md'));

            expect(File('$repo/docs/fresh.md').existsSync(), isFalse);
            expect(valueOf(await repository.status()).isClean, isTrue);
          },
        );

        test('a file staged and then edited is deleted all the same', () async {
          world.write(repo, 'docs/fresh.md', '# Fresh\n');
          world.git(<String>['add', 'docs/fresh.md'], inside: repo);
          world.write(repo, 'docs/fresh.md', '# Fresh, typed since\n');

          valueOf(await discardRow(repository, 'docs/fresh.md'));

          expect(File('$repo/docs/fresh.md').existsSync(), isFalse);
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a rename comes back as its old name, the new one gone', () async {
          world.git(<String>[
            'mv',
            'docs/a.md',
            'docs/renamed.md',
          ], inside: repo);
          final StatusEntryValueObject row = valueOf(
            await repository.status(),
          ).entries.single;
          expect(row.state, FileStateEnum.renamed);
          expect(row.previousPath, rel('docs/a.md'));

          valueOf(await discardRow(repository, 'docs/renamed.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(File('$repo/docs/renamed.md').existsSync(), isFalse);
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a rename edited since comes back whole', () async {
          world.git(<String>[
            'mv',
            'docs/a.md',
            'docs/renamed.md',
          ], inside: repo);
          world.write(repo, 'docs/renamed.md', '# A, and then some\n');

          valueOf(await discardRow(repository, 'docs/renamed.md'));

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(File('$repo/docs/renamed.md').existsSync(), isFalse);
          expect(valueOf(await repository.status()).isClean, isTrue);
        });

        test('a file beside the space is put back too', () async {
          world.write(repo, 'notes/c.md', '# C, edited\n');

          valueOf(await discardRow(repository, 'notes/c.md'));

          expect(world.read(repo, 'notes/c.md'), '# C\n');
        });

        for (final String name in const <String>[
          'docs/my notes.md',
          'docs/versão é.md',
          'docs/-dash.md',
        ]) {
          test('$name goes back and a neighbour is left as it is', () async {
            world.write(repo, name, '# Edited\n');
            world.write(repo, 'docs/b.md', '# B, mine\n');

            valueOf(await discardRow(repository, name));

            expect(world.read(repo, name), isNot('# Edited\n'));
            expect(world.read(repo, 'docs/b.md'), '# B, mine\n');
            expect(listed(valueOf(await repository.status())), <String>[
              'docs/b.md',
            ]);
          });
        }

        test('every kind leaves the other files alone', () async {
          world.write(repo, 'docs/a.md', '# A, edited\n');
          world.write(repo, 'docs/b.md', '# B, edited\n');
          world.write(repo, 'docs/loose.md', '# Loose\n');

          valueOf(await discardRow(repository, 'docs/a.md'));
          valueOf(await discardRow(repository, 'docs/loose.md'));

          expect(world.read(repo, 'docs/b.md'), '# B, edited\n');
          expect(listed(valueOf(await repository.status())), <String>[
            'docs/b.md',
          ]);
        });

        test('everything, in one go: edits and deletions back, new files '
            'kept', () async {
          world.write(repo, 'docs/a.md', '# A, edited\n');
          File('$repo/docs/b.md').deleteSync();
          world.write(repo, 'docs/loose.md', '# Loose\n');
          world.write(repo, 'docs/staged-new.md', '# Staged new\n');
          world.git(<String>['add', 'docs/staged-new.md'], inside: repo);

          valueOf(await repository.discardAll());

          expect(world.read(repo, 'docs/a.md'), '# A\n');
          expect(world.read(repo, 'docs/b.md'), '# B\n');
          expect(world.read(repo, 'docs/loose.md'), '# Loose\n');
          // An added file comes back untracked, with its content.
          expect(world.read(repo, 'docs/staged-new.md'), '# Staged new\n');
          final GitStatusValueObject status = valueOf(
            await repository.status(),
          );
          expect(listed(status), <String>[
            'docs/loose.md',
            'docs/staged-new.md',
          ]);
          expect(
            status.entries.every((StatusEntryValueObject e) => !e.isStaged),
            isTrue,
          );
        });
      },
    );
  }

  group('a conflicted row', () {
    late GitRepositoryImpl repository;

    setUp(() {
      commitBase();
      world.git(<String>['switch', '--quiet', '-c', 'other'], inside: repo);
      world.commitFile(repo, 'docs/a.md', '# A, theirs\n');
      world.git(<String>['switch', '--quiet', 'main'], inside: repo);
      world.commitFile(repo, 'docs/a.md', '# A, ours\n');
      expect(world.run(<String>['merge', 'other'], inside: repo).exitCode, 1);
      repository = world.repository('$repo/docs');
    });

    test('has no way to be discarded', () async {
      final StatusEntryValueObject row = valueOf(
        await repository.status(),
      ).entries.single;

      expect(row.state, FileStateEnum.conflicted);
      expect(DiscardKindEnum.of(row), isNull);
    });

    // Decision 22 (#29): `Discard all changes` is neither offered nor
    // accepted mid-merge. Today the use case passes straight through.
    test(
      'discarding everything is refused, and the merge is still there',
      () async {
        final Result<void, GitFailure> result = await repository.discardAll();

        expect(result, isA<Failure<void, GitFailure>>());
        expect(valueOf(await repository.mergeState()).inProgress, isTrue);
        expect(world.read(repo, 'docs/a.md'), contains('<<<<<<<'));
      },
    );
  });

  group('before the first commit', () {
    late GitRepositoryImpl repository;

    setUp(() {
      world.write(repo, 'docs/a.md', '# A\n');
      world.git(<String>['add', 'docs/a.md'], inside: repo);
      repository = world.repository('$repo/docs');
    });

    test('a staged file is deleted from its row', () async {
      valueOf(await discardRow(repository, 'docs/a.md'));

      expect(File('$repo/docs/a.md').existsSync(), isFalse);
      expect(valueOf(await repository.status()).isClean, isTrue);
    });

    // Decision 22 (#29): not accepted before the first commit. Intended:
    // a failure that has touched nothing.
    test(
      'discarding everything fails without having unstaged anything',
      () async {
        final Result<void, GitFailure> result = await repository.discardAll();

        expect(result, isA<Failure<void, GitFailure>>());
        expect(
          valueOf(await repository.status()).entries.single.isStaged,
          isTrue,
        );
        expect(world.read(repo, 'docs/a.md'), '# A\n');
      },
    );
  });
}
