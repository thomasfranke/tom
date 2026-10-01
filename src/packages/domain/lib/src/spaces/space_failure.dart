/// What working with a space's folder can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'space_failure.freezed.dart';

/// An operation on the space's folder itself that did not complete.
///
/// Separate from `DocumentFailure` because a folder failing sends the user
/// to another space, not another file. A variant carries the path the user
/// can act on; what the disk said travels in [AppFailure.cause].
@freezed
sealed class SpaceFailure with _$SpaceFailure implements AppFailure {
  /// The space's folder is not there any more.
  ///
  /// Expected rather than exceptional: a removable disk, a network share, a
  /// folder renamed outside TOM. Home offers to forget it
  /// (`docs/product/home/opening-a-space/doc.md`).
  const factory SpaceFailure.folderMissing(
    /// The absolute path the space was opened at.
    String root, {
    AppFailure? cause,
  }) = SpaceFolderMissing;

  /// The operating system refused to read the folder.
  const factory SpaceFailure.accessDenied(
    /// The absolute path that actually failed, which inside a recursive walk
    /// is rarely the space root.
    String path, {
    AppFailure? cause,
  }) = SpaceAccessDenied;

  /// Reading the folder failed in a way the product has no name for.
  ///
  /// The typed fallback, with the machine's report in [cause]; a variant
  /// promoted out of here is one that earned its own sentence on screen.
  const factory SpaceFailure.operationFailed(
    /// The absolute path the operation was attempted on.
    String path, {
    AppFailure? cause,
  }) = SpaceOperationFailed;
}
