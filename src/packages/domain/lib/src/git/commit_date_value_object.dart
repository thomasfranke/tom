/// When a commit was written, and where the author was when they wrote it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_date_value_object.freezed.dart';

/// The instant a commit was authored, with the UTC offset git recorded.
///
/// Two fields rather than a `DateTime`, because `DateTime.parse` reads
/// `2026-09-20T01:44:01-03:00` and discards the `-03:00`, and the offset is
/// what says the author committed late on Saturday rather than early on
/// Sunday.
@freezed
abstract class CommitDateValueObject with _$CommitDateValueObject {
  /// A commit date.
  const factory CommitDateValueObject({
    /// The instant, in UTC; what two commits are ordered by.
    required DateTime utc,

    /// How far the author's clock stood from UTC, as git recorded it.
    ///
    /// Zero is a real answer, the author was on UTC, not a missing one.
    required Duration offset,
  }) = _CommitDateValueObject;

  const CommitDateValueObject._();

  /// The wall clock the author saw, for formatting only.
  ///
  /// A shifted instant still flagged UTC, so reading its fields does not drag
  /// in the reader's timezone; its `millisecondsSinceEpoch` is meaningless.
  DateTime get authorLocal => utc.add(offset);
}
