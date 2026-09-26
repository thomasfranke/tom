/// The use cases, one per operation, that orchestrate the domain and its
/// repositories.
library;

export 'src/diff/diff_document_use_case.dart';
export 'src/documents/read_document_use_case.dart';
export 'src/documents/save_document_use_case.dart';
export 'src/documents/split_document_use_case.dart';
export 'src/git/commit_changes_use_case.dart';
export 'src/git/fetch_remote_use_case.dart';
export 'src/git/list_branches_use_case.dart';
export 'src/git/pull_remote_use_case.dart';
export 'src/git/push_remote_use_case.dart';
export 'src/git/read_file_history_use_case.dart';
export 'src/git/read_git_status_use_case.dart';
export 'src/git/read_version_use_case.dart';
export 'src/git/stage_changes_use_case.dart';
export 'src/git/switch_branch_use_case.dart';
export 'src/search/index_document_use_case.dart';
export 'src/search/index_space_use_case.dart';
export 'src/search/search_space_use_case.dart';
export 'src/spaces/forget_recent_space_use_case.dart';
export 'src/spaces/list_recent_spaces_use_case.dart';
export 'src/spaces/list_space_entries_use_case.dart';
export 'src/spaces/open_space_use_case.dart';
export 'src/use_case.dart';
