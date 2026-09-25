/// How a commit is named and dated on screen.
library;

import 'package:tom_domain/tom_domain.dart';

/// [date] as a person would say it — `3 days ago`, `just now`.
///
/// Relative, because "how old is this" is the question history answers;
/// measured on [CommitDateValueObject.utc], never on the author's wall
/// clock. [now] is a parameter so this can be tested.
String whenInWords(CommitDateValueObject date, {DateTime? now}) {
  final Duration ago = (now ?? DateTime.now().toUtc()).difference(date.utc);
  // A machine clock behind the author's must not read "in -1 minutes".
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

/// `<count> <unit>s ago`, singular at one.
String _plural(int count, String unit) =>
    '$count $unit${count == 1 ? '' : 's'} ago';
