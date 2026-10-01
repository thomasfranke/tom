/// Turning the log format `GitClient` asks for into [CommitEntity]s.
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The reader of what [GitClient.log] returned, in that format and with its
/// separators.
///
/// Total: a record whose sha or date it cannot read is skipped, because a
/// history missing one entry is smaller than one that will not open.
final class GitLogParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitLogParser();

  /// How many fields [GitClient.log] promises per commit.
  static const int _fieldCount = 6;

  /// [log] as commits, most recent first, as git ordered them.
  List<CommitEntity> parse(String log) => <CommitEntity>[
    for (final String record in log.split(GitClient.recordSeparator))
      if (_parseRecord(record) case final CommitEntity commit) commit,
  ];

  /// One record: sha, author name, author email, ISO date, subject, body.
  ///
  /// Trimmed on the left because git writes a newline after each record that
  /// lands at the head of the next. The body is trimmed on the right only:
  /// `%b` ends with git's newline, and the left side is [CommitEntity.body]'s
  /// rule.
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

  /// `%aI`, a strict ISO 8601 instant, as an instant and its offset.
  ///
  /// The offset is read off the tail of the text because `DateTime.tryParse`
  /// applies it and throws it away.
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
