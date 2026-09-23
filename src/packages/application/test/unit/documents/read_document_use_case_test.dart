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
  final ParsedDocumentValueObject parsed = ParsedDocumentValueObject(
    document: document,
    blocks: const <BlockValueObject>[
      BlockValueObject(
        startLine: 0,
        endLine: 0,
        source: '# Title',
        kind: BlockKindEnum.heading,
      ),
    ],
    linkDefinitions: '',
  );

  setUp(() => observability = _RecordingObservability());

  /// The use case over a repository and a reader answering what they are
  /// told to.
  ReadDocumentUseCase readingWith({
    required Result<DocumentEntity, DocumentFailure> read,
    Result<ParsedDocumentValueObject, DocumentFailure>? blocks,
  }) => ReadDocumentUseCase(
    documentsFor: (SpaceEntity space) => _Documents(answer: read),
    blocks: _Blocks(
      answer:
          blocks ?? Success<ParsedDocumentValueObject, DocumentFailure>(parsed),
    ),
    observability: observability,
  );

  test('it hands back the document, split into blocks', () async {
    final Result<ParsedDocumentValueObject, AppFailure> result =
        await readingWith(
          read: Success<DocumentEntity, DocumentFailure>(document),
        ).read(docs, path);

    expect(
      (result as Success<ParsedDocumentValueObject, AppFailure>).value,
      parsed,
    );
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
      blocks: _Blocks(
        answer: Success<ParsedDocumentValueObject, DocumentFailure>(parsed),
      ),
      observability: observability,
    ).read(docs, path);

    expect(asked, <SpaceEntity>[docs]);
  });

  group('an expected failure stays expected', () {
    test('a document that is gone is passed through', () async {
      final Result<ParsedDocumentValueObject, AppFailure> result =
          await readingWith(
            read: Failure<DocumentEntity, DocumentFailure>(
              DocumentNotFound(path.value),
            ),
          ).read(docs, path);

      expect(
        (result as Failure<ParsedDocumentValueObject, AppFailure>).failure,
        DocumentNotFound(path.value),
      );
    });

    test('and the parser is never asked about a file that failed', () async {
      // Reading and parsing fail differently, and the second one has
      // nothing to say about a file that was never read.
      final _Blocks blocks = _Blocks(
        answer: Success<ParsedDocumentValueObject, DocumentFailure>(parsed),
      );

      await ReadDocumentUseCase(
        documentsFor: (SpaceEntity space) => _Documents(
          answer: Failure<DocumentEntity, DocumentFailure>(
            DocumentNotFound(path.value),
          ),
        ),
        blocks: blocks,
        observability: observability,
      ).read(docs, path);

      expect(blocks.asked, isEmpty);
    });

    test('a parse that broke is passed through too', () async {
      final Result<ParsedDocumentValueObject, AppFailure> result =
          await readingWith(
            read: Success<DocumentEntity, DocumentFailure>(document),
            blocks: const Failure<ParsedDocumentValueObject, DocumentFailure>(
              DocumentOperationFailed('guides/writing.md'),
            ),
          ).read(docs, path);

      expect(
        (result as Failure<ParsedDocumentValueObject, AppFailure>).failure,
        const DocumentOperationFailed('guides/writing.md'),
      );
    });

    test('and nothing is reported to observability', () async {
      await readingWith(
        read: Failure<DocumentEntity, DocumentFailure>(
          DocumentNotFound(path.value),
        ),
      ).read(docs, path);

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case, and is reported', () async {
      final Result<ParsedDocumentValueObject, AppFailure> result =
          await ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => _ThrowingDocuments(),
            blocks: _Blocks(
              answer: Success<ParsedDocumentValueObject, DocumentFailure>(
                parsed,
              ),
            ),
            observability: observability,
          ).read(docs, path);

      expect(
        (result as Failure<ParsedDocumentValueObject, AppFailure>).failure,
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

/// A reader that answers what it was told to, and remembers being asked.
final class _Blocks implements BlockReaderPort {
  _Blocks({required this.answer});

  final Result<ParsedDocumentValueObject, DocumentFailure> answer;
  final List<DocumentEntity> asked = <DocumentEntity>[];

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async {
    asked.add(document);
    return answer;
  }
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
