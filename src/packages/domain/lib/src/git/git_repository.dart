/// What the application may ask of git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/git/branch.dart';
import 'package:tom_domain/src/git/branch_name.dart';
import 'package:tom_domain/src/git/commit.dart';
import 'package:tom_domain/src/git/git_failure.dart';
import 'package:tom_domain/src/git/git_status.dart';
import 'package:tom_domain/src/paths/repo_relative_path.dart';

/// Git, in the product's own vocabulary, for one space.
///
/// One instance per space: git runs against the space's repository, and the
/// commands are serialized per space by the infrastructure underneath
/// ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Entities in, entities out — never process output. What runs git is a
/// capability in `tom_infra` that returns text, and `tom_data` is where the
/// text becomes a [GitStatus] and a `GitClientFailure` becomes a
/// `GitFailure`; the package graph makes that translation mandatory rather
/// than customary
/// ([layers](../../../../../../docs/technical/layers.md#errors-across-boundaries)).
///
/// **Every path here is relative to the repository root**, in both
/// directions — which is not the same thing as relative to the space, and is
/// why [RepoRelativePath] is a type. A space opened at `docs/` inside a code
/// repository gets a status naming source files it does not contain;
/// converting, and deciding what to do with what falls outside, belongs to
/// the caller that holds the `Space`.
abstract interface class GitRepository {
  /// Where the repository stands: branch, distance from the remote, and
  /// everything that differs.
  ///
  /// A reading, not a subscription — it is stale as soon as anything writes
  /// to disk, and keeping it current is the watcher's job.
  Future<Result<GitStatus, GitFailure>> status();

  /// The commits reachable from `HEAD`, newest first.
  ///
  /// [path] narrows the history to one file — including across renames, the
  /// way file history is expected to work
  /// (`docs/product/git-workflow/file-history/doc.md`). [limit] caps how many
  /// are returned; null asks for all of them, which on a large repository is
  /// a decision the caller has to make on purpose.
  ///
  /// A repository with no commits yet answers with an empty list: a fresh
  /// `git init` is a normal state for a space, not a failure to report.
  Future<Result<List<Commit>, GitFailure>> history({
    RepoRelativePath? path,
    int? limit,
  });

  /// Every local branch, with which one is current and what each tracks.
  Future<Result<List<Branch>, GitFailure>> branches();

  /// The content of [path] as of [revision].
  ///
  /// What the rendered diff reads to build its "before" side. [revision] is
  /// anything git resolves — a sha, a branch name, `HEAD` — because that is
  /// what the diff screens offer to compare against.
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePath path,
  });

  /// Adds [paths] to the index.
  ///
  /// Whole files: there is no hunk-level staging
  /// (`docs/product/git-workflow/commit/doc.md`). An empty list stages
  /// nothing and succeeds — "stage the selection" with nothing selected is
  /// not an error.
  Future<Result<void, GitFailure>> stage(List<RepoRelativePath> paths);

  /// Removes [paths] from the index, leaving the working tree alone.
  Future<Result<void, GitFailure>> unstage(List<RepoRelativePath> paths);

  /// Records what is staged, with [message].
  ///
  /// Committing nothing is refused by git and by the UI before it gets here.
  Future<Result<void, GitFailure>> commit(String message);

  /// Starts [name] at the current `HEAD` and switches to it.
  ///
  /// One action, not two: the product creates a branch by moving onto it
  /// ("the app switches to it immediately",
  /// `docs/product/git-workflow/branch-switch/doc.md`), so a caller never
  /// has to remember to follow this with [switchBranch].
  Future<Result<void, GitFailure>> createBranch(BranchName name);

  /// Moves `HEAD` to [name].
  ///
  /// Refused by git when uncommitted changes would be overwritten; the
  /// product offers the choice before asking
  /// (`docs/product/git-workflow/branch-switch/doc.md`).
  Future<Result<void, GitFailure>> switchBranch(BranchName name);

  /// Updates the remote-tracking branches without touching the working tree.
  ///
  /// What makes ahead/behind in [status] mean anything.
  Future<Result<void, GitFailure>> fetch();

  /// Brings the tracked remote's commits into the current branch.
  ///
  /// Stops with `GitMergeConflict` when the two sides changed the same
  /// lines, which is a state to resolve rather than an error to report.
  Future<Result<void, GitFailure>> pull();

  /// Publishes the current branch to its remote.
  ///
  /// Answers `GitPushRejected` when the remote moved first — the one outcome
  /// the product shows as its own
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  Future<Result<void, GitFailure>> push();
}
