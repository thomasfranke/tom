import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Git git;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );
  // A real one: the type refuses anything that is not 40 hexadecimal
  // characters, which is the whole reason it is a type.
  final CommitShaValueObject sha = CommitShaValueObject(
    'abc1234def5678901234567890abcdef12345678',
  );

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  ReadVersionUseCase reading() => ReadVersionUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it asks for that revision of that file', () async {
    git.content = '# As it was\n';

    final Result<DocumentEntity, AppFailure> result = await reading().read(
      docs,
      sha,
      writing,
    );

    expect(git.revision, sha.value);
    // Repository-relative, because that is the only spelling git answers to.
    expect(git.path?.value, 'docs/guides/writing.md');
    expect(
      (result as Success<DocumentEntity, AppFailure>).value.content,
      '# As it was\n',
    );
  });

  test(
    'what comes back is a document, keeping the path it was asked for',
    () async {
      // The preview splits a document, and a version's own relative links have
      // to resolve where the working copy's do.
      final Result<DocumentEntity, AppFailure> result = await reading().read(
        docs,
        sha,
        writing,
      );

      expect(
        (result as Success<DocumentEntity, AppFailure>).value.path,
        writing,
      );
    },
  );

  test('a commit that never had the file arrives as a failure', () async {
    git.answer = const Failure<String, GitFailure>(GitOperationFailed());

    final Result<DocumentEntity, AppFailure> result = await reading().read(
      docs,
      sha,
      writing,
    );

    expect(
      (result as Failure<DocumentEntity, AppFailure>).failure,
      isA<GitOperationFailed>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<DocumentEntity, AppFailure> result = await reading().read(
      docs,
      sha,
      writing,
    );

    expect(
      (result as Failure<DocumentEntity, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, remembering what revision and path it was asked for.
final class _Git implements GitRepository {
  String content = '';
  Result<String, GitFailure>? answer;
  bool throws = false;

  String? revision;
  RepoRelativePathValueObject? path;

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    this.revision = revision;
    this.path = path;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? Success<String, GitFailure>(content));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An [Observability] that keeps what it was handed.
final class _RecordingObservability implements Observability {
  final List<({Object error, StackTrace stackTrace, String layer})> captured =
      <({Object error, StackTrace stackTrace, String layer})>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async =>
      captured.add((error: error, stackTrace: stackTrace, layer: layer));
}
