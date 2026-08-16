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
@freezed
sealed class DocumentFailure with _$DocumentFailure implements AppFailure {
  /// The document is no longer where it was.
  ///
  /// Expected rather than exceptional: files move under an open editor, and
  /// the watcher may report it after the panel has already asked for the
  /// content.
  const factory DocumentFailure.notFound(
    /// The path, relative to the space root.
    String path,
  ) = DocumentNotFound;

  /// The operating system refused the read or the write.
  const factory DocumentFailure.permissionDenied(
    /// The path, relative to the space root.
    String path,
  ) = PermissionDenied;

  /// The file changed on disk while there were unsaved local edits.
  ///
  /// Editing alongside VS Code is an expected use case, not an error
  /// (Decision 10): the user is offered the choice, so this failure exists to
  /// carry the question to the UI rather than to report a fault.
  const factory DocumentFailure.externalChangeConflict(
    /// The path, relative to the space root.
    String path,
  ) = ExternalChangeConflict;
}
