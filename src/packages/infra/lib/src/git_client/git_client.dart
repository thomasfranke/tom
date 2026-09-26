/// Driving git against one repository, behind a contract.
library;

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
  /// failure.
  Future<Result<String, GitClientFailure>> log({String? path, int? limit});

  /// Every local branch.
  ///
  /// One record per branch, [recordSeparator]-terminated, three
  /// [unitSeparator]-separated fields: short name, `*` for the branch `HEAD`
  /// points at and a space for the rest, short upstream name or empty.
  Future<Result<String, GitClientFailure>> branches();

  /// The content of [path] as of [revision] — a sha, `HEAD`, a branch name,
  /// anything git resolves.
  Future<Result<String, GitClientFailure>> show(String revision, String path);

  /// Adds [paths] to the index, deletions included.
  ///
  /// Whole files only, never a hunk
  /// (`product/git-workflow/commit/the-changes-list/doc.md`).
  Future<Result<void, GitClientFailure>> stage(List<String> paths);

  /// Removes [paths] from the index, leaving the working tree alone.
  Future<Result<void, GitClientFailure>> unstage(List<String> paths);

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

  /// Publishes the current branch to its upstream.
  ///
  /// Fails with [GitClientPushRejected] when the remote moved first, and
  /// [GitClientAuthenticationFailed] when the user's own git could not
  /// authenticate — TOM implements no authentication of its own.
  Future<Result<void, GitClientFailure>> push();
}
