/// What a pull request would carry.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_change_value_object.dart';
import 'package:tom_domain/src/git/commit_entity.dart';

part 'branch_proposal_value_object.freezed.dart';

/// The branch's commits over its base, and the paths they changed — the
/// `Pull request` segment's `3 commits · 2 documents` and `+48 −12`
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
@freezed
abstract class BranchProposalValueObject with _$BranchProposalValueObject {
  /// A proposal.
  const factory BranchProposalValueObject({
    /// The commits `HEAD` has over the base, newest first.
    required List<CommitEntity> commits,

    /// What they changed, one entry per path.
    required List<BranchChangeValueObject> changes,
  }) = _BranchProposalValueObject;

  const BranchProposalValueObject._();

  /// Lines added across every change git could count.
  int get linesAdded => changes.fold(
    0,
    (int sum, BranchChangeValueObject it) => sum + (it.added ?? 0),
  );

  /// Lines removed across every change git could count.
  int get linesRemoved => changes.fold(
    0,
    (int sum, BranchChangeValueObject it) => sum + (it.removed ?? 0),
  );
}
