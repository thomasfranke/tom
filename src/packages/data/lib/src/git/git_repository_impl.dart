/// The domain's git contract, fulfilled by running the system binary.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/git/git_branch_parser.dart';
import 'package:tom_data/src/git/git_log_parser.dart';
import 'package:tom_data/src/git/git_status_parser.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

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
  Future<Result<GitStatus>> status() async =>
      _parsed(await client.status(), statusParser.parse);

  @override
  Future<Result<List<Commit>>> history({
    RepoRelativePath? path,
    int? limit,
  }) async => _parsed(
    await client.log(path: path?.value, limit: limit),
    logParser.parse,
  );

  @override
  Future<Result<List<Branch>>> branches() async =>
      _parsed(await client.branches(), branchParser.parse);

  @override
  Future<Result<String>> contentAt({
    required String revision,
    required RepoRelativePath path,
  }) async => _parsed(await client.show(revision, path.value), _itself);

  @override
  Future<Result<void>> stage(List<RepoRelativePath> paths) async =>
      _done(await client.stage(_values(paths)));

  @override
  Future<Result<void>> unstage(List<RepoRelativePath> paths) async =>
      _done(await client.unstage(_values(paths)));

  @override
  Future<Result<void>> commit(String message) async =>
      _done(await client.commit(message));

  @override
  Future<Result<void>> createBranch(BranchName name) async =>
      _done(await client.createBranch(name.value));

  @override
  Future<Result<void>> switchBranch(BranchName name) async =>
      _done(await client.switchBranch(name.value));

  @override
  Future<Result<void>> fetch() async => _done(await client.fetch());

  @override
  Future<Result<void>> pull() async => _done(await client.pull());

  @override
  Future<Result<void>> push() async => _done(await client.push());

  /// [result] with its text read by [read], or its failure translated.
  ///
  /// The parsers are total — a record they cannot read is skipped, never
  /// thrown over — so there is no third branch here: text either parses into
  /// something, possibly empty, or the command failed before producing any.
  Result<T> _parsed<T>(Result<String> result, T Function(String) read) =>
      switch (result) {
        Success<String>(value: final String text) => Success<T>(read(text)),
        Failure<String>(failure: final AppFailure failure) => Failure<T>(
          _asGitFailure(failure),
        ),
      };

  /// [result] with its failure translated, for a command that produces
  /// nothing.
  Result<void> _done(Result<void> result) => switch (result) {
    Success<void>() => const Success<void>(null),
    Failure<void>(failure: final AppFailure failure) => Failure<void>(
      _asGitFailure(failure),
    ),
  };

  /// The same text — what [contentAt] "parses".
  ///
  /// A file's content is already the thing the domain wants; naming the
  /// identity keeps [contentAt] on the same path as every other method
  /// rather than repeating the translation inline.
  static String _itself(String text) => text;

  /// [paths] as the strings the capability takes.
  static List<String> _values(List<RepoRelativePath> paths) =>
      paths.map((RepoRelativePath path) => path.value).toList();

  /// What infrastructure reported, in the product's vocabulary.
  ///
  /// Exhaustive over [GitClientFailure] with no default branch: a failure
  /// mode discovered later breaks this switch, which is the whole reason the
  /// hierarchy is sealed. Detail infrastructure carries and the product has
  /// no use for is dropped on purpose — the stderr behind an authentication
  /// failure says nothing a user can act on, and the timeout's [Duration] is
  /// a setting, not news.
  ///
  /// [GitDetachedHead] is deliberately not produced here: git does not fail
  /// on a detached `HEAD`, it commits happily. It is a state `status()`
  /// reports and a use case refuses to act on, not an error a command
  /// returns.
  static AppFailure _asGitFailure(AppFailure failure) => switch (failure) {
    final GitClientFailure clientFailure => switch (clientFailure) {
      GitClientExecutableNotFound() => const GitNotInstalled(),
      GitClientNotARepository(path: final String path) => GitNotARepository(
        path,
      ),
      GitClientMergeConflict(conflictedPaths: final List<String> paths) =>
        GitMergeConflict(paths),
      GitClientAuthenticationFailed() => const GitAuthenticationFailed(),
      GitClientPushRejected() => const GitPushRejected(),
      GitClientTimedOut(command: final String command) => GitTimedOut(command),
      GitClientCommandFailed(
        command: final String command,
        stderr: final String stderr,
      ) =>
        GitCommandFailed(command, stderr),
    },
    // Unreachable by the capability's contract: `GitClient` returns nothing
    // else. Passed through rather than dressed up as a git failure it is
    // not — inventing a `GitCommandFailed` here would put a command in the
    // UI's "details" that was never run.
    _ => failure,
  };
}
