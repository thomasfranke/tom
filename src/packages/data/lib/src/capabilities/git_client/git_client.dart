/// Driving git against one repository, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/git_client/git_client_failure.dart';

/// Runs git operations and returns what the command printed.
///
/// The capability contract for version control ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// One implementation today, `dart_io/`; a `libgit2/` sibling arrives when a
/// platform has no binary to drive, and this contract does not change.
///
/// **Text crosses this contract, never an entity.**
/// `GitStatusValueObject`, `CommitEntity` and `BranchEntity` are domain
/// types and the parsers that build them live in
/// `tom_data`: this package knows how to run git, not what git said. So every
/// method below states the exact format it returns — flags, separators, field
/// order — because a caller cannot parse what it was not promised, and a
/// second implementation owes the same format.
///
/// **Every path crossing this contract is relative to the repository root**,
/// in both directions — what [status] reports and what [stage], [unstage],
/// [log] and [show] are given. A space is a folder, not a repository, so the
/// folder an implementation runs git inside is usually *not* that root, and a
/// path is only meaningful here if both sides measure it from the same place.
///
/// An instance belongs to one space and serializes its own commands
/// (`flows.md#one-serialized-queue-per-space`).
abstract interface class GitClient {
  /// Separates the fields of one record, ASCII `0x1F`.
  static const String unitSeparator = '\u001F';

  /// Separates records, ASCII `0x1E`.
  static const String recordSeparator = '\u001E';

  /// Terminates every entry of the `-z` form [status] returns, ASCII `0x00`.
  ///
  /// Named here rather than spelled again in the parser for the same reason
  /// as the two above: the format is this contract's promise, and a second
  /// copy of it drifts the day someone changes one.
  static const String nulSeparator = '\u0000';

  /// The absolute path of the repository enclosing this client's folder.
  ///
  /// A space is a folder, not a repository — what the user opened is often
  /// `docs/` inside a code repository. Fails with [GitClientNotARepository]
  /// when nothing encloses it, which Home shows as a named failure: TOM
  /// never creates a repository on the user's behalf and never falls back to
  /// a quieter mode (`docs/product/home/doc.md`).
  Future<Result<String, GitClientFailure>> repositoryRoot();

  /// What differs from `HEAD`, and where the branch stands against its
  /// remote.
  ///
  /// Returns `git status --porcelain=v2 --branch --untracked-files=all -z`
  /// verbatim: entries terminated by [nulSeparator], `# branch.*` headers
  /// first, every path relative to the repository root. The `-z` is what
  /// makes paths parseable — without it git quotes anything unusual, and a
  /// rename's two paths arrive as two entries rather than one line split on a
  /// tab.
  Future<Result<String, GitClientFailure>> status();

  /// The commits that touched [path] — relative to the repository root, as
  /// [status] reports it — most recent first, or with [path] null the commits
  /// on the current branch.
  ///
  /// A branch with no commits yet returns nothing, not a failure: a space
  /// opened on a freshly initialised repository has an empty history, which
  /// is a state and not an error.
  ///
  /// One record per commit, [recordSeparator]-terminated, six
  /// [unitSeparator]-separated fields: sha, author name, author email,
  /// author date in strict ISO 8601, subject, body. The body is last because
  /// it is the only field that may contain newlines.
  Future<Result<String, GitClientFailure>> log({String? path, int? limit});

  /// Every local branch.
  ///
  /// One record per branch, [recordSeparator]-terminated, three
  /// [unitSeparator]-separated fields: short name, `*` for the branch `HEAD`
  /// points at and a space for the rest, short upstream name or empty.
  Future<Result<String, GitClientFailure>> branches();

  /// The content of [path], relative to the repository root, as of
  /// [revision] — a sha, `HEAD`, a branch name, anything git resolves.
  Future<Result<String, GitClientFailure>> show(String revision, String path);

  /// Adds [paths] — relative to the repository root, as [status] reports
  /// them — to the index, deletions included.
  ///
  /// Whole files: staging is everything at once or one file at a time, never
  /// a hunk (`product/git-workflow/commit/doc.md`).
  Future<Result<void, GitClientFailure>> stage(List<String> paths);

  /// Removes [paths] from the index, leaving the working tree alone.
  ///
  /// Relative to the repository root, like everywhere else on this
  /// contract.
  Future<Result<void, GitClientFailure>> unstage(List<String> paths);

  /// Records what is staged, with [message].
  ///
  /// Fails with [GitClientCommandFailed] when nothing is staged: the product
  /// disables the action, so an empty index reaching git is a bug rather
  /// than a state to model.
  Future<Result<void, GitClientFailure>> commit(String message);

  /// Starts a branch named [name] at the current `HEAD` and switches to it.
  Future<Result<void, GitClientFailure>> createBranch(String name);

  /// Switches to the existing branch [name].
  ///
  /// Git refuses when the switch would discard uncommitted work, and that
  /// arrives as [GitClientCommandFailed]. The product asks first; this is
  /// the backstop, not the check.
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
