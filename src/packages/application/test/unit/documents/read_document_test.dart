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
        kind: BlockKind.heading,
      ),
    ],
    linkDefinitions: '',
  );

  setUp(() => observability = _RecordingObservability());

  /// The use case over a repository and a reader answering what they are
  /// told to.
  ReadDocument readingWith({
    required Result<Document> read,
    Result<ParsedDocument>? blocks,
  }) => ReadDocument(
    documentsFor: (Space space) => _Documents(answer: read),
    blocks: _Blocks(answer: blocks ?? Success<ParsedDocument>(parsed)),
    observability: observability,
  );

  test('it hands back the document, split into blocks', () async {
    final Result<ParsedDocument> result = await readingWith(
      read: Success<Document>(document),
    )(docs, path);

    expect((result as Success<ParsedDocument>).value, parsed);
  });

  test('the repository is built for the space it was asked about', () async {
    // A repository is per space, and handing the wrong one a relative path
    // would read a file from another folder.
    final List<Space> asked = <Space>[];

    await ReadDocument(
      documentsFor: (Space space) {
        asked.add(space);
        return _Documents(answer: Success<Document>(document));
      },
      blocks: _Blocks(answer: Success<ParsedDocument>(parsed)),
      observability: observability,
    )(docs, path);

    expect(asked, <Space>[docs]);
  });

  group('an expected failure stays expected', () {
    test('a document that is gone is passed through', () async {
      final Result<ParsedDocument> result = await readingWith(
        read: Failure<Document>(DocumentNotFound(path.value)),
      )(docs, path);

      expect(
        (result as Failure<ParsedDocument>).failure,
        DocumentNotFound(path.value),
      );
    });

    test('and the parser is never asked about a file that failed', () async {
      // Reading and parsing fail differently, and the second one has
      // nothing to say about a file that was never read.
      final _Blocks blocks = _Blocks(answer: Success<ParsedDocument>(parsed));

      await ReadDocument(
        documentsFor: (Space space) =>
            _Documents(answer: Failure<Document>(DocumentNotFound(path.value))),
        blocks: blocks,
        observability: observability,
      )(docs, path);

      expect(blocks.asked, isEmpty);
    });

    test('a parse that broke is passed through too', () async {
      final Result<ParsedDocument> result = await readingWith(
        read: Success<Document>(document),
        blocks: const Failure<ParsedDocument>(
          DocumentOperationFailed('guides/writing.md', 'broke'),
        ),
      )(docs, path);

      expect(
        (result as Failure<ParsedDocument>).failure,
        const DocumentOperationFailed('guides/writing.md', 'broke'),
      );
    });

    test('and nothing is reported to observability', () async {
      await readingWith(read: Failure<Document>(DocumentNotFound(path.value)))(
        docs,
        path,
      );

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case, and is reported', () async {
      final Result<ParsedDocument> result = await ReadDocument(
        documentsFor: (Space space) => _ThrowingDocuments(),
        blocks: _Blocks(answer: Success<ParsedDocument>(parsed)),
        observability: observability,
      )(docs, path);

      expect(
        (result as Failure<ParsedDocument>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });
}

/// A repository that answers what it was told to.
final class _Documents implements DocumentRepository {
  const _Documents({required this.answer});

  final Result<Document> answer;

  @override
  Future<Result<Document>> read(SpaceRelativePath path) async => answer;

  @override
  Future<Result<void>> write(Document document) async =>
      throw UnimplementedError();
}

/// A repository that breaks its contract by throwing.
final class _ThrowingDocuments implements DocumentRepository {
  @override
  Future<Result<Document>> read(SpaceRelativePath path) async =>
      throw StateError('the disk caught fire');

  @override
  Future<Result<void>> write(Document document) async =>
      throw UnimplementedError();
}

/// A reader that answers what it was told to, and remembers being asked.
final class _Blocks implements BlockReader {
  _Blocks({required this.answer});

  final Result<ParsedDocument> answer;
  final List<Document> asked = <Document>[];

  @override
  Future<Result<ParsedDocument>> read(Document document) async {
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
