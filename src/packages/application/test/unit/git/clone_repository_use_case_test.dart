import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Cloner cloner;
  late _Spaces spaces;
  late _Recents recents;

  final SpaceEntity cloned = SpaceEntity(
    root: '/code/docs',
    repositoryRoot: '/code/docs',
    name: 'docs',
  );

  setUp(() {
    observability = _RecordingObservability();
    cloner = _Cloner();
    spaces = _Spaces(answer: Success<SpaceEntity, AppFailure>(cloned));
    recents = _Recents();
  });

  CloneRepositoryUseCase cloning() => CloneRepositoryUseCase(
    cloner: cloner,
    openSpace: OpenSpaceUseCase(
      spaces: spaces,
      recents: recents,
      observability: observability,
    ),
    observability: observability,
  );

  Future<Result<SpaceEntity, AppFailure>> clone({
    void Function(CloneProgressValueObject progress)? onProgress,
  }) => cloning().clone(
    url: 'https://example.com/docs.git',
    destination: '/code/docs',
    onProgress: onProgress,
  );

  test('clones, then opens the folder as a space at once', () async {
    final Result<SpaceEntity, AppFailure> result = await clone();

    expect((result as Success<SpaceEntity, AppFailure>).value, cloned);
    expect(cloner.asked, ('https://example.com/docs.git', '/code/docs'));
    expect(spaces.asked, '/code/docs');
  });

  test('the space is remembered, as any space opened by hand', () async {
    await clone();

    expect(recents.remembered, <SpaceEntity>[cloned]);
  });

  test('progress reaches whoever is waiting', () async {
    const CloneProgressValueObject receiving = CloneProgressValueObject(
      stage: CloneStageEnum.receiving,
      percent: 40,
    );
    cloner.reports = <CloneProgressValueObject>[receiving];
    final List<CloneProgressValueObject> heard = <CloneProgressValueObject>[];

    await clone(onProgress: heard.add);

    expect(heard, <CloneProgressValueObject>[receiving]);
  });

  group('a clone that fails', () {
    for (final GitFailure failure in <GitFailure>[
      const GitRemoteNotFound(),
      const GitAuthenticationFailed(),
      const GitNetworkUnavailable(),
      const GitCloneDestinationTaken('/code/docs'),
    ]) {
      test(
        '${failure.runtimeType} is passed through, and opens nothing',
        () async {
          cloner.answer = Failure<void, GitFailure>(failure);

          final Result<SpaceEntity, AppFailure> result = await clone();

          expect((result as Failure<SpaceEntity, AppFailure>).failure, failure);
          expect(spaces.asked, isNull);
          expect(observability.captured, isEmpty);
        },
      );
    }
  });

  test('a folder that will not open says why, in its own words', () async {
    spaces = _Spaces(
      answer: const Failure<SpaceEntity, AppFailure>(
        SpaceFolderMissing('/code/docs'),
      ),
    );

    final Result<SpaceEntity, AppFailure> result = await clone();

    expect(
      (result as Failure<SpaceEntity, AppFailure>).failure,
      const SpaceFolderMissing('/code/docs'),
    );
  });

  test('an exception never escapes the use case, and is reported', () async {
    cloner.throws = true;

    final Result<SpaceEntity, AppFailure> result = await clone();

    expect(
      (result as Failure<SpaceEntity, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// A clone that answers what it was told to, and reports [reports] first.
final class _Cloner implements GitCloneRepository {
  Result<void, GitFailure> answer = const Success<void, GitFailure>(null);
  List<CloneProgressValueObject> reports = <CloneProgressValueObject>[];
  bool throws = false;
  (String, String)? asked;

  @override
  Future<Result<void, GitFailure>> clone({
    required String url,
    required String destination,
    void Function(CloneProgressValueObject progress)? onProgress,
  }) async {
    if (throws) {
      throw StateError('git fell over');
    }
    asked = (url, destination);
    reports.forEach(onProgress ?? (CloneProgressValueObject _) {});
    return answer;
  }
}

/// Spaces that open to [answer], remembering the folder; nothing else.
final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<SpaceEntity, AppFailure> answer;
  String? asked;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async {
    asked = folder;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A recent list that records what it was asked to remember.
final class _Recents implements RecentSpacesRepository {
  final List<SpaceEntity> remembered = <SpaceEntity>[];

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async {
    remembered.add(space);
    return const Success<void, Never>(null);
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
