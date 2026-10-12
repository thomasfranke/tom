/// What git can fail with, in the product's own vocabulary.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_failure.freezed.dart';

/// A git operation that did not complete, as the product talks about it.
///
/// **Nothing here is a machine's words**: a variant carries only what goes
/// on screen, and the command, stderr and exit code travel in
/// [AppFailure.cause]. A variant is as specific as the product's answer to it
/// and no more; `sealed`, so a `switch` over it is exhaustive.
@freezed
sealed class GitFailure with _$GitFailure implements AppFailure {
  /// No `git` executable was found on the PATH.
  ///
  /// Only the user can fix it: TOM drives the system binary (Decision 2).
  const factory GitFailure.notInstalled({AppFailure? cause}) = GitNotInstalled;

  /// The folder the user opened is not inside a Git repository.
  ///
  /// A state to offer to fix, not an error to report.
  const factory GitFailure.notARepository(
    /// The absolute path that was searched for an enclosing repository.
    String path, {
    AppFailure? cause,
  }) = GitNotARepository;

  /// A merge, pull or rebase stopped with conflicts.
  const factory GitFailure.mergeConflict(
    /// Paths left conflicted, relative to the repository root.
    ///
    /// Handed over, not copied (see `GitStatusValueObject.entries`).
    List<String> conflictedFiles, {
    AppFailure? cause,
  }) = GitMergeConflict;

  /// Staging was refused because a document still holds a conflict marker.
  ///
  /// This product's rule, not git's: git will record a marker somebody
  /// staged, and `<<<<<<<` committed into documentation is read by everyone
  /// who opens the file next
  /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
  const factory GitFailure.conflictMarkersPresent(
    /// The documents still holding one, so the refusal can name them.
    List<String> paths, {
    AppFailure? cause,
  }) = GitConflictMarkersPresent;

  /// The machine's git is older than the product works on.
  ///
  /// Its own outcome because Home says so in the product's words, and
  /// choosing another folder would not help
  /// (`docs/product/home/opening-a-space/doc.md`).
  const factory GitFailure.tooOld(
    /// The release this machine has, as `2.39.2`.
    String found, {
    AppFailure? cause,
  }) = GitTooOld;

  /// The remote refused the credentials, or asked for some TOM cannot supply.
  const factory GitFailure.authenticationFailed({AppFailure? cause}) =
      GitAuthenticationFailed;

  /// The remote could not be reached: the network, not the repository
  /// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).
  const factory GitFailure.networkUnavailable({AppFailure? cause}) =
      GitNetworkUnavailable;

  /// There is no remote to talk to.
  const factory GitFailure.noRemote({AppFailure? cause}) = GitNoRemote;

  /// The address names no repository git can clone: a typo, a repository
  /// that is gone, or a protocol git does not speak
  /// (`docs/product/home/cloning/doc.md`).
  const factory GitFailure.remoteNotFound({AppFailure? cause}) =
      GitRemoteNotFound;

  /// The folder a clone was to fill already holds something, and git never
  /// clones over it.
  const factory GitFailure.cloneDestinationTaken(
    /// The absolute path the clone was asked to create.
    String path, {
    AppFailure? cause,
  }) = GitCloneDestinationTaken;

  /// HEAD points at a commit rather than a branch.
  ///
  /// Legal in git and almost never what a documentation author meant, so it
  /// is surfaced rather than silently allowed.
  const factory GitFailure.detachedHead({AppFailure? cause}) = GitDetachedHead;

  /// The remote refused a push because it had moved on first.
  ///
  /// Its own outcome because pulling is the way out
  /// (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
  const factory GitFailure.pushRejected({AppFailure? cause}) = GitPushRejected;

  /// The remote refused a push because it protects the branch.
  ///
  /// Its own outcome because neither pulling nor trying again is the way in:
  /// a pull request is
  /// (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
  const factory GitFailure.branchProtected({AppFailure? cause}) =
      GitBranchProtected;

  /// Git refused to pull before starting, because what it brings would
  /// overwrite work that was never committed.
  ///
  /// Its own outcome because committing is the way out
  /// (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
  const factory GitFailure.localChangesOverwritten(
    /// The files at stake, relative to the repository root.
    List<String> paths, {
    AppFailure? cause,
  }) = GitLocalChangesOverwritten;

  /// The branch has no commit yet, and the action needs one to go back to.
  ///
  /// This product's refusal, not git's: `Discard all changes` before the
  /// first commit would empty the index and then fail, half done
  /// (`docs/product/git-workflow/git-menu/doc.md`).
  const factory GitFailure.noCommitsYet({AppFailure? cause}) = GitNoCommitsYet;

  /// A file to be deleted as *never committed* is in the last commit after
  /// all — the list it was pressed in had gone stale.
  ///
  /// Refused rather than deleted: what git has can be put back, and that is
  /// a different action with a different question
  /// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
  const factory GitFailure.pathCommitted(
    /// The files that turned out to be committed, relative to the
    /// repository root.
    List<String> paths, {
    AppFailure? cause,
  }) = GitPathCommitted;

  /// A git command ran past the time it was allowed and was killed.
  ///
  /// Which command is in [cause]; the product says "this took too long".
  const factory GitFailure.timedOut({AppFailure? cause}) = GitTimedOut;

  /// The document has no version at that revision.
  ///
  /// A new document, one only ever renamed into place, or a repository with
  /// no commits yet: every block is an addition, which is an answer rather
  /// than a failure to report
  /// (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
  const factory GitFailure.pathNotInRevision(
    /// The path, as the user's repository spells it.
    String path, {
    AppFailure? cause,
  }) = GitPathNotInRevision;

  /// The person refused the command before it ran
  /// (`docs/product/git-workflow/approvals/doc.md`).
  ///
  /// **Never worded as an error**: nothing went wrong, so whoever gets it
  /// stops quietly, and a refused read leaves the last reading on screen.
  @Implements<CommandDenial>()
  const factory GitFailure.commandDenied({AppFailure? cause}) =
      GitCommandDenied;

  /// Git failed in a way the product has no vocabulary for.
  ///
  /// The typed fallback, carrying nothing but [cause]; a variant promoted out
  /// of here is one that earned its own sentence on screen.
  const factory GitFailure.operationFailed({AppFailure? cause}) =
      GitOperationFailed;
}
