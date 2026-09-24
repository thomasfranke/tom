import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Git git;
  late _Blocks blocks;
  late _Aligner aligner;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  /// A document whose blocks are [sources].
  ParsedDocumentValueObject documentOf(List<String> sources) =>
      ParsedDocumentValueObject(
        document: DocumentEntity(path: writing, content: sources.join('\n\n')),
        blocks: <BlockValueObject>[
          for (int index = 0; index < sources.length; index++)
            BlockValueObject(
              startLine: index,
              endLine: index,
              source: sources[index],
              kind: BlockKindEnum.paragraph,
            ),
        ],
        linkDefinitions: '',
      );

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
    blocks = _Blocks(documentOf: documentOf);
    aligner = _Aligner();
  });

  DiffDocumentUseCase diffing() => DiffDocumentUseCase(
    gitFor: (SpaceEntity space) => git,
    blocks: blocks,
    differ: BlockDifferService(aligner: aligner),
    observability: observability,
  );

  test('it compares against HEAD, asking git for that file', () async {
    git.content = 'committed';

    await diffing().diff(space: docs, after: documentOf(<String>['buffer']));

    expect(git.revision, 'HEAD');
    // Repository-relative, because that is the only spelling git answers to
    // — and a space is a folder inside a repository, not the repository.
    expect(git.path?.value, 'docs/guides/writing.md');
  });

  test('the committed text is what the before side is parsed from', () async {
    git.content = 'committed';

    await diffing().diff(space: docs, after: documentOf(<String>['buffer']));

    expect(blocks.documents.single.content, 'committed');
    // Only the old side is parsed here: the new one arrived split, because
    // the preview had just drawn it.
    expect(blocks.documents, hasLength(1));
  });

  test('a document the revision does not hold is every block added', () async {
    git.answer = const Failure<String, GitFailure>(
      GitPathNotInRevision('docs/guides/writing.md'),
    );

    final Result<DocumentDiffValueObject, AppFailure> result = await diffing()
        .diff(space: docs, after: documentOf(<String>['one', 'two']));

    // The before side is an empty document, so the aligner is handed nothing
    // to pair against — and the reader is shown a new file, not an error.
    expect(blocks.documents.single.content, '');
    expect(
      (result as Success<DocumentDiffValueObject, AppFailure>).value.blocks,
      everyElement(isA<DiffBlockAdded>()),
    );
  });

  test('any other git failure is reported as itself', () async {
    git.answer = const Failure<String, GitFailure>(GitNotInstalled());

    final Result<DocumentDiffValueObject, AppFailure> result = await diffing()
        .diff(space: docs, after: documentOf(<String>['one']));

    expect(
      (result as Failure<DocumentDiffValueObject, AppFailure>).failure,
      isA<GitNotInstalled>(),
    );
  });

  test('a before side that will not parse is reported as itself', () async {
    blocks.answer = const Failure<ParsedDocumentValueObject, DocumentFailure>(
      DocumentOperationFailed('guides/writing.md'),
    );

    final Result<DocumentDiffValueObject, AppFailure> result = await diffing()
        .diff(space: docs, after: documentOf(<String>['one']));

    expect(
      (result as Failure<DocumentDiffValueObject, AppFailure>).failure,
      isA<DocumentOperationFailed>(),
    );
  });

  test('another revision can be asked for', () async {
    await diffing().diff(
      space: docs,
      after: documentOf(<String>['buffer']),
      revision: 'main',
    );

    // What the branch and commit diff will pass; HEAD is only the default.
    expect(git.revision, 'main');
  });

  test('an exception is captured and reported as unexpected', () async {
    git.throws = true;

    final Result<DocumentDiffValueObject, AppFailure> result = await diffing()
        .diff(space: docs, after: documentOf(<String>['one']));

    expect(
      (result as Failure<DocumentDiffValueObject, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, remembering what revision and path it was asked for.
final class _Git implements GitRepository {
  String content = '';
  Result<String, GitFailure>? answer;
  bool throws = false;

  String? revision;
  RepoRelativePathValueObject? path;

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    this.revision = revision;
    this.path = path;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? Success<String, GitFailure>(content));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A reader that splits on blank lines, keeping what it was handed.
final class _Blocks implements BlockReaderPort {
  _Blocks({required this.documentOf});

  final ParsedDocumentValueObject Function(List<String> sources) documentOf;

  /// Every document this was asked to split, in order.
  final List<DocumentEntity> documents = <DocumentEntity>[];
  Result<ParsedDocumentValueObject, DocumentFailure>? answer;

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async {
    documents.add(document);
    return answer ??
        Success<ParsedDocumentValueObject, DocumentFailure>(
          documentOf(<String>[
            for (final String source in document.content.split('\n\n'))
              if (source.trim().isNotEmpty) source,
          ]),
        );
  }
}

/// An aligner that pairs nothing: every old block went, every new one came.
final class _Aligner implements BlockAlignerPort {
  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async => Success<List<SequenceEditValueObject>, DocumentFailure>(
    <SequenceEditValueObject>[
      for (int index = 0; index < before.blocks.length; index++)
        SequenceEditValueObject(
          kind: SequenceEditKindEnum.removed,
          beforeIndex: index,
        ),
      for (int index = 0; index < after.blocks.length; index++)
        SequenceEditValueObject(
          kind: SequenceEditKindEnum.added,
          afterIndex: index,
        ),
    ],
  );
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
