/// What the working copy is compared against, and the commit that stands
/// for it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_ref_value_object.dart';
import 'package:tom_domain/src/git/commit_sha_value_object.dart';

part 'diff_base_value_object.freezed.dart';

/// The branch the checked-out one came from, and where it left it.
///
/// Two answers kept together because they are read together and must never
/// disagree: the bar names [branch], the diff is read at [forkPoint], so the
/// work that landed on the base since never reads as removed here
/// (`docs/product/diff/branch-diff/doc.md`).
@freezed
abstract class DiffBaseValueObject with _$DiffBaseValueObject {
  /// A base.
  const factory DiffBaseValueObject({
    /// The branch, as the bar names it.
    required BranchRefValueObject branch,

    /// `merge-base` of `HEAD` and [branch] — what the document is read at.
    required CommitShaValueObject forkPoint,
  }) = _DiffBaseValueObject;
}
