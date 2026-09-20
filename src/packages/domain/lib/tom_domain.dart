/// Entities, value objects, failures, repository contracts and domain services.
/// Knows no framework, no git, no disk.
///
/// Nothing outside `lib/src/` is importable from another package, so this file
/// is the whole public surface.
library;

export 'src/documents/document_failure.dart';
export 'src/git/author.dart';
export 'src/git/branch.dart';
export 'src/git/branch_name.dart';
export 'src/git/commit.dart';
export 'src/git/commit_date.dart';
export 'src/git/commit_sha.dart';
export 'src/git/file_state.dart';
export 'src/git/git_failure.dart';
export 'src/git/git_status.dart';
export 'src/git/status_entry.dart';
export 'src/paths/repo_relative_path.dart';
export 'src/search/search_failure.dart';
