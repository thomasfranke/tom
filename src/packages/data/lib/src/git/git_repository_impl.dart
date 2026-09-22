/// The domain's git contract, fulfilled by running the system binary.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/git_client/git_client.dart';
import 'package:tom_data/src/capabilities/git_client/git_client_failure.dart';
import 'package:tom_data/src/git/git_branch_parser.dart';
import 'package:tom_data/src/git/git_log_parser.dart';
import 'package:tom_data/src/git/git_status_parser.dart';
import 'package:tom_domain/tom_domain.dart';

/// [GitRepository] over the [GitClient] capability.
///
/// The seam the layer graph exists for. `GitClient` knows how to run git and
/// returns text and [GitClientFailure]; the domain knows [Commit],
/// [GitStatus] and [GitFailure] and nothing about processes. This class is
/// the only place the two meet: it hands the text to a parser and the
/// failure to [_asGitFailure].
///
/// Neither half can skip the other. `tom_infra` depends only on `tom_core`,
/// so it cannot name a [GitFailure] even by accident; `tom_domain` names no
/// capability, so it cannot reach a process
/// ([layers](../../../../../../docs/technical/layers.md#errors-across-boundaries)).
///
/// One instance per space, holding that space's client — the client
/// serializes its own commands, so nothing here has to.
final class GitRepositoryImpl implements GitRepository {
  /// Creates a repository over [client].
  ///
  /// The parsers are stateless and default to their shared instances; they
  /// are parameters so a test can substitute one, and so the composition
  /// root keeps deciding what is wired to what
  /// (`docs/technical/flows.md#wiring-three-lifetimes`).
  const GitRepositoryImpl({
    required this.client,
    this.statusParser = const GitStatusParser(),
    this.logParser = const GitLogParser(),
    this.branchParser = const GitBranchParser(),
  });

  /// What runs git for this space.
  final GitClient client;

  /// Reads `status --porcelain=v2 -z`.
  final GitStatusParser statusParser;

  /// Reads the `log` records.
  final GitLogParser logParser;

  /// Reads the `branch` records.
  final GitBranchParser branchParser;

  @override
  Future<Result<GitStatus, GitFailure>> status() =>
      client.status().map(statusParser.parse).mapFailure(_asGitFailure);

  @override
  Future<Result<List<Commit>, GitFailure>> history({
    RepoRelativePath? path,
    int? limit,
  }) => client
      .log(path: path?.value, limit: limit)
      .map(logParser.parse)
      .mapFailure(_asGitFailure);

  @override
  Future<Result<List<Branch>, GitFailure>> branches() =>
      client.branches().map(branchParser.parse).mapFailure(_asGitFailure);

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePath path,
  }) => client.show(revision, path.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> stage(List<RepoRelativePath> paths) =>
      client.stage(_values(paths)).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> unstage(List<RepoRelativePath> paths) =>
      client.unstage(_values(paths)).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> commit(String message) =>
      client.commit(message).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> createBranch(BranchName name) =>
      client.createBranch(name.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> switchBranch(BranchName name) =>
      client.switchBranch(name.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> fetch() =>
      client.fetch().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> pull() =>
      client.pull().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> push() =>
      client.push().mapFailure(_asGitFailure);

  /// [paths] as the strings the capability takes.
  static List<String> _values(List<RepoRelativePath> paths) =>
      paths.map((RepoRelativePath path) => path.value).toList();

  /// What infrastructure reported, in the product's vocabulary.
  ///
  /// Exhaustive over [GitClientFailure] with no default branch: a failure
  /// mode discovered later breaks this switch, which is the whole reason the
  /// hierarchy is sealed.
  ///
  /// **The command line and the stderr do not come up with it.** They are the
  /// machine's words, so they stay in the capability's failure and travel as
  /// the cause — which is where the UI's "details" disclosure reads them,
  /// without a [GitFailure] variant ever carrying one.
  ///
  /// [GitDetachedHead] is deliberately not produced here: git does not fail
  /// on a detached `HEAD`, it commits happily. It is a state `status()`
  /// reports and a use case refuses to act on, not an error a command
  /// returns.
  static GitFailure _asGitFailure(GitClientFailure failure) =>
      switch (failure) {
        GitClientExecutableNotFound() => GitNotInstalled(cause: failure),
        GitClientNotARepository(path: final String path) => GitNotARepository(
          path,
          cause: failure,
        ),
        GitClientMergeConflict(conflictedPaths: final List<String> paths) =>
          GitMergeConflict(paths, cause: failure),
        GitClientAuthenticationFailed() => GitAuthenticationFailed(
          cause: failure,
        ),
        GitClientPushRejected() => GitPushRejected(cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        GitClientCommandFailed() => GitOperationFailed(cause: failure),
      };
}
