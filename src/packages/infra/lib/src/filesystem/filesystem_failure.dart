/// What reading or writing a file on disk can fail with, in `dart:io` terms.
library;

import 'package:tom_core/tom_core.dart';

/// A filesystem operation that did not complete, as infrastructure sees it.
///
/// Technical, not product vocabulary: `tom_infra` depends only on `tom_core`,
/// so it cannot name a `DocumentFailure` — `tom_data` does that translation.
/// No `dart:io` type crosses out of `filesystem/dart_io/`; a
/// `FileSystemException` dies there and leaves as one of the variants below.
///
/// `sealed`, so a `switch` over it is exhaustive.
sealed class FilesystemFailure implements AppFailure {
  /// Const constructor, for the variants below.
  const FilesystemFailure();
}

/// Nothing exists at the path an operation was asked to read.
final class FilesystemEntryNotFound extends FilesystemFailure {
  /// Creates the failure for the entry at [path].
  const FilesystemEntryNotFound(this.path);

  /// The path that was asked for.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is FilesystemEntryNotFound && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}

/// The operating system refused the read or the write.
final class FilesystemAccessDenied extends FilesystemFailure {
  /// Creates the failure for the entry at [path].
  const FilesystemAccessDenied(this.path);

  /// The path the operation was denied on.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is FilesystemAccessDenied && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}

/// A filesystem operation failed in a way infrastructure has no name for.
///
/// The typed fallback, in the same spirit as `GitCommandFailed`: unexpected,
/// but still a [FilesystemFailure] rather than an exception. A variant
/// promoted out of here is a variant that earned a name.
final class FilesystemOperationFailed extends FilesystemFailure {
  /// Creates the failure for [path], carrying what `dart:io` reported.
  const FilesystemOperationFailed(this.path, this.description);

  /// The path the operation was attempted on.
  final String path;

  /// What `dart:io` reported, verbatim. For diagnostics — never parsed.
  final String description;

  @override
  bool operator ==(Object other) =>
      other is FilesystemOperationFailed &&
      other.path == path &&
      other.description == description;

  @override
  int get hashCode => Object.hash(runtimeType, path, description);
}
