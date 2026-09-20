/// Turning the log format `GitClient` asks for into [Commit]s.
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
  List<Commit> parse(String log) => <Commit>[
    for (final String record in log.split(GitClient.recordSeparator))
      if (_parseRecord(record) case final Commit commit) commit,
  ];

  /// One record: sha, author name, author email, ISO date, subject, body.
  ///
  /// `trimLeft` because git writes a newline after each record, which lands
  /// at the head of the next one. Only the left is trimmed — the body is the
  /// last field and its own trailing newlines are its content.
  Commit? _parseRecord(String record) {
    final List<String> fields = record.trimLeft().split(
      GitClient.unitSeparator,
    );
    if (fields.length != _fieldCount) {
      return null;
    }
    final CommitSha? sha = CommitSha.tryParse(fields[0]);
    final DateTime? date = DateTime.tryParse(fields[3]);
    if (sha == null || date == null) {
      return null;
    }
    return Commit(
      sha: sha,
      author: Author(name: fields[1], email: fields[2]),
      date: date,
      subject: fields[4],
      body: fields[5].trim(),
    );
  }
}
