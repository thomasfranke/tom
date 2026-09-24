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

  FetchRemoteUseCase fetching() => FetchRemoteUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it asks the remote what it has', () async {
    final Result<void, AppFailure> result = await fetching().fetch(docs);

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.fetched, 1);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await FetchRemoteUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).fetch(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a remote that refused is passed through, not reported', () async {
    // A machine with no network, or no key, is news for the screen — not a
    // bug to send anywhere.
    git.answer = const Failure<void, GitFailure>(GitAuthenticationFailed());

    final Result<void, AppFailure> result = await fetching().fetch(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitAuthenticationFailed(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await fetching().fetch(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering `fetch` and refusing every other question.
///
/// The unasked methods are left to `noSuchMethod`, which throws: a use case
/// that called one would fail loudly rather than pass quietly, and saying it
/// once beats eleven bodies that all say `UnimplementedError`.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;
  int fetched = 0;

  @override
  Future<Result<void, GitFailure>> fetch() async {
    fetched++;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? const Success<void, GitFailure>(null));
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
