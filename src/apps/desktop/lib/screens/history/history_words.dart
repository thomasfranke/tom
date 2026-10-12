/// How a commit is named and dated on screen.
library;

import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_domain/tom_domain.dart';

/// [date] as a person would say it in [l10n]'s language — `3 days ago`,
/// `just now`.
///
/// Relative, because "how old is this" is the question history answers;
/// measured on [CommitDateValueObject.utc], never on the author's wall
/// clock. [now] is a parameter so this can be tested.
String whenInWords(
  AppLocalizations l10n,
  CommitDateValueObject date, {
  DateTime? now,
}) {
  final Duration ago = (now ?? DateTime.now().toUtc()).difference(date.utc);
  // A machine clock behind the author's must not read "in -1 minutes".
  if (ago.inMinutes < 1) {
    return l10n.whenJustNow;
  }
  if (ago.inHours < 1) {
    return l10n.whenMinutesAgo(ago.inMinutes);
  }
  if (ago.inDays < 1) {
    return l10n.whenHoursAgo(ago.inHours);
  }
  if (ago.inDays < 31) {
    return l10n.whenDaysAgo(ago.inDays);
  }
  if (ago.inDays < 365) {
    return l10n.whenMonthsAgo(ago.inDays ~/ 30);
  }
  return l10n.whenYearsAgo(ago.inDays ~/ 365);
}
