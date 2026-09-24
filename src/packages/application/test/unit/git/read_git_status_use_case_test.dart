import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final GitStatusValueObject onMain = GitStatusValueObject(
    branch: BranchNameValueObject('main'),
    upstream: null,
    ahead: 0,
    behind: 0,
    entries: const <StatusEntryValueObject>[],
    isDetached: false,
  );
  final Result<GitStatusValueObject, GitFailure> reported =
      Success<GitStatusValueObject, GitFailure>(onMain);

  setUp(() => observability = _RecordingObservability());

  test('it hands back what git said', () async {
    final Result<GitStatusValueObject, AppFailure> result =
        await ReadGitStatusUseCase(
          gitFor: (SpaceEntity space) => _Git(answer: reported),
          observability: observability,
        ).read(docs);

    expect((result as Success<GitStatusValueObject, AppFailure>).value, onMain);
  });

  test('the repository is built for the space it was asked about', () async {
    // A repository is per space: git runs in that space's repository, and
    // the wrong one would report another checkout entirely.
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await ReadGitStatusUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return _Git(answer: reported);
      },
      observability: observability,
    ).read(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a folder outside a repository passes through, not reported', () async {
    final Result<GitStatusValueObject, AppFailure> result =
        await ReadGitStatusUseCase(
          gitFor: (SpaceEntity space) => const _Git(
            answer: Failure<GitStatusValueObject, GitFailure>(
              GitNotARepository('/code/app'),
            ),
          ),
          observability: observability,
        ).read(docs);

    expect(
      (result as Failure<GitStatusValueObject, AppFailure>).failure,
      const GitNotARepository('/code/app'),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<GitStatusValueObject, AppFailure> result =
        await ReadGitStatusUseCase(
          gitFor: (SpaceEntity space) => const _Git(),
          observability: observability,
        ).read(docs);

    expect(
      (result as Failure<GitStatusValueObject, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering what it was told to and throwing for everything else.
///
/// Throwing rather than returning is the point for the unasked methods: a
/// use case that called one would fail loudly instead of quietly passing.
final class _Git implements GitRepository {
  const _Git({this.answer});

  /// What `status()` reports, or null to throw instead.
  final Result<GitStatusValueObject, GitFailure>? answer;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      answer ?? (throw StateError('git fell over'));

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
  Future<Result<void, GitFailure>> commit(String message) async =>
      throw UnimplementedError();

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
