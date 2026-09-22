import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final Space docs = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePath path = SpaceRelativePath('guides/writing.md');
  final Document document = Document(path: path, content: '# Title\n');
  final ParsedDocument parsed = ParsedDocument(
    document: document,
    blocks: const <Block>[
      Block(
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
    required Result<Document, DocumentFailure> read,
    Result<ParsedDocument, DocumentFailure>? blocks,
  }) => ReadDocumentUseCase(
    documentsFor: (Space space) => _Documents(answer: read),
    blocks: _Blocks(
      answer: blocks ?? Success<ParsedDocument, DocumentFailure>(parsed),
    ),
    observability: observability,
  );

  test('it hands back the document, split into blocks', () async {
    final Result<ParsedDocument, AppFailure> result = await readingWith(
      read: Success<Document, DocumentFailure>(document),
    ).read(docs, path);

    expect((result as Success<ParsedDocument, AppFailure>).value, parsed);
  });

  test('the repository is built for the space it was asked about', () async {
    // A repository is per space, and handing the wrong one a relative path
    // would read a file from another folder.
    final List<Space> asked = <Space>[];

    await ReadDocumentUseCase(
      documentsFor: (Space space) {
        asked.add(space);
        return _Documents(answer: Success<Document, DocumentFailure>(document));
      },
      blocks: _Blocks(answer: Success<ParsedDocument, DocumentFailure>(parsed)),
      observability: observability,
    ).read(docs, path);

    expect(asked, <Space>[docs]);
  });

  group('an expected failure stays expected', () {
    test('a document that is gone is passed through', () async {
      final Result<ParsedDocument, AppFailure> result = await readingWith(
        read: Failure<Document, DocumentFailure>(DocumentNotFound(path.value)),
      ).read(docs, path);

      expect(
        (result as Failure<ParsedDocument, AppFailure>).failure,
        DocumentNotFound(path.value),
      );
    });

    test('and the parser is never asked about a file that failed', () async {
      // Reading and parsing fail differently, and the second one has
      // nothing to say about a file that was never read.
      final _Blocks blocks = _Blocks(
        answer: Success<ParsedDocument, DocumentFailure>(parsed),
      );

      await ReadDocumentUseCase(
        documentsFor: (Space space) => _Documents(
          answer: Failure<Document, DocumentFailure>(
            DocumentNotFound(path.value),
          ),
        ),
        blocks: blocks,
        observability: observability,
      ).read(docs, path);

      expect(blocks.asked, isEmpty);
    });

    test('a parse that broke is passed through too', () async {
      final Result<ParsedDocument, AppFailure> result = await readingWith(
        read: Success<Document, DocumentFailure>(document),
        blocks: const Failure<ParsedDocument, DocumentFailure>(
          DocumentOperationFailed('guides/writing.md'),
        ),
      ).read(docs, path);

      expect(
        (result as Failure<ParsedDocument, AppFailure>).failure,
        const DocumentOperationFailed('guides/writing.md'),
      );
    });

    test('and nothing is reported to observability', () async {
      await readingWith(
        read: Failure<Document, DocumentFailure>(DocumentNotFound(path.value)),
      ).read(docs, path);

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case, and is reported', () async {
      final Result<ParsedDocument, AppFailure> result =
          await ReadDocumentUseCase(
            documentsFor: (Space space) => _ThrowingDocuments(),
            blocks: _Blocks(
              answer: Success<ParsedDocument, DocumentFailure>(parsed),
            ),
            observability: observability,
          ).read(docs, path);

      expect(
        (result as Failure<ParsedDocument, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });
}

/// A repository that answers what it was told to.
final class _Documents implements DocumentRepository {
  const _Documents({required this.answer});

  final Result<Document, DocumentFailure> answer;

  @override
  Future<Result<Document, DocumentFailure>> read(
    SpaceRelativePath path,
  ) async => answer;

  @override
  Future<Result<void, DocumentFailure>> write(Document document) async =>
      throw UnimplementedError();
}

/// A repository that breaks its contract by throwing.
final class _ThrowingDocuments implements DocumentRepository {
  @override
  Future<Result<Document, DocumentFailure>> read(
    SpaceRelativePath path,
  ) async => throw StateError('the disk caught fire');

  @override
  Future<Result<void, DocumentFailure>> write(Document document) async =>
      throw UnimplementedError();
}

/// A reader that answers what it was told to, and remembers being asked.
final class _Blocks implements BlockReader {
  _Blocks({required this.answer});

  final Result<ParsedDocument, DocumentFailure> answer;
  final List<Document> asked = <Document>[];

  @override
  Future<Result<ParsedDocument, DocumentFailure>> read(
    Document document,
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
