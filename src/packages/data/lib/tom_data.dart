/// Fulfils the domain's repository contracts by orchestrating infrastructure,
/// and parses its output.
///
/// Nothing outside `lib/src/` is importable from another package, so this
/// file is the whole public surface.
library;

export 'src/git/git_branch_parser.dart';
export 'src/git/git_log_parser.dart';
export 'src/git/git_repository_impl.dart';
export 'src/git/git_status_parser.dart';
