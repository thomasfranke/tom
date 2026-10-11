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

  group('asked what it replaces', () {
    Future<Result<void, AppFailure>> saveOver(_Documents documents) =>
        SaveDocumentUseCase(
          documentsFor: (SpaceEntity space) => documents,
          observability: observability,
        ).save(docs, document, replacing: '# Before\n');

    test('a file that still holds it is written', () async {
      final _Documents documents = _Documents(
        onDisk: Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(path: path, content: '# Before\n'),
        ),
      );

      expect(await saveOver(documents), isA<Success<void, AppFailure>>());
      expect(documents.written, <DocumentEntity>[document]);
    });

    test('a file somebody else changed is refused, and not written', () async {
      final _Documents documents = _Documents(
        onDisk: Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(path: path, content: '# Theirs\n'),
        ),
      );

      expect(
        ((await saveOver(documents)) as Failure<void, AppFailure>).failure,
        DocumentExternalChangeConflict(path.value),
      );
      expect(documents.written, isEmpty);
      expect(observability.captured, isEmpty);
    });

    test('a file that stopped being text is refused too', () async {
      final _Documents documents = _Documents(
        onDisk: Failure<DocumentEntity, DocumentFailure>(
          DocumentNotUtf8(path.value),
        ),
      );

      expect(
        ((await saveOver(documents)) as Failure<void, AppFailure>).failure,
        DocumentExternalChangeConflict(path.value),
      );
      expect(documents.written, isEmpty);
    });

    test('a file that is gone is written again', () async {
      final _Documents documents = _Documents(
        onDisk: Failure<DocumentEntity, DocumentFailure>(
          DocumentNotFound(path.value),
        ),
      );

      expect(await saveOver(documents), isA<Success<void, AppFailure>>());
      expect(documents.written, <DocumentEntity>[document]);
    });

    test('a disk that will not say leaves the refusal to the write', () async {
      final _Documents documents = _Documents(
        onDisk: Failure<DocumentEntity, DocumentFailure>(
          DocumentPermissionDenied(path.value),
        ),
        answer: Failure<void, DocumentFailure>(
          DocumentPermissionDenied(path.value),
        ),
      );

      expect(
        ((await saveOver(documents)) as Failure<void, AppFailure>).failure,
        DocumentPermissionDenied(path.value),
      );
    });
  });

  test('asked nothing, the disk is not read before the write', () async {
    final _Documents documents = _Documents();

    await SaveDocumentUseCase(
      documentsFor: (SpaceEntity space) => documents,
      observability: observability,
    ).save(docs, document);

    expect(documents.asked, 0);
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
  _Documents({this.answer, this.onDisk});

  final Result<void, DocumentFailure>? answer;

  /// What the disk says when it is asked; unset, asking is a test's mistake.
  final Result<DocumentEntity, DocumentFailure>? onDisk;
  final List<DocumentEntity> written = <DocumentEntity>[];
  int asked = 0;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    asked++;
    return onDisk ?? (throw UnimplementedError());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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
