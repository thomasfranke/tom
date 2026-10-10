/// [PullRequestDraftRepositoryImpl] against real repositories, a worktree
/// included — where `.git` is a file and the drafts live elsewhere.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory temp;
  late String base;

  void git(List<String> arguments, String inside) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside,
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  PullRequestDraftRepositoryImpl draftsAt(String folder) =>
      PullRequestDraftRepositoryImpl(
        git: GitRepositoryImpl(
          git: GitDataSource(
            client: DartIoGitClientImpl(workingDirectory: folder),
          ),
        ),
        documents: const DocumentDataSource(filesystem: DartIoFilesystemImpl()),
      );

  setUp(() {
    temp = Directory.systemTemp.createTempSync('tom_drafts_');
    base = temp.resolveSymbolicLinksSync();
    Directory('$base/repo').createSync();
    git(<String>['init', '--quiet', '.'], '$base/repo');
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], '$base/repo');
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting], '$base/repo');
    }
    File('$base/repo/a.md').writeAsStringSync('# A\n');
    git(<String>['add', 'a.md'], '$base/repo');
    git(<String>['commit', '--quiet', '--message', 'A'], '$base/repo');
  });

  tearDown(() => temp.deleteSync(recursive: true));

  final DocumentEntity draft = DocumentEntity(
    path: SpaceRelativePathValueObject('feat/x.md'),
    content: '# Close it\n',
  );

  test(
    'a draft is written under .git/tom, where status never sees it',
    () async {
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$base/repo');

      expect(await drafts.create(draft), isA<Success<void, DocumentFailure>>());

      expect(
        File('$base/repo/.git/tom/pull-request/feat/x.md').readAsStringSync(),
        '# Close it\n',
      );
    },
  );

  test(
    'in a worktree, where .git is a file, it lands in the shared one',
    () async {
      git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/x',
        '$base/wt',
      ], '$base/repo');
      final PullRequestDraftRepositoryImpl drafts = draftsAt('$base/wt');

      expect(await drafts.create(draft), isA<Success<void, DocumentFailure>>());

      expect(File('$base/wt/.git').statSync().type, FileSystemEntityType.file);
      expect(
        File('$base/repo/.git/tom/pull-request/feat/x.md').existsSync(),
        isTrue,
      );
      final Result<DocumentEntity, DocumentFailure> read = await draftsAt(
        '$base/repo',
      ).read(draft.path);
      expect(read, isA<Success<DocumentEntity, DocumentFailure>>());
    },
  );

  test('a folder git does not know is a failure, not a write', () async {
    Directory('$base/plain').createSync();
    final Result<void, DocumentFailure> written = await draftsAt(
      '$base/plain',
    ).create(draft);

    expect(written, isA<Failure<void, DocumentFailure>>());
    expect(Directory('$base/plain/.git').existsSync(), isFalse);
  });
}
