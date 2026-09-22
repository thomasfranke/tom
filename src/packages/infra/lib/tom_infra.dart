/// The data layer's outer half: the adapters.
///
/// One implementation per capability contract, each owning the package that
/// does the work — `dart:io` for the filesystem and for git, the `markdown`
/// package for the parser, a JSON file for settings. The contracts they
/// implement live in `tom_data` ([Decision
/// 22](../../../../docs/technical/decisions/022-ports-live-in-the-data-layer.md)).
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/filesystem/dart_io/dart_io_filesystem.dart';
export 'src/git_client/dart_io/dart_io_git_client.dart';
export 'src/markdown_parser/markdown_package/markdown_package_parser.dart';
export 'src/settings/json_file/application_support.dart';
export 'src/settings/json_file/json_file_settings.dart';
