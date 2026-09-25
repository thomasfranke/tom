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
/// The one place the source's text and [GitClientFailure] meet the domain's
/// entities and [GitFailure], one instance per space
/// ([errors](../../../../../../docs/technical/conventions/errors.md)).
final class GitRepositoryImpl implements GitRepository {
  /// Creates a repository over [git].
  ///
  /// The parsers are parameters so a test can substitute one.
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
  /// Exhaustive with no default branch, so a new failure mode breaks this.
  /// The command line and the stderr travel as the cause, never on a
  /// [GitFailure]. [GitDetachedHead] is produced by nothing here: git commits
  /// happily on a detached `HEAD`, so refusing is a use case's policy.
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
        GitClientPathNotInRevision(path: final String path) =>
          GitPathNotInRevision(path, cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        GitClientCommandFailed() => GitOperationFailed(cause: failure),
      };
}
