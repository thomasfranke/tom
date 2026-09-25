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

  /// A record as git writes it: the separator, then a newline.
  String log(List<String> records) =>
      records.map((String r) => '$r$record').join('\n');

  test('reads the six fields into a commit', () {
    final List<CommitEntity> commits = parser.parse(
      log(<String>[commitRecord()]),
    );

    final CommitEntity commit = commits.single;
    expect(
      commit.sha,
      CommitShaValueObject('a618609c8c58e65560ac3b7341607f93cb4e3019'),
    );
    expect(commit.sha.short, 'a618609');
    expect(
      commit.author,
      const AuthorValueObject(name: 'Test', email: 'test@example.com'),
    );
    expect(
      commit.date,
      CommitDateValueObject(
        utc: DateTime.utc(2026, 9, 20, 4, 44, 1),
        offset: const Duration(hours: -3),
      ),
    );
    expect(commit.subject, 'other side');
    expect(commit.body, isEmpty);
  });

  group('the offset git recorded', () {
    /// The commit date of a single commit parsed from [date].
    CommitDateValueObject? dateOf(String date) => parser
        .parse(log(<String>[commitRecord(date: date)]))
        .singleOrNull
        ?.date;

    test('survives, because DateTime alone would discard it', () {
      final CommitDateValueObject date = dateOf('2026-09-20T01:44:01-03:00')!;

      expect(date.utc, DateTime.utc(2026, 9, 20, 4, 44, 1));
      expect(date.offset, const Duration(hours: -3));
      expect(date.authorLocal.hour, 1);
      expect(date.authorLocal.day, 20);
    });

    test('a positive offset is read as one', () {
      final CommitDateValueObject date = dateOf('2026-09-20T10:30:00+05:45')!;

      expect(date.utc, DateTime.utc(2026, 9, 20, 4, 45));
      expect(date.offset, const Duration(hours: 5, minutes: 45));
      expect(date.authorLocal.hour, 10);
      expect(date.authorLocal.minute, 30);
    });

    test('Z is a real zero offset, not a missing one', () {
      final CommitDateValueObject date = dateOf('2026-09-20T04:44:01Z')!;

      expect(date.offset, Duration.zero);
      expect(date.authorLocal, date.utc);
    });

    test('the instant is what two commits compare by', () {
      final CommitDateValueObject rio = dateOf('2026-09-20T01:44:01-03:00')!;
      final CommitDateValueObject berlin = dateOf('2026-09-20T06:44:01+02:00')!;

      expect(rio.utc, berlin.utc);
      expect(rio, isNot(berlin));
      expect(rio.authorLocal, isNot(berlin.authorLocal));
    });

    test('a date with no offset at all is skipped, not assumed to be UTC', () {
      expect(dateOf('2026-09-20 04:44:01'), isNull);
    });
  });

  test('keeps the order git listed, which is most recent first', () {
    final List<CommitEntity> commits = parser.parse(
      log(<String>[
        commitRecord(subject: 'newest'),
        commitRecord(
          sha: 'bab5959044018dac1ee236a7d3b9bc5ef144b603',
          subject: 'oldest',
        ),
      ]),
    );

    expect(commits.map((CommitEntity c) => c.subject), <String>[
      'newest',
      'oldest',
    ]);
  });

  test('a body with its own newlines stays whole', () {
    final List<CommitEntity> commits = parser.parse(
      log(<String>[
        commitRecord(
          subject: 'Add B',
          body: 'Why: because.\nAnd a second line.\n',
        ),
      ]),
    );

    expect(commits.single.subject, 'Add B');
    expect(commits.single.body, 'Why: because.\nAnd a second line.');
  });

  test('a body keeps the indentation it was written with', () {
    final List<CommitEntity> commits = parser.parse(
      log(<String>[
        commitRecord(body: '    make coverage\n\nRuns the gate.\n'),
      ]),
    );

    expect(commits.single.body, '    make coverage\n\nRuns the gate.');
  });

  test('a subject containing the field separator is not possible, but a '
      'subject with punctuation is', () {
    final List<CommitEntity> commits = parser.parse(
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
      final List<CommitEntity> commits = parser.parse(
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
