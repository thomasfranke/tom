/// The pull request's reads and its draft as the composition root wires
/// them, over a real repository, a bare remote and a `gh` that is a script
/// ([Decision 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md),
/// `docs/product/git-workflow/pull-request/`).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_remote_stack.dart';

void main() {
  late RealRemoteStack stack;

  final BranchNameValueObject main = BranchNameValueObject('main');
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');

  setUp(() => stack = RealRemoteStack.create());

  /// What [result] holds, or a failure of the test.
  T valueOf<T extends Object?>(Result<T, AppFailure> result) =>
      switch (result) {
        Success<T, AppFailure>(value: final T value) => value,
        Failure<T, AppFailure>(failure: final AppFailure failure) =>
          throw StateError('expected a success, got $failure'),
      };

  T failureOf<T extends AppFailure>(Result<Object?, AppFailure> result) =>
      (result as Failure<Object?, AppFailure>).failure as T;

  Future<PullRequestTargetValueObject> target([SpaceEntity? space]) async =>
      valueOf(
        await stack.container
            .read(readPullRequestTargetProvider)
            .read(space ?? stack.space),
      );

  /// A branch `feat/x` off `main` holding two commits — one inside the
  /// space, one beside it — and then `origin/main` moves on without it.
  void proposeBranch() {
    stack
      ..git(<String>['checkout', '--quiet', '-b', 'feat/x'])
      ..write(
        'docs/guide.md',
        '# Guide\n\nOriginal line.\n\nOne two three four five six seven.\n',
      )
      ..write('docs/new.md', '# New\n\nAlpha beta gamma.\n')
      ..git(<String>['add', '.'])
      ..git(<String>['commit', '--quiet', '-m', 'Describe the guide'])
      ..write('README.md', '# Readme\n\nNow it says something.\n');
    File('${stack.clone}/docs/pic.png').writeAsBytesSync(<int>[0, 1, 2, 3]);
    stack
      ..git(<String>['add', '.'])
      ..git(<String>['commit', '--quiet', '-m', 'Fix the readme'])
      ..pushFromElsewhere(<String, String>{'docs/later.md': '# Later\n'})
      ..git(<String>['fetch', '--quiet']);
  }

  group('the target, from the address git holds', () {
    for (final (String label, String address, RemoteHostEnum host, String path)
        in <(String, String, RemoteHostEnum, String)>[
          (
            'https',
            'https://github.com/acme/docs.git',
            RemoteHostEnum.github,
            'acme/docs',
          ),
          (
            'scp-like ssh',
            'git@github.com:acme/docs.git',
            RemoteHostEnum.github,
            'acme/docs',
          ),
          (
            'ssh://',
            'ssh://git@gitlab.com/acme/docs',
            RemoteHostEnum.gitlab,
            'acme/docs',
          ),
          (
            'bitbucket',
            'https://bitbucket.org/acme/docs',
            RemoteHostEnum.bitbucket,
            'acme/docs',
          ),
        ]) {
      test('$label is the host and the project', () async {
        stack.git(<String>['remote', 'set-url', 'origin', address]);

        final PullRequestTargetValueObject read = await target();

        expect(read.hasRemote, isTrue);
        expect(read.project, RemoteProjectValueObject(host: host, path: path));
        expect(read.branch, main);
        expect(read.isDetached, isFalse);
      });
    }

    test('an insteadOf shorthand is expanded before it is read', () async {
      stack
        ..git(<String>[
          'config',
          'url.https://github.com/acme/.insteadOf',
          'gh:',
        ])
        ..git(<String>['remote', 'set-url', 'origin', 'gh:docs']);

      final PullRequestTargetValueObject read = await target();

      expect(read.project?.label, 'github.com/acme/docs');
    });

    test('a push address of its own does not change the project', () async {
      stack
        ..git(<String>[
          'remote',
          'set-url',
          'origin',
          'https://github.com/acme/docs.git',
        ])
        ..git(<String>['config', 'remote.origin.pushurl', stack.remote]);

      final PullRequestTargetValueObject read = await target();

      expect(read.project?.label, 'github.com/acme/docs');
    });

    test('a remote on a folder has a remote and no project', () async {
      final PullRequestTargetValueObject read = await target();

      expect(read.hasRemote, isTrue);
      expect(read.project, isNull);
    });

    test(
      'a host the product does not know has a remote and no project',
      () async {
        stack.git(<String>[
          'remote',
          'set-url',
          'origin',
          'https://example.com/acme/docs.git',
        ]);

        final PullRequestTargetValueObject read = await target();

        expect(read.hasRemote, isTrue);
        expect(read.project, isNull);
      },
    );

    test('no remote at all is said by hasRemote', () async {
      stack.git(<String>['remote', 'remove', 'origin']);

      final PullRequestTargetValueObject read = await target();

      expect(read.hasRemote, isFalse);
      expect(read.project, isNull);
    });

    test('the default branch is main when the remote names none', () async {
      expect((await target()).defaultBranch, main);
    });

    test("the default branch is the one the remote's HEAD points to", () async {
      stack
        ..git(<String>['push', '--quiet', 'origin', 'main:trunk'])
        ..git(<String>['fetch', '--quiet'])
        ..git(<String>[
          'symbolic-ref',
          'refs/remotes/origin/HEAD',
          'refs/remotes/origin/trunk',
        ]);

      expect((await target()).defaultBranch, BranchNameValueObject('trunk'));
    });

    test('a detached HEAD has no branch', () async {
      stack.git(<String>['checkout', '--quiet', '--detach']);

      final PullRequestTargetValueObject read = await target();

      expect(read.isDetached, isTrue);
      expect(read.branch, isNull);
    });

    test('a space in a worktree reads its own branch', () async {
      stack.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        '${stack.root}/work/wt',
      ]);

      final PullRequestTargetValueObject read = await target(
        SpaceEntity(
          root: '${stack.root}/work/wt/docs',
          repositoryRoot: '${stack.root}/work/wt',
          name: 'docs',
        ),
      );

      expect(read.branch, BranchNameValueObject('feat/wt'));
    });
  });

  group('what the branch proposes', () {
    setUp(proposeBranch);

    Future<BranchProposalValueObject> proposal() async => valueOf(
      await stack.container
          .read(readBranchProposalProvider)
          .read(stack.space, main),
    );

    test('lists its commits newest first, against origin/main, not the '
        'stale local branch', () async {
      final BranchProposalValueObject read = await proposal();

      expect(read.commits.map((CommitEntity it) => it.subject), <String>[
        'Fix the readme',
        'Describe the guide',
      ]);
    });

    test('lists every change, one beside the space too, and none of what '
        'the base did since', () async {
      final BranchProposalValueObject read = await proposal();

      expect(
        <String, FileStateEnum>{
          for (final BranchChangeValueObject it in read.changes)
            it.path.value: it.state,
        },
        <String, FileStateEnum>{
          'docs/guide.md': FileStateEnum.modified,
          'docs/new.md': FileStateEnum.added,
          'docs/pic.png': FileStateEnum.added,
          'README.md': FileStateEnum.modified,
        },
      );
    });

    test('counts lines for text and nothing for a binary', () async {
      final BranchProposalValueObject read = await proposal();

      BranchChangeValueObject change(String path) => read.changes.firstWhere(
        (BranchChangeValueObject it) => it.path.value == path,
      );
      expect(change('docs/new.md').added, 3);
      expect(change('docs/new.md').removed, 0);
      expect(change('docs/pic.png').added, isNull);
      expect(change('docs/pic.png').removed, isNull);
    });

    test('reads the same without a copy of the base on the remote', () async {
      stack.git(<String>['remote', 'remove', 'origin']);

      final BranchProposalValueObject read = await proposal();

      // No origin/main to read: the local `main` is the base, and it
      // stopped where the branch started.
      expect(read.commits, hasLength(2));
      expect(read.changes, hasLength(4));
    });

    test('a branch with nothing of its own proposes nothing', () async {
      stack.git(<String>['checkout', '--quiet', 'main']);

      final BranchProposalValueObject read = await proposal();

      expect(read.commits, isEmpty);
      expect(read.changes, isEmpty);
    });

    test(
      'is an overview of the words and blocks, read from the fork point',
      () async {
        final BranchProposalValueObject read = await proposal();

        final BranchOverviewValueObject overview = valueOf(
          await stack.container
              .read(readBranchOverviewProvider)
              .read(stack.space, main, read),
        );

        expect(overview.commits, 2);
        expect(overview.added, 2);
        expect(overview.modified, 2);
        expect(overview.deleted, 0);
        // Seven words in the guide's new paragraph, four in the new
        // document (heading and paragraph), four in the readme's.
        expect(overview.wordsAdded, 15);
        expect(overview.wordsRemoved, 0);
        expect(overview.blocks, <BlockKindEnum, int>{
          BlockKindEnum.paragraph: 3,
          BlockKindEnum.heading: 1,
        });
        // The binary counts as a change in `docs`, never as words.
        expect(overview.folders, <String, int>{'docs': 3, '': 1});
        expect(overview.readingMinutes, 1);
        expect(overview.mostChanged?.path.value, 'docs/new.md');
      },
    );
  });

  group('reading changes nothing', () {
    test('the target, the proposal and the overview leave the repository '
        'as it was', () async {
      proposeBranch();
      String snapshot() => <String>[
        stack.git(<String>['for-each-ref']),
        stack.git(<String>['rev-parse', 'HEAD']),
        stack.git(<String>['status', '--porcelain=v1', '--branch']),
        stack.git(<String>['config', '--list', '--local']),
      ].join('\n---\n');
      final String before = snapshot();

      final BranchProposalValueObject proposal = valueOf(
        await stack.container
            .read(readBranchProposalProvider)
            .read(stack.space, main),
      );
      await stack.container
          .read(readBranchOverviewProvider)
          .read(stack.space, main, proposal);
      await target();

      expect(snapshot(), before);
    });
  });

  group('the draft', () {
    String draftFile(String branch, {String? git}) =>
        '${git ?? '${stack.clone}/.git'}/tom/pull-request/$branch.md';

    Future<DocumentEntity> open({SpaceEntity? space, String? branch}) async =>
        valueOf(
          await stack.container
              .read(openPullRequestDraftProvider)
              .open(
                space ?? stack.space,
                BranchNameValueObject(branch ?? 'feat/x'),
                main,
              ),
        );

    setUp(proposeBranch);

    test('is seeded from the commits, oldest as the title', () async {
      final DocumentEntity draft = await open();

      expect(draft.content, '# Describe the guide\n\n- Fix the readme\n');
    });

    test('lives under the git directory and leaves the work tree '
        'clean', () async {
      await open();

      expect(File(draftFile('feat/x')).existsSync(), isTrue);
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
    });

    test('is seeded once, and a second opening keeps what was written, '
        'whatever the branch gained since', () async {
      await open();
      valueOf(
        await stack.container
            .read(saveDraftProvider)
            .save(
              stack.space,
              DocumentEntity(
                path: OpenPullRequestDraftUseCase.pathFor(feature),
                content: '# My own title\n\nWhy it exists.\n',
              ),
            ),
      );
      stack
        ..write('docs/more.md', '# More\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'One more']);

      final DocumentEntity again = await open();

      expect(again.content, '# My own title\n\nWhy it exists.\n');
      expect(File(draftFile('feat/x')).readAsStringSync(), again.content);
    });

    test('one branch name with a slash is a folder in the drafts, one file '
        'per branch', () async {
      await open();
      stack
        ..git(<String>['checkout', '--quiet', '-b', 'fix/typo', 'main'])
        ..write('docs/typo.md', '# Typo\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'Fix a typo']);

      final DocumentEntity second = await open(branch: 'fix/typo');

      expect(second.content, '# Fix a typo\n');
      expect(File(draftFile('feat/x')).existsSync(), isTrue);
      expect(File(draftFile('fix/typo')).existsSync(), isTrue);
    });

    test('in a worktree lands in the shared git directory, and neither work '
        'tree sees it', () async {
      final String worktree = '${stack.root}/work/wt';
      stack.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        worktree,
        'feat/x',
      ]);
      final SpaceEntity inWorktree = SpaceEntity(
        root: '$worktree/docs',
        repositoryRoot: worktree,
        name: 'docs',
      );

      final DocumentEntity draft = await open(
        space: inWorktree,
        branch: 'feat/wt',
      );

      expect(draft.content, startsWith('# '));
      expect(File('$worktree/.git').statSync().type, FileSystemEntityType.file);
      expect(File(draftFile('feat/wt')).existsSync(), isTrue);
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
      expect(
        stack.git(<String>['status', '--porcelain'], inside: worktree),
        isEmpty,
      );
    });

    test('a folder git does not know cannot hold one', () async {
      Directory('${stack.root}/plain/docs').createSync(recursive: true);

      final Result<DocumentEntity, AppFailure> opened = await stack.container
          .read(openPullRequestDraftProvider)
          .open(
            SpaceEntity(
              root: '${stack.root}/plain/docs',
              repositoryRoot: '${stack.root}/plain',
              name: 'docs',
            ),
            feature,
            main,
          );

      expect(opened, isA<Failure<DocumentEntity, AppFailure>>());
      expect(Directory('${stack.root}/plain/.git').existsSync(), isFalse);
    });
  });

  group('on the host, through gh', () {
    final RemoteProjectValueObject docs = RemoteProjectValueObject.tryParse(
      'git@github.com:acme/docs.git',
    )!;

    setUp(() {
      proposeBranch();
      stack
        ..git(<String>[
          'remote',
          'set-url',
          'origin',
          'git@github.com:acme/docs.git',
        ])
        ..git(<String>['config', 'remote.origin.pushurl', stack.remote]);
    });

    Future<Result<OpenedPullRequestValueObject?, AppFailure>> opened() => stack
        .container
        .read(readOpenPullRequestProvider)
        .read(stack.space, docs, feature);

    Future<Result<OpenedPullRequestValueObject, AppFailure>> create({
      String title = 'Describe the guide',
      String body = 'Why it exists — in “quotes”.\n\nSecond paragraph.',
    }) => stack.container
        .read(createPullRequestProvider)
        .create(
          stack.space,
          docs,
          base: main,
          head: feature,
          title: title,
          body: body,
        );

    String repositoryRoot() =>
        Directory(stack.clone).resolveSymbolicLinksSync();

    test('with nothing open, the list is empty and asked as the account, '
        'from the repository, not the space', () async {
      stack.installGh(pushers: <String>['ada']);

      final Result<OpenedPullRequestValueObject?, AppFailure> found =
          await opened();

      expect(valueOf(found), isNull);
      expect(
        stack.ghAsked(),
        contains(
          startsWith(
            'tok-ada|pr list --repo '
            'github.com/acme/docs --head feat/x --state open --json',
          ),
        ),
      );
      expect(
        Directory(
          stack.ghKept('pr-list.folder').trim(),
        ).resolveSymbolicLinksSync(),
        repositoryRoot(),
      );
    });

    test('creating hands the body over whole, from the repository, and '
        'comes back as the one the host lists', () async {
      stack.installGh(pushers: <String>['ada']);

      final OpenedPullRequestValueObject made = valueOf(await create());

      expect(made.number, 123);
      expect(made.address.toString(), 'https://github.com/acme/docs/pull/123');
      expect(made.title, 'Describe the guide');
      expect(
        stack.ghKept('body.md'),
        'Why it exists — in “quotes”.\n\nSecond paragraph.',
      );
      expect(
        Directory(
          stack.ghKept('pr-create.folder').trim(),
        ).resolveSymbolicLinksSync(),
        repositoryRoot(),
      );
      expect(valueOf(await opened())?.number, 123);
    });

    test('the draft is not touched by creating from it', () async {
      stack.installGh(pushers: <String>['ada']);
      final DocumentEntity draft = valueOf(
        await stack.container
            .read(openPullRequestDraftProvider)
            .open(stack.space, feature, main),
      );

      valueOf(await create(title: 'T', body: draft.content));

      expect(
        File(
          '${stack.clone}/.git/tom/pull-request/feat/x.md',
        ).readAsStringSync(),
        draft.content,
      );
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
    });

    test('a chosen account is the one whose token is used', () async {
      stack.installGh(
        logins: <String>['ada', 'hopper'],
        pushers: <String>['ada'],
      );
      valueOf(
        await stack.container
            .read(chooseAccountProvider)
            .choose(
              stack.space,
              const GithubAccountValueObject(
                login: 'hopper',
                source: AccountSourceEnum.gh,
              ),
            ),
      );

      await opened();

      expect(
        stack.ghAsked().singleWhere((String it) => it.contains('|pr list')),
        startsWith('tok-hopper|'),
      );
    });

    test('with none chosen, the first account that can push is used', () async {
      stack.installGh(
        logins: <String>['ada', 'hopper'],
        pushers: <String>['hopper'],
      );

      await opened();

      expect(
        stack.ghAsked().singleWhere((String it) => it.contains('|pr list')),
        startsWith('tok-hopper|'),
      );
    });

    test('with no account signed in, the host is unavailable', () async {
      stack.installGh(logins: <String>[]);

      expect(
        failureOf<PullRequestHostFailure>(await opened()),
        isA<PullRequestHostUnavailable>(),
      );
      expect(
        failureOf<PullRequestHostFailure>(await create()),
        isA<PullRequestHostUnavailable>(),
      );
      expect(stack.ghKeeps('body.md'), isFalse);
    });

    test('with no gh at all, the host is unavailable', () async {
      expect(
        failureOf<PullRequestHostFailure>(await opened()),
        isA<PullRequestHostUnavailable>(),
      );
    });
  });
}
