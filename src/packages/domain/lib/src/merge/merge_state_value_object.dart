/// Whether the repository is mid-merge, and what git drafted for it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_state_value_object.freezed.dart';

/// The merge a conflicted pull left behind, read from git rather than
/// remembered.
///
/// It carries no list of conflicted paths: the status already answers that,
/// and one fact with two sources is one fact that can disagree with itself.
/// The state belongs to the repository, so it survives the window being
/// closed (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
@freezed
abstract class MergeStateValueObject with _$MergeStateValueObject {
  /// A merge that is either in progress or not.
  const factory MergeStateValueObject({
    /// Whether `MERGE_HEAD` is there.
    required bool inProgress,

    /// The message git prepared, empty when there is no merge.
    ///
    /// Concluding the merge starts from this rather than from a blank box,
    /// because git already wrote the sentence a terminal would have opened
    /// an editor on.
    required String message,
  }) = _MergeStateValueObject;

  const MergeStateValueObject._();

  /// A repository at rest: no merge, nothing drafted.
  static const MergeStateValueObject none = MergeStateValueObject(
    inProgress: false,
    message: '',
  );
}
