/// What reading or writing a document can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'document_failure.freezed.dart';

/// An operation on a `.md` file that did not complete.
///
/// The file on disk is the truth, so every variant here describes the disk
/// disagreeing with what the app believed — never a cache the app could have
/// repaired on its own.
///
/// Domain vocabulary: a variant carries the path the user knows and nothing a
/// machine wrote. What the disk actually said travels in [AppFailure.cause].
@freezed
sealed class DocumentFailure with _$DocumentFailure implements AppFailure {
  /// The document is no longer where it was.
  ///
  /// Expected rather than exceptional: files move under an open editor, and
  /// the watcher may report it after the panel has already asked for the
  /// content.
  const factory DocumentFailure.notFound(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentNotFound;

  /// The operating system refused the read or the write.
  const factory DocumentFailure.permissionDenied(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentPermissionDenied;

  /// The file is not valid UTF-8 text.
  ///
  /// TOM writes a document back where it read it, so a file it cannot decode
  /// losslessly is one it refuses to open rather than one it opens with
  /// replacement characters that would be saved over the bytes they stood
  /// for.
  const factory DocumentFailure.notUtf8(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentNotUtf8;

  /// Reading or writing failed in a way the product has no name for.
  ///
  /// The typed fallback: unexpected, but still a [DocumentFailure] rather than
  /// an exception, so the guarantee that nothing throws across a boundary
  /// holds without enumerating every way a disk can refuse. What the machine
  /// reported is in [cause]; a variant promoted out of here is one that earned
  /// a sentence of its own on screen.
  const factory DocumentFailure.operationFailed(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentOperationFailed;

  /// The file changed on disk while there were unsaved local edits.
  ///
  /// Editing alongside VS Code is an expected use case, not an error
  /// (Decision 10): the user is offered the choice, so this failure exists to
  /// carry the question to the UI rather than to report a fault.
  const factory DocumentFailure.externalChangeConflict(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentExternalChangeConflict;
}
