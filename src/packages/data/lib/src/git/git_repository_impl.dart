/// The domain's git contract, fulfilled by running the system binary.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/git/git_branch_parser.dart';
import 'package:tom_data/src/git/git_data_source.dart';
import 'package:tom_data/src/git/git_log_parser.dart';
import 'package:tom_data/src/git/git_status_parser.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [GitRepository] over [GitDataSource].
///
/// The seam the layer graph exists for. The source runs git and returns text
/// and [GitClientFailure]; the domain knows [CommitEntity],
/// [GitStatusValueObject] and [GitFailure] and nothing about processes. This
/// class is the only place the two meet: it hands the text to a parser and
/// the
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
  /// Creates a repository over [git].
  ///
  /// The parsers are stateless and default to their shared instances; they
  /// are parameters so a test can substitute one, and so the composition
  /// root keeps deciding what is wired to what
  /// (`docs/technical/flows.md#wiring-three-lifetimes`).
  const GitRepositoryImpl({
    required this.git,
    this.statusParser = const GitStatusParser(),
    this.logParser = const GitLogParser(),
    this.branchParser = const GitBranchParser(),
  });

  /// Where git's answers come from.
  final GitDataSource git;

  /// Reads `status --porcelain=v2 -z`.
  final GitStatusParser statusParser;

  /// Reads the `log` records.
  final GitLogParser logParser;

  /// Reads the `branch` records.
  final GitBranchParser branchParser;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() =>
      git.status().map(statusParser.parse).mapFailure(_asGitFailure);

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) => git
      .log(path: path?.value, limit: limit)
      .map(logParser.parse)
      .mapFailure(_asGitFailure);

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() =>
      git.branches().map(branchParser.parse).mapFailure(_asGitFailure);

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) => git.show(revision, path.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) => git.stage(_values(paths)).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) => git.unstage(_values(paths)).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> commit(String message) =>
      git.commit(message).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> createBranch(BranchNameValueObject name) =>
      git.createBranch(name.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> switchBranch(BranchNameValueObject name) =>
      git.switchBranch(name.value).mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> fetch() =>
      git.fetch().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> pull() =>
      git.pull().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> push() =>
      git.push().mapFailure(_asGitFailure);

  /// [paths] as the strings the capability takes.
  static List<String> _values(List<RepoRelativePathValueObject> paths) =>
      paths.map((RepoRelativePathValueObject path) => path.value).toList();

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
