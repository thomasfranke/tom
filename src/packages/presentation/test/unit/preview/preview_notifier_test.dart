import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late ProviderContainer container;

  final Space docs = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePath writing = SpaceRelativePath('guides/writing.md');
  final SpaceRelativePath index = SpaceRelativePath('index.md');

  ParsedDocument parsedOf(SpaceRelativePath path) => ParsedDocument(
    document: Document(path: path, content: '# ${path.name}\n'),
    blocks: <Block>[
      Block(
        startLine: 0,
        endLine: 0,
        source: '# ${path.name}',
        kind: BlockKindEnum.heading,
      ),
    ],
    linkDefinitions: '',
  );

  setUp(() {
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (Space space) => documents,
            blocks: const _Blocks(),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the preview, and answers its first state.
  PreviewState start() {
    container.listen<PreviewState>(previewProvider, (_, _) {});
    return container.read(previewProvider);
  }

  /// Opens [space] and shows [document], the way the tree does.
  void show(Space space, SpaceRelativePath? document) {
    container.read(spaceSessionProvider.notifier).open(space);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('with no space open there is nothing to read', () async {
    expect(start(), isA<PreviewEmpty>());
    await settle();

    expect(documents.asked, isEmpty);
  });

  test('a space with no document chosen is empty, not loading', () async {
    // Every space opens this way: the tree is on screen and nothing has
    // been clicked.
    start();
    show(docs, null);
    await settle();

    expect(container.read(previewProvider), isA<PreviewEmpty>());
    expect(documents.asked, isEmpty);
  });

  test('choosing a document reads it and shows its blocks', () async {
    start();
    show(docs, writing);

    expect(container.read(previewProvider), isA<PreviewLoading>());
    await settle();
    expect(
      (container.read(previewProvider) as PreviewReady).document,
      parsedOf(writing),
    );
    expect(documents.asked, <SpaceRelativePath>[writing]);
  });

  test('choosing another document reads that one', () async {
    start();
    show(docs, writing);
    await settle();

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(documents.asked, <SpaceRelativePath>[writing, index]);
    expect(
      (container.read(previewProvider) as PreviewReady).document,
      parsedOf(index),
    );
  });

  test('a document that is gone is a failure, not an empty page', () async {
    // An empty page would say the document holds nothing, which is a
    // different claim from "it is not there".
    documents.answer = Failure<Document, DocumentFailure>(
      DocumentNotFound(writing.value),
    );
    start();
    show(docs, writing);
    await settle();

    expect(
      (container.read(previewProvider) as PreviewFailed).failure,
      DocumentNotFound(writing.value),
    );
  });
}

/// A repository that answers what it was told to, and remembers what it was
/// asked for.
final class _Documents implements DocumentRepository {
  Result<Document, DocumentFailure>? answer;

  /// What this was asked to read, in order.
  final List<SpaceRelativePath> asked = <SpaceRelativePath>[];

  @override
  Future<Result<Document, DocumentFailure>> read(SpaceRelativePath path) async {
    asked.add(path);
    return answer ??
        Success<Document, DocumentFailure>(
          Document(path: path, content: '# ${path.name}\n'),
        );
  }

  @override
  Future<Result<void, DocumentFailure>> write(Document document) async =>
      throw UnimplementedError();
}

/// A reader that splits nothing: one heading block, whatever it is given.
final class _Blocks implements BlockReader {
  const _Blocks();

  @override
  Future<Result<ParsedDocument, DocumentFailure>> read(
    Document document,
  ) async => Success<ParsedDocument, DocumentFailure>(
    ParsedDocument(
      document: document,
      blocks: <Block>[
        Block(
          startLine: 0,
          endLine: 0,
          source: '# ${document.path.name}',
          kind: BlockKindEnum.heading,
        ),
      ],
      linkDefinitions: '',
    ),
  );
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
