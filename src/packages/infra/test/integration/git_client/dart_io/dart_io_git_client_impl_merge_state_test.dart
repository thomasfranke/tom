/// [DartIoGitClientImpl] while a repository sits mid-merge — and while it
/// sits mid-something-else the client does not call a merge.
@TestOn('!windows')
library;

// Arranging a repository is a list of commands, not one object configured.
// ignore_for_file: cascade_invocations

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_remote_world.dart';

void main() {
  late GitRemoteWorld world;
  late String remote;
  late String work;
  late String docs;
  late DartIoGitClientImpl client;

  AppFailure failureOf(Result<Object?, GitClientFailure> result) {
    expect(
      result,
      isA<Failure<Object?, GitClientFailure>>(),
      reason: '$result',
    );
    return (result as Failure<Object?, GitClientFailure>).failure;
  }

  T valueOf<T>(Result<T, GitClientFailure> result) {
    expect(result, isA<Success<T, GitClientFailure>>(), reason: '$result');
    return (result as Success<T, GitClientFailure>).value;
  }

  /// What git itself lists as unmerged: the name of every index entry above
  /// stage 0, which is a different question from the client's own.
  List<String> unmerged(String repository) =>
      world
          .say(<String>['ls-files', '--unmerged'], inside: repository)
          .split('\n')
          .where((String line) => line.isNotEmpty)
          .map((String line) => line.split('\t').last)
          .toSet()
          .toList()
        ..sort();

  /// A peer commits [change] in its own copy and pushes it.
  void peerPushes(String message, void Function(String peer) change) {
    final String peer = world.peerOf(remote, '${world.base}/peer');
    change(peer);
    world.commitAll(peer, message);
    world.git(<String>['push', '--quiet'], inside: peer);
  }

  /// A local commit that edits `docs/a.md`, and the peer's edit of the same
  /// line pushed first: the pull between them conflicts.
  void divergeOnTheDocument() {
    peerPushes(
      'Peer edits A',
      (String peer) => world.write(peer, 'docs/a.md', '# A by the peer\n'),
    );
    world.write(work, 'docs/a.md', '# A by me\n');
    world.commitAll(work, 'Edit A');
  }

  setUp(() {
    world = GitRemoteWorld();
    work = '${world.base}/work';
    docs = '$work/docs';
    remote = world.remoteWithClone(work, file: 'docs/a.md');
    world.write(work, 'root.md', '# Root\n');
    world.write(work, 'notes.md', '# Notes\n');
    world.commitAll(work, 'Add the others');
    world.git(<String>['push', '--quiet'], inside: work);
    // The client lives in a space below the repository's root.
    client = world.clientIn(docs);
  });

  tearDown(() {
    world.dispose();
  });

  group('mergeMessage and mergeInProgress', () {
    test('from a folder below the root, git\'s draft is found', () async {
      divergeOnTheDocument();
      expect(await client.pull(), isA<Failure<void, GitClientFailure>>());

      expect(valueOf(await client.mergeInProgress()), isTrue);
      final String message = valueOf(await client.mergeMessage());
      expect(message, startsWith("Merge branch 'main'"));
      expect(message, File('$work/.git/MERGE_MSG').readAsStringSync());
    });

    test('inside a worktree the message is that worktree\'s own', () async {
      final String tree = '${world.base}/tree';
      world.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'other',
        tree,
        'HEAD~1',
      ], inside: work);
      world.identify(tree);
      world.write(tree, 'docs/a.md', '# A on the worktree\n');
      world.commitAll(tree, 'Edit A there');
      world.write(work, 'docs/a.md', '# A on main\n');
      world.commitAll(work, 'Edit A here');
      world.git(<String>['merge', 'main'], inside: tree, mayFail: true);
      final DartIoGitClientImpl inTree = world.clientIn('$tree/docs');

      expect(valueOf(await inTree.mergeInProgress()), isTrue);
      expect(valueOf(await inTree.mergeMessage()), startsWith('Merge branch'));
      // The first checkout is not merging, and says so.
      expect(valueOf(await client.mergeInProgress()), isFalse);
      expect(valueOf(await client.mergeMessage()), isEmpty);
    });

    test('a worktree\'s merge can be aborted from the worktree', () async {
      final String tree = '${world.base}/tree';
      world.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'other',
        tree,
        'HEAD~1',
      ], inside: work);
      world.identify(tree);
      world.write(tree, 'docs/a.md', '# A on the worktree\n');
      world.commitAll(tree, 'Edit A there');
      world.write(work, 'docs/a.md', '# A on main\n');
      world.commitAll(work, 'Edit A here');
      world.git(<String>['merge', 'main'], inside: tree, mayFail: true);
      final DartIoGitClientImpl inTree = world.clientIn(tree);

      expect(await inTree.abortMerge(), isA<Success<void, GitClientFailure>>());

      expect(valueOf(await inTree.mergeInProgress()), isFalse);
      expect(
        File('$tree/docs/a.md').readAsStringSync(),
        '# A on the worktree\n',
      );
    });

    test('a rebase stopped on a conflict is not a merge', () async {
      divergeOnTheDocument();
      world.git(<String>['fetch', '--quiet'], inside: work);
      world.git(<String>['rebase', 'origin/main'], inside: work, mayFail: true);

      // No `MERGE_HEAD`, so the client says what it can prove and no more.
      expect(valueOf(await client.mergeInProgress()), isFalse);
      // The rebase did leave a `MERGE_MSG` (the commit being replayed), and
      // the client reads it: the message alone is not the merge's state.
      expect(valueOf(await client.mergeMessage()), contains('Edit A'));
      // The conflict is there for status to show all the same.
      expect(valueOf(await client.status()), contains('u UU'));
    });

    test('abortMerge leaves a stopped rebase alone', () async {
      divergeOnTheDocument();
      world.git(<String>['fetch', '--quiet'], inside: work);
      world.git(<String>['rebase', 'origin/main'], inside: work, mayFail: true);

      final AppFailure failure = failureOf(await client.abortMerge());

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('MERGE_HEAD'),
      );
      expect(Directory('$work/.git/rebase-merge').existsSync(), isTrue);
    });

    test('a cherry-pick stopped on a conflict is not a merge either', () async {
      divergeOnTheDocument();
      world.git(<String>['fetch', '--quiet'], inside: work);
      world.git(<String>['reset', '--quiet', '--hard', 'HEAD~1'], inside: work);
      world.write(work, 'docs/a.md', '# A local\n');
      world.commitAll(work, 'Local A');
      world.git(
        <String>['cherry-pick', 'origin/main'],
        inside: work,
        mayFail: true,
      );

      expect(valueOf(await client.mergeInProgress()), isFalse);
      expect(valueOf(await client.status()), contains('u UU'));
      expect(await client.abortMerge(), isA<Failure<void, GitClientFailure>>());
    });
  });

  group('abortMerge', () {
    test('with nothing to abort fails with git\'s words, exactly', () async {
      final AppFailure failure = failureOf(await client.abortMerge());

      expect(failure, isA<GitClientCommandFailed>());
      final GitClientCommandFailed failed = failure as GitClientCommandFailed;
      expect(failed.command, 'git merge --abort');
      expect(failed.exitCode, 128);
      expect(failed.stderr, contains('There is no merge to abort'));
    });

    test('keeps the edits that had nothing to do with the merge', () async {
      divergeOnTheDocument();
      // Unrelated work, tracked and untracked, left in the tree when the
      // pull starts: the abort must not take it with the merge.
      world.write(work, 'notes.md', '# Notes, edited\n');
      world.write(work, 'draft.md', '# Never committed\n');

      expect(await client.pull(), isA<Failure<void, GitClientFailure>>());
      expect(valueOf(await client.mergeInProgress()), isTrue);

      expect(await client.abortMerge(), isA<Success<void, GitClientFailure>>());

      expect(valueOf(await client.mergeInProgress()), isFalse);
      expect(valueOf(await client.mergeMessage()), isEmpty);
      expect(File('$work/docs/a.md').readAsStringSync(), '# A by me\n');
      expect(File('$work/notes.md').readAsStringSync(), '# Notes, edited\n');
      expect(File('$work/draft.md').readAsStringSync(), '# Never committed\n');
      expect(
        world.say(<String>['log', '--format=%s', '-1'], inside: work),
        'Edit A',
      );
    });
  });

  group('a pull that stops on a conflict', () {
    test(
      'a second pull while merging is refused and changes nothing',
      () async {
        divergeOnTheDocument();
        expect(await client.pull(), isA<Failure<void, GitClientFailure>>());
        final String markers = File('$work/docs/a.md').readAsStringSync();

        final AppFailure failure = failureOf(await client.pull());

        // Git refuses to start: it is not a second conflict to name.
        expect(failure, isA<GitClientCommandFailed>());
        expect(
          (failure as GitClientCommandFailed).stderr,
          contains('unmerged files'),
        );
        expect(valueOf(await client.mergeInProgress()), isTrue);
        expect(File('$work/docs/a.md').readAsStringSync(), markers);
      },
    );

    test('names the file from below the root, root-relative', () async {
      divergeOnTheDocument();

      final AppFailure failure = failureOf(await client.pull());

      expect(failure, isA<GitClientMergeConflict>());
      expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
        'docs/a.md',
      ]);
    });

    test(
      'diff3 puts the base in the file, and the conflict is the same',
      () async {
        world.writeGlobalConfig('[merge]\n\tconflictStyle = diff3\n');
        divergeOnTheDocument();

        final AppFailure failure = failureOf(await client.pull());

        expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
          'docs/a.md',
        ]);
        final String text = File('$work/docs/a.md').readAsStringSync();
        expect(text, contains('|||||||'));
        expect(text, contains('# A by the peer'));
      },
    );

    test('zdiff3 is the same conflict', () async {
      world.writeGlobalConfig('[merge]\n\tconflictStyle = zdiff3\n');
      divergeOnTheDocument();

      expect(failureOf(await client.pull()), isA<GitClientMergeConflict>());
      expect(File('$work/docs/a.md').readAsStringSync(), contains('<<<<<<<'));
    });

    test('a binary file on both sides is named, and has no markers', () async {
      peerPushes('Peer logo', (String peer) {
        File('$peer/docs/logo.png').writeAsBytesSync(<int>[0, 1, 2, 3]);
      });
      File('$work/docs/logo.png').writeAsBytesSync(<int>[9, 8, 0, 7]);
      world.commitAll(work, 'My logo');

      final AppFailure failure = failureOf(await client.pull());

      expect(failure, isA<GitClientMergeConflict>());
      expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
        'docs/logo.png',
      ]);
      // Git keeps one side's bytes and writes nothing a scanner could find.
      final Uint8List kept = File('$work/docs/logo.png').readAsBytesSync();
      expect(String.fromCharCodes(kept), isNot(contains('<<<<<<<')));
    });

    test('a rename on both sides names every path git left unmerged', () async {
      peerPushes('Peer renames', (String peer) {
        world.git(<String>['mv', 'docs/a.md', 'docs/b.md'], inside: peer);
      });
      world.git(<String>['mv', 'docs/a.md', 'docs/c.md'], inside: work);
      world.commitAll(work, 'Rename to C');

      final AppFailure failure = failureOf(await client.pull());

      expect(failure, isA<GitClientMergeConflict>());
      final List<String> named = <String>[
        ...(failure as GitClientMergeConflict).conflictedPaths,
      ]..sort();
      expect(named, unmerged(work));
      expect(named, hasLength(3));
    });

    test(
      'a file edited on one side and deleted on the other is named',
      () async {
        peerPushes('Peer deletes', (String peer) {
          File('$peer/docs/a.md').deleteSync();
        });
        world.write(work, 'docs/a.md', '# A, still edited\n');
        world.commitAll(work, 'Edit A');

        final AppFailure failure = failureOf(await client.pull());

        expect((failure as GitClientMergeConflict).conflictedPaths, <String>[
          'docs/a.md',
        ]);
      },
    );

    test(
      'showStagedBytes on a conflicted path answers, never the markers',
      () async {
        divergeOnTheDocument();
        await client.pull();

        final Result<Uint8List, GitClientFailure> staged = await client
            .showStagedBytes('docs/a.md');

        // Depending on git, an unmerged path is a refusal or "our" side; what
        // it must never be is the file with its markers.
        switch (staged) {
          case Success<Uint8List, GitClientFailure>(:final Uint8List value):
            expect(String.fromCharCodes(value), '# A by me\n');
          case Failure<Uint8List, GitClientFailure>(
            :final GitClientFailure failure,
          ):
            expect(failure, isA<GitClientCommandFailed>());
        }
      },
    );

    test('a commit while paths are unmerged fails and ends nothing', () async {
      divergeOnTheDocument();
      await client.pull();

      final AppFailure failure = failureOf(await client.commit('Too soon'));

      expect(failure, isA<GitClientCommandFailed>());
      expect(valueOf(await client.mergeInProgress()), isTrue);
    });
  });

  group('a pull under the person\'s own configuration', () {
    test('pull.rebase=true is still a merge', () async {
      world.writeGlobalConfig('[pull]\n\trebase = true\n');
      peerPushes('Peer root', (String peer) {
        world.write(peer, 'root.md', '# Root by the peer\n');
      });
      world.write(work, 'notes.md', '# Notes, mine\n');
      world.commitAll(work, 'Edit notes');

      expect(await client.pull(), isA<Success<void, GitClientFailure>>());

      // Two parents: a merge commit, not replayed commits.
      expect(
        world
            .say(<String>['rev-list', '--parents', '-n1', 'HEAD'], inside: work)
            .split(' '),
        hasLength(3),
      );
      expect(Directory('$work/.git/rebase-merge').existsSync(), isFalse);
    });

    test('pull.rebase=true leaves a conflict as a merge to resolve', () async {
      world.writeGlobalConfig('[pull]\n\trebase = true\n');
      divergeOnTheDocument();

      expect(failureOf(await client.pull()), isA<GitClientMergeConflict>());

      expect(valueOf(await client.mergeInProgress()), isTrue);
      expect(Directory('$work/.git/rebase-merge').existsSync(), isFalse);
    });

    test('pull.ff=only does not turn divergence into a failure', () async {
      world.writeGlobalConfig('[pull]\n\tff = only\n');
      peerPushes('Peer root', (String peer) {
        world.write(peer, 'root.md', '# Root by the peer\n');
      });
      world.write(work, 'notes.md', '# Notes, mine\n');
      world.commitAll(work, 'Edit notes');

      expect(await client.pull(), isA<Success<void, GitClientFailure>>());

      expect(File('$work/root.md').readAsStringSync(), '# Root by the peer\n');
      expect(File('$work/notes.md').readAsStringSync(), '# Notes, mine\n');
    });
  });
}
