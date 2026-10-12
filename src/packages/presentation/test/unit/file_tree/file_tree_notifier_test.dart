import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Spaces spaces;
  late _Documents documents;
  late _Desktop desktop;
  _Reading? reading;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceEntity other = SpaceEntity(
    root: '/code/notes',
    repositoryRoot: '/code/notes',
    name: 'notes',
  );

  SpaceEntryValueObject entry(String path, SpaceEntryTypeEnum type) =>
      SpaceEntryValueObject(
        path: SpaceRelativePathValueObject(path),
        type: type,
      );

  final List<SpaceEntryValueObject> held = <SpaceEntryValueObject>[
    entry('guides', SpaceEntryTypeEnum.directory),
    entry('guides/writing.md', SpaceEntryTypeEnum.file),
    entry('logo.svg', SpaceEntryTypeEnum.file),
    entry('elsewhere', SpaceEntryTypeEnum.link),
    entry('index.md', SpaceEntryTypeEnum.file),
  ];

  setUp(() {
    spaces = _Spaces();
    documents = _Documents();
    desktop = _Desktop();
    container = ProviderContainer(
      overrides: <Override>[
        listSpaceEntriesProvider.overrideWithValue(
          ListSpaceEntriesUseCase(
            spaces: spaces,
            observability: const _Silent(),
          ),
        ),
        gitReadingProvider.overrideWith(() => reading = _Reading()),
        createFolderProvider.overrideWithValue(
          CreateFolderUseCase(spaces: spaces, observability: const _Silent()),
        ),
        revealFolderProvider.overrideWithValue(
          RevealFolderUseCase(desktop: desktop, observability: const _Silent()),
        ),
        createDocumentProvider.overrideWithValue(
          CreateDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the tree, and answers its first state; listening is what starts
  /// it, since a provider nobody listens to is disposed as soon as it is read.
  FileTreeState start() {
    container.listen<FileTreeState>(fileTreeProvider, (_, _) {});
    return container.read(fileTreeProvider);
  }

  /// The state once everything scheduled has run.
  Future<FileTreeState> settled() async {
    start();
    await Future<void>.delayed(Duration.zero);
    return container.read(fileTreeProvider);
  }

  /// Opens [space], the way Home does.
  void open(SpaceEntity space) =>
      container.read(spaceSessionProvider.notifier).open(space);

  FileTreeNotifier notifier() => container.read(fileTreeProvider.notifier);

  /// What the tree is showing, by path.
  List<String> showing() => <String>[
    for (final FileTreeRow row
        in (container.read(fileTreeProvider) as FileTreeReady).rows)
      row.entry.path.value,
  ];

  group('with no space open', () {
    test('there is nothing to list, and nothing is asked', () async {
      expect(await settled(), isA<FileTreeInitial>());
      expect(spaces.listings, isEmpty);
    });
  });

  group('when a space opens', () {
    test('it reads the folder without being asked to', () async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);

      expect(container.read(fileTreeProvider), isA<FileTreeLoading>());
      await Future<void>.delayed(Duration.zero);
      expect(showing(), <String>[
        'guides',
        'guides/writing.md',
        'logo.svg',
        'elsewhere',
        'index.md',
      ]);
      expect(spaces.listings, <SpaceEntity>[docs]);
    });

    test('every folder starts open', () async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);

      expect(
        (container.read(fileTreeProvider) as FileTreeReady).collapsed,
        isEmpty,
      );
    });

    test(
      'a folder that cannot be read is a failure, not an empty tree',
      () async {
        spaces.answer =
            const Failure<List<SpaceEntryValueObject>, SpaceFailure>(
              SpaceFolderMissing('/code/app/docs'),
            );
        start();
        open(docs);
        await Future<void>.delayed(Duration.zero);

        expect(
          (container.read(fileTreeProvider) as FileTreeFailed).failure,
          const SpaceFolderMissing('/code/app/docs'),
        );
      },
    );

    test('another space is read again, from scratch', () async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);
      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

      open(other);
      await Future<void>.delayed(Duration.zero);

      expect(spaces.listings, <SpaceEntity>[docs, other]);
      expect(
        (container.read(fileTreeProvider) as FileTreeReady).collapsed,
        isEmpty,
      );
    });
  });

  group('clicking a row', () {
    setUp(() async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);
    });

    test('a folder closes, and opens again', () {
      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

      expect(showing(), <String>[
        'guides',
        'logo.svg',
        'elsewhere',
        'index.md',
      ]);

      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

      expect(showing(), contains('guides/writing.md'));
    });

    test('closing a folder does not re-read the space', () {
      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

      expect(spaces.listings, <SpaceEntity>[docs]);
    });

    test('a markdown file becomes the document the window shows', () {
      notifier().activate(entry('index.md', SpaceEntryTypeEnum.file));

      expect(
        container.read(spaceSessionProvider)?.openDocument,
        SpaceRelativePathValueObject('index.md'),
      );
    });

    test('showing a document does not re-read the space', () {
      notifier().activate(entry('index.md', SpaceEntryTypeEnum.file));

      expect(spaces.listings, <SpaceEntity>[docs]);
      expect(container.read(fileTreeProvider), isA<FileTreeReady>());
    });

    test('a file that is not markdown opens too, as the changes list opens '
        'it', () {
      notifier().activate(entry('logo.svg', SpaceEntryTypeEnum.file));

      expect(
        container.read(spaceSessionProvider)?.openDocument,
        SpaceRelativePathValueObject('logo.svg'),
      );
    });

    test('a link does nothing, whatever it is named', () {
      notifier().activate(entry('elsewhere', SpaceEntryTypeEnum.link));

      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });
  });

  group('a new document', () {
    setUp(() async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);
    });

    FileTreeReady ready() => container.read(fileTreeProvider) as FileTreeReady;

    test('with nothing open, is asked for at the root, first', () {
      notifier().startNewDocument();

      expect(ready().draft, const NewEntryDraft());
      expect(ready().draftIndex, 0);
      expect(ready().draftDepth, 0);
    });

    test('goes into the open document\'s folder, under its row', () {
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('guides/writing.md'));

      notifier().startNewDocument();

      expect(ready().draft?.folder, SpaceRelativePathValueObject('guides'));
      expect(ready().draftIndex, 1);
      expect(ready().draftDepth, 1);
    });

    test('opens the folder it goes into, so the row is on screen', () {
      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('guides/writing.md'));

      notifier().startNewDocument();

      expect(ready().collapsed, isEmpty);
    });

    test('closing another folder keeps the row', () {
      notifier().startNewDocument();

      notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

      expect(ready().draft, isNotNull);
    });

    test('cancelling takes the row away and creates nothing', () {
      notifier()
        ..startNewDocument()
        ..cancelDraft();

      expect(ready().draft, isNull);
      expect(documents.created, isEmpty);
    });

    test('is created, the tree re-read, and opened in source', () async {
      notifier().startNewDocument();
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[
          ...held,
          entry('ideas.md', SpaceEntryTypeEnum.file),
        ],
      );

      await notifier().submitDraft('ideas');

      expect(documents.created, <String>['ideas.md']);
      expect(showing(), contains('ideas.md'));
      expect(ready().draft, isNull);
      final SpaceSessionState? session = container.read(spaceSessionProvider);
      expect(session?.openDocument, SpaceRelativePathValueObject('ideas.md'));
      expect(session?.mode, DocumentModeEnum.source);
    });

    test('asks git again, so the new file is marked at once', () async {
      notifier().startNewDocument();

      await notifier().submitDraft('ideas');

      expect(reading?.refreshes, 1);
    });

    test('a re-read keeps the folders the reader closed', () async {
      notifier()
        ..activate(entry('guides', SpaceEntryTypeEnum.directory))
        ..startNewDocument();

      await notifier().submitDraft('ideas');

      expect(ready().collapsed, <SpaceRelativePathValueObject>{
        SpaceRelativePathValueObject('guides'),
      });
    });

    test('a taken name is refused in place, and nothing opens', () async {
      documents.answer = const Failure<void, DocumentFailure>(
        DocumentAlreadyExists('index.md'),
      );
      notifier().startNewDocument();

      await notifier().submitDraft('index');

      expect(ready().draft?.refused, const DocumentAlreadyExists('index.md'));
      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });

    test('a name that is not one never reaches the disk', () async {
      notifier().startNewDocument();

      await notifier().submitDraft('  ');

      expect(ready().draft?.refused, isA<DocumentInvalidName>());
      expect(documents.created, isEmpty);
    });

    test('nothing is created without a row being typed in', () async {
      await notifier().submitDraft('ideas');

      expect(documents.created, isEmpty);
    });
  });

  group('a document a link asks for', () {
    setUp(() async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);
    });

    test('is created where it is asked for, and opened in source', () async {
      final bool created = await notifier().createDocument(
        SpaceRelativePathValueObject('guides'),
        'setup',
      );

      expect(created, isTrue);
      expect(documents.created, <String>['guides/setup.md']);
      final SpaceSessionState? session = container.read(spaceSessionProvider);
      expect(session?.openDocument?.value, 'guides/setup.md');
      expect(session?.mode, DocumentModeEnum.source);
      expect(reading?.refreshes, 1);
    });

    test('needs no row typed in, and leaves none behind', () async {
      await notifier().createDocument(null, 'setup');

      expect(documents.created, <String>['setup.md']);
      expect((container.read(fileTreeProvider) as FileTreeReady).draft, isNull);
    });

    test('a refusal opens nothing, and says so', () async {
      documents.answer = const Failure<void, DocumentFailure>(
        DocumentAlreadyExists('index.md'),
      );

      final bool created = await notifier().createDocument(null, 'index');

      expect(created, isFalse);
      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });
  });

  group('the explorer menu', () {
    setUp(() async {
      spaces.answer = Success<List<SpaceEntryValueObject>, SpaceFailure>(held);
      start();
      open(docs);
      await Future<void>.delayed(Duration.zero);
    });

    FileTreeReady ready() => container.read(fileTreeProvider) as FileTreeReady;

    test('New folder asks for a folder\'s name where a document goes', () {
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('guides/writing.md'));

      notifier().startNewFolder();

      expect(
        ready().draft,
        NewEntryDraft(
          folder: SpaceRelativePathValueObject('guides'),
          isFolder: true,
        ),
      );
    });

    test('a folder is created and the tree re-read, nothing opened', () async {
      notifier().startNewFolder();

      await notifier().submitDraft('drafts');

      expect(spaces.folders, <String>['drafts']);
      expect(documents.created, isEmpty);
      expect(ready().draft, isNull);
      expect(spaces.listings, <SpaceEntity>[docs, docs]);
      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
      expect(reading?.refreshes ?? 0, 0);
    });

    test('a folder name already taken is refused in place', () async {
      spaces.folderAnswer = const Failure<void, SpaceFailure>(
        SpaceEntryExists('guides'),
      );
      notifier().startNewFolder();

      await notifier().submitDraft('guides');

      expect(ready().draft?.refused, const SpaceEntryExists('guides'));
    });

    test('Collapse all closes every folder', () {
      notifier().collapseAll();

      expect(ready().collapsed, <SpaceRelativePathValueObject>{
        SpaceRelativePathValueObject('guides'),
      });
    });

    test('but keeps the open document\'s folder open', () {
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('guides/writing.md'));

      notifier().collapseAll();

      expect(ready().collapsed, isEmpty);
    });

    test('Reload reads the folder again, and asks git again', () async {
      await notifier().reload();

      expect(spaces.listings, <SpaceEntity>[docs, docs]);
      expect(reading?.refreshes, 1);
    });

    test('Reveal shows the space\'s folder, not the repository\'s', () async {
      await notifier().revealSpace();

      expect(desktop.revealed, <String>['/code/app/docs']);
    });
  });

  test('a folder cannot be closed before the space has been read', () {
    final FileTreeState before = start();

    notifier().activate(entry('guides', SpaceEntryTypeEnum.directory));

    expect(container.read(fileTreeProvider), before);
  });
}

