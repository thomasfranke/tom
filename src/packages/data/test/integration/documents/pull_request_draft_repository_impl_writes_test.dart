/// The pull request draft's other half: writing it, reading it as bytes,
/// reading one that is not there — and that git never sees it in any state
/// of the repository, a worktree and a clean included.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late String repo;

  setUp(() {
    world = GitWorld();
    repo = world.init('${world.base}/repo');
    world.commitFile(repo, 'docs/a.md', '# A\n');
  });

  tearDown(() => world.dispose());

  PullRequestDraftRepositoryImpl draftsAt(String folder) =>
      PullRequestDraftRepositoryImpl(
        git: world.repository(folder),
        documents: const DocumentDataSource(filesystem: DartIoFilesystemImpl()),
      );

  DocumentEntity draft(String name, String content) => DocumentEntity(
    path: SpaceRelativePathValueObject(name),
    content: content,
  );

  group('a draft', () {
    test('is rewritten in place and read back', () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$repo/docs');
      valueOf(await drafts.create(draft('feat/x.md', '# First\n')));

      valueOf(await drafts.write(draft('feat/x.md', '# Second, longer\n')));

      expect(
        valueOf(
          await drafts.read(SpaceRelativePathValueObject('feat/x.md')),
        ).content,
        '# Second, longer\n',
      );
      expect(
        File('$repo/.git/tom/pull-request/feat/x.md').readAsStringSync(),
        '# Second, longer\n',
      );
    });

    test('is read as the bytes that were written', () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$repo/docs');
      valueOf(await drafts.create(draft('feat/x.md', '# Título é\n')));

      final Uint8List bytes = valueOf(
        await drafts.readBytes(SpaceRelativePathValueObject('feat/x.md')),
      );

      expect(String.fromCharCodes(bytes), contains('T'));
      expect(
        bytes,
        File('$repo/.git/tom/pull-request/feat/x.md').readAsBytesSync(),
      );
    });

    test('that was never made is not found, from either read', () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$repo/docs');
      final SpaceRelativePathValueObject missing = SpaceRelativePathValueObject(
        'feat/none.md',
      );

      expect(failureOf(await drafts.read(missing)), isA<DocumentNotFound>());
      expect(
        failureOf(await drafts.readBytes(missing)),
        isA<DocumentNotFound>(),
      );
    });

    test('written before it was created makes the file', () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$repo/docs');

      final Result<void, DocumentFailure> written = await drafts.write(
        draft('feat/none.md', '# Nothing\n'),
      );

      // `write` creates or replaces (the contract), so the first save of
      // a draft the editor opened needs no `create` before it.
      expect(written, isA<Success<void, DocumentFailure>>());
      expect(
        File('$repo/.git/tom/pull-request/feat/none.md').readAsStringSync(),
        '# Nothing\n',
      );
    });

    test('is invisible to status, to a stage-all and to a clean', () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$repo/docs');
      valueOf(await drafts.create(draft('feat/x.md', '# Draft\n')));

      expect(
        world.git(<String>['status', '--porcelain'], inside: repo),
        isEmpty,
      );
      world.git(<String>['add', '--all'], inside: repo);
      world.git(<String>['clean', '-fdx', '--quiet'], inside: repo);

      expect(
        world.git(<String>['status', '--porcelain'], inside: repo),
        isEmpty,
      );
      expect(
        File('$repo/.git/tom/pull-request/feat/x.md').existsSync(),
        isTrue,
      );
    });

    test('stays out of status in a worktree too, and one branch\'s '
        'draft is not another\'s', () async {
      world.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/x',
        '${world.base}/wt',
      ], inside: repo);
      final PullRequestDraftRepositoryImpl drafts = draftsAt(
        '${world.base}/wt/docs',
      );
      valueOf(await drafts.create(draft('feat/x.md', '# Draft x\n')));
      valueOf(await drafts.create(draft('feat/y.md', '# Draft y\n')));

      expect(
        world.git(<String>[
          'status',
          '--porcelain',
        ], inside: '${world.base}/wt'),
        isEmpty,
      );
      expect(
        world.git(<String>['status', '--porcelain'], inside: repo),
        isEmpty,
      );
      expect(
        valueOf(
          await drafts.read(SpaceRelativePathValueObject('feat/x.md')),
        ).content,
        '# Draft x\n',
      );
    });
  });
}
