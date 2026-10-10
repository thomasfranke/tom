/// What the application may ask of git.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/account/commit_identity_value_object.dart';
import 'package:tom_domain/src/git/branch_change_value_object.dart';
import 'package:tom_domain/src/git/branch_entity.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/git/branch_standing_value_object.dart';
import 'package:tom_domain/src/git/commit_entity.dart';
import 'package:tom_domain/src/git/commit_sha_value_object.dart';
import 'package:tom_domain/src/git/discard_kind_enum.dart';
import 'package:tom_domain/src/git/git_failure.dart';
import 'package:tom_domain/src/git/git_status_value_object.dart';
import 'package:tom_domain/src/merge/merge_state_value_object.dart';
import 'package:tom_domain/src/paths/repo_relative_path_value_object.dart';

/// Git, in the product's own vocabulary, for one space.
///
/// One instance per space, entities in and entities out: `tom_data` turns
/// the capability's text into these and its failures into [GitFailure]
/// ([errors](../../../../../../docs/technical/conventions/errors.md)).
/// **Every path is relative to the repository root, in both directions**,
/// which is why [RepoRelativePathValueObject] is a type; a status may name
/// files outside the space, and converting belongs to whoever holds the
/// `SpaceEntity`.
abstract interface class GitRepository {
  /// Where the repository stands: branch, distance from the remote, and
  /// everything that differs.
  ///
  /// A reading, not a subscription; stale as soon as anything writes to disk.
  Future<Result<GitStatusValueObject, GitFailure>> status();

