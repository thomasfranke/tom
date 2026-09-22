/// Entities, value objects, failures, repository contracts and domain services.
/// Knows no framework, no git, no disk.
///
/// Nothing outside `lib/src/` is importable from another package, so this file
/// is the whole public surface.
library;

export 'src/documents/block_kind_enum.dart';
export 'src/documents/block_reader.dart';
export 'src/documents/block_value_object.dart';
export 'src/documents/document_entity.dart';
export 'src/documents/document_failure.dart';
export 'src/documents/document_repository.dart';
export 'src/documents/document_repository_for.dart';
export 'src/documents/parsed_document_value_object.dart';
export 'src/git/author_value_object.dart';
export 'src/git/branch_entity.dart';
export 'src/git/branch_name_value_object.dart';
export 'src/git/commit_date_value_object.dart';
export 'src/git/commit_entity.dart';
export 'src/git/commit_sha_value_object.dart';
export 'src/git/file_state_enum.dart';
export 'src/git/git_failure.dart';
export 'src/git/git_repository.dart';
export 'src/git/git_status_value_object.dart';
export 'src/git/status_entry_value_object.dart';
export 'src/paths/repo_relative_path_value_object.dart';
export 'src/paths/space_relative_path_value_object.dart';
export 'src/search/search_failure.dart';
export 'src/spaces/recent_space_entity.dart';
export 'src/spaces/recent_spaces_repository.dart';
export 'src/spaces/space_entity.dart';
export 'src/spaces/space_entry_type_enum.dart';
export 'src/spaces/space_entry_value_object.dart';
export 'src/spaces/space_failure.dart';
export 'src/spaces/space_repository.dart';
