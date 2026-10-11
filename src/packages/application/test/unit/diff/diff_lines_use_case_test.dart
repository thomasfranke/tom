import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Git git;
  late _Aligner aligner;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final DocumentEntity buffer = DocumentEntity(
    path: SpaceRelativePathValueObject('site.yaml'),
    content: 'title: Docs\nlang: en\n',
  );

  setUp(() {
    git = _Git();
    aligner = _Aligner();
  });

  DiffLinesUseCase diffing() => DiffLinesUseCase(
    gitFor: (SpaceEntity space) => git,
    differ: LineDifferService(aligner: aligner),
    observability: const _SilentObservability(),
  );

  test('it compares against HEAD by default, by git\'s path', () async {
    git.answer = const Success<String, GitFailure>('title: Docs\n');
    await diffing().diff(space: docs, after: buffer);
    expect(git.revision, 'HEAD');
    expect(git.path?.value, 'docs/site.yaml');
    expect(aligner.before, <String>['title: Docs']);
    expect(aligner.after, <String>['title: Docs', 'lang: en']);
  });

  test('another revision is the one asked of git', () async {
    await diffing().diff(space: docs, after: buffer, revision: 'abc123');
    expect(git.revision, 'abc123');
  });

  test('a file the revision does not hold is compared with nothing', () async {
    git.answer = const Failure<String, GitFailure>(
      GitPathNotInRevision('docs/site.yaml'),
    );
    final Result<LineDiffValueObject, AppFailure> result = await diffing().diff(
      space: docs,
      after: buffer,
    );
    expect(result, isA<Success<LineDiffValueObject, AppFailure>>());
    expect(aligner.before, isEmpty);
  });

  test('a file the status calls new is not asked about at all', () async {
    final Result<LineDiffValueObject, AppFailure> result = await diffing().diff(
      space: docs,
      after: buffer,
      status: GitStatusValueObject(
        branch: null,
        upstream: null,
        ahead: 0,
        behind: 0,
        isDetached: false,
        entries: <StatusEntryValueObject>[
          StatusEntryValueObject(
            path: RepoRelativePathValueObject('docs/site.yaml'),
            state: FileStateEnum.added,
            isStaged: true,
          ),
        ],
      ),
    );

    expect(result, isA<Success<LineDiffValueObject, AppFailure>>());
    expect(git.path, isNull, reason: 'git was never asked');
    expect(aligner.before, isEmpty);
  });

  test('any other refusal from git is the diff failing', () async {
    const GitFailure broken = GitOperationFailed();
    git.answer = const Failure<String, GitFailure>(broken);
    final Result<LineDiffValueObject, AppFailure> result = await diffing().diff(
      space: docs,
      after: buffer,
    );
    expect(
      (result as Failure<LineDiffValueObject, AppFailure>).failure,
      broken,
    );
  });
}

final class _Git implements GitRepository {
  Result<String, GitFailure> answer = const Success<String, GitFailure>('');
  String? revision;
  RepoRelativePathValueObject? path;

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    this.revision = revision;
    this.path = path;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Aligner implements LineAlignerPort {
  List<String>? before;
  List<String>? after;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  }) async {
    this.before = before;
    this.after = after;
    return const Success<List<SequenceEditValueObject>, DocumentFailure>(
      <SequenceEditValueObject>[],
    );
  }
}

final class _SilentObservability implements Observability {
  const _SilentObservability();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
