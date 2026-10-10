/// Running git for one space, and handing back what it printed.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where git's answers come from, as text in the format [GitClient] documents
/// per method and never as an entity.
///
/// The parsers belong to the repository above ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
/// One instance per space, holding a client that serializes its own commands.
final class GitDataSource {
  /// Creates a source over [client].
  const GitDataSource({required this.client});

  /// What runs git for this space.
  final GitClient client;

  /// `status --porcelain=v2 -z`.
  Future<Result<String, GitClientFailure>> status() => client.status();

  /// The `log` records, newest first.
  Future<Result<String, GitClientFailure>> log({
    String? path,
    int? limit,
    String? since,
  }) => client.log(path: path, limit: limit, since: since);

  /// `diff --numstat` from where `HEAD` left [base].
  Future<Result<String, GitClientFailure>> diffNumstat(String base) =>
      client.diffNumstat(base);

  /// `diff --name-status` from where `HEAD` left [base].
  Future<Result<String, GitClientFailure>> diffNameStatus(String base) =>
      client.diffNameStatus(base);

  /// Where `HEAD` left [revision], empty with no shared history.
  Future<Result<String, GitClientFailure>> mergeBase(String revision) =>
      client.mergeBase(revision);

  /// Whether [revision] names a commit.
  Future<Result<bool, GitClientFailure>> resolves(String revision) =>
      client.resolves(revision);

  /// `origin`'s address, empty when there is none.
  Future<Result<String, GitClientFailure>> remoteUrl() => client.remoteUrl();

  /// `origin`'s own `HEAD` branch, empty when nothing says.
  Future<Result<String, GitClientFailure>> defaultBranch() =>
      client.defaultBranch();

  /// The `branch` records, in git's order.
  Future<Result<String, GitClientFailure>> branches() => client.branches();

  /// Every branch's `ahead behind` against `HEAD`.
  Future<Result<String, GitClientFailure>> branchStandings() =>
      client.branchStandings();

  /// How many commits `HEAD` has.
  Future<Result<int, GitClientFailure>> commitCount() => client.commitCount();

  /// The branch [branch] was recorded as started from, empty when none was.
  Future<Result<String, GitClientFailure>> branchBase(String branch) =>
      client.branchBase(branch);

  /// Records [base] as where [branch] was started from.
  Future<Result<void, GitClientFailure>> recordBranchBase(
    String branch,
    String base,
  ) => client.recordBranchBase(branch, base);

  /// `user.name` and `user.email`, unit-separated.
  Future<Result<String, GitClientFailure>> identity() => client.identity();

  /// The GitHub login chosen for this repository, empty when none was.
  Future<Result<String, GitClientFailure>> githubAccount() =>
      client.githubAccount();

  /// Records [login] as this repository's GitHub account.
  Future<Result<void, GitClientFailure>> recordGithubAccount(String login) =>
      client.recordGithubAccount(login);

  /// The file's content at [revision].
  Future<Result<String, GitClientFailure>> show(String revision, String path) =>
      client.show(revision, path);

  /// The file's bytes at [revision].
  Future<Result<Uint8List, GitClientFailure>> showBytes(
    String revision,
    String path,
  ) => client.showBytes(revision, path);

  /// The file's bytes as the index holds them.
  Future<Result<Uint8List, GitClientFailure>> showStagedBytes(String path) =>
      client.showStagedBytes(path);

  /// Adds [paths] to the index.
  Future<Result<void, GitClientFailure>> stage(List<String> paths) =>
      client.stage(paths);

  /// Takes [paths] back out of the index.
  Future<Result<void, GitClientFailure>> unstage(List<String> paths) =>
      client.unstage(paths);

  /// Commits what is staged.
  Future<Result<void, GitClientFailure>> commit(String message) =>
      client.commit(message);

  /// Creates a branch at `HEAD`.
  Future<Result<void, GitClientFailure>> createBranch(String name) =>
      client.createBranch(name);

  /// Moves `HEAD` to an existing branch.
  Future<Result<void, GitClientFailure>> switchBranch(String name) =>
      client.switchBranch(name);

  /// Updates the remote-tracking refs.
  Future<Result<void, GitClientFailure>> fetch() => client.fetch();

  /// Fetches and integrates.
  Future<Result<void, GitClientFailure>> pull() => client.pull();

  /// The sha `HEAD` names, empty before the first commit.
  Future<Result<String, GitClientFailure>> head() => client.head();

  /// How many commits the upstream has that [since] does not.
  Future<Result<int, GitClientFailure>> upstreamCommitsSince(String since) =>
      client.upstreamCommitsSince(since);

  /// Sends the current branch to its upstream.
  Future<Result<void, GitClientFailure>> push() => client.push();

  /// Sends [branch] to `origin` for the first time, tracking it from then on.
  Future<Result<void, GitClientFailure>> publish(String branch) =>
      client.publish(branch);

  /// The git directory every worktree shares, absolute.
  Future<Result<String, GitClientFailure>> gitDirectory() =>
      client.gitDirectory();

  /// Whether `MERGE_HEAD` says a merge is in progress.
  Future<Result<bool, GitClientFailure>> mergeInProgress() =>
      client.mergeInProgress();

  /// The message git drafted for the merge in progress.
  Future<Result<String, GitClientFailure>> mergeMessage() =>
      client.mergeMessage();

  /// Undoes the merge in progress.
  Future<Result<void, GitClientFailure>> abortMerge() => client.abortMerge();

  /// Puts every tracked file back as the last commit has it.
  Future<Result<void, GitClientFailure>> discardAll() => client.discardAll();

  /// Puts [paths] in the working tree back as staged.
  Future<Result<void, GitClientFailure>> discardUnstaged(List<String> paths) =>
      client.discardUnstaged(paths);

  /// Puts [paths] back as the last commit has them.
  Future<Result<void, GitClientFailure>> discardSinceCommit(
    List<String> paths,
  ) => client.discardSinceCommit(paths);

  /// Deletes [paths], which git never committed.
  Future<Result<void, GitClientFailure>> deleteUncommitted(
    List<String> paths,
  ) => client.deleteUncommitted(paths);
}