/// A space repository that answers what it was told to, and remembers who
/// asked.
final class _Spaces implements SpaceRepository {
  Result<List<SpaceEntryValueObject>, SpaceFailure> answer =
      const Success<List<SpaceEntryValueObject>, SpaceFailure>(
        <SpaceEntryValueObject>[],
      );

  /// Every space this was asked to list, in order.
  final List<SpaceEntity> listings = <SpaceEntity>[];

  /// What a folder's creation answers.
  Result<void, SpaceFailure> folderAnswer = const Success<void, SpaceFailure>(
    null,
  );

  /// Every folder a creation was asked for, in order.
  final List<String> folders = <String>[];

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async {
    folders.add(path.value);
    return folderAnswer;
  }

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async {
    listings.add(space);
    return answer;
  }
}

/// The machine's desktop, remembering what it was asked to show.
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

/// The git reading, counting the times it was asked to re-read.
final class _Reading extends GitReadingNotifier {
  int refreshes = 0;

  @override
  GitReadingState build() => const GitReadingState.initial();

  @override
  Future<void> refresh() async => refreshes++;
}

/// Documents that answer a creation as told, and remember what was asked.
final class _Documents implements DocumentRepository {
  Result<void, DocumentFailure> answer = const Success<void, DocumentFailure>(
    null,
  );

  /// Every path a creation was asked for, in order.
  final List<String> created = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async {
    created.add(document.path.value);
    return answer;
  }

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
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
