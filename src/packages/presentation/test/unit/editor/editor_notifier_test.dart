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
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the editor, and answers its first state.
  EditorState start() {
    container.listen<EditorState>(editorProvider, (_, _) {});
    return container.read(editorProvider);
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

  EditorReady ready() => container.read(editorProvider) as EditorReady;

  test('with no document chosen there is no buffer', () async {
    expect(start(), isA<EditorEmpty>());
    show(docs, null);
    await settle();

    expect(container.read(editorProvider), isA<EditorEmpty>());
    expect(documents.asked, isEmpty);
  });

  test('choosing a document reads it into a clean buffer', () async {
    start();
    show(docs, writing);

    expect(container.read(editorProvider), isA<EditorLoading>());
    await settle();

    expect(ready().source, '# writing.md\n');
    expect(container.read(editorProvider).isDirty, isFalse);
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });

  test('a document that is gone is a failure, not an empty buffer', () async {
    // An empty buffer would invite typing into a file that is not there,
    // and the first save would create it.
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(writing.value),
    );
    start();
    show(docs, writing);
    await settle();

    expect(
      (container.read(editorProvider) as EditorFailed).failure,
      DocumentNotFound(writing.value),
    );
  });

  group('the buffer and the file', () {
    test('typing makes the document unsaved', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# changed\n');

      expect(container.read(editorProvider).isDirty, isTrue);
      expect(documents.written, isEmpty);
    });

    test('typing a character and taking it back leaves it clean', () async {
      // Compared, never flagged: a flag would call this unsaved for the
      // rest of the session and the mark would stop meaning anything.
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier)
        ..edit('# writing.md!\n')
        ..edit('# writing.md\n');

      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('saving writes the buffer and clears the mark', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      await container.read(editorProvider.notifier).save();

      expect(
        documents.written.single,
        DocumentEntity(path: writing, content: '# changed\n'),
      );
      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('saving a document nobody touched writes nothing', () async {
      // Pressing the shortcut twice is not an error, and a write nobody
      // needs still moves the timestamp git reads.
      start();
      show(docs, writing);
      await settle();

      await container.read(editorProvider.notifier).save();

      expect(documents.written, isEmpty);
    });

    test('a refused save keeps the work and says so', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');
      documents.refusal = Failure<void, DocumentFailure>(
        DocumentPermissionDenied(writing.value),
      );

      await container.read(editorProvider.notifier).save();

      expect(ready().source, '# changed\n');
      expect(container.read(editorProvider).isDirty, isTrue);
      expect(ready().saveFailure, DocumentPermissionDenied(writing.value));
    });

    test('typing during a save leaves the document dirty again', () async {
      // What reached the disk is not what is on screen, and saying "saved"
      // would be a claim about text no file holds.
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# first\n');

      final Future<void> saving = container
          .read(editorProvider.notifier)
          .save();
      container.read(editorProvider.notifier).edit('# second\n');
      await saving;

      expect(documents.written.single.content, '# first\n');
      expect(ready().source, '# second\n');
      expect(container.read(editorProvider).isDirty, isTrue);
    });
  });

  test('choosing another document starts another buffer', () async {
    start();
    show(docs, writing);
    await settle();
    container.read(editorProvider.notifier).edit('# changed\n');

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(ready().source, '# index.md\n');
    expect(container.read(editorProvider).isDirty, isFalse);
    expect(documents.asked, <SpaceRelativePathValueObject>[writing, index]);
  });

  test('changing the mode does not throw the buffer away', () async {
    // The editor watches the space and the document, never the session
    // whole: looking at the preview must not lose somebody's work.
    start();
    show(docs, writing);
    await settle();
    container.read(editorProvider.notifier).edit('# changed\n');

    container
        .read(spaceSessionProvider.notifier)
        .look(DocumentModeEnum.preview);
    await settle();

    expect(ready().source, '# changed\n');
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });
}

/// A repository that answers what it was told to, and remembers everything.
final class _Documents implements DocumentRepository {
  Result<DocumentEntity, DocumentFailure>? answer;
  Result<void, DocumentFailure>? refusal;

  /// What this was asked to read, in order.
  final List<SpaceRelativePathValueObject> asked =
      <SpaceRelativePathValueObject>[];

  /// What actually reached the disk, in order.
  final List<DocumentEntity> written = <DocumentEntity>[];

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
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document);
    return refusal ?? const Success<void, DocumentFailure>(null);
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
