/// What a branch did, in numbers.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_kind_enum.dart';
import 'package:tom_domain/src/git/branch_change_value_object.dart';
import 'package:tom_domain/src/git/commit_date_value_object.dart';

part 'branch_overview_value_object.freezed.dart';

/// The `Overview` segment's reading
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
///
/// Half of it is git's — documents, commits, folders, lines — and half only
/// this tool can give: words, blocks by kind and the time it takes to read,
/// which are measured in what prose is made of rather than in lines.
@freezed
abstract class BranchOverviewValueObject with _$BranchOverviewValueObject {
  /// An overview.
  const factory BranchOverviewValueObject({
    /// How many commits the branch has over its base.
    required int commits,

    /// Documents the branch added.
    required int added,

    /// Documents it changed.
    required int modified,

    /// Documents it deleted.
    required int deleted,

    /// Words the new text has that the old did not.
    required int wordsAdded,

    /// Words the old text had that the new does not.
    required int wordsRemoved,

    /// How many blocks of each kind changed, most first.
    required Map<BlockKindEnum, int> blocks,

    /// How many changed documents each folder holds, most first; the root
    /// is the empty string.
    required Map<String, int> folders,

    /// Minutes a reviewer needs for the words above, at least one when any
    /// word changed.
    required int readingMinutes,

    /// When the oldest commit was written, or null with none.
    CommitDateValueObject? firstCommit,

    /// The document with the most lines added and removed, or null when
    /// nothing has a count.
    BranchChangeValueObject? mostChanged,
  }) = _BranchOverviewValueObject;
}
