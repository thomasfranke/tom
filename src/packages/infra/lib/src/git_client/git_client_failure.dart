/// What driving git can fail with, in the terms infrastructure sees.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_client_failure.freezed.dart';

/// A git operation that did not complete, as the capability sees it.
///
/// Technical, not product vocabulary: `tom_infra` depends only on `tom_core`,
/// so it cannot name a `GitFailure` — `tom_data` does that translation
/// (`docs/technical/layers.md#errors-across-boundaries`). What reaches here
/// is an exit code, a stderr and a timeout; what the product calls it is
/// somebody else's decision.
///
/// No `dart:io` type crosses out of `git_client/dart_io/`: a
/// `ProcessException` dies there and leaves as [GitClientExecutableNotFound].
///
/// `sealed`, so a `switch` over it is exhaustive.
@freezed
sealed class GitClientFailure with _$GitClientFailure implements AppFailure {
  /// No `git` executable was found on the PATH.
  ///
  /// TOM drives the system binary ([Decision
  /// 2](../../../../../../docs/technical/decisions/002-git-via-system-binary.md)),
  /// so there is nothing to fall back to until a `libgit2/` sibling of
  /// `dart_io/` exists.
  const factory GitClientFailure.executableNotFound() =
      GitClientExecutableNotFound;

  /// The path the client was pointed at is not inside a git repository.
  ///
  /// A space is a folder, not a repository, and the search runs upwards — so
  /// this means no repository encloses the folder at all. Home names it and
  /// stops there: TOM never runs `git init` for the user, and never opens
  /// the folder in a quieter mode instead (`docs/product/home/doc.md`).
  const factory GitClientFailure.notARepository(
    /// The absolute path that was searched for an enclosing repository.
    String path,
  ) = GitClientNotARepository;

  /// A merge, pull or rebase stopped with conflicts.
  const factory GitClientFailure.mergeConflict(
    /// Paths left conflicted, relative to the repository root.
    List<String> conflictedPaths,
  ) = GitClientMergeConflict;

  /// The remote asked for credentials TOM cannot supply.
  ///
  /// Authentication is the user's own git — credentials, SSH and config come
  /// from their machine — so this means their setup did not answer, not that
  /// TOM failed to log in.
  const factory GitClientFailure.authenticationFailed(
    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr,
  ) = GitClientAuthenticationFailed;

  /// The remote refused a push because it had moved on first.
  ///
  /// Named rather than folded into [GitClientCommandFailed] because the
  /// product requires it to be shown as its own outcome
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  const factory GitClientFailure.pushRejected(
    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr,
  ) = GitClientPushRejected;

  /// A command ran past the time it was allowed.
  ///
  /// The process is killed before this is returned: the queue is serialized,
  /// so one command left hanging would stop the space rather than one action.
  const factory GitClientFailure.timedOut(
    /// The command as it was run, for the "details" disclosure in the UI.
    String command,

    /// How long it was allowed to take.
    Duration timeout,
  ) = GitClientTimedOut;

  /// A git command failed in a way infrastructure has no name for.
  ///
  /// The typed fallback: unexpected, but still a [GitClientFailure] rather
  /// than an exception. A variant promoted out of here is a variant that
  /// earned a name.
  const factory GitClientFailure.commandFailed(
    /// The command as it was run, for the "details" disclosure in the UI.
    String command,

    /// The process exit code.
    int exitCode,

    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr,
  ) = GitClientCommandFailed;
}
