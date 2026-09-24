/// How a commit is named and dated on screen.
library;

import 'package:tom_domain/tom_domain.dart';

/// [date] as a person would say it — `3 days ago`, `just now`.
///
/// Relative rather than a timestamp: the question history is read to answer
/// is "how old is this", and nobody subtracts dates in their head.
///
/// Measured on [CommitDateValueObject.utc] and never on the author's wall
/// clock — the offset is what a date is *displayed* in. [now] is a
/// parameter so this can be tested at all.
String whenInWords(CommitDateValueObject date, {DateTime? now}) {
  final Duration ago = (now ?? DateTime.now().toUtc()).difference(date.utc);
  // A clock that disagrees with the author's — a machine whose time is off,
  // a commit made a second ago — must not read "in -1 minutes".
  if (ago.inMinutes < 1) {
    return 'just now';
  }
  if (ago.inHours < 1) {
    return _plural(ago.inMinutes, 'minute');
  }
  if (ago.inDays < 1) {
    return _plural(ago.inHours, 'hour');
  }
  if (ago.inDays < 31) {
    return _plural(ago.inDays, 'day');
  }
  if (ago.inDays < 365) {
    return _plural(ago.inDays ~/ 30, 'month');
  }
  return _plural(ago.inDays ~/ 365, 'year');
}

/// [count] [unit]s ago, with the `s` only when it is earned.
String _plural(int count, String unit) =>
    '$count $unit${count == 1 ? '' : 's'} ago';
