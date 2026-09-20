/// [GitLogParser] over fixtures in the format `GitClient.log` promises.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const GitLogParser parser = GitLogParser();

  const String unit = GitClient.unitSeparator;
  const String record = GitClient.recordSeparator;

  /// One commit, in the six fields the contract promises.
  String commitRecord({
    String sha = 'a618609c8c58e65560ac3b7341607f93cb4e3019',
    String name = 'Test',
    String email = 'test@example.com',
    String date = '2026-09-20T01:44:01-03:00',
    String subject = 'other side',
    String body = '',
  }) => <String>[sha, name, email, date, subject, body].join(unit);

  /// What git actually writes: a record separator, then a newline.
  String log(List<String> records) =>
      records.map((String r) => '$r$record').join('\n');

  test('reads the six fields into a commit', () {
    final List<Commit> commits = parser.parse(log(<String>[commitRecord()]));

    final Commit commit = commits.single;
    expect(commit.sha, CommitSha('a618609c8c58e65560ac3b7341607f93cb4e3019'));
    expect(commit.sha.short, 'a618609');
    expect(
      commit.author,
      const Author(name: 'Test', email: 'test@example.com'),
    );
    expect(commit.date, DateTime.parse('2026-09-20T01:44:01-03:00'));
    expect(commit.subject, 'other side');
    expect(commit.body, isEmpty);
  });

  test('keeps the order git listed, which is most recent first', () {
    final List<Commit> commits = parser.parse(
      log(<String>[
        commitRecord(subject: 'newest'),
        commitRecord(
          sha: 'bab5959044018dac1ee236a7d3b9bc5ef144b603',
          subject: 'oldest',
        ),
      ]),
    );

    expect(commits.map((Commit c) => c.subject), <String>['newest', 'oldest']);
  });

  test('a body with its own newlines stays whole', () {
    final List<Commit> commits = parser.parse(
      log(<String>[
        commitRecord(
          subject: 'Add B',
          body: 'Why: because.\nAnd a second line.\n',
        ),
      ]),
    );

    // The body is the last field precisely so that its newlines cannot be
    // mistaken for the end of the record.
    expect(commits.single.subject, 'Add B');
    expect(commits.single.body, 'Why: because.\nAnd a second line.');
  });

  test('a subject containing the field separator is not possible, but a '
      'subject with punctuation is', () {
    final List<Commit> commits = parser.parse(
      log(<String>[
        commitRecord(subject: 'fix(git): stop | splitting -- here'),
      ]),
    );

    expect(commits.single.subject, 'fix(git): stop | splitting -- here');
  });

  group('what it refuses to guess at', () {
    test('an empty log is no commits, not a failure', () {
      expect(parser.parse(''), isEmpty);
    });

    test('a record with the wrong field count is skipped', () {
      final List<Commit> commits = parser.parse(
        log(<String>['only${unit}three${unit}fields', commitRecord()]),
      );

      expect(commits, hasLength(1));
    });

    test('an abbreviated sha is not a sha', () {
      expect(
        parser.parse(log(<String>[commitRecord(sha: 'a618609')])),
        isEmpty,
      );
    });

    test('a date git did not write is skipped rather than invented', () {
      expect(
        parser.parse(log(<String>[commitRecord(date: 'last tuesday')])),
        isEmpty,
      );
    });
  });
}
