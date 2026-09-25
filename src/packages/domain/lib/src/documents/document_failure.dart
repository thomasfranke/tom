/// What reading or writing a document can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'document_failure.freezed.dart';

/// An operation on a `.md` file that did not complete.
///
/// Every variant is the disk disagreeing with what the app believed, never a
/// cache it could have repaired; a variant carries the path the user knows,
/// and what the disk said travels in [AppFailure.cause].
@freezed
sealed class DocumentFailure with _$DocumentFailure implements AppFailure {
  /// The document is no longer where it was.
  ///
  /// Ordinary rather than exceptional: files move under an open editor.
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
  /// Refused rather than opened with replacement characters, because a save
  /// would write those over the bytes they stood for.
  const factory DocumentFailure.notUtf8(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentNotUtf8;

  /// Reading or writing failed in a way the product has no name for.
  ///
  /// The typed fallback, so nothing throws across a boundary without every
  /// way a disk can refuse being enumerated; a variant promoted out of here is
  /// one that earned its own sentence on screen.
  const factory DocumentFailure.operationFailed(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentOperationFailed;

  /// The file changed on disk while there were unsaved local edits.
  ///
  /// Carries a question to the UI rather than reporting a fault: editing
  /// beside another editor is expected (Decision 10).
  const factory DocumentFailure.externalChangeConflict(
    /// The path, relative to the space root.
    String path, {
    AppFailure? cause,
  }) = DocumentExternalChangeConflict;
}
