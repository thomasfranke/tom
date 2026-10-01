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
  final DocumentEntity writing = DocumentEntity(
    path: SpaceRelativePathValueObject('guides/writing.md'),
    content: '# Writing\n',
  );

  setUp(() => observability = _RecordingObservability());

  test('the document is filed again, as it is now', () async {
    final _Search index = _Search();

    await IndexDocumentUseCase(
      searchFor: (SpaceEntity space) => index,
      observability: observability,
    ).index(docs, writing);

    expect(index.refiled, <DocumentEntity>[writing]);
  });

  test('the index is the one that belongs to the space asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await IndexDocumentUseCase(
      searchFor: (SpaceEntity space) {
        asked.add(space);
        return _Search();
      },
      observability: observability,
    ).index(docs, writing);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('an index that refuses is passed through, and not reported', () async {
    final Result<void, AppFailure> result = await IndexDocumentUseCase(
      searchFor: (SpaceEntity space) => _Search()
        ..answer = const Failure<void, SearchFailure>(SearchIndexCorrupted()),
      observability: observability,
    ).index(docs, writing);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<SearchIndexCorrupted>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<void, AppFailure> result = await IndexDocumentUseCase(
      searchFor: (SpaceEntity space) => _ThrowingSearch(),
      observability: observability,
    ).index(docs, writing);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// An index that keeps what it was told to file again.
final class _Search implements SearchRepository {
  List<DocumentEntity> refiled = <DocumentEntity>[];
  Result<void, SearchFailure> answer = const Success<void, SearchFailure>(null);

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async {
    refiled.add(document);
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An index that breaks its contract by throwing.
final class _ThrowingSearch implements SearchRepository {
  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async =>
      throw StateError('the database caught fire');

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
