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
/// A sandboxed mobile implementation is a sibling folder, not a change to
/// [Filesystem] (`docs/technical/mobile.md`).
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
      // Refused rather than decoded leniently, unlike the git client: a
      // document is written back, and a replacement character saved over the
      // byte it stood for destroys it (see [FilesystemNotUtf8]).
      return Failure<String, FilesystemFailure>(FilesystemNotUtf8(path));
    }
  }

  @override
  Future<Result<Uint8List, FilesystemFailure>> readBytes(String path) async {
    try {
      return Success<Uint8List, FilesystemFailure>(
        await File(path).readAsBytes(),
      );
    } on FileSystemException catch (exception) {
      return Failure<Uint8List, FilesystemFailure>(_translate(path, exception));
    }
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) => writeBytes(path, utf8.encode(content));

  @override
  Future<Result<void, FilesystemFailure>> writeBytes(
    String path,
    Uint8List bytes,
  ) async {
    final File temporary = File(_temporaryPathFor(path));
    try {
      await File(path).parent.create(recursive: true);
      // Written beside the target and renamed over it, because a rename is
      // the only write the operating system finishes or does not start — and
      // beside it, not in the system's temporary directory, because a rename
      // is atomic within one filesystem only.
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(path);
      return const Success<void, FilesystemFailure>(null);
    } on FileSystemException catch (exception) {
      await _discard(temporary);
      return Failure<void, FilesystemFailure>(_translate(path, exception));
    }
  }

  @override
  Future<Result<void, FilesystemFailure>> createFile(
    String path,
    String content,
  ) async {
    try {
      await File(path).parent.create(recursive: true);
      // `exclusive` is `O_CREAT | O_EXCL`: the machine checks and creates in
      // one step, so a name taken between a check and a write cannot be
      // overwritten.
      await File(path).create(exclusive: true);
    } on FileSystemException catch (exception) {
      return Failure<void, FilesystemFailure>(_translate(path, exception));
    }
    // The empty file is already the document; content goes through the
    // atomic write rather than into the file the create just made.
    return content.isEmpty
        ? const Success<void, FilesystemFailure>(null)
        : writeFile(path, content);
  }

  @override
  Future<Result<void, FilesystemFailure>> createDirectory(String path) async {
    try {
      // A check, then a create: `dart:io` has no exclusive directory create,
      // and `Directory.create` answers an existing one as success.
      if (FileSystemEntity.typeSync(path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        return Failure<void, FilesystemFailure>(FilesystemAlreadyExists(path));
      }
      await Directory(path).create(recursive: true);
      return const Success<void, FilesystemFailure>(null);
    } on FileSystemException catch (exception) {
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
            // The async stream rather than `listSync`, so a folder of
            // thousands of entries does not block the isolate the app draws
            // from.
            await for (final FileSystemEntity entity
                in Directory(path)
                    .list(recursive: recursive, followLinks: false)
                    .handleError(
                      // One folder the machine will not open costs that
                      // folder, never the listing; an error on the directory
                      // that was asked for is the listing failing, and still
                      // travels.
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
      // probe would block the isolate for as long as a stale one takes to
      // answer.
      // ignore: avoid_slow_async_io
      final bool exists = await Directory(path).exists();
      return Success<bool, FilesystemFailure>(exists);
    } on FileSystemException catch (exception) {
      return Failure<bool, FilesystemFailure>(_translate(path, exception));
    }
  }

  @override
  Future<Result<FilesystemEntryTypeEnum?, FilesystemFailure>> entryTypeOf(
    String path,
  ) async {
    try {
      // Asynchronous for the reason [directoryExists] is: a network mount.
      // ignore: avoid_slow_async_io
      final FileSystemEntityType type = await FileSystemEntity.type(
        path,
        followLinks: false,
      );
      return Success<FilesystemEntryTypeEnum?, FilesystemFailure>(
        _entryTypeOf(type),
      );
    } on FileSystemException catch (exception) {
      return Failure<FilesystemEntryTypeEnum?, FilesystemFailure>(
        _translate(path, exception),
      );
    }
  }

  @override
  Future<Result<void, FilesystemFailure>> delete(String path) async {
    try {
      // Asynchronous for the reason [directoryExists] is: a network mount.
      // ignore: avoid_slow_async_io
      final FileSystemEntityType type = await FileSystemEntity.type(
        path,
        followLinks: false,
      );
      // A link is removed through `Link`, because `Directory.delete` on a
      // link to a folder would empty the folder it points at.
      await switch (_entryTypeOf(type)) {
        null => Future<void>.value(),
        FilesystemEntryTypeEnum.link => Link(path).delete(),
        FilesystemEntryTypeEnum.directory => Directory(
          path,
        ).delete(recursive: true),
        FilesystemEntryTypeEnum.file => File(path).delete(),
      };
      return const Success<void, FilesystemFailure>(null);
    } on PathNotFoundException {
      // Gone between the look and the removal: what was asked for.
      return const Success<void, FilesystemFailure>(null);
    } on FileSystemException catch (exception) {
      return Failure<void, FilesystemFailure>(_translate(path, exception));
    }
  }

  /// [type] in the capability's terms, null for nothing there.
  static FilesystemEntryTypeEnum? _entryTypeOf(FileSystemEntityType type) =>
      switch (type) {
        FileSystemEntityType.directory => FilesystemEntryTypeEnum.directory,
        FileSystemEntityType.link => FilesystemEntryTypeEnum.link,
        FileSystemEntityType.notFound => null,
        _ => FilesystemEntryTypeEnum.file,
      };

  @override
  Future<Result<String, FilesystemFailure>> resolvePath(String path) async {
    try {
      // The resolution is `realpath` on the string; a `Directory` is only the
      // handle `dart:io` needs to call it on, whatever [path] is.
      return Success<String, FilesystemFailure>(
        await Directory(path).resolveSymbolicLinks(),
      );
    } on FileSystemException catch (exception) {
      return Failure<String, FilesystemFailure>(_translate(path, exception));
    }
  }

  /// A sibling path of [path] no other write is using.
  ///
  /// Visible to [listDirectory] for as long as the write takes, which beats a
  /// window in which the document itself is truncated.
  static String _temporaryPathFor(String path) =>
      '$path.$pid.${_sequence++}.tom-tmp';

  /// Removes a temporary file a failed write left behind.
  Future<void> _discard(File temporary) async {
    try {
      await temporary.delete();
    } on FileSystemException {
      // Ignored: the write has already failed, and this would name the wrong
      // problem over it.
    }
  }

  /// Whether [exception] is about [path] itself rather than something inside
  /// it.
  ///
  /// `dart:io` names the directory a listing started from with a trailing
  /// separator and the ones it walked into without, so both are bared first.
  /// An exception carrying no path is about what was asked for.
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
  /// [FileSystemEntity] has exactly these three subclasses, and a listing
  /// that does not follow links reports a link as itself.
  FilesystemEntryTypeEnum _typeOf(FileSystemEntity entity) => switch (entity) {
    Directory() => FilesystemEntryTypeEnum.directory,
    Link() => FilesystemEntryTypeEnum.link,
    _ => FilesystemEntryTypeEnum.file,
  };

  /// Maps what the OS reported to a [FilesystemFailure].
  ///
  /// By exception type, never by `errorCode`: POSIX `errno` and Win32 codes
  /// share one namespace with different meanings (`5` is `EIO` on one and
  /// `ERROR_ACCESS_DENIED` on the other), and `dart:io` has already mapped
  /// them to [PathNotFoundException] and [PathAccessException]. The path is
  /// [requested] unless the failure is about an entry inside it.
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
      PathExistsException() => FilesystemAlreadyExists(path),
      _ => FilesystemOperationFailed(path, exception.message),
    };
  }
}
