/// Technical capabilities behind contracts — git, filesystem, markdown,
/// search. Implementations never leave this package.
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/filesystem/dart_io/dart_io_filesystem.dart';
export 'src/filesystem/filesystem.dart';
export 'src/filesystem/filesystem_failure.dart';
