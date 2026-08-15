/// What git can fail with, in the product's own vocabulary.
library;

import 'package:tom_core/tom_core.dart';

/// A git operation that did not complete, as the product talks about it.
///
/// Domain vocabulary, not technical: infrastructure reports what the process
/// did — an exit code, a stderr — and `tom_data` translates that into one of
/// the variants below. The package graph is what keeps the translation honest:
/// `tom_infra` depends only on `tom_core`, so it cannot name a [GitFailure]
/// even by accident, and skipping the translation does not compile.
///
/// `sealed`, so a new variant breaks every `switch` that has to handle it —
/// in an app where new git failure modes are discovered continuously, that
/// turns "I forgot this case" from a silent bug into a compile error.
sealed class GitFailure implements AppFailure {
  /// Const constructor, for the variants below.
  const GitFailure();
}

/// No `git` executable was found on the PATH.
///
/// Recoverable only by the user: TOM drives the system binary (Decision 2), so
/// there is nothing to fall back to.
final class GitNotInstalled extends GitFailure {
  /// Creates the failure.
  const GitNotInstalled();
}

/// The folder the user opened is not inside a Git repository.
///
/// A space is a folder, not a repository, so this is a state to offer to fix
/// (`git init`), not an error to report.
final class NotARepository extends GitFailure {
  /// Creates the failure for the folder at [path].
  const NotARepository(this.path);

  /// The absolute path that was searched for an enclosing repository.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is NotARepository && other.path == path;

  @override
  int get hashCode => Object.hash(runtimeType, path);
}

/// A merge, pull or rebase stopped with conflicts.
final class MergeConflict extends GitFailure {
  /// Creates the failure listing the [conflictedFiles].
  const MergeConflict(this.conflictedFiles);

  /// Paths left conflicted, relative to the repository root.
  final List<String> conflictedFiles;

  @override
  bool operator ==(Object other) =>
      other is MergeConflict &&
      _sameStrings(other.conflictedFiles, conflictedFiles);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(conflictedFiles));
}

/// The remote refused the credentials, or asked for some TOM cannot supply.
final class AuthenticationFailed extends GitFailure {
  /// Creates the failure.
  const AuthenticationFailed();
}

/// HEAD points at a commit rather than a branch.
///
/// Committing from here is legal in git and almost never what a documentation
/// author meant, so it is surfaced rather than silently allowed.
final class DetachedHead extends GitFailure {
  /// Creates the failure.
  const DetachedHead();
}

/// A git command failed in a way the product has no vocabulary for.
///
/// The typed fallback: unexpected, but still a `GitFailure` rather than an
/// exception, so the guarantee that nothing throws across a boundary holds
/// without having to enumerate every way git can fail up front. A variant
/// promoted out of here is a variant that earned a name.
final class GitCommandFailed extends GitFailure {
  /// Creates the failure for [command], carrying its [stderr].
  const GitCommandFailed(this.command, this.stderr);

  /// The command as it was run, for the "details" disclosure in the UI.
  final String command;

  /// What git wrote to stderr, verbatim.
  final String stderr;

  @override
  bool operator ==(Object other) =>
      other is GitCommandFailed &&
      other.command == command &&
      other.stderr == stderr;

  @override
  int get hashCode => Object.hash(runtimeType, command, stderr);
}

/// Element-wise comparison, so two failures listing the same paths are equal.
///
/// Hand-written to keep `tom_domain` free of a collections dependency for six
/// lines; Freezed replaces it when codegen arrives.
bool _sameStrings(List<String> a, List<String> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
