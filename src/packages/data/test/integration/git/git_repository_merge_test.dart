/// A merge in progress, seen through [GitRepositoryImpl]: the pull that
/// stops, what `status` and `mergeState` say while it waits, and the three
/// ways out — abort, resolve and commit, or a pull git refuses to start.
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
  late String remote;
  late String work;
  late String colleague;

  setUp(() {
    world = GitWorld();
    // The remote's first commit already holds the files every case
    // disagrees about, in the space (`docs/`) and beside it.
    final String seed = world.init('${world.base}/seed');
    world.write(seed, 'docs/a.md', '# A\n');
    world.write(seed, 'docs/b.md', '# B\n');
    world.write(seed, 'notes/c.md', '# C\n');
    world.commitAll(seed, 'Start');
    remote = '${world.base}/remote.git';
    world.git(<String>[
      'clone',
      '--quiet',
      '--bare',
      seed,
      remote,
    ], inside: world.base);
    work = world.clone(remote, '${world.base}/work');
    colleague = world.colleague(remote);
  });

  tearDown(() => world.dispose());

  /// A colleague's push and a commit of the person's own, disagreeing about
  /// a file each way git can: both edit `docs/a.md`, both add
  /// `docs/new.md`, one deletes `docs/b.md` while the other edits it.
  void disagree() {
    world.write(colleague, 'docs/a.md', '# A, theirs\n');
    world.write(colleague, 'docs/new.md', '# New, theirs\n');
    File('$colleague/docs/b.md').deleteSync();
    world.commitAll(colleague, 'Theirs');
    world.git(<String>['push', '--quiet', 'origin', 'main'], inside: colleague);

    world.write(work, 'docs/a.md', '# A, ours\n');
    world.write(work, 'docs/new.md', '# New, ours\n');
    world.write(work, 'docs/b.md', '# B, ours\n');
    world.commitAll(work, 'Ours');
  }

  for (final String below in const <String>['', 'docs']) {
    group(
      'a pull that stops, the client in ${below.isEmpty ? 'root' : '$below/'}',
      () {
        late GitRepositoryImpl repository;

        setUp(() {
          disagree();
          repository = world.repository(below.isEmpty ? work : '$work/$below');
        });

        test('names the repository paths of the files in conflict', () async {
          final GitFailure failure = failureOf(await repository.pull());

          expect(
            failure,
            isA<GitMergeConflict>().having(
              (GitMergeConflict it) => it.conflictedFiles.toList()..sort(),
              'the files named',
              <String>['docs/a.md', 'docs/b.md', 'docs/new.md'],
            ),
          );
        });

        test('shows every kind of conflict as a conflicted entry', () async {
          await repository.pull();

          final GitStatusValueObject status = valueOf(
            await repository.status(),
          );

          expect(
            status.entries
                .map((StatusEntryValueObject e) => e.path.value)
                .toList()
              ..sort(),
            <String>['docs/a.md', 'docs/b.md', 'docs/new.md'],
          );
          expect(
            status.entries.every(
              (StatusEntryValueObject e) =>
                  e.state == FileStateEnum.conflicted && !e.isStaged,
            ),
            isTrue,
          );
        });

        test('is a merge in progress, with the message git drafted', () async {
          expect(valueOf(await repository.mergeState()).inProgress, isFalse);

          await repository.pull();

          final MergeStateValueObject state = valueOf(
            await repository.mergeState(),
          );
          expect(state.inProgress, isTrue);
          expect(state.message, startsWith('Merge'));
          expect(state.message, isNot(endsWith('\n')));
        });

        test('writes the markers git wrote, the file only', () async {
          await repository.pull();

          final String text = world.read(work, 'docs/a.md');
          expect(text, contains('<<<<<<< HEAD'));
          expect(text, contains('# A, ours'));
          expect(text, contains('# A, theirs'));
          expect(text, contains('>>>>>>> '));
          // add/add leaves both sides in the file; modify/delete keeps ours.
          expect(world.read(work, 'docs/new.md'), contains('<<<<<<<'));
          expect(world.read(work, 'docs/b.md'), '# B, ours\n');
        });

        test('cannot be committed while a path is unmerged', () async {
          await repository.pull();

          final Result<void, GitFailure> result = await repository.commit(
            'Merge, hopefully',
          );

          expect(failureOf(result), isA<GitOperationFailed>());
          expect(
            world.git(<String>['log', '--format=%s', '-1'], inside: work),
            'Ours',
          );
          expect(valueOf(await repository.mergeState()).inProgress, isTrue);
        });

        test('aborts: the tree and the local commit are back', () async {
          await repository.pull();
          world.write(work, 'notes/c.md', '# C, edited meanwhile\n');

          valueOf(await repository.abortMerge());

          expect(valueOf(await repository.mergeState()).inProgress, isFalse);
          expect(world.read(work, 'docs/a.md'), '# A, ours\n');
          expect(world.read(work, 'docs/new.md'), '# New, ours\n');
          expect(world.read(work, 'docs/b.md'), '# B, ours\n');
          // What was typed in a file the merge never touched survives.
          expect(world.read(work, 'notes/c.md'), '# C, edited meanwhile\n');
          expect(valueOf(await repository.history()).first.subject, 'Ours');
          final GitStatusValueObject status = valueOf(
            await repository.status(),
          );
          expect(
            status.entries.map((StatusEntryValueObject e) => e.path.value),
            <String>['notes/c.md'],
          );
        });

        test('is concluded by staging what was resolved and committing, '
            'with two parents', () async {
          await repository.pull();
          world.write(work, 'docs/a.md', '# A, both\n');
          world.write(work, 'docs/new.md', '# New, both\n');
          // Keeping the file modify/delete left on disk is the resolution.
          valueOf(
            await repository.stage(<RepoRelativePathValueObject>[
              rel('docs/a.md'),
              rel('docs/b.md'),
              rel('docs/new.md'),
            ]),
          );
          final String draft = valueOf(await repository.mergeState()).message;

          valueOf(await repository.commit(draft));

          expect(valueOf(await repository.mergeState()).inProgress, isFalse);
          expect(valueOf(await repository.status()).isClean, isTrue);
          final List<String> parents = world
              .git(<String>[
                'rev-list',
                '--parents',
                '-n',
                '1',
                'HEAD',
              ], inside: work)
              .split(' ');
          expect(parents, hasLength(3));
          expect(
            world.git(<String>['show', 'HEAD:docs/a.md'], inside: work),
            '# A, both',
          );
          expect(
            valueOf(await repository.history()).first.subject,
            startsWith('Merge'),
          );
        });

        test(
          'keeps committing refused until the last path is staged',
          () async {
            await repository.pull();
            valueOf(
              await repository.stage(<RepoRelativePathValueObject>[
                rel('docs/b.md'),
                rel('docs/a.md'),
              ]),
            );

            final Result<void, GitFailure> result = await repository.commit(
              'Almost',
            );

            expect(failureOf(result), isA<GitOperationFailed>());
            expect(valueOf(await repository.mergeState()).inProgress, isTrue);
          },
        );
      },
    );
  }

  group('a pull git refuses to start', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository('$work/docs'));

    test('over a tracked edit it would overwrite, names the path and '
        'leaves the edit', () async {
      world.write(colleague, 'docs/a.md', '# A, theirs\n');
      world.commitAll(colleague, 'Theirs');
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main',
      ], inside: colleague);
      world.write(work, 'docs/a.md', '# A, typed here\n');

      final GitFailure failure = failureOf(await repository.pull());

      expect(
        failure,
        isA<GitLocalChangesOverwritten>().having(
          (GitLocalChangesOverwritten it) => it.paths,
          'the files named',
          <String>['docs/a.md'],
        ),
      );
      expect(world.read(work, 'docs/a.md'), '# A, typed here\n');
      expect(valueOf(await repository.mergeState()).inProgress, isFalse);
    });

    test('over an untracked file it would overwrite, names the path and '
        'leaves the file', () async {
      world.write(colleague, 'docs/new.md', '# New, theirs\n');
      world.commitAll(colleague, 'Theirs');
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main',
      ], inside: colleague);
      world.write(work, 'docs/new.md', '# New, typed here\n');

      final GitFailure failure = failureOf(await repository.pull());

      expect(
        failure,
        isA<GitLocalChangesOverwritten>().having(
          (GitLocalChangesOverwritten it) => it.paths,
          'the files named',
          <String>['docs/new.md'],
        ),
      );
      expect(world.read(work, 'docs/new.md'), '# New, typed here\n');
    });

    test('names several files at once', () async {
      world.write(colleague, 'docs/a.md', '# A, theirs\n');
      world.write(colleague, 'notes/c.md', '# C, theirs\n');
      world.commitAll(colleague, 'Theirs');
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main',
      ], inside: colleague);
      world.write(work, 'docs/a.md', '# A, typed\n');
      world.write(work, 'notes/c.md', '# C, typed\n');

      final GitFailure failure = failureOf(await repository.pull());

      expect(
        (failure as GitLocalChangesOverwritten).paths.toList()..sort(),
        <String>['docs/a.md', 'notes/c.md'],
      );
    });
  });

  group('in a worktree', () {
    late String wt;
    late GitRepositoryImpl repository;

    setUp(() {
      // A branch that tracks the remote's, in a folder of its own.
      world.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        '${world.base}/wt',
        'origin/main',
      ], inside: work);
      wt = '${world.base}/wt';
      repository = world.repository('$wt/docs');
    });

    test('a pull refused over local work names the path', () async {
      world.write(colleague, 'docs/a.md', '# A, theirs\n');
      world.commitAll(colleague, 'Theirs');
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main',
      ], inside: colleague);
      world.write(wt, 'docs/a.md', '# A, typed in the worktree\n');

      final GitFailure failure = failureOf(await repository.pull());

      expect(failure, isA<GitLocalChangesOverwritten>());
      expect((failure as GitLocalChangesOverwritten).paths, <String>[
        'docs/a.md',
      ]);
    });

    test('a conflicting pull leaves a merge in progress, with its message, '
        'and it aborts', () async {
      world.write(colleague, 'docs/a.md', '# A, theirs\n');
      world.commitAll(colleague, 'Theirs');
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main',
      ], inside: colleague);
      world.commitFile(wt, 'docs/a.md', '# A, the worktree\n');

      expect(failureOf(await repository.pull()), isA<GitMergeConflict>());

      final MergeStateValueObject state = valueOf(
        await repository.mergeState(),
      );
      expect(state.inProgress, isTrue);
      expect(state.message, startsWith('Merge'));
      valueOf(await repository.abortMerge());
      expect(valueOf(await repository.mergeState()).inProgress, isFalse);
      expect(world.read(wt, 'docs/a.md'), '# A, the worktree\n');
    });
  });
}
