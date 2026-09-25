/// The repository implementations, the parsers and the DTOs that cross a
/// capability's contract ([Decision 21](../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md)).
library;

export 'src/capabilities/filesystem/filesystem_entry_dto.dart';
export 'src/capabilities/filesystem/filesystem_entry_type_enum.dart';
export 'src/capabilities/markdown_parser/markdown_outline_dto.dart';
export 'src/capabilities/markdown_parser/markdown_span_dto.dart';
export 'src/capabilities/markdown_parser/markdown_span_kind_enum.dart';
export 'src/capabilities/text_differ/text_edit_dto.dart';
export 'src/capabilities/text_differ/text_edit_kind_enum.dart';
export 'src/diff/text_differ_block_aligner_impl.dart';
export 'src/diff/text_differ_data_source.dart';
export 'src/documents/document_data_source.dart';
export 'src/documents/document_repository_impl.dart';
export 'src/documents/markdown_block_reader_impl.dart';
export 'src/documents/markdown_data_source.dart';
export 'src/git/git_branch_parser.dart';
export 'src/git/git_data_source.dart';
export 'src/git/git_log_parser.dart';
export 'src/git/git_repository_impl.dart';
export 'src/git/git_status_parser.dart';
export 'src/spaces/recent_space_dto.dart';
export 'src/spaces/recent_spaces_data_source.dart';
export 'src/spaces/recent_spaces_repository_impl.dart';
export 'src/spaces/space_data_source.dart';
export 'src/spaces/space_repository_impl.dart';
