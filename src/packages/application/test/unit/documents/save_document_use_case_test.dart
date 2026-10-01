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
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'guides/writing.md',
  );
  final DocumentEntity document = DocumentEntity(
    path: path,
    content: '# Title\n',
  );

  setUp(() => observability = _RecordingObservability());

  test('it writes the document it was handed', () async {
    final _Documents documents = _Documents();

    final Result<void, AppFailure> result = await SaveDocumentUseCase(
      documentsFor: (SpaceEntity space) => documents,
      observability: observability,
    ).save(docs, document);

    expect(result, isA<Success<void, AppFailure>>());
    expect(documents.written, <DocumentEntity>[document]);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await SaveDocumentUseCase(
      documentsFor: (SpaceEntity space) {
        asked.add(space);
        return _Documents();
      },
      observability: observability,
    ).save(docs, document);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a refused write is passed through, not reported', () async {
    final Result<void, AppFailure> result = await SaveDocumentUseCase(
      documentsFor: (SpaceEntity space) => _Documents(
        answer: Failure<void, DocumentFailure>(
          DocumentPermissionDenied(path.value),
        ),
      ),
      observability: observability,
    ).save(docs, document);

    expect(
      (result as Failure<void, AppFailure>).failure,
      DocumentPermissionDenied(path.value),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<void, AppFailure> result = await SaveDocumentUseCase(
      documentsFor: (SpaceEntity space) => _ThrowingDocuments(),
      observability: observability,
    ).save(docs, document);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// A repository that keeps what it was asked to write.
final class _Documents implements DocumentRepository {
  _Documents({this.answer});

  final Result<void, DocumentFailure>? answer;
  final List<DocumentEntity> written = <DocumentEntity>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document);
    return answer ?? const Success<void, DocumentFailure>(null);
  }
}

/// A repository that breaks its contract by throwing.
final class _ThrowingDocuments implements DocumentRepository {
  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw StateError('the disk caught fire');
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
