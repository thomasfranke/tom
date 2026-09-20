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
  ///
  /// [branch] may be null while [isDetached] is false: that is a repository
  /// on a branch whose name the parser could not read, which is a different
  /// state from a detached `HEAD` and must not be shown as one. The reverse
  /// is impossible and asserted.
  @Assert('!isDetached || branch == null')
  const factory GitStatus({
    /// The branch `HEAD` points at.
    ///
    /// Null when `HEAD` is detached, and also when git named a branch this
    /// version cannot parse — [isDetached] is what tells the two apart.
    required BranchName? branch,

    /// The branch it tracks, or null when it tracks nothing.
    required BranchName? upstream,

    /// Commits this branch has that [upstream] does not.
    required int ahead,

    /// Commits [upstream] has that this branch does not.
    required int behind,

    /// Every path that differs, in the order git reported it.
    ///
    /// Handed over, not copied: Freezed generates element-wise equality but
    /// does not copy the collection, so a caller that kept its own reference
    /// could change what this status says — and change its `hashCode` while
    /// it sits in a set or drives a rebuild. Every producer therefore passes
    /// a list nothing else holds; `GitStatusParser` passes an unmodifiable
    /// one. Making that structural needs an immutable-collection package,
    /// which is a dependency decision and not this file's to take.
    required List<StatusEntry> entries,

    /// Whether `HEAD` points at a commit rather than a branch.
    required bool isDetached,
  }) = _GitStatus;

  const GitStatus._();

  /// Whether nothing differs from the last commit.
  bool get isClean => entries.isEmpty;

  /// Whether anything is staged and a commit would therefore record
  /// something.
  bool get hasStagedChanges =>
      entries.any((StatusEntry entry) => entry.isStaged);
}
