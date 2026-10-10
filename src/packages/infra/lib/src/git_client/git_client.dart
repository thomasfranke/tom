/// Driving git against one repository, behind a contract.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/git_client/git_client_failure.dart';

/// Runs git operations and returns what the command printed.
///
/// The version-control capability ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// **Text crosses this contract, never an entity** — the parsers live in
/// `tom_data`, so every method states the exact format it returns and a
/// second implementation owes the same one. **Every path is relative to the
/// repository root, in both directions**, because the folder git runs inside
/// is usually not that root. An instance belongs to one space and serializes
/// its own commands (`docs/technical/runtime/git.md`).
abstract interface class GitClient {
  /// Separates the fields of one record, ASCII `0x1F`.
  static const String unitSeparator = '\u001F';

  /// Separates records, ASCII `0x1E`.
  static const String recordSeparator = '\u001E';

  /// Terminates every entry of the `-z` form [status] returns, ASCII `0x00`.
  static const String nulSeparator = '\u0000';

  /// The absolute path of the repository enclosing this client's folder.
  ///
  /// Fails with [GitClientNotARepository] when nothing encloses it; TOM never
  /// creates a repository on the user's behalf
  /// (`docs/product/home/opening-a-space/doc.md`).
  Future<Result<String, GitClientFailure>> repositoryRoot();

  /// Clones [url] into this client's own folder, which must not exist yet or
  /// be empty, handing each line git reports to [onProgress].
  ///
  /// On the client of the folder it creates, because a client is already
  /// "git for one folder" and the clone is what makes that folder a
  /// repository; the same client then serves it. [onProgress] gets
  /// `--progress` output split at `\r` as well as `\n`, verbatim.
  /// [GitClientRemoteNotFound], [GitClientDestinationTaken], and the
  /// authentication and network failures the other remote commands share.
  Future<Result<void, GitClientFailure>> clone(
    String url, {
    void Function(String line)? onProgress,
  });

  /// What differs from `HEAD`, and where the branch stands against its
  /// remote.
  ///
  /// `git status --porcelain=v2 --branch --untracked-files=all -z` verbatim:
  /// entries terminated by [nulSeparator], `# branch.*` headers first, paths
  /// relative to the repository root. `-z` is what keeps a rename's two paths
  /// unquoted and separable.
  Future<Result<String, GitClientFailure>> status();

  /// The commits that touched [path], most recent first, or with [path] null
  /// the commits on the current branch.
  ///
  /// One record per commit, [recordSeparator]-terminated, six
  /// [unitSeparator]-separated fields: sha, author name, author email, author
  /// date in strict ISO 8601, subject, body — body last because it alone may
  /// hold newlines. A branch with no commits yet returns nothing, not a
  /// failure. With [since], only the commits `HEAD` has and [since] has not
  /// — `since..HEAD`, what a pull request would propose.
  Future<Result<String, GitClientFailure>> log({
    String? path,
    int? limit,
    String? since,
  });

  /// What changed between where `HEAD` left [base] and `HEAD`, in lines.
  ///
  /// `diff --numstat -z --no-renames base...HEAD` verbatim: one entry per
  /// path, [nulSeparator]-terminated, `added\tremoved\tpath`, with `-` for
  /// both counts on a binary file. Three dots, so what [base] gained since
  /// is not counted against the branch.
  Future<Result<String, GitClientFailure>> diffNumstat(String base);

  /// What happened to each path between where `HEAD` left [base] and
  /// `HEAD`.
  ///
  /// `diff --name-status -z --no-renames base...HEAD` verbatim: a letter and
  /// a path per entry, each [nulSeparator]-terminated.
  Future<Result<String, GitClientFailure>> diffNameStatus(String base);

  /// The commit where `HEAD` left [revision] — `merge-base`, the full sha —
  /// or empty when the two share no history.
  Future<Result<String, GitClientFailure>> mergeBase(String revision);

  /// Whether [revision] names a commit here — `rev-parse --verify`, with no
  /// answer read as no rather than as a failure.
  Future<Result<bool, GitClientFailure>> resolves(String revision);

  /// The address `origin` is fetched from, or empty when there is no
  /// `origin` — a state, not a failure.
  Future<Result<String, GitClientFailure>> remoteUrl();

