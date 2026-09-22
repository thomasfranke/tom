/// A line of work in the repository.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';

part 'branch_entity.freezed.dart';

/// A local branch, and whether it is the one checked out.
///
/// Local only: the branch switcher moves between branches that exist on this
/// machine (`docs/product/git-workflow/branch-switch/doc.md`), and a remote
/// branch appears here only as some local branch's [upstream].
@freezed
abstract class BranchEntity with _$BranchEntity {
  /// Creates a branch.
  const factory BranchEntity({
    /// What it is called, which is its identity.
    required BranchNameValueObject name,

    /// Whether `HEAD` points at it.
    required bool isCurrent,

    /// The branch it tracks, or null when it tracks nothing.
    BranchNameValueObject? upstream,
  }) = _BranchEntity;
}
