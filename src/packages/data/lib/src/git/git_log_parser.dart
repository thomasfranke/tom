/// Turning the log format `GitClient` asks for into [CommitEntity]s.
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// Reads what `GitClient.log` returned.
///
/// The separators come from [GitClient] rather than being spelled again
/// here: the format is that contract's promise, and two copies of it drift
/// the day someone changes one.
///
/// **Total, and deliberately so.** A record whose sha or date it cannot read
/// is skipped — a history panel missing one entry is a smaller failure than
/// a history panel that will not open.
final class GitLogParser {
  /// Creates a parser.
  ///
  /// Stateless, so one instance serves the whole app
  /// (`docs/technical/flows.md#wiring-three-lifetimes`).
  const GitLogParser();

  /// How many fields `GitClient.log` promises per commit.
  static const int _fieldCount = 6;

  /// Reads [log] into commits, most recent first, as git ordered them.
  List<CommitEntity> parse(String log) => <CommitEntity>[
    for (final String record in log.split(GitClient.recordSeparator))
      if (_parseRecord(record) case final CommitEntity commit) commit,
  ];

  /// One record: sha, author name, author email, ISO date, subject, body.
  ///
  /// The record is trimmed on the left because git writes a newline after
  /// each one, which lands at the head of the next; the sha that follows it
  /// is hexadecimal, so nothing of the record is lost.
  ///
  /// The body is trimmed on the right only: `%b` ends with a newline git
  /// puts there rather than one the author typed. Why the left side is never
  /// touched is the type's own rule, on [CommitEntity.body].
  CommitEntity? _parseRecord(String record) {
    final List<String> fields = record.trimLeft().split(
      GitClient.unitSeparator,
    );
    if (fields.length != _fieldCount) {
      return null;
    }
    final CommitShaValueObject? sha = CommitShaValueObject.tryParse(fields[0]);
    final CommitDateValueObject? date = _parseDate(fields[3]);
    if (sha == null || date == null) {
      return null;
    }
    return CommitEntity(
      sha: sha,
      author: AuthorValueObject(name: fields[1], email: fields[2]),
      date: date,
      subject: fields[4],
      body: fields[5].trimRight(),
    );
  }

  /// `%aI` — a strict ISO 8601 instant — into an instant *and* its offset.
  ///
  /// `DateTime.tryParse` alone would not do: it reads the offset, applies it,
  /// and throws it away, so `2026-09-20T01:44:01-03:00` comes back as
  /// `04:44:01Z` and the author's Saturday night becomes the reader's Sunday
  /// morning. The offset is read off the tail of the text instead, which is
  /// the only place it still exists.
  CommitDateValueObject? _parseDate(String value) {
    final DateTime? utc = DateTime.tryParse(value);
    if (utc == null) {
      return null;
    }
    final RegExpMatch? offset = _offset.firstMatch(value);
    if (offset == null) {
      return null;
    }
    // A `Z` tail is a real zero offset, not a missing one.
    if (offset.namedGroup('sign') == null) {
      return CommitDateValueObject(utc: utc.toUtc(), offset: Duration.zero);
    }
    final Duration magnitude = Duration(
      hours: int.parse(offset.namedGroup('hours')!),
      minutes: int.parse(offset.namedGroup('minutes')!),
    );
    return CommitDateValueObject(
      utc: utc.toUtc(),
      offset: offset.namedGroup('sign') == '-' ? -magnitude : magnitude,
    );
  }

  /// The tail of a strict ISO 8601 instant: `Z`, or `±HH:MM`.
  static final RegExp _offset = RegExp(
    r'(?:Z|(?<sign>[+-])(?<hours>\d{2}):?(?<minutes>\d{2}))$',
  );
}
