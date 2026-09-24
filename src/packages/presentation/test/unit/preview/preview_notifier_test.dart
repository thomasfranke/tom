import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late _Blocks blocks;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  setUp(() {
    documents = _Documents();
    blocks = _Blocks();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(blocks: blocks, observability: const _Silent()),
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
  void show(SpaceEntity space, SpaceRelativePathValueObject? document) {
    container.read(spaceSessionProvider.notifier).open(space);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Everything scheduled, including what is waiting out the debounce.
  Future<void> settleTyping() =>
      Future<void>.delayed(PreviewNotifier.settle * 2);

  String rendered() => (container.read(previewProvider) as PreviewReady)
      .document
      .document
      .content;

  test('with no space open there is nothing to render', () async {
    expect(start(), isA<PreviewEmpty>());
    await settle();

    expect(documents.asked, isEmpty);
    expect(blocks.asked, isEmpty);
  });

  test('a space with no document chosen is empty, not loading', () async {
    // Every space opens this way: the tree is on screen and nothing has
    // been clicked.
    start();
    show(docs, null);
    await settle();

    expect(container.read(previewProvider), isA<PreviewEmpty>());
    expect(blocks.asked, isEmpty);
  });

  test('choosing a document renders what the editor read', () async {
    start();
    show(docs, writing);

    expect(container.read(previewProvider), isA<PreviewLoading>());
    await settle();

    expect(rendered(), '# writing.md\n');
    // The disk was read once, by the editor. The preview reads the buffer.
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });

  test('choosing another document renders that one', () async {
    start();
    show(docs, writing);
    await settle();

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(rendered(), '# index.md\n');
  });

  test('a document that is gone is a failure, not an empty page', () async {
    // An empty page would say the document holds nothing, which is a
    // different claim from "it is not there".
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
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

  group('typing', () {
    test('an edit reaches the preview with no refresh step', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# typed\n');
      await settleTyping();

      expect(rendered(), '# typed\n');
    });

    test('a run of typing is parsed once, not once per character', () async {
      // A parse per keystroke is work nobody sees: the frame it would land
      // in already has the next keystroke in it.
      start();
      show(docs, writing);
      await settle();
      final int before = blocks.asked.length;

      container.read(editorProvider.notifier)
        ..edit('# a\n')
        ..edit('# ab\n')
        ..edit('# abc\n');
      await settleTyping();

      expect(blocks.asked.length - before, 1);
      expect(rendered(), '# abc\n');
    });

    test('the last blocks stay on screen while the next parse waits', () async {
      // Flashing "reading it" between two keystrokes would make the pane
      // unreadable exactly while it is being written in.
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# typed\n');

      expect(container.read(previewProvider), isA<PreviewReady>());
      expect(rendered(), '# writing.md\n');
    });

    test('a parse that broke says so rather than showing the last', () async {
      // Stale blocks under a document that no longer produces them would be
      // the preview lying about what is on screen.
      start();
      show(docs, writing);
      await settle();
      blocks.answer = const Failure<ParsedDocumentValueObject, DocumentFailure>(
        DocumentOperationFailed('guides/writing.md'),
      );

      container.read(editorProvider.notifier).edit('# broken\n');
      await settleTyping();

      expect(
        (container.read(previewProvider) as PreviewFailed).failure,
        const DocumentOperationFailed('guides/writing.md'),
      );
    });

    test('a parse the user has already typed past is dropped', () async {
      // Two renders in flight answer in whatever order the machine likes;
      // the newer one is the one on screen either way.
      start();
      show(docs, writing);
      await settle();
      blocks.delay = PreviewNotifier.settle * 4;

      container.read(editorProvider.notifier).edit('# first\n');
      await settleTyping();
      container.read(editorProvider.notifier).edit('# second\n');
      await Future<void>.delayed(PreviewNotifier.settle * 10);

      expect(rendered(), '# second\n');
    });

    test('saving redraws nothing, because nothing changed', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# typed\n');
      await settleTyping();
      final int before = blocks.asked.length;

      await container.read(editorProvider.notifier).save();
      await settleTyping();

      expect(blocks.asked.length, before);
    });
  });
}

/// A repository that answers what it was told to, and remembers what it was
/// asked for.
final class _Documents implements DocumentRepository {
  Result<DocumentEntity, DocumentFailure>? answer;

  /// What this was asked to read, in order.
  final List<SpaceRelativePathValueObject> asked =
      <SpaceRelativePathValueObject>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    asked.add(path);
    return answer ??
        Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(path: path, content: '# ${path.name}\n'),
        );
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
}

/// A reader that splits nothing: one heading block, whatever it is given.
final class _Blocks implements BlockReaderPort {
  /// What this was asked to split, in order.
  final List<DocumentEntity> asked = <DocumentEntity>[];

  /// What to answer instead of splitting, when a test says so.
  Result<ParsedDocumentValueObject, DocumentFailure>? answer;

  /// How long to take about it.
  Duration delay = Duration.zero;

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async {
    asked.add(document);
    // Only when a test asked for one: a zero `Future.delayed` is still a
    // timer, and a timer costs a turn of the event loop that the settling
    // helper here does not wait for.
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (answer
        case final Result<ParsedDocumentValueObject, DocumentFailure> given) {
      return given;
    }
    return Success<ParsedDocumentValueObject, DocumentFailure>(
      ParsedDocumentValueObject(
        document: document,
        blocks: <BlockValueObject>[
          BlockValueObject(
            startLine: 0,
            endLine: 0,
            source: document.content.trimRight(),
            kind: BlockKindEnum.heading,
          ),
        ],
        linkDefinitions: '',
      ),
    );
  }
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
