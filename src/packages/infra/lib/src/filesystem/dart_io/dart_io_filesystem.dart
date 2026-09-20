/// The `dart:io` implementation of [Filesystem].
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/filesystem/filesystem.dart';
import 'package:tom_infra/src/filesystem/filesystem_entry.dart';
import 'package:tom_infra/src/filesystem/filesystem_entry_type.dart';
import 'package:tom_infra/src/filesystem/filesystem_failure.dart';

/// Reads and writes files through `dart:io`'s [File].
///
/// The only implementation today, chosen at the composition root. A sandboxed
/// mobile implementation is a sibling folder next to this one, not a change
/// to [Filesystem] (Phase 3, see `layers.md#when-mobile-arrives-phase-3`).
final class DartIoFilesystem implements Filesystem {
  /// Creates the implementation.
  const DartIoFilesystem();

  @override
  Future<Result<String>> readFile(String path) async {
    try {
      return Success<String>(await File(path).readAsString());
    } on FileSystemException catch (exception) {
      return Failure<String>(_translate(path, exception));
    }
  }

  @override
  Future<Result<void>> writeFile(String path, String content) async {
    try {
      await File(path).writeAsString(content);
      return const Success<void>(null);
    } on FileSystemException catch (exception) {
      return Failure<void>(_translate(path, exception));
    }
  }

  @override
  Future<Result<List<FilesystemEntry>>> listDirectory(
    String path, {
    bool recursive = false,
  }) async {
    try {
      final List<FilesystemEntry> entries =
          <FilesystemEntry>[
            // The async stream rather than `listSync`: a space's documentation
            // folder can hold thousands of entries, and the walk must not block
            // the isolate the app draws from.
            await for (final FileSystemEntity entity in Directory(
              path,
            ).list(recursive: recursive, followLinks: false))
              FilesystemEntry(path: entity.path, type: _typeOf(entity)),
          ]..sort(
            (FilesystemEntry a, FilesystemEntry b) => a.path.compareTo(b.path),
          );
      return Success<List<FilesystemEntry>>(entries);
    } on FileSystemException catch (exception) {
      return Failure<List<FilesystemEntry>>(_translate(path, exception));
    }
  }

  @override
  Future<Result<bool>> directoryExists(String path) async {
    try {
      return Success<bool>(Directory(path).existsSync());
    } on FileSystemException catch (exception) {
      return Failure<bool>(_translate(path, exception));
    }
  }

  /// What `dart:io` says the entity is.
  ///
  /// [FileSystemEntity] has exactly these three subclasses, and a listing that
  /// does not follow links never reports a link as the thing it points at.
  FilesystemEntryType _typeOf(FileSystemEntity entity) => switch (entity) {
    Directory() => FilesystemEntryType.directory,
    Link() => FilesystemEntryType.link,
    _ => FilesystemEntryType.file,
  };

  /// Maps what the OS reported to a [FilesystemFailure].
  ///
  /// `errorCode` is POSIX `errno` on macOS/Linux and a Win32 error code on
  /// Windows; `ENOENT`/`ERROR_FILE_NOT_FOUND` and `EACCES`/
  /// `ERROR_ACCESS_DENIED` happen to share the values TOM targets across all
  /// three, so one check covers the desktop matrix. Windows additionally
  /// reports `ERROR_PATH_NOT_FOUND` (3), distinct from `ERROR_FILE_NOT_FOUND`
  /// (2), when a parent directory in the path is missing rather than just the
  /// final entry — both mean "not found" from this API's point of view.
  /// Anything else falls back to [FilesystemOperationFailed] rather than
  /// guessing at a name for it.
  FilesystemFailure _translate(String path, FileSystemException exception) {
    final int? code = exception.osError?.errorCode;
    if (code == 2 || code == 3) {
      return FilesystemEntryNotFound(path);
    }
    if (code == 13 || code == 5) {
      return FilesystemAccessDenied(path);
    }
    return FilesystemOperationFailed(path, exception.message);
  }
}
