/// What reading or writing a document can fail with.
library;

import 'package:tom_core/tom_core.dart';

/// An operation on a `.md` file that did not complete.
///
/// The file on disk is the truth, so every variant here describes the disk
/// disagreeing with what the app believed — never a cache the app could have
/// repaired on its own.
sealed class DocumentFailure implements AppFailure {
  /// Const constructor, for the variants below.
  const DocumentFailure();
}

/// The document is no longer where it was.
///
/// Expected rather than exceptional: files move under an open editor, and the
/// watcher may report it after the panel has already asked for the content.
final class DocumentNotFound extends DocumentFailure {
  /// Creates the failure for the document at [path].
  const DocumentNotFound(this.path);

  /// The path, relative to the space root.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is DocumentNotFound && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}

/// The operating system refused the read or the write.
final class PermissionDenied extends DocumentFailure {
  /// Creates the failure for the document at [path].
  const PermissionDenied(this.path);

  /// The path, relative to the space root.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is PermissionDenied && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}

/// The file changed on disk while there were unsaved local edits.
///
/// Editing alongside VS Code is an expected use case, not an error
/// (Decision 10): the user is offered the choice, so this failure exists to
/// carry the question to the UI rather than to report a fault.
final class ExternalChangeConflict extends DocumentFailure {
  /// Creates the failure for the document at [path].
  const ExternalChangeConflict(this.path);

  /// The path, relative to the space root.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is ExternalChangeConflict && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}
