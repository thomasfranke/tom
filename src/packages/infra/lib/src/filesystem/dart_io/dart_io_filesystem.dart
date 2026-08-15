/// The `dart:io` implementation of [Filesystem].
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/filesystem/filesystem.dart';
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

  /// Maps what the OS reported to a [FilesystemFailure].
  ///
  /// `errorCode` is POSIX `errno` on macOS/Linux and a Win32 error code on
  /// Windows; `ENOENT`/`ERROR_FILE_NOT_FOUND` and `EACCES`/
  /// `ERROR_ACCESS_DENIED` happen to share the values TOM targets across all
  /// three, so one check covers the desktop matrix. Anything else falls back
  /// to [FilesystemOperationFailed] rather than guessing at a name for it.
  FilesystemFailure _translate(String path, FileSystemException exception) {
    final int? code = exception.osError?.errorCode;
    if (code == 2) {
      return FilesystemEntryNotFound(path);
    }
    if (code == 13 || code == 5) {
      return FilesystemAccessDenied(path);
    }
    return FilesystemOperationFailed(path, exception.message);
  }
}
