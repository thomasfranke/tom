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
  /// Named rather than decoded leniently: TOM writes a document back where it
  /// read it, and a replacement character saved over the byte it stood for
  /// destroys the original. A file TOM cannot read losslessly is a file it
  /// refuses to open — a capability decision, made here because nothing in
  /// `docs/product/` rules on encodings yet.
  const factory FilesystemFailure.notUtf8(
    /// The path whose bytes could not be decoded.
    String path, {
    AppFailure? cause,
  }) = FilesystemNotUtf8;

  /// A filesystem operation failed in a way the contract has no name for.
  ///
  /// The typed fallback: unexpected, but still a [FilesystemFailure] rather
  /// than an exception. A variant promoted out of here is one an adapter can
  /// recognise *and* a translator answers differently.
  const factory FilesystemFailure.operationFailed(
    /// The path the operation was attempted on.
    String path,

    /// What the machine reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = FilesystemOperationFailed;
}
