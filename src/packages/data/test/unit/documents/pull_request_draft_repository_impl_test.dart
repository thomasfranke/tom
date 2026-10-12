/// [PullRequestDraftRepositoryImpl]: where the drafts are looked for, and
/// that git is asked once — against a git that answers on command and a
/// filesystem of one file. A real worktree is the integration suite's.
library;

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Git git;
  late _Disk disk;
  late PullRequestDraftRepositoryImpl drafts;
  final SpaceRelativePathValueObject branchFile = SpaceRelativePathValueObject(
    'feat-x.md',
  );

  setUp(() {
    git = _Git();
    disk = _Disk();
    drafts = PullRequestDraftRepositoryImpl(
      git: git,
      documents: DocumentDataSource(filesystem: disk),
    );
  });

  test('a draft is read under the git directory git named', () async {
    disk.content = '# Title\n';

    final Result<DocumentEntity, DocumentFailure> read = await drafts.read(
      branchFile,
    );

    expect(disk.touched.single, '/repo/.git/tom/pull-request/feat-x.md');
    expect(
      (read as Success<DocumentEntity, DocumentFailure>).value.content,
      '# Title\n',
    );
  });

  test('git is asked once for every kind of request', () async {
    await drafts.read(branchFile);
    await drafts.readBytes(branchFile);
    await drafts.write(DocumentEntity(path: branchFile, content: 'x'));
    await drafts.create(DocumentEntity(path: branchFile, content: 'y'));

    expect(git.asked, 1);
    expect(disk.touched, hasLength(4));
  });

  test(
    'git refusing is a failure about the draft, and is asked again',
    () async {
      git.answer = const Failure<String, GitFailure>(GitCommandDenied());

      final Result<DocumentEntity, DocumentFailure> first = await drafts.read(
        branchFile,
      );
      git.answer = const Success<String, GitFailure>('/repo/.git');
      final Result<DocumentEntity, DocumentFailure> second = await drafts.read(
        branchFile,
      );

      expect(
        (first as Failure<DocumentEntity, DocumentFailure>).failure,
        isA<DocumentOperationFailed>().having(
          (DocumentOperationFailed f) => f.path,
          'path',
          'feat-x.md',
        ),
      );
      expect(second, isA<Success<DocumentEntity, DocumentFailure>>());
      expect(git.asked, 2);
    },
  );

  test('each request names the draft in the failure git caused', () async {
    git.answer = const Failure<String, GitFailure>(GitCommandDenied());
    final DocumentEntity document = DocumentEntity(
      path: branchFile,
      content: 'x',
    );

    for (final Result<Object?, DocumentFailure> result
        in <Result<Object?, DocumentFailure>>[
          await drafts.readBytes(branchFile),
          await drafts.create(document),
          await drafts.write(document),
        ]) {
      expect(
        (result as Failure<Object?, DocumentFailure>).failure,
        isA<DocumentOperationFailed>(),
      );
    }
  });
}

final class _Git implements GitRepository {
  int asked = 0;
  Result<String, GitFailure> answer = const Success<String, GitFailure>(
    '/repo/.git',
  );

  @override
  Future<Result<String, GitFailure>> gitDirectory() async {
    asked++;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _Disk implements Filesystem {
  String content = '';
  final List<String> touched = <String>[];

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    touched.add(path);
    return Success<String, FilesystemFailure>(content);
  }

  @override
  Future<Result<Uint8List, FilesystemFailure>> readBytes(String path) async {
    touched.add(path);
    return Success<Uint8List, FilesystemFailure>(Uint8List(0));
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async {
    touched.add(path);
    return const Success<void, FilesystemFailure>(null);
  }

  @override
  Future<Result<void, FilesystemFailure>> createFile(
    String path,
    String content,
  ) async {
    touched.add(path);
    return const Success<void, FilesystemFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
