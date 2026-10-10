import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late _Exports exports;
  late _Desktop desktop;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/docs',
    repositoryRoot: '/code',
    name: 'docs',
  );
  final SpaceRelativePathValueObject roadmap = SpaceRelativePathValueObject(
    'tasks/roadmap.md',
  );
  final SpaceRelativePathValueObject about = SpaceRelativePathValueObject(
    'about.md',
  );
  const String destination = '/Users/me/Documents/roadmap.pdf';

  setUp(() {
    documents = _Documents();
    exports = _Exports();
    desktop = _Desktop();
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
          const SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: _Silent(),
          ),
        ),
        exportDocumentProvider.overrideWithValue(
          ExportDocumentUseCase(
            exports: exports,
            observability: const _Silent(),
          ),
        ),
        revealFolderProvider.overrideWithValue(
          RevealFolderUseCase(desktop: desktop, observability: const _Silent()),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen<ExportState>(exportProvider, (_, _) {})
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a tab that is not on screen is exported as the disk has it', () async {
    await container
        .read(exportProvider.notifier)
        .export(about, ExportFormatEnum.pdf, destination);

    expect(documents.asked, <SpaceRelativePathValueObject>[about]);
    expect(exports.written.single.document.content, '# about.md\n');
    // The space its images are read from.
    expect(exports.spaces.single, docs);
    expect(
      container.read(exportProvider),
      const ExportState.exported(
        format: ExportFormatEnum.pdf,
        destination: destination,
      ),
    );
  });

  test('the tab on screen is exported as its buffer, edits and all', () async {
    container.read(spaceSessionProvider.notifier).show(roadmap);
    await settle();
    container.read(editorProvider.notifier).edit('# Roadmap, unsaved\n');

    await container
        .read(exportProvider.notifier)
        .export(roadmap, ExportFormatEnum.html, '/tmp/roadmap.html');

    expect(exports.written.single.document.content, '# Roadmap, unsaved\n');
    expect(exports.formats.single, ExportFormatEnum.html);
  });

  test('a refusal is said, naming where it was going', () async {
    exports.refusal = const ExportCannotWrite(destination);

    await container
        .read(exportProvider.notifier)
        .export(about, ExportFormatEnum.pdf, destination);

    expect(
      container.read(exportProvider),
      isA<ExportFailed>()
          .having(
            (ExportFailed it) => it.destination,
            'destination',
            destination,
          )
          .having(
            (ExportFailed it) => it.failure,
            'failure',
            isA<ExportCannotWrite>(),
          ),
    );
  });

  test('Reveal shows the folder the file landed in', () async {
    await container.read(exportProvider.notifier).reveal();
    expect(desktop.revealed, isEmpty, reason: 'nothing exported yet');

    await container
        .read(exportProvider.notifier)
        .export(about, ExportFormatEnum.pdf, destination);
    await container.read(exportProvider.notifier).reveal();

    expect(desktop.revealed, <String>['/Users/me/Documents']);
  });

  test('the folder is cut on either separator', () {
    expect(ExportNotifier.folderOf(r'C:\Users\me\roadmap.pdf'), r'C:\Users\me');
    expect(ExportNotifier.folderOf('/roadmap.pdf'), '/');
  });

  test('the news goes when another document opens', () async {
    await container
        .read(exportProvider.notifier)
        .export(about, ExportFormatEnum.pdf, destination);
    expect(container.read(exportProvider), isA<ExportExported>());

    container.read(spaceSessionProvider.notifier).show(about);

    expect(container.read(exportProvider), const ExportState.idle());
  });
}

final class _Documents implements DocumentRepository {
  final List<SpaceRelativePathValueObject> asked =
      <SpaceRelativePathValueObject>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    asked.add(path);
    return Success<DocumentEntity, DocumentFailure>(
      DocumentEntity(path: path, content: '# ${path.name}\n'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
}

/// A reader that finds no blocks: the export is what is under test.
final class _Blocks implements BlockReaderPort {
  const _Blocks();

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => Success<ParsedDocumentValueObject, DocumentFailure>(
    ParsedDocumentValueObject(
      document: document,
      blocks: const <BlockValueObject>[],
      linkDefinitions: '',
    ),
  );
}

final class _Exports implements ExportRepository {
  final List<ParsedDocumentValueObject> written = <ParsedDocumentValueObject>[];
  final List<ExportFormatEnum> formats = <ExportFormatEnum>[];
  final List<SpaceEntity> spaces = <SpaceEntity>[];
  ExportFailure? refusal;

  @override
  Future<Result<void, ExportFailure>> export(
    SpaceEntity space,
    ParsedDocumentValueObject document,
    ExportFormatEnum format,
    String destination,
  ) async {
    if (refusal case final ExportFailure failure) {
      return Failure<void, ExportFailure>(failure);
    }
    spaces.add(space);
    written.add(document);
    formats.add(format);
    return const Success<void, ExportFailure>(null);
  }
}

final class _Desktop implements DesktopRepository {
  final List<String> revealed = <String>[];

  @override
  Future<Result<void, AppFailure>> reveal(String folder) async {
    revealed.add(folder);
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async =>
      throw UnimplementedError();
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
