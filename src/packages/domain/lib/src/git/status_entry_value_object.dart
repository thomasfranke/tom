/// One path the working tree reports as different.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/file_state_enum.dart';
import 'package:tom_domain/src/paths/repo_relative_path_value_object.dart';

part 'status_entry_value_object.freezed.dart';

/// A path that differs from the last commit, and how.
///
/// One state per path (`docs/technical/domain/git.md`): git keeps the index
/// and the working tree apart, so a file staged and then edited again has two
/// states, and [state] reports the staged side when there is one. Staging is
/// whole files, so nothing needs the pair.
@freezed
abstract class StatusEntryValueObject with _$StatusEntryValueObject {
  /// An entry.
  const factory StatusEntryValueObject({
    /// Where the file is, relative to the repository root.
    required RepoRelativePathValueObject path,

    /// What happened to it.
    required FileStateEnum state,

    /// Whether the change is in the index, ready to be committed.
    required bool isStaged,

    /// Where the file came from, when [state] is [FileStateEnum.renamed].
    RepoRelativePathValueObject? previousPath,
  }) = _StatusEntryValueObject;
}
