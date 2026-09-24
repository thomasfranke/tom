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

  /// The use case over a repository answering what it is told to.
  ReadDocumentUseCase readingWith(
    Result<DocumentEntity, DocumentFailure> read,
  ) => ReadDocumentUseCase(
    documentsFor: (SpaceEntity space) => _Documents(answer: read),
    observability: observability,
  );

  test('it hands back the document as it is on disk', () async {
    final Result<DocumentEntity, AppFailure> result = await readingWith(
      Success<DocumentEntity, DocumentFailure>(document),
    ).read(docs, path);

    expect((result as Success<DocumentEntity, AppFailure>).value, document);
  });

  test('the repository is built for the space it was asked about', () async {
    // A repository is per space, and handing the wrong one a relative path
    // would read a file from another folder.
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await ReadDocumentUseCase(
      documentsFor: (SpaceEntity space) {
        asked.add(space);
        return _Documents(
          answer: Success<DocumentEntity, DocumentFailure>(document),
        );
      },
      observability: observability,
    ).read(docs, path);

    expect(asked, <SpaceEntity>[docs]);
  });

  group('an expected failure stays expected', () {
    test('a document that is gone is passed through', () async {
      final Result<DocumentEntity, AppFailure> result = await readingWith(
        Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value)),
      ).read(docs, path);

      expect(
        (result as Failure<DocumentEntity, AppFailure>).failure,
        DocumentNotFound(path.value),
      );
    });

    test('and nothing is reported to observability', () async {
      await readingWith(
        Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value)),
      ).read(docs, path);

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case, and is reported', () async {
      final Result<DocumentEntity, AppFailure> result =
          await ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => _ThrowingDocuments(),
            observability: observability,
          ).read(docs, path);

      expect(
        (result as Failure<DocumentEntity, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });
}

/// A repository that answers what it was told to.
final class _Documents implements DocumentRepository {
  const _Documents({required this.answer});

  final Result<DocumentEntity, DocumentFailure> answer;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => answer;

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}

/// A repository that breaks its contract by throwing.
final class _ThrowingDocuments implements DocumentRepository {
  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => throw StateError('the disk caught fire');

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
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
