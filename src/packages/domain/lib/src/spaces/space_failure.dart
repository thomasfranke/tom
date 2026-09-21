/// What working with a space's folder can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'space_failure.freezed.dart';

/// An operation on the space's folder itself that did not complete.
///
/// Separate from `DocumentFailure` because it answers a different question.
/// A document failing is about one file the user asked for; a space failing
/// is about the folder the whole session is scoped to — the answer is to
/// close the space or fix the machine, never to try another file.
@freezed
sealed class SpaceFailure with _$SpaceFailure implements AppFailure {
  /// The space's folder is not there any more.
  ///
  /// Expected rather than exceptional: a space on a removable disk, a
  /// network share that went away, a folder renamed outside TOM. Home offers
  /// to forget it rather than reporting a fault
  /// (`docs/product/home/doc.md`).
  const factory SpaceFailure.folderMissing(
    /// The absolute path the space was opened at.
    String root,
  ) = SpaceFolderMissing;

  /// The operating system refused to read the folder.
  const factory SpaceFailure.accessDenied(
    /// The absolute path that could not be read.
    ///
    /// The folder that actually failed, which inside a recursive walk is
    /// rarely the space root.
    String path,
  ) = SpaceAccessDenied;

  /// Reading the folder failed in a way the product has no name for.
  ///
  /// The typed fallback, in the same spirit as `GitCommandFailed`:
  /// unexpected, but still a [SpaceFailure] rather than an exception. A
  /// variant promoted out of here is a variant that earned a name.
  const factory SpaceFailure.operationFailed(
    /// The absolute path the operation was attempted on.
    String path,

    /// What the machine reported, verbatim. For diagnostics — never parsed.
    String description,
  ) = SpaceOperationFailed;
}
