/// What reading or writing a file on disk can fail with, in `dart:io` terms.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'filesystem_failure.freezed.dart';

/// A filesystem operation that did not complete, as infrastructure sees it.
///
/// Technical vocabulary; `tom_data` translates it to a `DocumentFailure`. No
/// `dart:io` type crosses out of `filesystem/dart_io/`. `sealed`, so a
/// `switch` is exhaustive.
@freezed
sealed class FilesystemFailure with _$FilesystemFailure implements AppFailure {
  /// Nothing exists at the path an operation was asked to read.
  const factory FilesystemFailure.entryNotFound(
    /// The path that was asked for.
    String path, {
    AppFailure? cause,
  }) = FilesystemEntryNotFound;

  /// The operating system refused the read or the write.
  const factory FilesystemFailure.accessDenied(
    /// The path the operation was denied on.
    String path, {
    AppFailure? cause,
  }) = FilesystemAccessDenied;

  /// The bytes at the path are not valid UTF-8 text.
  ///
  /// Named rather than decoded leniently: a replacement character saved back
  /// over the byte it stood for destroys the original, so a file TOM cannot
  /// read losslessly is one it refuses to open.
  const factory FilesystemFailure.notUtf8(
    /// The path whose bytes could not be decoded.
    String path, {
    AppFailure? cause,
  }) = FilesystemNotUtf8;

  /// A filesystem operation failed in a way the contract has no name for.
  ///
  /// The typed fallback; a variant is promoted out of it only when an adapter
  /// can recognise it *and* a translator answers differently.
  const factory FilesystemFailure.operationFailed(
    /// The path the operation was attempted on.
    String path,

    /// What the machine reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = FilesystemOperationFailed;
}
