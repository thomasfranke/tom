/// What reading or writing a file on disk can fail with, in `dart:io` terms.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'filesystem_failure.freezed.dart';

/// A filesystem operation that did not complete, as infrastructure sees it.
///
/// Technical, not product vocabulary: `tom_infra` depends only on `tom_core`,
/// so it cannot name a `DocumentFailure` — `tom_data` does that translation.
/// No `dart:io` type crosses out of `filesystem/dart_io/`; a
/// `FileSystemException` dies there and leaves as one of the variants below.
///
/// `sealed`, so a `switch` over it is exhaustive.
@freezed
sealed class FilesystemFailure with _$FilesystemFailure implements AppFailure {
  /// Nothing exists at the path an operation was asked to read.
  const factory FilesystemFailure.entryNotFound(
    /// The path that was asked for.
    String path,
  ) = FilesystemEntryNotFound;

  /// The operating system refused the read or the write.
  const factory FilesystemFailure.accessDenied(
    /// The path the operation was denied on.
    String path,
  ) = FilesystemAccessDenied;

  /// A filesystem operation failed in a way infrastructure has no name for.
  ///
  /// The typed fallback, in the same spirit as `GitCommandFailed`: unexpected,
  /// but still a [FilesystemFailure] rather than an exception. A variant
  /// promoted out of here is a variant that earned a name.
  const factory FilesystemFailure.operationFailed(
    /// The path the operation was attempted on.
    String path,

    /// What `dart:io` reported, verbatim. For diagnostics — never parsed.
    String description,
  ) = FilesystemOperationFailed;
}
