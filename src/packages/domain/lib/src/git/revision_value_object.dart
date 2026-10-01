/// A point in the repository's history the product can name.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_entity.dart';
import 'package:tom_domain/src/git/commit_entity.dart';

part 'revision_value_object.freezed.dart';

/// A branch or a commit, as something to compare a document against.
///
/// The two things the product offers to compare between
/// (`docs/product/diff/branch-diff/doc.md`), carried whole rather than as
/// the string git resolves: the bar that says what is being compared names
/// the commit's author and age, and a sha alone could not.
@freezed
sealed class RevisionValueObject with _$RevisionValueObject {
  /// The tip of [branch].
  const factory RevisionValueObject.branch(BranchEntity branch) =
      RevisionBranch;

  /// Exactly [commit].
  const factory RevisionValueObject.commit(CommitEntity commit) =
      RevisionCommit;

  const RevisionValueObject._();

  /// What git resolves this by: the branch's name, or the commit's sha.
  String get spec => switch (this) {
    RevisionBranch(:final BranchEntity branch) => branch.name.value,
    RevisionCommit(:final CommitEntity commit) => commit.sha.value,
  };
}
