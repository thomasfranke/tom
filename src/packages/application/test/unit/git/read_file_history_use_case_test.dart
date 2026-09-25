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

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  ReadFileHistoryUseCase reading() => ReadFileHistoryUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it asks about the file, in the repository\'s own spelling', () async {
    await reading().read(docs, writing);

    expect(git.asked?.value, 'docs/guides/writing.md');
  });

  test('it is scoped to the file and never to the repository', () async {
    await reading().read(docs, writing);

    expect(git.asked, isNotNull, reason: 'it asked for the whole repository');
  });

  test('the cap is passed through', () async {
    await reading().read(docs, writing, limit: 25);

    expect(git.limit, 25);
  });

  test('a file git has never seen is an empty list, not a failure', () async {
    git.answer = const Success<List<CommitEntity>, GitFailure>(
      <CommitEntity>[],
    );

    final Result<List<CommitEntity>, AppFailure> result = await reading().read(
      docs,
      writing,
    );

    expect((result as Success<List<CommitEntity>, AppFailure>).value, isEmpty);
  });

  test('a failure arrives as itself', () async {
    git.answer = const Failure<List<CommitEntity>, GitFailure>(
      GitNotARepository('/code/app'),
    );

    final Result<List<CommitEntity>, AppFailure> result = await reading().read(
      docs,
      writing,
    );

    expect(
      (result as Failure<List<CommitEntity>, AppFailure>).failure,
      isA<GitNotARepository>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<List<CommitEntity>, AppFailure> result = await reading().read(
      docs,
      writing,
    );

    expect(
      (result as Failure<List<CommitEntity>, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, remembering what it was asked about.
final class _Git implements GitRepository {
  Result<List<CommitEntity>, GitFailure>? answer;
  bool throws = false;

  RepoRelativePathValueObject? asked;
  int? limit;

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async {
    asked = path;
    this.limit = limit;
    return throws
        ? throw StateError('git fell over')
        : (answer ??
              const Success<List<CommitEntity>, GitFailure>(<CommitEntity>[]));
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
