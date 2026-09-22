/// [SpaceRepositoryImpl] against a filesystem that records what it was asked.
///
/// Unit, not integration: the claim worth testing here is not that a listing
/// works — the capability's own tests cover that against real disk — but
/// that `.git/` is never *descended into*. That is a statement about which
/// calls are made, and only a recording double can answer it.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingFilesystem filesystem;
  late SpaceRepositoryImpl repository;

  final SpaceEntity space = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    filesystem = _RecordingFilesystem();
    repository = SpaceRepositoryImpl(
      filesystem: filesystem,
      gitClientFor: (String folder) =>
          throw StateError('open() is not what these tests exercise'),
    );
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  /// The paths of [entries], as the tree would read them.
  List<String> pathsOf(List<SpaceEntryValueObject> entries) =>
      entries.map((SpaceEntryValueObject entry) => entry.path.value).toList();

  group('what the tree gets', () {
    test('paths are relative to the space, not to the disk', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _file('/code/app/docs/guide.md'),
      ];

      expect(pathsOf(valueOf(await repository.entries(space))), <String>[
        'guide.md',
      ]);
    });

    test('a folder is followed immediately by what is inside it', () async {
      // Tree order, so a caller can build the tree in one pass.
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _directory('/code/app/docs/adr'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.tree['/code/app/docs/adr'] = <FilesystemEntryDto>[
        _file('/code/app/docs/adr/001.md'),
        _file('/code/app/docs/adr/002.md'),
      ];

      expect(pathsOf(valueOf(await repository.entries(space))), <String>[
        'adr',
        'adr/001.md',
        'adr/002.md',
        'guide.md',
      ]);
    });

    test('every kind is reported, not only markdown', () async {
      // What the tree draws and what the editor opens are two questions.
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _file('/code/app/docs/logo.png'),
        _link('/code/app/docs/shared'),
      ];

      final List<SpaceEntryValueObject> entries = valueOf(
        await repository.entries(space),
      );

      expect(pathsOf(entries), <String>['logo.png', 'shared']);
      expect(entries.last.type, SpaceEntryTypeEnum.link);
      expect(
        entries.every((SpaceEntryValueObject entry) => entry.isDocument),
        isFalse,
      );
    });

    test('what comes back cannot be changed under the caller', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _file('/code/app/docs/a.md'),
      ];

      final List<SpaceEntryValueObject> entries = valueOf(
        await repository.entries(space),
      );

      expect(
        () => entries.add(
          SpaceEntryValueObject(
            path: SpaceRelativePathValueObject('b.md'),
            type: SpaceEntryTypeEnum.file,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('.git', () {
    setUp(() {
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _directory('/code/app/docs/.ai'),
        _directory('/code/app/docs/.git'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.tree['/code/app/docs/.ai'] = <FilesystemEntryDto>[
        _file('/code/app/docs/.ai/skills.md'),
      ];
      filesystem.tree['/code/app/docs/.git'] = <FilesystemEntryDto>[
        _file('/code/app/docs/.git/HEAD'),
      ];
    });

    test('is not in the tree', () async {
      expect(
        pathsOf(valueOf(await repository.entries(space))),
        isNot(contains('.git')),
      );
    });

    test('is never descended into', () async {
      // The reason this repository walks a level at a time instead of
      // asking the capability for a recursive listing: a `.git/` holds more
      // entries than every document the product will ever show, and
      // filtering them out afterwards means reading them first.
      await repository.entries(space);

      expect(filesystem.listed, isNot(contains('/code/app/docs/.git')));
    });

    test('every other dotfolder is kept, and walked', () async {
      // A team's own tooling is documentation too
      // (`docs/product/navigation/file-tree/doc.md`).
      expect(pathsOf(valueOf(await repository.entries(space))), <String>[
        '.ai',
        '.ai/skills.md',
        'guide.md',
      ]);
    });

    test('is hidden as a file too, which is what a worktree has', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _file('/code/app/docs/.git'),
      ];

      expect(valueOf(await repository.entries(space)), isEmpty);
    });
  });

  group('when a folder will not open', () {
    test('one folder inside the space costs that folder only', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntryDto>[
        _directory('/code/app/docs/private'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.unreadable.add('/code/app/docs/private');

      // The folder itself is still shown — it exists, it just cannot be
      // opened — and everything beside it survives.
      expect(pathsOf(valueOf(await repository.entries(space))), <String>[
        'private',
        'guide.md',
      ]);
    });

    test('the space root failing fails the listing', () async {
      filesystem.unreadable.add('/code/app/docs');

      expect(
        failureOf(await repository.entries(space)),
        isA<SpaceAccessDenied>().having(
          (SpaceAccessDenied failure) => failure.path,
          'path',
          '/code/app/docs',
        ),
      );
    });

    test('a space whose folder is gone says so', () async {
      // Home offers to forget it rather than reporting a fault.
      expect(
        failureOf(await repository.entries(space)),
        isA<SpaceFolderMissing>().having(
          (SpaceFolderMissing failure) => failure.root,
          'root',
          '/code/app/docs',
        ),
      );
    });

    test('anything else keeps what the machine said', () async {
      filesystem.failures['/code/app/docs'] = const FilesystemOperationFailed(
        '/code/app/docs',
        'EIO',
      );

      expect(
        failureOf(await repository.entries(space)),
        isA<SpaceOperationFailed>().having(
          (SpaceOperationFailed failure) => failure.path,
          'path',
          '/code/app/docs',
        ),
      );
    });

    test('no infrastructure failure reaches the caller', () async {
      expect(
        failureOf(await repository.entries(space)),
        isNot(isA<FilesystemFailure>()),
      );
    });
  });
}

FilesystemEntryDto _file(String path) =>
    FilesystemEntryDto(path: path, type: FilesystemEntryTypeEnum.file);

FilesystemEntryDto _directory(String path) =>
    FilesystemEntryDto(path: path, type: FilesystemEntryTypeEnum.directory);

FilesystemEntryDto _link(String path) =>
    FilesystemEntryDto(path: path, type: FilesystemEntryTypeEnum.link);

/// A [Filesystem] that answers from a map and remembers what it was asked.
final class _RecordingFilesystem implements Filesystem {
  /// What each directory holds, by absolute path.
  final Map<String, List<FilesystemEntryDto>> tree =
      <String, List<FilesystemEntryDto>>{};

  /// Directories the machine refuses to open.
  final Set<String> unreadable = <String>{};

  /// Directories that fail in some other way.
  final Map<String, FilesystemFailure> failures = <String, FilesystemFailure>{};

  /// Every directory a listing was asked for, in order.
  final List<String> listed = <String>[];

  @override
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  }) async {
    listed.add(path);
    if (recursive) {
      throw StateError('a recursive listing would walk into .git');
    }
    if (failures[path] case final FilesystemFailure failure) {
      return Failure<List<FilesystemEntryDto>, FilesystemFailure>(failure);
    }
    if (unreadable.contains(path)) {
      return Failure<List<FilesystemEntryDto>, FilesystemFailure>(
        FilesystemAccessDenied(path),
      );
    }
    if (tree[path] case final List<FilesystemEntryDto> entries) {
      return Success<List<FilesystemEntryDto>, FilesystemFailure>(entries);
    }
    return Failure<List<FilesystemEntryDto>, FilesystemFailure>(
      FilesystemEntryNotFound(path),
    );
  }

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async => throw UnimplementedError();

  @override
  Future<Result<bool, FilesystemFailure>> directoryExists(String path) async =>
      throw UnimplementedError();
}
