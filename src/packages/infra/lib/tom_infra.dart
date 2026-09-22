/// Technical capabilities behind contracts — git, filesystem, settings,
/// markdown, search. Implementations never leave this package.
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/filesystem/dart_io/dart_io_filesystem.dart';
export 'src/filesystem/filesystem.dart';
export 'src/filesystem/filesystem_entry.dart';
export 'src/filesystem/filesystem_entry_type.dart';
export 'src/filesystem/filesystem_failure.dart';
export 'src/git_client/dart_io/dart_io_git_client.dart';
export 'src/git_client/git_client.dart';
export 'src/git_client/git_client_failure.dart';
export 'src/git_client/git_client_for.dart';
export 'src/markdown_parser/markdown_outline.dart';
export 'src/markdown_parser/markdown_package/markdown_package_parser.dart';
export 'src/markdown_parser/markdown_parser.dart';
export 'src/markdown_parser/markdown_parser_failure.dart';
export 'src/markdown_parser/markdown_span.dart';
export 'src/markdown_parser/markdown_span_kind.dart';
export 'src/settings/json_file/application_support.dart';
export 'src/settings/json_file/json_file_settings.dart';
export 'src/settings/settings.dart';
export 'src/settings/settings_failure.dart';