  /// The branch `origin` calls its own `HEAD`, without the remote's name,
  /// or empty when nothing says.
  ///
  /// `refs/remotes/origin/HEAD` first; a clone made before it existed has
  /// none, so `main` and then `master` are asked for by name.
  Future<Result<String, GitClientFailure>> defaultBranch();

  /// The branch `HEAD` points at, short, or empty when `HEAD` is detached.
  ///
  /// `symbolic-ref`, which reads one file: cheap enough to ask for every row
  /// of a list, and it names an unborn branch where `rev-parse` fails.
  Future<Result<String, GitClientFailure>> currentBranch();

  /// Every local branch.
  ///
  /// One record per branch, [recordSeparator]-terminated, three
  /// [unitSeparator]-separated fields: short name, `*` for the branch `HEAD`
  /// points at and a space for the rest, short upstream name or empty.
  Future<Result<String, GitClientFailure>> branches();

  /// Every local and remote-tracking branch, and how far each stands from
  /// `HEAD`; empty on a branch with no commits yet.
  ///
  /// One record per ref, [recordSeparator]-terminated, three
  /// [unitSeparator]-separated fields: the full ref name, the ref it points
  /// at when it is symbolic (`origin/HEAD`) or empty, and `for-each-ref`'s
  /// `%(ahead-behind:HEAD)` verbatim — one walk for every ref, which needs
  /// git 2.41; an older git fails the command.
  Future<Result<String, GitClientFailure>> branchStandings();

  /// How many commits `HEAD` has, 0 on a branch with no commits yet.
  Future<Result<int, GitClientFailure>> commitCount();

  /// The branch TOM recorded [branch] as started from, or empty when nothing
  /// was — a key of the repository's own config, so deleting or renaming the
  /// branch takes it along.
  Future<Result<String, GitClientFailure>> branchBase(String branch);

  /// Records [base] as the branch [branch] was started from.
  Future<Result<void, GitClientFailure>> recordBranchBase(
    String branch,
    String base,
  );

  /// Who a commit here is made as: `user.name` and `user.email` as git
  /// resolves them for this repository, [unitSeparator]-separated, either
  /// empty when nothing sets it.
  Future<Result<String, GitClientFailure>> identity();

  /// The GitHub login TOM was told to use in this repository, or empty when
  /// nobody chose — a key of the repository's own config, `tom.githubAccount`.
  Future<Result<String, GitClientFailure>> githubAccount();

  /// Records [login] as the GitHub account this repository is used with.
  Future<Result<void, GitClientFailure>> recordGithubAccount(String login);

  /// The content of [path] as of [revision] — a sha, `HEAD`, a branch name,
  /// anything git resolves.
  Future<Result<String, GitClientFailure>> show(String revision, String path);

  /// [path] as of [revision], byte for byte.
  ///
  /// Apart from [show], which decodes leniently: whether a file is text can
  /// only be told from what was not yet decoded.
  Future<Result<Uint8List, GitClientFailure>> showBytes(
    String revision,
    String path,
  );

  /// [path] as the index holds it, byte for byte — `show :<path>`, the last
  /// version git knows of a file that was staged and never committed.
  ///
  /// [GitClientPathNotInRevision], with an empty revision, when the index
  /// does not hold it.
  Future<Result<Uint8List, GitClientFailure>> showStagedBytes(String path);

  /// Adds [paths] to the index, deletions included.
  ///
  /// Whole files only, never a hunk
  /// (`product/git-workflow/commit/the-changes-list/doc.md`).
  Future<Result<void, GitClientFailure>> stage(List<String> paths);

  /// Removes [paths] from the index, leaving the working tree alone.
  Future<Result<void, GitClientFailure>> unstage(List<String> paths);

  /// Puts every tracked file back as `HEAD` has it, staged or not, in the
  /// whole repository (`docs/product/git-workflow/git-menu/doc.md`).
  ///
  /// **Nothing git never committed is lost**: an untracked file is not
  /// touched, and an added one is only taken out of the index, which leaves
  /// it untracked with its content. Fails before the first commit, where
  /// there is no `HEAD` to go back to.
  Future<Result<void, GitClientFailure>> discardAll();

