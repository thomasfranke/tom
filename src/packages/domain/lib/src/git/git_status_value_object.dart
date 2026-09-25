/// Where the repository stands right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/git/status_entry_value_object.dart';

part 'git_status_value_object.freezed.dart';

/// The branch, its distance from the remote, and everything that differs.
///
/// A reading, not a subscription: it is stale the moment an editor saves,
/// and keeping it current is the watcher's job ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
@freezed
abstract class GitStatusValueObject with _$GitStatusValueObject {
  /// A status.
  ///
  /// [branch] may be null while [isDetached] is false: a branch whose name
  /// the parser could not read is not a detached `HEAD` and must not be shown
  /// as one. The reverse is asserted.
  @Assert('!isDetached || branch == null')
  const factory GitStatusValueObject({
    /// The branch `HEAD` points at; null when detached, and also when the
    /// name could not be parsed, which [isDetached] tells apart.
    required BranchNameValueObject? branch,

    /// The branch it tracks, or null when it tracks nothing.
    required BranchNameValueObject? upstream,

    /// Commits this branch has that [upstream] does not.
    required int ahead,

    /// Commits [upstream] has that this branch does not.
    required int behind,

    /// Every path that differs, in the order git reported it.
    ///
    /// Handed over, not copied: Freezed compares element-wise but copies
    /// nothing, so a caller keeping its own reference could change this
    /// status and its `hashCode` under a set or a rebuild. Every producer
    /// passes a list nothing else holds (`GitStatusParser` an unmodifiable
    /// one); making that structural needs an immutable-collection package,
    /// a dependency decision not this file's to take.
    required List<StatusEntryValueObject> entries,

    /// Whether `HEAD` points at a commit rather than a branch.
    required bool isDetached,
  }) = _GitStatusValueObject;

  const GitStatusValueObject._();

  /// Whether nothing differs from the last commit.
  bool get isClean => entries.isEmpty;

  /// Whether a commit would record something.
  bool get hasStagedChanges =>
      entries.any((StatusEntryValueObject entry) => entry.isStaged);
}
