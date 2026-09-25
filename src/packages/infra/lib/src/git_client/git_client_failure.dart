/// What driving git can fail with, in the terms infrastructure sees.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_client_failure.freezed.dart';

/// A git operation that did not complete, as the capability sees it.
///
/// Technical vocabulary — an exit code, a stderr, a timeout; `tom_data`
/// translates it to a `GitFailure`
/// (`docs/technical/conventions/errors.md`). No `dart:io` type
/// crosses out of `git_client/dart_io/`. `sealed`, so a `switch` is exhaustive.
@freezed
sealed class GitClientFailure with _$GitClientFailure implements AppFailure {
  /// No `git` executable was found on the PATH.
  ///
  /// Nothing to fall back to until a `libgit2/` sibling of `dart_io/` exists
  /// ([Decision
  /// 2](../../../../../../docs/technical/decisions/002-git-via-system-binary.md)).
  const factory GitClientFailure.executableNotFound({AppFailure? cause}) =
      GitClientExecutableNotFound;

  /// The path the client was pointed at is inside no git repository.
  ///
  /// The search runs upwards, so nothing encloses the folder at all; TOM never
  /// runs `git init` for the user (`docs/product/home/doc.md`).
  const factory GitClientFailure.notARepository(
    /// The absolute path that was searched for an enclosing repository.
    String path, {
    AppFailure? cause,
  }) = GitClientNotARepository;

  /// A merge, pull or rebase stopped with conflicts.
  const factory GitClientFailure.mergeConflict(
    /// Paths left conflicted, relative to the repository root.
    List<String> conflictedPaths, {
    AppFailure? cause,
  }) = GitClientMergeConflict;

  /// The remote asked for credentials the user's own git could not supply.
  ///
  /// Authentication is the user's setup, so this means it did not answer,
  /// not that TOM failed to log in.
  const factory GitClientFailure.authenticationFailed(
    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr, {
    AppFailure? cause,
  }) = GitClientAuthenticationFailed;

  /// The remote refused a push because it had moved on first.
  ///
  /// Its own variant because the product shows it as its own outcome
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  const factory GitClientFailure.pushRejected(
    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr, {
    AppFailure? cause,
  }) = GitClientPushRejected;

  /// A command ran past the time it was allowed and was killed.
  ///
  /// The queue is serialized, so one hung command would stop the space.
  const factory GitClientFailure.timedOut(
    /// The command as it was run, for the "details" disclosure in the UI.
    String command,

    /// How long it was allowed to take.
    Duration timeout, {
    AppFailure? cause,
  }) = GitClientTimedOut;

  /// The revision holds no such path.
  ///
  /// An answer rather than an error for "what did this file look like
  /// before": a new or renamed document, or an unborn `HEAD`, has no earlier
  /// version.
  const factory GitClientFailure.pathNotInRevision(
    /// The revision as it was asked for — a sha, a branch, `HEAD`.
    String revision,

    /// The path, relative to the repository root.
    String path, {
    AppFailure? cause,
  }) = GitClientPathNotInRevision;

  /// A git command failed in a way the contract has no name for.
  ///
  /// The typed fallback; a variant is promoted out of it only when an adapter
  /// can recognise it *and* a translator answers differently.
  const factory GitClientFailure.commandFailed(
    /// The command as it was run, for the "details" disclosure in the UI.
    String command,

    /// The process exit code.
    int exitCode,

    /// What git wrote to stderr, verbatim. For diagnostics — never parsed.
    String stderr, {
    AppFailure? cause,
  }) = GitClientCommandFailed;
}