  /// Puts [paths] in the working tree back as the index has them; what is
  /// staged stays (`product/git-workflow/commit/the-changes-list/doc.md`).
  Future<Result<void, GitClientFailure>> discardUnstaged(List<String> paths);

  /// Puts [paths] back as `HEAD` has them, in the index and the working tree
  /// both — a path `HEAD` does not have, a rename's new name, goes.
  ///
  /// Fails before the first commit, where there is no `HEAD` to go back to.
  Future<Result<void, GitClientFailure>> discardSinceCommit(List<String> paths);

  /// Deletes [paths], which git never committed: out of the index when they
  /// are staged, then off the disk.
  Future<Result<void, GitClientFailure>> deleteUncommitted(List<String> paths);

  /// Records what is staged, with [message].
  ///
  /// Fails with [GitClientCommandFailed] when nothing is staged: the product
  /// disables the action, so an empty index reaching git is a bug.
  Future<Result<void, GitClientFailure>> commit(String message);

  /// Starts a branch named [name] at the current `HEAD` and switches to it.
  Future<Result<void, GitClientFailure>> createBranch(String name);

  /// Switches to the existing branch [name].
  ///
  /// Git refuses when the switch would discard uncommitted work, and that
  /// arrives as [GitClientCommandFailed] — the backstop, not the check.
  Future<Result<void, GitClientFailure>> switchBranch(String name);

  /// Updates the remote-tracking refs, touching no file on disk.
  Future<Result<void, GitClientFailure>> fetch();

  /// Fetches and integrates the upstream branch into the current one.
  ///
  /// Fails with [GitClientMergeConflict], carrying the conflicted paths, and
  /// leaves the repository mid-merge exactly as the command left it.
  Future<Result<void, GitClientFailure>> pull();

  /// The full sha `HEAD` names, or empty on a branch with no commits yet.
  Future<Result<String, GitClientFailure>> head();

  /// How many commits the current branch's upstream has that [since] does
  /// not — `rev-list --count since..@{upstream}`, or every upstream commit
  /// when [since] is empty.
  ///
  /// [GitClientCommandFailed] when the branch has no upstream.
  Future<Result<int, GitClientFailure>> upstreamCommitsSince(String since);

  /// Publishes the current branch to its upstream.
  ///
  /// Fails with [GitClientPushRejected] when the remote moved first, and
  /// [GitClientAuthenticationFailed] when the user's own git could not
  /// authenticate — TOM implements no authentication of its own.
  Future<Result<void, GitClientFailure>> push();

  /// Publishes [branch] to `origin` for the first time and makes it the
  /// branch's upstream — `push --set-upstream origin branch`.
  ///
  /// A method of its own rather than a flag on [push], because the two
  /// differ in what they change: this one writes the branch's config.
  Future<Result<void, GitClientFailure>> publish(String branch);

  /// The absolute path of the repository's git directory **shared by every
  /// worktree** — `rev-parse --git-common-dir`, made absolute.
  ///
  /// `<root>/.git` is only the common case: in a worktree or a submodule
  /// `.git` is a file pointing elsewhere. Shared rather than per worktree,
  /// because what TOM keeps there is keyed by branch and a branch follows
  /// whichever worktree checks it out.
  Future<Result<String, GitClientFailure>> gitDirectory();

  /// Whether the repository is sitting mid-merge, as `MERGE_HEAD` says.
  ///
  /// Asked of git rather than remembered, so the state survives the window
  /// being closed: a conflict is the repository's, not the session's
  /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
  Future<Result<bool, GitClientFailure>> mergeInProgress();

  /// The message git prepared for the merge in progress, or empty when there
  /// is none.
  ///
  /// `MERGE_MSG` is git's own draft — the one a terminal would open an editor
  /// on — so concluding the merge starts from what git already wrote rather
  /// than from a blank box.
  Future<Result<String, GitClientFailure>> mergeMessage();

  /// Undoes the merge in progress, putting the working tree back.
  ///
  /// `GitClientCommandFailed` when there is no merge to abort; the caller
  /// asks [mergeInProgress] first rather than reading that as a state.
  Future<Result<void, GitClientFailure>> abortMerge();
}
