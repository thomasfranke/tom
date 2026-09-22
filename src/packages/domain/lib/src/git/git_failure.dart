/// What git can fail with, in the product's own vocabulary.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_failure.freezed.dart';

/// A git operation that did not complete, as the product talks about it.
///
/// Domain vocabulary, not technical: the capability reports what the process
/// did — an exit code, a stderr — and `tom_data` translates that into one of
/// the variants below. The package graph keeps the translation honest, since
/// the capability cannot name a [GitFailure] even by accident.
///
/// **Nothing here is a machine's words.** No command line, no stderr, no exit
/// code: a variant carries only what the product puts on screen, and the
/// technical half travels in [AppFailure.cause], where the "details"
/// disclosure finds it. A variant is as specific as the product's answer to it
/// and no more — [GitPushRejected] exists because pulling is the way out, not
/// because git spells it differently.
///
/// `sealed`, so a `switch` over it is exhaustive — in an app where new git
/// failure modes are discovered continuously, that turns "I forgot this case"
/// from a silent bug into a compile error.
@freezed
sealed class GitFailure with _$GitFailure implements AppFailure {
  /// No `git` executable was found on the PATH.
  ///
  /// Recoverable only by the user: TOM drives the system binary (Decision 2),
  /// so there is nothing to fall back to.
  const factory GitFailure.notInstalled({AppFailure? cause}) = GitNotInstalled;

  /// The folder the user opened is not inside a Git repository.
  ///
  /// A space is a folder, not a repository, so this is a state to offer to
  /// fix, not an error to report.
  const factory GitFailure.notARepository(
    /// The absolute path that was searched for an enclosing repository.
    String path, {
    AppFailure? cause,
  }) = GitNotARepository;

  /// A merge, pull or rebase stopped with conflicts.
  const factory GitFailure.mergeConflict(
    /// Paths left conflicted, relative to the repository root.
    ///
    /// Handed over, not copied — see `GitStatus.entries` for why, and for
    /// what it would take to make it structural.
    List<String> conflictedFiles, {
    AppFailure? cause,
  }) = GitMergeConflict;

  /// The remote refused the credentials, or asked for some TOM cannot supply.
  const factory GitFailure.authenticationFailed({AppFailure? cause}) =
      GitAuthenticationFailed;

  /// HEAD points at a commit rather than a branch.
  ///
  /// Committing from here is legal in git and almost never what a
  /// documentation author meant, so it is surfaced rather than silently
  /// allowed.
  const factory GitFailure.detachedHead({AppFailure? cause}) = GitDetachedHead;

  /// The remote refused a push because it had moved on first.
  ///
  /// Its own outcome rather than a generic failure: the product shows it as
  /// one, with pulling as the way out
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  const factory GitFailure.pushRejected({AppFailure? cause}) = GitPushRejected;

  /// A git command ran past the time it was allowed and was killed.
  ///
  /// Named because it is the one failure the user can neither fix nor retry
  /// into a different answer. Which command ran is in [cause]: the product
  /// says "this took too long", not `git fetch --prune`.
  const factory GitFailure.timedOut({AppFailure? cause}) = GitTimedOut;

  /// Git failed in a way the product has no vocabulary for.
  ///
  /// The typed fallback, and it carries nothing: everything a reader would
  /// want — the command, the stderr — is in [cause], which is the only place
  /// a machine's words belong. A variant promoted out of here is one that
  /// earned a sentence of its own on screen.
  const factory GitFailure.operationFailed({AppFailure? cause}) =
      GitOperationFailed;
}
