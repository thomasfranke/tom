import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Search search;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  SpaceEntryValueObject entry(String path, SpaceEntryTypeEnum type) =>
      SpaceEntryValueObject(
        path: SpaceRelativePathValueObject(path),
        type: type,
      );

  setUp(() {
    observability = _RecordingObservability();
    search = _Search();
  });

  /// The use case over a folder answering what it is told to.
  IndexSpaceUseCase indexingWith(
    Result<List<SpaceEntryValueObject>, SpaceFailure> listed,
  ) => IndexSpaceUseCase(
    spaces: _Spaces(answer: listed),
    searchFor: (SpaceEntity space) => search,
    observability: observability,
  );

  test('every document the space holds is filed, and nothing else', () async {
    // The listing is the file tree's, so an image and a folder are in it.
    await indexingWith(
      Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[
          entry('guides', SpaceEntryTypeEnum.directory),
          entry('guides/writing.md', SpaceEntryTypeEnum.file),
          entry('logo.svg', SpaceEntryTypeEnum.file),
          entry('index.md', SpaceEntryTypeEnum.file),
        ],
      ),
    ).index(docs);

    expect(
      search.indexed.map((SpaceRelativePathValueObject p) => p.value),
      <String>['guides/writing.md', 'index.md'],
    );
  });

  test('the index is the one that belongs to the space asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await IndexSpaceUseCase(
      spaces: const _Spaces(
        answer: Success<List<SpaceEntryValueObject>, SpaceFailure>(
          <SpaceEntryValueObject>[],
        ),
      ),
      searchFor: (SpaceEntity space) {
        asked.add(space);
        return search;
      },
      observability: observability,
    ).index(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  group('an expected failure stays expected', () {
    test('a folder that cannot be listed is passed through', () async {
      final Result<void, AppFailure> result = await indexingWith(
        const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
          SpaceFolderMissing('/code/app/docs'),
        ),
      ).index(docs);

      expect(
        (result as Failure<void, AppFailure>).failure,
        const SpaceFolderMissing('/code/app/docs'),
      );
      expect(observability.captured, isEmpty);
    });

    test('an index that refuses is passed through', () async {
      search.answer = const Failure<void, SearchFailure>(
        SearchIndexCorrupted(),
      );

      final Result<void, AppFailure> result = await indexingWith(
        const Success<List<SpaceEntryValueObject>, SpaceFailure>(
          <SpaceEntryValueObject>[],
        ),
      ).index(docs);

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<SearchIndexCorrupted>(),
      );
      expect(observability.captured, isEmpty);
    });
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<void, AppFailure> result = await IndexSpaceUseCase(
      spaces: _ThrowingSpaces(),
      searchFor: (SpaceEntity space) => search,
      observability: observability,
    ).index(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// A search that keeps what it was given to file.
final class _Search implements SearchRepository {
  List<SpaceRelativePathValueObject> indexed = <SpaceRelativePathValueObject>[];
  Result<void, SearchFailure> answer = const Success<void, SearchFailure>(null);

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async {
    indexed = paths;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A folder that answers what it was told to.
final class _Spaces implements SpaceRepository {
  const _Spaces({required this.answer});

  final Result<List<SpaceEntryValueObject>, SpaceFailure> answer;

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => answer;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) =>
      throw UnimplementedError();
}

/// A folder that breaks its contract by throwing.
final class _ThrowingSpaces implements SpaceRepository {
  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw StateError('the disk caught fire');

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) =>
      throw UnimplementedError();
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
