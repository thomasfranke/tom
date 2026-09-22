/// When a commit was written, and where the author was when they wrote it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_date_value_object.freezed.dart';

/// The instant a commit was authored, with the UTC offset git recorded.
///
/// Two fields rather than a bare `DateTime`, because a `DateTime` cannot
/// hold the second one: `DateTime.parse` reads `2026-09-20T01:44:01-03:00`
/// and answers the instant `04:44:01Z`, discarding the `-03:00`. The offset
/// is not decoration — it is the only thing that says the author committed
/// late on Saturday night rather than early on Sunday morning, and a
/// documentation team spread across timezones reads history to find out
/// exactly that.
///
/// One concept rather than two fields on
/// [CommitEntity](commit_entity.dart): they always travel together, and an
/// offset without its instant means nothing.
///
/// A Freezed value object, not an `extension type`: it has two fields
/// ([Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md)).
@freezed
abstract class CommitDateValueObject with _$CommitDateValueObject {
  /// Creates a commit date.
  const factory CommitDateValueObject({
    /// The instant, in UTC. Comparing two commits in time uses this.
    required DateTime utc,

    /// How far the author's clock stood from UTC, as git recorded it.
    ///
    /// Zero is a real answer — the author was on UTC — not a missing one.
    required Duration offset,
  }) = _CommitDateValueObject;

  const CommitDateValueObject._();

  /// The wall clock the author saw, as a `DateTime` whose `year`, `hour` and
  /// the rest read the way their machine displayed them.
  ///
  /// A shifted instant, not a real one: it stays flagged UTC so that reading
  /// its fields does not drag in the *reader's* timezone, which means its
  /// [DateTime.millisecondsSinceEpoch] is meaningless. It exists to be
  /// formatted — a history row shows this and sorts by [utc].
  DateTime get authorLocal => utc.add(offset);
}
