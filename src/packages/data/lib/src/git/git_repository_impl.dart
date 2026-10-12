/// The domain's git contract, fulfilled by running the system binary.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/git/git_branch_parser.dart';
import 'package:tom_data/src/git/git_data_source.dart';
import 'package:tom_data/src/git/git_diff_parser.dart';
import 'package:tom_data/src/git/git_log_parser.dart';
import 'package:tom_data/src/git/git_standing_parser.dart';
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
    this.diffParser = const GitDiffParser(),
    this.standingParser = const GitStandingParser(),
  });

  /// Where git's answers come from.
  final GitDataSource git;

  /// Reads `status --porcelain=v2 -z`.
  final GitStatusParser statusParser;

  /// Reads the `log` records.
  final GitLogParser logParser;

  /// Reads the `branch` records.
  final GitBranchParser branchParser;

  /// Reads the two diffs a branch's changes come from.
  final GitDiffParser diffParser;

  /// Reads where each branch stands against `HEAD`.
  final GitStandingParser standingParser;

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
  Future<Result<List<CommitEntity>, GitFailure>> commitsSince(
    BranchNameValueObject base,
  ) async {
    final Result<String, GitFailure> revision = await _baseRevision(base);
    if (revision case Failure<String, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<List<CommitEntity>, GitFailure>(failure);
    }
    return git
        .log(since: (revision as Success<String, GitFailure>).value)
        .map(logParser.parse)
        .mapFailure(_asGitFailure);
  }

  @override
  Future<Result<List<BranchChangeValueObject>, GitFailure>> changesSince(
    BranchNameValueObject base,
  ) async {
    final Result<String, GitFailure> revision = await _baseRevision(base);
    if (revision case Failure<String, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<List<BranchChangeValueObject>, GitFailure>(failure);
    }
    final String since = (revision as Success<String, GitFailure>).value;
    final Result<String, GitClientFailure> nameStatus = await git
        .diffNameStatus(since);
    if (nameStatus case Failure<String, GitClientFailure>(
      failure: final GitClientFailure failure,
    )) {
      return Failure<List<BranchChangeValueObject>, GitFailure>(
        _asGitFailure(failure),
      );
    }
    return git
        .diffNumstat(since)
        .map(
          (String numstat) => diffParser.parse(
            nameStatus: (nameStatus as Success<String, GitClientFailure>).value,
            numstat: numstat,
          ),
        )
        .mapFailure(_asGitFailure);
  }

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async {
    final Result<String, GitFailure> revision = await _baseRevision(base);
    if (revision case Failure<String, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<CommitShaValueObject?, GitFailure>(failure);
    }
    return git
        .mergeBase((revision as Success<String, GitFailure>).value)
        .map(CommitShaValueObject.tryParse)
        .mapFailure(_asGitFailure);
  }

  @override
  Future<Result<String?, GitFailure>> remoteAddress() => git
      .remoteUrl()
      .map((String address) => address.isEmpty ? null : address)
      .mapFailure(_asGitFailure);

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch() => git
      .defaultBranch()
      .map(BranchNameValueObject.tryParse)
      .mapFailure(_asGitFailure);

  /// What [base] is read as: `origin`'s copy when there is one, because the
  /// host compares against that and a stale local branch would propose
  /// commits it already has.
  Future<Result<String, GitFailure>> _baseRevision(
    BranchNameValueObject base,
  ) async {
    final String remote = 'origin/${base.value}';
    return git
        .resolves(remote)
        .map((bool found) => found ? remote : base.value)
        .mapFailure(_asGitFailure);
  }

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() =>
      git.branches().map(branchParser.parse).mapFailure(_asGitFailure);

  @override
  Future<Result<List<BranchStandingValueObject>, GitFailure>>
  standings() async {
    final Result<int, GitClientFailure> count = await git.commitCount();
    if (count case Failure<int, GitClientFailure>(
      failure: final GitClientFailure failure,
    )) {
      return Failure<List<BranchStandingValueObject>, GitFailure>(
        _asGitFailure(failure),
      );
    }
    final int headCommits = (count as Success<int, GitClientFailure>).value;
    return git
        .branchStandings()
        .map(
          (String text) => standingParser.parse(text, headCommits: headCommits),
        )
        .mapFailure(_asGitFailure);
  }

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> recordedBase(
    BranchNameValueObject branch,
  ) => git
      .branchBase(branch.value)
      .map(BranchNameValueObject.tryParse)
      .mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> recordBase(
    BranchNameValueObject branch,
    BranchNameValueObject base,
  ) => git.recordBranchBase(branch.value, base.value).mapFailure(_asGitFailure);

  @override
  Future<Result<CommitIdentityValueObject, GitFailure>> commitIdentity() => git
      .identity()
      .map((String text) {
        final List<String> halves = text.split(GitClient.unitSeparator);
        String? given(int at) =>
            at < halves.length && halves[at].trim().isNotEmpty
            ? halves[at].trim()
            : null;
        return CommitIdentityValueObject(name: given(0), email: given(1));
      })
      .mapFailure(_asGitFailure);

  @override
  Future<Result<String?, GitFailure>> chosenAccount() => git
      .githubAccount()
      .map((String login) => login.isEmpty ? null : login)
      .mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> chooseAccount(String login) =>
      git.recordGithubAccount(login).mapFailure(_asGitFailure);

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) => git.show(revision, path.value).mapFailure(_asGitFailure);

  @override
  Future<Result<Uint8List, GitFailure>> bytesAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) => git.showBytes(revision, path.value).mapFailure(_asGitFailure);

  @override
  Future<Result<Uint8List, GitFailure>> stagedBytes(
    RepoRelativePathValueObject path,
  ) => git.showStagedBytes(path.value).mapFailure(_asGitFailure);

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
  Future<Result<CommitShaValueObject?, GitFailure>> head() =>
      git.head().map(CommitShaValueObject.tryParse).mapFailure(_asGitFailure);

  @override
  Future<Result<int, GitFailure>> upstreamCommitsSince(
    CommitShaValueObject? since,
  ) => git.upstreamCommitsSince(since?.value ?? '').mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> push() =>
      git.push().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> publish(BranchNameValueObject branch) =>
      git.publish(branch.value).mapFailure(_asGitFailure);

  @override
  Future<Result<String, GitFailure>> gitDirectory() =>
      git.gitDirectory().mapFailure(_asGitFailure);

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async {
    final Result<bool, GitClientFailure> inProgress = await git
        .mergeInProgress();
    if (inProgress case Failure<bool, GitClientFailure>(
      failure: final GitClientFailure failure,
    )) {
      return Failure<MergeStateValueObject, GitFailure>(_asGitFailure(failure));
    }
    if (!(inProgress as Success<bool, GitClientFailure>).value) {
      return const Success<MergeStateValueObject, GitFailure>(
        MergeStateValueObject.none,
      );
    }
    // A merge with an unreadable draft is still a merge; the message is what
    // the box starts from, not what says the state exists.
    final Result<String, GitClientFailure> message = await git.mergeMessage();
    return Success<MergeStateValueObject, GitFailure>(
      MergeStateValueObject(
        inProgress: true,
        message: switch (message) {
          Success<String, GitClientFailure>(value: final String drafted) =>
            drafted.trim(),
          Failure<String, GitClientFailure>() => '',
        },
      ),
    );
  }

  @override
  Future<Result<void, GitFailure>> abortMerge() =>
      git.abortMerge().mapFailure(_asGitFailure);

  @override
  Future<Result<void, GitFailure>> discardAll() async {
    // Safe on its own: mid-merge it would end the merge and overwrite the
    // conflicted files, and before the first commit it would unstage and then
    // fail half-applied, so both are refused before git is asked to write.
    switch (await mergeState()) {
      case Failure<MergeStateValueObject, GitFailure>(
        failure: final GitFailure failure,
      ):
        return Failure<void, GitFailure>(failure);
      case Success<MergeStateValueObject, GitFailure>(
        value: MergeStateValueObject(inProgress: true),
      ):
        return const Failure<void, GitFailure>(GitMergeConflict(<String>[]));
      case Success<MergeStateValueObject, GitFailure>():
    }
    switch (await head()) {
      case Failure<CommitShaValueObject?, GitFailure>(
        failure: final GitFailure failure,
      ):
        return Failure<void, GitFailure>(failure);
      case Success<CommitShaValueObject?, GitFailure>(value: null):
        return const Failure<void, GitFailure>(GitNoCommitsYet());
      case Success<CommitShaValueObject?, GitFailure>():
    }
    return git.discardAll().mapFailure(_asGitFailure);
  }

  @override
  Future<Result<void, GitFailure>> discard(
    DiscardKindEnum kind,
    List<RepoRelativePathValueObject> paths,
  ) => switch (kind) {
    DiscardKindEnum.toStaged => git.discardUnstaged(_values(paths)),
    DiscardKindEnum.toLastCommit => git.discardSinceCommit(_values(paths)),
    DiscardKindEnum.delete => git.deleteUncommitted(_values(paths)),
  }.mapFailure(_asGitFailure);

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
        GitClientBranchProtected() => GitBranchProtected(cause: failure),
        GitClientLocalChangesOverwritten(paths: final List<String> paths) =>
          GitLocalChangesOverwritten(paths, cause: failure),
        GitClientNetworkUnavailable() => GitNetworkUnavailable(cause: failure),
        GitClientNoRemote() => GitNoRemote(cause: failure),
        GitClientRemoteNotFound() => GitRemoteNotFound(cause: failure),
        GitClientDestinationTaken(path: final String path) =>
          GitCloneDestinationTaken(path, cause: failure),
        GitClientPathNotInRevision(path: final String path) =>
          GitPathNotInRevision(path, cause: failure),
        GitClientPathCommitted(paths: final List<String> paths) =>
          GitPathCommitted(paths, cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        GitClientCommandDenied() => GitCommandDenied(cause: failure),
        GitClientCommandFailed() => GitOperationFailed(cause: failure),
      };
}
