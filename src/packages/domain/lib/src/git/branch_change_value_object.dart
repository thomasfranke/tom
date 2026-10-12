/// One path a branch changed since it left its base.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/file_state_enum.dart';
import 'package:tom_domain/src/paths/repo_relative_path_value_object.dart';

part 'branch_change_value_object.freezed.dart';

/// A path the branch changed, how, and by how many lines.
///
/// What a pull request proposes, read between the base and `HEAD` rather
/// than against the working tree — so [state] is never untracked or
/// conflicted, and a rename arrives as a deletion and an addition.
@freezed
abstract class BranchChangeValueObject with _$BranchChangeValueObject {
  /// A change.
  const factory BranchChangeValueObject({
    /// Where the file is, relative to the repository root.
    required RepoRelativePathValueObject path,

    /// What happened to it.
    required FileStateEnum state,

    /// Lines the branch added, or null for a file git calls binary.
    int? added,

    /// Lines the branch removed, or null for a file git calls binary.
    int? removed,
  }) = _BranchChangeValueObject;
}
