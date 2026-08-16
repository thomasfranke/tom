/// What git can fail with, in the product's own vocabulary.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_failure.freezed.dart';

/// A git operation that did not complete, as the product talks about it.
///
/// Domain vocabulary, not technical: infrastructure reports what the process
/// did — an exit code, a stderr — and `tom_data` translates that into one of
/// the variants below. The package graph is what keeps the translation honest:
/// `tom_infra` depends only on `tom_core`, so it cannot name a [GitFailure]
/// even by accident, and skipping the translation does not compile.
///
/// `sealed`, so a `switch` over it is exhaustive — in an app where new git
/// failure modes are discovered continuously, that turns "I forgot this case"
/// from a silent bug into a compile error. Freezed generates the variants'
/// `==`/`hashCode` (element-wise for [MergeConflict.conflictedFiles]), which
/// is what used to be hand-written here.
@freezed
sealed class GitFailure with _$GitFailure implements AppFailure {
  /// No `git` executable was found on the PATH.
  ///
  /// Recoverable only by the user: TOM drives the system binary (Decision 2),
  /// so there is nothing to fall back to.
  const factory GitFailure.notInstalled() = GitNotInstalled;

  /// The folder the user opened is not inside a Git repository.
  ///
  /// A space is a folder, not a repository, so this is a state to offer to
  /// fix (`git init`), not an error to report.
  const factory GitFailure.notARepository(
    /// The absolute path that was searched for an enclosing repository.
    String path,
  ) = NotARepository;

  /// A merge, pull or rebase stopped with conflicts.
  const factory GitFailure.mergeConflict(
    /// Paths left conflicted, relative to the repository root.
    List<String> conflictedFiles,
  ) = MergeConflict;

  /// The remote refused the credentials, or asked for some TOM cannot supply.
  const factory GitFailure.authenticationFailed() = AuthenticationFailed;

  /// HEAD points at a commit rather than a branch.
  ///
  /// Committing from here is legal in git and almost never what a
  /// documentation author meant, so it is surfaced rather than silently
  /// allowed.
  const factory GitFailure.detachedHead() = DetachedHead;

  /// A git command failed in a way the product has no vocabulary for.
  ///
  /// The typed fallback: unexpected, but still a `GitFailure` rather than an
  /// exception, so the guarantee that nothing throws across a boundary holds
  /// without having to enumerate every way git can fail up front. A variant
  /// promoted out of here is a variant that earned a name.
  const factory GitFailure.commandFailed(
    /// The command as it was run, for the "details" disclosure in the UI.
    String command,

    /// What git wrote to stderr, verbatim.
    String stderr,
  ) = GitCommandFailed;
}
