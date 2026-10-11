/// What the composition root hands each use case, proven over a real
/// repository: where documents and drafts are rooted, that every command
/// reaches the command log and the gate, and that no seam
/// `tom_presentation` declares is left without an override.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_remote_stack.dart';

void main() {
  late RealRemoteStack stack;

  setUp(() => stack = RealRemoteStack.create());

  SpaceRelativePathValueObject at(String path) =>
      SpaceRelativePathValueObject(path);

  group('documents are rooted in the space, not the repository', () {
    DocumentRepository documents() =>
        stack.container.read(documentRepositoryForProvider)(stack.space);

    test('a path is read relative to the space', () async {
      final Result<DocumentEntity, DocumentFailure> read = await documents()
          .read(at('guide.md'));

      expect(read.valueOrNull?.content, '# Guide\n\nOriginal line.\n');
    });

    test('a path that only means something from the repository root is '
        'not found', () async {
      final Result<DocumentEntity, DocumentFailure> read = await documents()
          .read(at('docs/guide.md'));

      expect(
        (read as Failure<DocumentEntity, DocumentFailure>).failure,
        isA<DocumentNotFound>(),
      );
    });

    test('a file beside the space is not a document of it', () async {
      final Result<DocumentEntity, DocumentFailure> read = await documents()
          .read(at('README.md'));

      expect(read, isA<Failure<DocumentEntity, DocumentFailure>>());
    });

    test('a document created lands inside the space', () async {
      final Result<void, DocumentFailure> created = await documents().create(
        DocumentEntity(path: at('notes/new.md'), content: '# New\n'),
      );

      expect(created, isA<Success<void, DocumentFailure>>());
      expect(stack.read('docs/notes/new.md'), '# New\n');
      expect(stack.has('notes/new.md'), isFalse);
    });

    test('the use case the stage guard reads through sees the space\'s '
        'documents, so a conflict marker is found', () async {
      stack.conflictingPull();

      final Result<void, AppFailure> staged = await stack.container
          .read(stageChangesProvider)
          .stage(stack.space, <RepoRelativePathValueObject>[
            RepoRelativePathValueObject('docs/guide.md'),
          ]);

      expect(
        ((staged as Failure<void, AppFailure>).failure
                as GitConflictMarkersPresent)
            .paths,
        <String>['docs/guide.md'],
      );
    });
  });

  group('drafts are rooted in the git directory', () {
    DocumentEntity draft() =>
        DocumentEntity(path: at('feat/x.md'), content: '# Draft\n');

    test('a draft is written under .git/tom/pull-request and the work tree '
        'stays clean', () async {
      final DocumentRepository drafts = stack.container.read(
        pullRequestDraftsForProvider,
      )(stack.space);

      expect(
        await drafts.create(draft()),
        isA<Success<void, DocumentFailure>>(),
      );

      expect(
        File(
          '${stack.clone}/.git/tom/pull-request/feat/x.md',
        ).readAsStringSync(),
        '# Draft\n',
      );
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
      expect(stack.has('docs/feat/x.md'), isFalse);
    });

    test('in a worktree it is written in the shared git directory, and '
        'both work trees stay clean', () async {
      final String worktree = '${stack.root}/work/wt';
      stack.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        worktree,
      ]);
      final DocumentRepository drafts =
          stack.container.read(pullRequestDraftsForProvider)(
            SpaceEntity(
              root: '$worktree/docs',
              repositoryRoot: worktree,
              name: 'docs',
            ),
          );

      expect(
        await drafts.create(draft()),
        isA<Success<void, DocumentFailure>>(),
      );

      expect(
        File('${stack.clone}/.git/tom/pull-request/feat/x.md').existsSync(),
        isTrue,
      );
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
      expect(
        stack.git(<String>['status', '--porcelain'], inside: worktree),
        isEmpty,
      );
    });

    test('a draft written from the space below the root is the one read '
        'from the repository root', () async {
      final GitRepositoryFor gitFor = stack.container.read(
        gitRepositoryForProvider,
      );
      final DocumentRepositoryFor draftsFor = stack.container.read(
        pullRequestDraftsForProvider,
      );
      await draftsFor(stack.space).create(draft());

      final SpaceEntity atRoot = SpaceEntity(
        root: stack.clone,
        repositoryRoot: stack.clone,
        name: 'repo',
      );
      final Result<DocumentEntity, DocumentFailure> read = await draftsFor(
        atRoot,
      ).read(at('feat/x.md'));

      expect(read.valueOrNull?.content, '# Draft\n');
      expect(
        (await gitFor(atRoot).gitDirectory()).valueOrNull,
        '${stack.clone}/.git',
      );
    });
  });

  group('one git for a repository, however many use cases ask', () {
    test('a burst of stage and commit from separate asks never meets '
        'index.lock, and every file is committed', () async {
      final GitRepositoryFor gitFor = stack.container.read(
        gitRepositoryForProvider,
      );
      final List<RepoRelativePathValueObject> files =
          <RepoRelativePathValueObject>[
            for (int number = 0; number < 12; number++)
              RepoRelativePathValueObject('docs/burst-$number.md'),
          ];
      for (final RepoRelativePathValueObject file in files) {
        stack.write(file.value, '# ${file.value}\n' * 100);
      }

      // Every ask is made at once, the way two use cases would make them:
      // the queue, not the caller, decides the order.
      final List<Future<Result<void, GitFailure>>> writes =
          <Future<Result<void, GitFailure>>>[
            for (final RepoRelativePathValueObject file
                in files) ...<Future<Result<void, GitFailure>>>[
              gitFor(stack.space).stage(<RepoRelativePathValueObject>[file]),
              gitFor(stack.space).commit('add ${file.value}'),
            ],
          ];
      final List<Result<void, GitFailure>> results = await Future.wait(writes);

      final Iterable<String> locked = results
          .whereType<Failure<void, GitFailure>>()
          .map((Failure<void, GitFailure> it) => '${it.failure}')
          .where((String it) => it.contains('index.lock'));
      expect(locked, isEmpty, reason: 'a write lost a race for the index');
      final String committed = stack.git(<String>[
        'ls-tree',
        '-r',
        '--name-only',
        'HEAD',
      ]);
      for (final RepoRelativePathValueObject file in files) {
        expect(committed, contains(file.value));
      }
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
    });
  });

  group('every command is written down and asked at the gate', () {
    /// The command lines the Commands panel holds, `ssh` apart: it is
    /// written down and never asked about
    /// ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
    List<String> logged() => stack.container
        .read(commandsProvider)
        .rows
        .map((CommandRow it) => it.record.commandLine)
        .where((String it) => !it.startsWith('ssh '))
        .toList();

    test('git through the use cases: each line in the log was asked at '
        'the gate, and the other way round', () async {
      final ProviderContainer app = stack.container;
      await app.read(openSpaceProvider).open(stack.space.root);
      await app.read(readGitStatusProvider).read(stack.space);
      stack.write('docs/new.md', '# New\n');
      await app.read(stageChangesProvider).stage(
        stack.space,
        <RepoRelativePathValueObject>[
          RepoRelativePathValueObject('docs/new.md'),
        ],
      );
      await app.read(commitChangesProvider).commit(stack.space, 'add new');
      await app.read(fetchRemoteProvider).fetch(stack.space);
      await app.read(pushRemoteProvider).push(stack.space);
      await app.read(pullRemoteProvider).pull(stack.space);
      await app.read(listBranchesProvider).list(stack.space);
      await app
          .read(readRecentBranchProvider)
          .read(
            RecentSpaceEntity(
              root: stack.space.root,
              name: 'docs',
              lastOpened: DateTime.utc(2026, 10, 11),
            ),
          );

      expect(logged(), isNotEmpty);
      expect(logged(), unorderedEquals(stack.gateSeen));
    });

    test('gh and the credential readers go through them too', () async {
      stack
        ..installGh(logins: <String>['ada'], pushers: <String>['ada'])
        ..git(<String>[
          'remote',
          'set-url',
          'origin',
          'git@github.com:acme/docs.git',
        ]);
      await stack.container.read(readAccountProvider).read(stack.space);
      await stack.container
          .read(readOpenPullRequestProvider)
          .read(
            stack.space,
            RemoteProjectValueObject.tryParse('git@github.com:acme/docs.git')!,
            BranchNameValueObject('main'),
          );

      final List<String> lines = logged();
      expect(
        lines.where((String it) => it.contains(' pr list ')),
        hasLength(1),
      );
      expect(
        lines.where((String it) => it.contains('auth status')),
        isNotEmpty,
      );
      expect(lines, unorderedEquals(stack.gateSeen));
    });
  });

  group('every seam presentation declares has an override', () {
    // A seam is a provider whose body throws "has no default": the
    // composition root is the one place that satisfies it.
    test('no "has no default" provider is missing from appOverrides', () async {
      final RegExp declared = RegExp(r'(\w+)Provider has no default');
      final Set<String> seams = <String>{
        for (final FileSystemEntity file in Directory(
          '../../packages/presentation/lib/src',
        ).listSync(recursive: true))
          if (file is File &&
              file.path.endsWith('.dart') &&
              !file.path.endsWith('.g.dart') &&
              !file.path.endsWith('.freezed.dart'))
            for (final RegExpMatch match in declared.allMatches(
              file.readAsStringSync(),
            ))
              match.group(1)!,
      };
      final String root = File(
        'lib/bootstrap/providers.dart',
      ).readAsStringSync();
      final Set<String> overridden = <String>{
        for (final RegExpMatch match in RegExp(
          r'(\w+)Provider\.overrideWith',
        ).allMatches(root))
          match.group(1)!,
      };

      expect(seams, hasLength(greaterThan(40)));
      expect(seams.difference(overridden), isEmpty);
    });
  });
}
