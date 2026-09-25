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

  final List<SpaceEntryValueObject> held = <SpaceEntryValueObject>[
    SpaceEntryValueObject(
      path: SpaceRelativePathValueObject('guides'),
      type: SpaceEntryTypeEnum.directory,
    ),
    SpaceEntryValueObject(
      path: SpaceRelativePathValueObject('guides/writing.md'),
      type: SpaceEntryTypeEnum.file,
    ),
  ];

  setUp(() => observability = _RecordingObservability());

  /// The use case over a repository that answers [answer].
  ListSpaceEntriesUseCase listingWith(
    Result<List<SpaceEntryValueObject>, SpaceFailure> answer,
  ) => ListSpaceEntriesUseCase(
    spaces: _Spaces(answer: answer),
    observability: observability,
  );

  test('it hands back what the space holds, in the order given', () async {
    final Result<List<SpaceEntryValueObject>, AppFailure> result =
        await listingWith(
          Success<List<SpaceEntryValueObject>, SpaceFailure>(held),
        ).list(docs);

    expect(
      (result as Success<List<SpaceEntryValueObject>, AppFailure>).value,
      held,
    );
  });

  test('the space it was asked about reaches the repository', () async {
    final _Spaces spaces = _Spaces(
      answer: Success<List<SpaceEntryValueObject>, SpaceFailure>(held),
    );

    await ListSpaceEntriesUseCase(
      spaces: spaces,
      observability: observability,
    ).list(docs);

    expect(spaces.asked, docs);
  });

  group('an expected failure stays expected', () {
    test('a folder that is gone is passed through', () async {
      final Result<List<SpaceEntryValueObject>, AppFailure> result =
          await listingWith(
            const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
              SpaceFolderMissing('/code/app/docs'),
            ),
          ).list(docs);

      expect(
        (result as Failure<List<SpaceEntryValueObject>, AppFailure>).failure,
        const SpaceFolderMissing('/code/app/docs'),
      );
    });

    test('and nothing is reported to observability', () async {
      await listingWith(
        const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
          SpaceAccessDenied('/code/app/docs'),
        ),
      ).list(docs);

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case', () async {
      final Result<List<SpaceEntryValueObject>, AppFailure> result =
          await ListSpaceEntriesUseCase(
            spaces: _ThrowingSpaces(),
            observability: observability,
          ).list(docs);

      expect(
        (result as Failure<List<SpaceEntryValueObject>, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
    });

    test('and it is reported, tagged with the layer that caught it', () async {
      await ListSpaceEntriesUseCase(
        spaces: _ThrowingSpaces(),
        observability: observability,
      ).list(docs);

      expect(observability.captured, hasLength(1));
      expect(observability.captured.single.layer, 'application');
      expect(
        observability.captured.single.error.toString(),
        contains('the disk caught fire'),
      );
    });
  });
}

/// A repository that answers what it was told to, and remembers the space.
final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<List<SpaceEntryValueObject>, SpaceFailure> answer;
  SpaceEntity? asked;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async {
    asked = space;
    return answer;
  }
}

/// A repository that breaks its contract by throwing.
final class _ThrowingSpaces implements SpaceRepository {
  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw StateError('the disk caught fire');
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
