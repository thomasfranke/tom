/// Fetch, pull, push and abort as the composition root wires them, over a
/// real bare remote and a second clone that pushes
/// (`docs/product/git-workflow/push-pull/`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_remote_stack.dart';

void main() {
  late RealRemoteStack stack;

  setUp(() => stack = RealRemoteStack.create());

  PullRemoteUseCase pulling() => stack.container.read(pullRemoteProvider);
  PushRemoteUseCase pushing() => stack.container.read(pushRemoteProvider);
  FetchRemoteUseCase fetching() => stack.container.read(fetchRemoteProvider);

  Future<GitStatusValueObject> status() async =>
      (await stack.container
              .read(readGitStatusProvider)
              .read(stack.space)
              .then((Result<GitStatusValueObject, AppFailure> it) => it))
          .valueOrNull!;

  /// The failure [result] holds, or a failure of the test.
  T failureOf<T extends AppFailure>(Result<Object?, AppFailure> result) =>
      (result as Failure<Object?, AppFailure>).failure as T;

  /// A commit on the clone's own branch.
  void commitHere(String path, String content, String message) {
    stack
      ..write(path, content)
      ..git(<String>['add', '.'])
      ..git(<String>['commit', '--quiet', '-m', message]);
  }

  String remoteHead(String branch) => stack.git(<String>[
    'rev-parse',
    'refs/heads/$branch',
  ], inside: stack.remote).trim();

  group('pulling what the remote has', () {
    test('counts the commits that arrived, and lands them on disk', () async {
      stack
        ..pushFromElsewhere(<String, String>{'docs/one.md': '# One\n'})
        ..pushFromElsewhere(<String, String>{'docs/two.md': '# Two\n'});

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(pulled.valueOrNull, 2);
      expect(stack.read('docs/two.md'), '# Two\n');
      expect(stack.git(<String>['rev-list', '--count', 'HEAD']).trim(), '3');
    });

    test('with nothing new, arrives nothing and moves nothing', () async {
      final String before = stack.git(<String>['rev-parse', 'HEAD']);

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(pulled.valueOrNull, 0);
      expect(stack.git(<String>['rev-parse', 'HEAD']), before);
    });

    test('a pull that merges counts what came, not the merge commit', () async {
      commitHere('docs/mine.md', '# Mine\n', 'mine');
      stack.pushFromElsewhere(<String, String>{'docs/theirs.md': '# T\n'});

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(pulled.valueOrNull, 1);
      expect(
        stack.git(<String>['rev-list', '--merges', '--count', 'HEAD']).trim(),
        '1',
      );
      expect(stack.has('docs/mine.md'), isTrue);
      expect(stack.has('docs/theirs.md'), isTrue);
    });

    test('a change beside the space arrives like one inside it', () async {
      stack.pushFromElsewhere(<String, String>{'README.md': '# Elsewhere\n'});

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(pulled.valueOrNull, 1);
      expect(stack.read('README.md'), '# Elsewhere\n');
    });

    test('names the files of a pull that stopped, and leaves the merge for '
        'the person', () async {
      stack
        ..pushFromElsewhere(<String, String>{
          'docs/guide.md': '# Guide\n\nTheir line.\n',
          'README.md': '# Readme\n\nTheir line.\n',
        })
        ..write('docs/guide.md', '# Guide\n\nOur line.\n')
        ..write('README.md', '# Readme\n\nOur line.\n')
        ..git(<String>['commit', '--quiet', '-am', 'ours']);

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(
        failureOf<GitMergeConflict>(pulled).conflictedFiles,
        unorderedEquals(<String>['docs/guide.md', 'README.md']),
      );
      final GitStatusValueObject reading = await status();
      expect(
        reading.entries
            .where((StatusEntryValueObject it) => it.state.name == 'conflicted')
            .map((StatusEntryValueObject it) => it.path.value),
        unorderedEquals(<String>['docs/guide.md', 'README.md']),
      );
    });
  });

  group('a pull that would overwrite work', () {
    test('a tracked file edited and not committed is refused by name, and '
        'the edit stays', () async {
      stack
        ..pushFromElsewhere(<String, String>{
          'docs/guide.md': '# Guide\n\nTheir line.\n',
        })
        ..write('docs/guide.md', '# Guide\n\nMy unsaved thought.\n');

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(failureOf<GitLocalChangesOverwritten>(pulled).paths, <String>[
        'docs/guide.md',
      ]);
      expect(stack.read('docs/guide.md'), '# Guide\n\nMy unsaved thought.\n');
      expect(stack.git(<String>['rev-list', '--count', 'HEAD']).trim(), '1');
    });

    test('a file beside the space is refused the same way', () async {
      stack
        ..pushFromElsewhere(<String, String>{'README.md': '# Theirs\n'})
        ..write('README.md', '# Mine, not committed\n');

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(failureOf<GitLocalChangesOverwritten>(pulled).paths, <String>[
        'README.md',
      ]);
      expect(stack.read('README.md'), '# Mine, not committed\n');
    });

    test('an untracked file the pull would create is refused by name, '
        'and stays', () async {
      stack
        ..pushFromElsewhere(<String, String>{'docs/new.md': '# Theirs\n'})
        ..write('docs/new.md', '# Mine, never committed\n');

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(failureOf<GitLocalChangesOverwritten>(pulled).paths, <String>[
        'docs/new.md',
      ]);
      expect(stack.read('docs/new.md'), '# Mine, never committed\n');
    });

    test('an unrelated edit does not stop the pull and survives it', () async {
      stack
        ..pushFromElsewhere(<String, String>{'docs/other.md': '# Other\n'})
        ..write('docs/guide.md', '# Guide\n\nMy unsaved thought.\n');

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(pulled.valueOrNull, 1);
      expect(stack.read('docs/guide.md'), '# Guide\n\nMy unsaved thought.\n');
    });
  });

  group('pushing', () {
    test('a tracked branch ahead goes to the remote it tracks', () async {
      commitHere('docs/mine.md', '# Mine\n', 'mine');

      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(pushed, isA<Success<void, AppFailure>>());
      expect(
        remoteHead('main'),
        stack.git(<String>['rev-parse', 'HEAD']).trim(),
      );
      expect((await status()).ahead, 0);
    });

    test('a branch with no upstream publishes itself and tracks it '
        'afterwards', () async {
      stack.git(<String>['checkout', '--quiet', '-b', 'feat/notes']);
      commitHere('docs/notes.md', '# Notes\n', 'notes');
      expect((await status()).upstream, isNull);

      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(pushed, isA<Success<void, AppFailure>>());
      expect(
        remoteHead('feat/notes'),
        stack.git(<String>['rev-parse', 'HEAD']).trim(),
      );
      final GitStatusValueObject after = await status();
      expect(after.upstream?.value, 'origin/feat/notes');
      expect(after.ahead, 0);
    });

    test('a push the remote has moved past is rejected, and nothing '
        'is lost on either side', () async {
      stack.pushFromElsewhere(<String, String>{'docs/theirs.md': '# T\n'});
      commitHere('docs/mine.md', '# Mine\n', 'mine');
      final String theirs = remoteHead('main');

      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(failureOf<GitPushRejected>(pushed), isA<GitPushRejected>());
      expect(remoteHead('main'), theirs);
      expect(stack.has('docs/mine.md'), isTrue);
    });

    test('a remote that refuses the branch says it is protected', () async {
      stack.installRemoteHook(
        'pre-receive',
        'echo "remote: error: GH006: Protected branch update failed" >&2\n'
            'exit 1',
      );
      commitHere('docs/mine.md', '# Mine\n', 'mine');

      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(failureOf<GitBranchProtected>(pushed), isA<GitBranchProtected>());
    });
  });

  // Git answers "does not appear to be a git repository" for an address
  // with nothing behind it, and the client counts that as no remote.
  group('a remote whose address leads nowhere', () {
    setUp(() {
      stack.git(<String>[
        'remote',
        'set-url',
        'origin',
        '${stack.root}/nowhere.git',
      ]);
      commitHere('docs/mine.md', '# Mine\n', 'mine');
    });

    test('push cannot talk to it', () async {
      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(failureOf<GitFailure>(pushed), isA<GitNoRemote>());
    });

    test('fetch cannot talk to it', () async {
      final Result<void, AppFailure> fetched = await fetching().fetch(
        stack.space,
      );

      expect(failureOf<GitFailure>(fetched), isA<GitNoRemote>());
    });

    test('pull cannot talk to it, and the commit made here stays', () async {
      final String ours = stack.git(<String>['rev-parse', 'HEAD']);

      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(failureOf<GitFailure>(pulled), isA<GitNoRemote>());
      expect(stack.git(<String>['rev-parse', 'HEAD']), ours);
    });
  });

  group('fetching', () {
    test('learns what the remote has without touching the disk', () async {
      stack.pushFromElsewhere(<String, String>{'docs/theirs.md': '# T\n'});
      expect((await status()).behind, 0);

      final Result<void, AppFailure> fetched = await fetching().fetch(
        stack.space,
      );

      expect(fetched, isA<Success<void, AppFailure>>());
      expect((await status()).behind, 1);
      expect(stack.has('docs/theirs.md'), isFalse);
    });
  });

  group('a repository with no remote', () {
    setUp(() => stack.git(<String>['remote', 'remove', 'origin']));

    // Decision AL-090: fetch and pull both say it. Today `git fetch` with no
    // remote exits 0 and `git pull` says "no tracking information".
    test('fetch says there is no remote', () async {
      final Result<void, AppFailure> fetched = await fetching().fetch(
        stack.space,
      );

      expect(failureOf<GitFailure>(fetched), isA<GitNoRemote>());
    });

    test('pull says there is no remote', () async {
      final Result<int?, AppFailure> pulled = await pulling().pull(stack.space);

      expect(failureOf<GitFailure>(pulled), isA<GitNoRemote>());
    });

    test('push says there is no remote', () async {
      final Result<void, AppFailure> pushed = await pushing().push(stack.space);

      expect(failureOf<GitFailure>(pushed), isA<GitNoRemote>());
    });
  });

  group('a pull that stopped on a conflict', () {
    setUp(() => stack.conflictingPull());

    test('the merge state is in progress with git\'s own message', () async {
      final MergeStateValueObject state =
          (await stack.container.read(readMergeStateProvider).read(stack.space))
              .valueOrNull!;

      expect(state.inProgress, isTrue);
      expect(state.message, startsWith('Merge'));
    });

    test('is not in progress before any pull', () async {
      stack.git(<String>['merge', '--abort']);

      final MergeStateValueObject state =
          (await stack.container.read(readMergeStateProvider).read(stack.space))
              .valueOrNull!;

      expect(state, MergeStateValueObject.none);
    });

    test(
      'aborting puts the tree back and keeps the commit made here',
      () async {
        final String ours = stack.git(<String>['rev-parse', 'HEAD']);

        final Result<void, AppFailure> aborted = await stack.container
            .read(abortPullProvider)
            .abort(stack.space);

        expect(aborted, isA<Success<void, AppFailure>>());
        expect(stack.git(<String>['rev-parse', 'HEAD']), ours);
        expect(stack.read('docs/guide.md'), '# Guide\n\nOur line.\n');
        expect(stack.read('README.md'), '# Readme\n\nOur line.\n');
        expect(stack.unmerged, isEmpty);
        expect(
          (await stack.container.read(readMergeStateProvider).read(stack.space))
              .valueOrNull,
          MergeStateValueObject.none,
        );
      },
    );
  });

  test('aborting keeps an unrelated edit that was not committed', () async {
    stack
      ..write('docs/notes.md', '# Notes\n')
      ..git(<String>['add', '.'])
      ..git(<String>['commit', '--quiet', '-m', 'notes'])
      ..git(<String>['push', '--quiet'])
      ..write('docs/notes.md', '# Notes\n\nHalf a thought.\n')
      ..pushFromElsewhere(<String, String>{
        'docs/guide.md': '# Guide\n\nTheir line.\n',
      })
      ..write('docs/guide.md', '# Guide\n\nOur line.\n')
      ..git(<String>['commit', '--quiet', '-m', 'ours', 'docs/guide.md'])
      ..git(<String>['pull', '--no-rebase'], allowFailure: true);
    expect(stack.unmerged, <String>['docs/guide.md']);

    final Result<void, AppFailure> aborted = await stack.container
        .read(abortPullProvider)
        .abort(stack.space);

    expect(aborted, isA<Success<void, AppFailure>>());
    expect(stack.read('docs/notes.md'), '# Notes\n\nHalf a thought.\n');
    expect(stack.read('docs/guide.md'), '# Guide\n\nOur line.\n');
  });

  test('aborting with no merge in progress is a failure, not a silent '
      'success', () async {
    final Result<void, AppFailure> aborted = await stack.container
        .read(abortPullProvider)
        .abort(stack.space);

    expect(aborted, isA<Failure<void, AppFailure>>());
  });
}