  /// The commits reachable from `HEAD`, newest first.
  ///
  /// [path] narrows the history to one file, across renames
  /// (`docs/product/git-workflow/file-history/doc.md`); a null [limit] asks
  /// for all of them. A repository with no commits yet answers an empty list.
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  });

  /// The commits a pull request onto [base] would propose — `HEAD` has them
  /// and [base] does not — newest first.
  ///
  /// [base] is read as the remote has it when `origin` carries a copy, since
  /// that is what the host compares against; the local branch otherwise.
  Future<Result<List<CommitEntity>, GitFailure>> commitsSince(
    BranchNameValueObject base,
  );

  /// What the branch changed since it left [base], one entry per path, read
  /// against the same copy of [base] [commitsSince] uses.
  Future<Result<List<BranchChangeValueObject>, GitFailure>> changesSince(
    BranchNameValueObject base,
  );

  /// The commit where the branch left [base] — the version a pull request's
  /// diff is read against — or null when the two share no history.
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  );

  /// The address `origin` is fetched from, or null when there is none.
  Future<Result<String?, GitFailure>> remoteAddress();

  /// The branch the remote calls its own, or null when nothing says
  /// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch();

  /// Every local branch, with which one is current and what each tracks.
  Future<Result<List<BranchEntity>, GitFailure>> branches();

  /// Every local and remote-tracking branch, and where each stands against
  /// `HEAD`; none on a branch with no commits yet. A remote's own `HEAD` is
  /// a pointer to one of them and is left out.
  Future<Result<List<BranchStandingValueObject>, GitFailure>> standings();

  /// The branch TOM recorded [branch] as started from, or null when nothing
  /// was — it was started outside TOM, or before TOM recorded it.
  Future<Result<BranchNameValueObject?, GitFailure>> recordedBase(
    BranchNameValueObject branch,
  );

  /// Records [base] as the branch [branch] was started from, in the
  /// repository's own config — nothing of TOM's, so it is rebuildable and
  /// goes with the branch when git renames or deletes it.
  Future<Result<void, GitFailure>> recordBase(
    BranchNameValueObject branch,
    BranchNameValueObject base,
  );

  /// Who a commit here is made as, either half unset when git has none.
  Future<Result<CommitIdentityValueObject, GitFailure>> commitIdentity();

  /// The GitHub login somebody chose for this repository, or null.
  ///
  /// Kept in the repository's own config, so the choice is per repository
  /// and rebuildable from what is on disk.
  Future<Result<String?, GitFailure>> chosenAccount();

  /// Records [login] as the GitHub account used in this repository.
  Future<Result<void, GitFailure>> chooseAccount(String login);

  /// The content of [path] as of [revision], anything git resolves: a sha, a
  /// branch name, `HEAD`.
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  });

  /// [path] as of [revision], byte for byte — for a file that may not be
  /// text, which [contentAt] could no longer tell.
  Future<Result<Uint8List, GitFailure>> bytesAt({
    required String revision,
    required RepoRelativePathValueObject path,
  });

  /// [path] as the index holds it, byte for byte: the last version git
  /// knows of a file that was staged and never committed.
  ///
  /// `GitPathNotInRevision` when the index does not hold it.
  Future<Result<Uint8List, GitFailure>> stagedBytes(
    RepoRelativePathValueObject path,
  );

  /// Adds [paths] to the index, whole files only
  /// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
  ///
  /// An empty list stages nothing and succeeds.
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  );

  /// Removes [paths] from the index, leaving the working tree alone.
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  );

  /// Records what is staged, with [message].
  ///
  /// Committing nothing is refused by git and by the UI before it gets here.
  Future<Result<void, GitFailure>> commit(String message);

  /// Starts [name] at the current `HEAD` and switches to it.
  ///
  /// One action, not two, so a caller never has to remember to follow this
  /// with [switchBranch] (`docs/product/git-workflow/branch-switch/doc.md`).
  Future<Result<void, GitFailure>> createBranch(BranchNameValueObject name);

  /// Moves `HEAD` to [name].
  ///
  /// Refused by git when uncommitted changes would be overwritten
  /// (`docs/product/git-workflow/branch-switch/doc.md`).
  Future<Result<void, GitFailure>> switchBranch(BranchNameValueObject name);

  /// Updates the remote-tracking branches without touching the working tree.
  Future<Result<void, GitFailure>> fetch();

  /// Brings the tracked remote's commits into the current branch.
  ///
  /// Stops with `GitMergeConflict` when both sides changed the same lines.
  Future<Result<void, GitFailure>> pull();

  /// The commit `HEAD` names, or null on a branch with no commits yet.
  Future<Result<CommitShaValueObject?, GitFailure>> head();

  /// How many commits the current branch's upstream has that [since] does
  /// not — read after a pull from [since], what arrived, and 0 when it was
  /// already level. A null [since] is a branch with no commits yet.
  ///
  /// The upstream rather than `HEAD`, so the merge commit a pull makes here
  /// is not counted as something that came from the remote
  /// (`docs/product/git-workflow/push-pull/when-it-works/doc.md`).
  Future<Result<int, GitFailure>> upstreamCommitsSince(
    CommitShaValueObject? since,
  );

  /// Publishes the current branch to its remote.
  ///
  /// Answers `GitPushRejected` when the remote moved first
  /// (`docs/product/git-workflow/push-pull/README.md`).
  Future<Result<void, GitFailure>> push();

  /// Publishes [branch] to `origin` for the first time and tracks it from
  /// then on, for a branch [push] has nowhere to send.
  ///
  /// Its own method, not a flag on [push], because it also writes the
  /// branch's upstream into the repository's config.
  Future<Result<void, GitFailure>> publish(BranchNameValueObject branch);

  /// The absolute path of the git directory every worktree of the
  /// repository shares, where TOM keeps what must never be committed.
  ///
  /// Asked of git, because `<root>/.git` is a file in a worktree or a
  /// submodule; shared rather than per worktree, because what is kept
  /// there is keyed by branch and a branch moves between worktrees.
  Future<Result<String, GitFailure>> gitDirectory();

  /// Whether a merge is in progress, and the message git drafted for it.
  ///
  /// Read from git every time rather than remembered, so closing the window
  /// does not leave the `C` marks with nothing explaining them
  /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
  Future<Result<MergeStateValueObject, GitFailure>> mergeState();

  /// Undoes the merge in progress, putting the working tree back.
  ///
  /// The commits that were already made survive: aborting undoes the merge,
  /// never the work.
  Future<Result<void, GitFailure>> abortMerge();

  /// Puts every tracked file of the repository back as the last commit has
  /// it (`docs/product/git-workflow/git-menu/doc.md`).
  ///
  /// What git never committed survives: an untracked file is untouched and
  /// an added one becomes untracked, its content kept.
  Future<Result<void, GitFailure>> discardAll();

  /// Discards [paths] the way [kind] says — every path of one row, a
  /// rename's old name with its new one
  /// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
  Future<Result<void, GitFailure>> discard(
    DiscardKindEnum kind,
    List<RepoRelativePathValueObject> paths,
  );
}
