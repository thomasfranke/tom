/// Technical capabilities behind contracts — git, filesystem, markdown,
/// search. Implementations never leave this package.
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
