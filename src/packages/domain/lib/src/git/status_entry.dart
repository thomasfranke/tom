/// One path the working tree reports as different.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/file_state.dart';
import 'package:tom_domain/src/paths/repo_relative_path.dart';

part 'status_entry.freezed.dart';

/// A path that differs from the last commit, and how.
///
/// One state per path, as the domain model settles it
/// (`docs/technical/domain-model.md`). Git keeps the index and the working
/// tree apart, so a file staged as modified and then edited again has two
/// states at once; [state] reports the staged side when there is one, and
/// [isStaged] says whether there is. Staging is whole files here — there is
/// no hunk-level staging (`docs/product/git-workflow/commit/doc.md`) — so
/// nothing else needs the pair.
@freezed
abstract class StatusEntry with _$StatusEntry {
  /// Creates an entry.
  const factory StatusEntry({
    /// Where the file is, relative to the repository root.
    required RepoRelativePath path,

    /// What happened to it.
    required FileState state,

    /// Whether the change is in the index, ready to be committed.
    required bool isStaged,

    /// Where the file came from, when [state] is [FileState.renamed].
    RepoRelativePath? previousPath,
  }) = _StatusEntry;
}
