import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

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

  test('it hands back what the reader made of the source', () async {
    final Result<ParsedDocumentValueObject, AppFailure> result =
        await SplitDocumentUseCase(
          blocks: _Blocks(
            answer: Success<ParsedDocumentValueObject, DocumentFailure>(parsed),
          ),
          observability: observability,
        ).split(document);

    expect(
      (result as Success<ParsedDocumentValueObject, AppFailure>).value,
      parsed,
    );
  });

  test('it splits a buffer no file holds', () async {
    // The whole reason this is not part of reading: the preview renders
    // what is being typed, which has not reached the disk.
    final _Blocks blocks = _Blocks(
      answer: Success<ParsedDocumentValueObject, DocumentFailure>(parsed),
    );
    final DocumentEntity edited = document.copyWith(content: '# Typed\n');

    await SplitDocumentUseCase(
      blocks: blocks,
      observability: observability,
    ).split(edited);

    expect(blocks.asked, <DocumentEntity>[edited]);
  });

  test('a parse that broke is passed through, not reported', () async {
    final Result<ParsedDocumentValueObject, AppFailure> result =
        await SplitDocumentUseCase(
          blocks: _Blocks(
            answer: const Failure<ParsedDocumentValueObject, DocumentFailure>(
              DocumentOperationFailed('guides/writing.md'),
            ),
          ),
          observability: observability,
        ).split(document);

    expect(
      (result as Failure<ParsedDocumentValueObject, AppFailure>).failure,
      const DocumentOperationFailed('guides/writing.md'),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<ParsedDocumentValueObject, AppFailure> result =
        await SplitDocumentUseCase(
          blocks: _ThrowingBlocks(),
          observability: observability,
        ).split(document);

    expect(
      (result as Failure<ParsedDocumentValueObject, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
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

/// A reader that breaks its contract by throwing.
final class _ThrowingBlocks implements BlockReaderPort {
  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => throw StateError('the parser fell over');
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
