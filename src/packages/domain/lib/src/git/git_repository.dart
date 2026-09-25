/// What the application may ask of git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/git/branch_entity.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/git/commit_entity.dart';
import 'package:tom_domain/src/git/git_failure.dart';
import 'package:tom_domain/src/git/git_status_value_object.dart';
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

  /// Every local branch, with which one is current and what each tracks.
  Future<Result<List<BranchEntity>, GitFailure>> branches();

  /// The content of [path] as of [revision], anything git resolves: a sha, a
  /// branch name, `HEAD`.
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  });

  /// Adds [paths] to the index, whole files only
  /// (`docs/product/git-workflow/commit/doc.md`).
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

  /// Publishes the current branch to its remote.
  ///
  /// Answers `GitPushRejected` when the remote moved first
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  Future<Result<void, GitFailure>> push();
}
