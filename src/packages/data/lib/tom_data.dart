/// The data layer's inner half: the capability contracts and their DTOs, and
/// the repository implementations that fulfil the domain's contracts over
/// them.
///
/// The ports live here and the adapters in `tom_infra`, which depends on this
/// package rather than the other way round ([Decision
/// 22](../../../../docs/technical/decisions/022-ports-live-in-the-data-layer.md)).
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/capabilities/filesystem/filesystem.dart';
export 'src/capabilities/filesystem/filesystem_entry_dto.dart';
export 'src/capabilities/filesystem/filesystem_entry_type_enum.dart';
export 'src/capabilities/filesystem/filesystem_failure.dart';
export 'src/capabilities/git_client/git_client.dart';
export 'src/capabilities/git_client/git_client_failure.dart';
export 'src/capabilities/git_client/git_client_for.dart';
export 'src/capabilities/markdown_parser/markdown_outline_dto.dart';
export 'src/capabilities/markdown_parser/markdown_parser.dart';
export 'src/capabilities/markdown_parser/markdown_parser_failure.dart';
export 'src/capabilities/markdown_parser/markdown_span_dto.dart';
export 'src/capabilities/markdown_parser/markdown_span_kind_enum.dart';
export 'src/capabilities/settings/settings.dart';
export 'src/capabilities/settings/settings_failure.dart';
export 'src/documents/document_repository_impl.dart';
export 'src/documents/markdown_block_reader.dart';
export 'src/git/git_branch_parser.dart';
export 'src/git/git_log_parser.dart';
export 'src/git/git_repository_impl.dart';
export 'src/git/git_status_parser.dart';
export 'src/spaces/recent_spaces_repository_impl.dart';
export 'src/spaces/space_repository_impl.dart';
