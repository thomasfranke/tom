/// The capabilities: one folder each, holding the contract, its failures,
/// and one subfolder per implementation.
///
/// A capability is a thing the app needs from outside itself — the disk,
/// git, a markdown parser, a preference store. Each folder under `lib/src/`
/// is one, and holds its contract, the sealed failure hierarchy that
/// contract answers with, and a subfolder named after the dependency that
/// does the work ([Decision
/// 24](../../../../docs/technical/decisions/024-a-capability-is-a-folder.md)).
///
/// **This package depends on `tom_core` and on `tom_data`'s DTOs, and on
/// nothing else** — no domain type can be named here, because the package
/// that holds them is not on the list.
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface, and every file under `lib/src/` is on
/// it. A capability that exported less than it declares would be a contract
/// nobody can fulfil from outside.
library;

export 'src/filesystem/dart_io/dart_io_filesystem_impl.dart';
export 'src/filesystem/filesystem.dart';
export 'src/filesystem/filesystem_failure.dart';
export 'src/git_client/dart_io/dart_io_git_client_impl.dart';
export 'src/git_client/git_client.dart';
export 'src/git_client/git_client_failure.dart';
export 'src/git_client/git_client_for.dart';
export 'src/markdown_parser/markdown_package/markdown_package_parser_impl.dart';
export 'src/markdown_parser/markdown_parser.dart';
export 'src/markdown_parser/markdown_parser_failure.dart';
export 'src/platform_paths/dart_io/dart_io_platform_paths_impl.dart';
export 'src/platform_paths/platform_paths.dart';
export 'src/platform_paths/platform_paths_failure.dart';
export 'src/settings/json_file/json_file_settings_impl.dart';
export 'src/settings/settings.dart';
export 'src/settings/settings_failure.dart';
export 'src/text_differ/diffutil/diffutil_text_differ_impl.dart';
export 'src/text_differ/text_differ.dart';
export 'src/text_differ/text_differ_failure.dart';
