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
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _RecordingFilesystem filesystem;
  late SpaceRepositoryImpl repository;

  final Space space = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    filesystem = _RecordingFilesystem();
    repository = SpaceRepositoryImpl(filesystem: filesystem, space: space);
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T>(Result<T> result) => switch (result) {
    Success<T>(value: final T value) => value,
    Failure<T>(failure: final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  /// The paths of [entries], as the tree would read them.
  List<String> pathsOf(List<SpaceEntry> entries) =>
      entries.map((SpaceEntry entry) => entry.path.value).toList();

  group('what the tree gets', () {
    test('paths are relative to the space, not to the disk', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _file('/code/app/docs/guide.md'),
      ];

      expect(pathsOf(valueOf(await repository.entries())), <String>[
        'guide.md',
      ]);
    });

    test('a folder is followed immediately by what is inside it', () async {
      // Tree order, so a caller can build the tree in one pass.
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _directory('/code/app/docs/adr'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.tree['/code/app/docs/adr'] = <FilesystemEntry>[
        _file('/code/app/docs/adr/001.md'),
        _file('/code/app/docs/adr/002.md'),
      ];

      expect(pathsOf(valueOf(await repository.entries())), <String>[
        'adr',
        'adr/001.md',
        'adr/002.md',
        'guide.md',
      ]);
    });

    test('every kind is reported, not only markdown', () async {
      // What the tree draws and what the editor opens are two questions.
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _file('/code/app/docs/logo.png'),
        _link('/code/app/docs/shared'),
      ];

      final List<SpaceEntry> entries = valueOf(await repository.entries());

      expect(pathsOf(entries), <String>['logo.png', 'shared']);
      expect(entries.last.type, SpaceEntryType.link);
      expect(entries.every((SpaceEntry entry) => entry.isDocument), isFalse);
    });

    test('what comes back cannot be changed under the caller', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _file('/code/app/docs/a.md'),
      ];

      final List<SpaceEntry> entries = valueOf(await repository.entries());

      expect(
        () => entries.add(
          SpaceEntry(
            path: SpaceRelativePath('b.md'),
            type: SpaceEntryType.file,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('.git', () {
    setUp(() {
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _directory('/code/app/docs/.ai'),
        _directory('/code/app/docs/.git'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.tree['/code/app/docs/.ai'] = <FilesystemEntry>[
        _file('/code/app/docs/.ai/skills.md'),
      ];
      filesystem.tree['/code/app/docs/.git'] = <FilesystemEntry>[
        _file('/code/app/docs/.git/HEAD'),
      ];
    });

    test('is not in the tree', () async {
      expect(
        pathsOf(valueOf(await repository.entries())),
        isNot(contains('.git')),
      );
    });

    test('is never descended into', () async {
      // The reason this repository walks a level at a time instead of
      // asking the capability for a recursive listing: a `.git/` holds more
      // entries than every document the product will ever show, and
      // filtering them out afterwards means reading them first.
      await repository.entries();

      expect(filesystem.listed, isNot(contains('/code/app/docs/.git')));
    });

    test('every other dotfolder is kept, and walked', () async {
      // A team's own tooling is documentation too
      // (`docs/product/navigation/file-tree/doc.md`).
      expect(pathsOf(valueOf(await repository.entries())), <String>[
        '.ai',
        '.ai/skills.md',
        'guide.md',
      ]);
    });

    test('is hidden as a file too, which is what a worktree has', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _file('/code/app/docs/.git'),
      ];

      expect(valueOf(await repository.entries()), isEmpty);
    });
  });

  group('when a folder will not open', () {
    test('one folder inside the space costs that folder only', () async {
      filesystem.tree['/code/app/docs'] = <FilesystemEntry>[
        _directory('/code/app/docs/private'),
        _file('/code/app/docs/guide.md'),
      ];
      filesystem.unreadable.add('/code/app/docs/private');

      // The folder itself is still shown — it exists, it just cannot be
      // opened — and everything beside it survives.
      expect(pathsOf(valueOf(await repository.entries())), <String>[
        'private',
        'guide.md',
      ]);
    });

    test('the space root failing fails the listing', () async {
      filesystem.unreadable.add('/code/app/docs');

      expect(
        failureOf(await repository.entries()),
        const SpaceAccessDenied('/code/app/docs'),
      );
    });

    test('a space whose folder is gone says so', () async {
      // Home offers to forget it rather than reporting a fault.
      expect(
        failureOf(await repository.entries()),
        const SpaceFolderMissing('/code/app/docs'),
      );
    });

    test('anything else keeps what the machine said', () async {
      filesystem.failures['/code/app/docs'] = const FilesystemOperationFailed(
        '/code/app/docs',
        'EIO',
      );

      expect(
        failureOf(await repository.entries()),
        const SpaceOperationFailed('/code/app/docs', 'EIO'),
      );
    });

    test('no infrastructure failure reaches the caller', () async {
      expect(
        failureOf(await repository.entries()),
        isNot(isA<FilesystemFailure>()),
      );
    });
  });
}

FilesystemEntry _file(String path) =>
    FilesystemEntry(path: path, type: FilesystemEntryType.file);

FilesystemEntry _directory(String path) =>
    FilesystemEntry(path: path, type: FilesystemEntryType.directory);

FilesystemEntry _link(String path) =>
    FilesystemEntry(path: path, type: FilesystemEntryType.link);

/// A [Filesystem] that answers from a map and remembers what it was asked.
final class _RecordingFilesystem implements Filesystem {
  /// What each directory holds, by absolute path.
  final Map<String, List<FilesystemEntry>> tree =
      <String, List<FilesystemEntry>>{};

  /// Directories the machine refuses to open.
  final Set<String> unreadable = <String>{};

  /// Directories that fail in some other way.
  final Map<String, FilesystemFailure> failures = <String, FilesystemFailure>{};

  /// Every directory a listing was asked for, in order.
  final List<String> listed = <String>[];

  @override
  Future<Result<List<FilesystemEntry>>> listDirectory(
    String path, {
    bool recursive = false,
  }) async {
    listed.add(path);
    if (recursive) {
      throw StateError('a recursive listing would walk into .git');
    }
    if (failures[path] case final FilesystemFailure failure) {
      return Failure<List<FilesystemEntry>>(failure);
    }
    if (unreadable.contains(path)) {
      return Failure<List<FilesystemEntry>>(FilesystemAccessDenied(path));
    }
    if (tree[path] case final List<FilesystemEntry> entries) {
      return Success<List<FilesystemEntry>>(entries);
    }
    return Failure<List<FilesystemEntry>>(FilesystemEntryNotFound(path));
  }

  @override
  Future<Result<String>> readFile(String path) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> writeFile(String path, String content) async =>
      throw UnimplementedError();

  @override
  Future<Result<bool>> directoryExists(String path) async =>
      throw UnimplementedError();
}
