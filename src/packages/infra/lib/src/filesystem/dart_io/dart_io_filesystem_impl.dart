/// The `dart:io` implementation of [Filesystem].
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// Reads and writes files through `dart:io`'s [File].
///
/// The only implementation today, chosen at the composition root. A sandboxed
/// mobile implementation is a sibling folder next to this one, not a change
/// to [Filesystem] (Phase 3, see `layers.md#when-mobile-arrives-phase-3`).
final class DartIoFilesystemImpl implements Filesystem {
  /// Creates the implementation.
  const DartIoFilesystemImpl();

  /// Distinguishes two temporary files taken in the same process.
  static int _sequence = 0;

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    final Uint8List bytes;
    try {
      bytes = await File(path).readAsBytes();
    } on FileSystemException catch (exception) {
      return Failure<String, FilesystemFailure>(_translate(path, exception));
    }
    try {
      return Success<String, FilesystemFailure>(utf8.decode(bytes));
    } on FormatException {
      // Named rather than decoded leniently, which is the opposite of what
      // the git client does with the same hazard — and for the same reason.
      // Nothing TOM shows is written back to git; a document is. A
      // replacement character saved over a latin-1 file destroys the bytes
      // that could not be read, so refusing is the only lossless answer.
      return Failure<String, FilesystemFailure>(FilesystemNotUtf8(path));
    }
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async {
    final File temporary = File(_temporaryPathFor(path));
    try {
      await File(path).parent.create(recursive: true);
      // Written beside the target and renamed over it, because a rename is
      // the only write the operating system finishes or does not start: the
      // files are the truth for this product, and a document half-written by
      // a crash is a document lost. The temporary cannot live in the system's
      // temporary directory — a rename is atomic within one filesystem only.
      await temporary.writeAsString(content, flush: true);
      await temporary.rename(path);
      return const Success<void, FilesystemFailure>(null);
    } on FileSystemException catch (exception) {
      await _discard(temporary);
      return Failure<void, FilesystemFailure>(_translate(path, exception));
    }
  }

  @override
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  }) async {
    try {
      final List<FilesystemEntryDto> entries =
          <FilesystemEntryDto>[
            // The async stream rather than `listSync`: a space's documentation
            // folder can hold thousands of entries, and the walk must not block
            // the isolate the app draws from.
            await for (final FileSystemEntity entity
                in Directory(path)
                    .list(recursive: recursive, followLinks: false)
                    .handleError(
                      // One folder the machine will not open costs that
                      // folder, never the listing: a single unreadable
                      // directory somewhere under a space would otherwise
                      // leave the file tree with nothing to show. An error on
                      // the directory that was asked for is the listing
                      // itself failing, and still travels.
                      (Object? _) {},
                      test: (Object? error) =>
                          error is FileSystemException &&
                          !_isAbout(path, error),
                    ))
              FilesystemEntryDto(path: entity.path, type: _typeOf(entity)),
          ]..sort(
            (FilesystemEntryDto a, FilesystemEntryDto b) =>
                a.path.compareTo(b.path),
          );
      return Success<List<FilesystemEntryDto>, FilesystemFailure>(entries);
    } on FileSystemException catch (exception) {
      return Failure<List<FilesystemEntryDto>, FilesystemFailure>(
        _translate(path, exception),
      );
    }
  }

  @override
  Future<Result<bool, FilesystemFailure>> directoryExists(String path) async {
    try {
      // A space's folder can sit on a network mount, and the synchronous
      // probe blocks for as long as a stale one takes to give up — which Home
      // would spend frozen while it checks the spaces it offers to reopen.
      // ignore: avoid_slow_async_io
      final bool exists = await Directory(path).exists();
      return Success<bool, FilesystemFailure>(exists);
    } on FileSystemException catch (exception) {
      return Failure<bool, FilesystemFailure>(_translate(path, exception));
    }
  }

  @override
  Future<Result<String, FilesystemFailure>> resolvePath(String path) async {
    try {
      // Type-agnostic: the resolution is `realpath` on the string, and a
      // `Directory` is only the handle `dart:io` needs to call it on.
      return Success<String, FilesystemFailure>(
        await Directory(path).resolveSymbolicLinks(),
      );
    } on FileSystemException catch (exception) {
      return Failure<String, FilesystemFailure>(_translate(path, exception));
    }
  }

  /// A sibling path of [path] no other write is using.
  ///
  /// It is visible on disk for as long as the write takes: [listDirectory]
  /// filters nothing, so a caller walking the folder at that instant sees it.
  /// The alternative is a window in which the document itself is truncated,
  /// which is worse.
  static String _temporaryPathFor(String path) =>
      '$path.$pid.${_sequence++}.tom-tmp';

  /// Removes a temporary file a failed write left behind.
  Future<void> _discard(File temporary) async {
    try {
      await temporary.delete();
    } on FileSystemException {
      // Deliberately ignored: the write has already failed, and reporting
      // "the temporary file could not be deleted" over "the document could
      // not be saved" would name the wrong problem.
    }
  }

  /// Whether [exception] is about [path] itself rather than something inside
  /// it.
  ///
  /// `dart:io` names the directory a listing started from with a trailing
  /// separator and the ones it walked into without one, so the difference has
  /// to be taken out before the two can be compared. An exception carrying no
  /// path at all is about what was asked for: there is nothing else it could
  /// be about.
  static bool _isAbout(String path, FileSystemException exception) {
    final String? failed = exception.path;
    return failed == null || _bare(failed) == _bare(path);
  }

  /// [path] without a trailing separator, either platform's.
  static String _bare(String path) => path.endsWith('/') || path.endsWith(r'\')
      ? path.substring(0, path.length - 1)
      : path;

  /// What `dart:io` says the entity is.
  ///
  /// [FileSystemEntity] has exactly these three subclasses, and a listing that
  /// does not follow links never reports a link as the thing it points at.
  FilesystemEntryTypeEnum _typeOf(FileSystemEntity entity) => switch (entity) {
    Directory() => FilesystemEntryTypeEnum.directory,
    Link() => FilesystemEntryTypeEnum.link,
    _ => FilesystemEntryTypeEnum.file,
  };

  /// Maps what the OS reported to a [FilesystemFailure].
  ///
  /// By exception type, not by `errorCode`: POSIX `errno` and Win32 error
  /// codes share one namespace with different meanings — `5` is `EIO` on one
  /// and `ERROR_ACCESS_DENIED` on the other — so a disk failing on Linux
  /// would be reported as a permission problem and send the user to `chmod`.
  /// `dart:io` has already done that platform mapping to reach
  /// [PathNotFoundException] and [PathAccessException]; anything it did not
  /// name falls back to [FilesystemOperationFailed] rather than being guessed
  /// at.
  ///
  /// The path is [requested] as the caller spelled it, unless the failure is
  /// about something else: a recursive walk fails on an entry deep inside the
  /// folder that was asked for, and telling the user the folder they opened
  /// is unreadable when it is not would be a lie.
  ///
  /// What the exception carried and the contract has no word for is dropped
  /// rather than kept as a cause: `cause` links two *vocabularies*, and an
  /// adapter has only one. The variant is what a second implementation of
  /// this contract would have to produce too.
  FilesystemFailure _translate(
    String requested,
    FileSystemException exception,
  ) {
    final String path = _isAbout(requested, exception)
        ? requested
        : exception.path!;
    return switch (exception) {
      PathNotFoundException() => FilesystemEntryNotFound(path),
      PathAccessException() => FilesystemAccessDenied(path),
      _ => FilesystemOperationFailed(path, exception.message),
    };
  }
}
