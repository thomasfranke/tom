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

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  CommitChangesUseCase committing() => CommitChangesUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it records the index with the message it was given', () async {
    final Result<void, AppFailure> result = await committing().commit(
      docs,
      'docs: say what changed',
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.messages, <String>['docs: say what changed']);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await CommitChangesUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).commit(docs, 'docs: say what changed');

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a refusal is passed through, not reported', () async {
    git.answer = const Failure<void, GitFailure>(GitOperationFailed());

    final Result<void, AppFailure> result = await committing().commit(
      docs,
      'docs: say what changed',
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitOperationFailed(),
    );
    expect(observability.captured, isEmpty);
  });

  test('a detached HEAD is refused, and nothing is committed', () async {
    git.detached = true;

    final Result<void, AppFailure> result = await committing().commit(
      docs,
      'docs: say what changed',
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitDetachedHead(),
    );
    expect(git.messages, isEmpty, reason: 'git was never asked to commit');
    expect(observability.captured, isEmpty, reason: 'a policy is not a fault');
  });

  test(
    'a status git could not read is passed through, not swallowed',
    () async {
      git.statusAnswer = const Failure<GitStatusValueObject, GitFailure>(
        GitOperationFailed(),
      );

      final Result<void, AppFailure> result = await committing().commit(
        docs,
        'docs: say what changed',
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        const GitOperationFailed(),
      );
      expect(git.messages, isEmpty);
    },
  );

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await committing().commit(
      docs,
      'docs: say what changed',
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, remembering the messages it was asked to commit.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  Result<GitStatusValueObject, GitFailure>? statusAnswer;
  bool throws = false;
  bool detached = false;

  final List<String> messages = <String>[];

  @override
  Future<Result<void, GitFailure>> commit(String message) async {
    messages.add(message);
    return throws
        ? throw StateError('git fell over')
        : (answer ?? const Success<void, GitFailure>(null));
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      statusAnswer ??
      Success<GitStatusValueObject, GitFailure>(
        GitStatusValueObject(
          branch: detached ? null : BranchNameValueObject('main'),
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: const <StatusEntryValueObject>[],
          isDetached: detached,
        ),
      );

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      throw UnimplementedError();

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> fetch() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> pull() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> push() async => throw UnimplementedError();
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
