/// Running git for one space, and handing back what it printed.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where git's answers come from.
///
/// **Text out, never an entity.** Git's own output in the format
/// [GitClient] documents per method is this capability's DTO — the parsers
/// that turn it into the domain's vocabulary belong to the repository
/// above, which is the half allowed to name a `CommitEntity` ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
///
/// Thin, method for method, and that is the shape of an adapter over a
/// command-line tool: every question is one command. What it buys is that
/// nothing above holds a [GitClient], and that a question needing *two*
/// commands — how far ahead of its upstream a branch is, which M1 asks
/// beside the status — is composed here rather than in the repository.
///
/// One instance per space, holding that space's client — the client
/// serializes its own commands, so nothing here has to.
final class GitDataSource {
  /// Creates a source over [client].
  const GitDataSource({required this.client});

  /// What runs git for this space.
  final GitClient client;

  /// `status --porcelain=v2 -z`.
  Future<Result<String, GitClientFailure>> status() => client.status();

  /// The `log` records, newest first.
  Future<Result<String, GitClientFailure>> log({String? path, int? limit}) =>
      client.log(path: path, limit: limit);

  /// The `branch` records, in git's order.
  Future<Result<String, GitClientFailure>> branches() => client.branches();

  /// The file's content at [revision].
  Future<Result<String, GitClientFailure>> show(String revision, String path) =>
      client.show(revision, path);

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

  /// Sends the current branch to its upstream.
  Future<Result<void, GitClientFailure>> push() => client.push();
}
