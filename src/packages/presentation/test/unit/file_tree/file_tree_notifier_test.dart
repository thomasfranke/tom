import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Spaces spaces;
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
    container = ProviderContainer(
      overrides: <Override>[
        listSpaceEntriesProvider.overrideWithValue(
          ListSpaceEntriesUseCase(
            spaces: spaces,
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

    test('a file the editor cannot open does nothing', () {
      notifier().activate(entry('logo.svg', SpaceEntryTypeEnum.file));

      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });

    test('a link does nothing, whatever it is named', () {
      notifier().activate(entry('elsewhere', SpaceEntryTypeEnum.link));

      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
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
