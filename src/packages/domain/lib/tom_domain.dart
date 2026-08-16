/// Entities, value objects, failures, repository contracts and domain services.
/// Knows no framework, no git, no disk.
///
/// Nothing outside `lib/src/` is importable from another package, so this file
/// is the whole public surface.
library;

export 'src/documents/document_failure.dart';
export 'src/git/git_failure.dart';
export 'src/search/search_failure.dart';
