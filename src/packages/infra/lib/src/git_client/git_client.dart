/// Driving git against one repository, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/git_client/git_client_failure.dart';

/// Runs git operations and returns what the command printed.
///
/// The capability contract for version control ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// One implementation today, `dart_io/`; a `libgit2/` sibling arrives when a
/// platform has no binary to drive, and this contract does not change.
///
/// **Text crosses this contract, never an entity.** `GitStatus`, `Commit` and
/// `Branch` are domain types and the parsers that build them live in
/// `tom_data`: this package knows how to run git, not what git said. So every
/// method below states the exact format it returns — flags, separators, field
/// order — because a caller cannot parse what it was not promised, and a
/// second implementation owes the same format.
///
/// An instance belongs to one space and serializes its own commands
/// (`flows.md#one-serialized-queue-per-space`).
abstract interface class GitClient {
  /// Separates the fields of one record, ASCII `0x1F`.
  static const String unitSeparator = '\u001F';

  /// Separates records, ASCII `0x1E`.
  static const String recordSeparator = '\u001E';

  /// The absolute path of the repository enclosing this client's folder.
  ///
  /// A space is a folder, not a repository — what the user opened is often
  /// `docs/` inside a code repository. Fails with [GitClientNotARepository]
  /// when nothing encloses it, which Home shows as a named failure: TOM
  /// never creates a repository on the user's behalf and never falls back to
  /// a quieter mode (`docs/product/home/doc.md`).
  Future<Result<String>> repositoryRoot();

  /// What differs from `HEAD`, and where the branch stands against its
  /// remote.
  ///
  /// Returns `git status --porcelain=v2 --branch --untracked-files=all -z`
  /// verbatim: NUL-terminated entries, `# branch.*` headers first. The `-z`
  /// is what makes paths parseable — without it git quotes anything unusual.
  Future<Result<String>> status();

  /// The commits that touched [path], most recent first — or, with [path]
  /// null, the commits on the current branch.
  ///
  /// One record per commit, [recordSeparator]-terminated, six
  /// [unitSeparator]-separated fields: sha, author name, author email,
  /// author date in strict ISO 8601, subject, body. The body is last because
  /// it is the only field that may contain newlines.
  Future<Result<String>> log({String? path, int? limit});

  /// Every local branch.
  ///
  /// One record per branch, [recordSeparator]-terminated, three
  /// [unitSeparator]-separated fields: short name, `*` for the branch `HEAD`
  /// points at and a space for the rest, short upstream name or empty.
  Future<Result<String>> branches();

  /// The content of [path], relative to the repository root, as of
  /// [revision] — a sha, `HEAD`, a branch name, anything git resolves.
  Future<Result<String>> show(String revision, String path);

  /// Adds [paths] to the index, deletions included.
  ///
  /// Whole files: staging is everything at once or one file at a time, never
  /// a hunk (`product/git-workflow/commit/doc.md`).
  Future<Result<void>> stage(List<String> paths);

  /// Removes [paths] from the index, leaving the working tree alone.
  Future<Result<void>> unstage(List<String> paths);

  /// Records what is staged, with [message].
  ///
  /// Fails with [GitClientCommandFailed] when nothing is staged: the product
  /// disables the action, so an empty index reaching git is a bug rather
  /// than a state to model.
  Future<Result<void>> commit(String message);

  /// Starts a branch named [name] at the current `HEAD` and switches to it.
  Future<Result<void>> createBranch(String name);

  /// Switches to the existing branch [name].
  ///
  /// Git refuses when the switch would discard uncommitted work, and that
  /// arrives as [GitClientCommandFailed]. The product asks first; this is
  /// the backstop, not the check.
  Future<Result<void>> switchBranch(String name);

  /// Updates the remote-tracking refs, touching no file on disk.
  Future<Result<void>> fetch();

  /// Fetches and integrates the upstream branch into the current one.
  ///
  /// Fails with [GitClientMergeConflict], carrying the conflicted paths, and
  /// leaves the repository mid-merge exactly as the command left it.
  Future<Result<void>> pull();

  /// Publishes the current branch to its upstream.
  ///
  /// Fails with [GitClientPushRejected] when the remote moved first, and
  /// [GitClientAuthenticationFailed] when the user's own git could not
  /// authenticate — TOM implements no authentication of its own.
  Future<Result<void>> push();
}
