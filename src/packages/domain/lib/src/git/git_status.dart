/// Where the repository stands right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name.dart';
import 'package:tom_domain/src/git/status_entry.dart';

part 'git_status.freezed.dart';

/// The branch, its distance from the remote, and everything that differs.
///
/// A reading, not a subscription: it is stale the moment an editor saves,
/// and keeping it current is the watcher's job ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
@freezed
abstract class GitStatus with _$GitStatus {
  /// Creates a status.
  const factory GitStatus({
    /// The branch `HEAD` points at, or null when `HEAD` is detached.
    required BranchName? branch,

    /// The branch it tracks, or null when it tracks nothing.
    required BranchName? upstream,

    /// Commits this branch has that [upstream] does not.
    required int ahead,

    /// Commits [upstream] has that this branch does not.
    required int behind,

    /// Every path that differs, in the order git reported it.
    required List<StatusEntry> entries,
  }) = _GitStatus;

  const GitStatus._();

  /// Whether `HEAD` points at a commit rather than a branch.
  ///
  /// Committing from here is legal in git and almost never what a
  /// documentation author meant, so the product surfaces it rather than
  /// quietly allowing it.
  bool get isDetached => branch == null;

  /// Whether nothing differs from the last commit.
  bool get isClean => entries.isEmpty;

  /// Whether anything is staged and a commit would therefore record
  /// something.
  bool get hasStagedChanges =>
      entries.any((StatusEntry entry) => entry.isStaged);
}
