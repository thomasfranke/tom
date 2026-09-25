/// [GitStatusParser] over records captured from a real repository put into
/// each state, because a hand-written fixture proves only that the parser
/// agrees with its author.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GitStatusParser parser = GitStatusParser();

  /// The NUL-terminated stream git writes in `-z` mode.
  String porcelain(List<String> records) =>
      records.map((String r) => '$r${String.fromCharCode(0)}').join();

  /// The entry for [name], or a failed expectation naming what was there.
  StatusEntryValueObject entryFor(GitStatusValueObject status, String name) =>
      status.entries.firstWhere(
        (StatusEntryValueObject entry) => entry.path.name == name,
        orElse: () => fail(
          'no entry for $name in '
          '${status.entries.map((StatusEntryValueObject e) => e.path.value)}',
        ),
      );

  group('headers', () {
    test('reads the branch', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>[
          '# branch.oid 0cc54f652f648ff6d6b9f2516b3b4bc7005a5455',
          '# branch.head main',
        ]),
      );

      expect(status.branch, BranchNameValueObject('main'));
      expect(status.isDetached, isFalse);
      expect(status.isClean, isTrue);
    });

    test('a branch name this version cannot read is not a detached HEAD', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head feat/weird~name']),
      );

      expect(status.branch, isNull);
      expect(status.isDetached, isFalse);
    });

    test('a status git said nothing about is not detached either', () {
      expect(parser.parse('').isDetached, isFalse);
    });

    test('a detached HEAD has no branch', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>[
          '# branch.oid 0cc54f652f648ff6d6b9f2516b3b4bc7005a5455',
          '# branch.head (detached)',
        ]),
      );

      expect(status.branch, isNull);
      expect(status.isDetached, isTrue);
    });

    test('reads the upstream and how far it has drifted', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '# branch.upstream origin/main',
          '# branch.ab +2 -3',
        ]),
      );

      expect(status.upstream, BranchNameValueObject('origin/main'));
      expect(status.ahead, 2);
      expect(status.behind, 3);
    });

    test('no upstream means no drift, not unknown drift', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head main']),
      );

      expect(status.upstream, isNull);
      expect(status.ahead, 0);
      expect(status.behind, 0);
    });
  });

  group('entries', () {
    /// Every shape one working tree produced at once.
    final GitStatusValueObject status = parser.parse(
      porcelain(<String>[
        '# branch.oid 0cc54f652f648ff6d6b9f2516b3b4bc7005a5455',
        '# branch.head main',
        '1 MM N... 100644 100644 100644 '
            '7f3b95d297183eca8f6cf38ceaa253bee8c2d7cd '
            '97d5e3908a59a1d69b6ffb314d975c9fa8c8a937 a.md',
        '1 .M N... 100644 100644 100644 '
            '399d8833f40aa9393618e2c0280445239dfbe935 '
            '399d8833f40aa9393618e2c0280445239dfbe935 b.md',
        '2 R. N... 100644 100644 100644 '
            'c2a29eb94540613517391de898c9f944c08748be '
            'c2a29eb94540613517391de898c9f944c08748be R100 new-name.md',
        'old-name.md',
        '1 .D N... 100644 100644 000000 '
            '5f28fc0e865a4b9f7dab27b8d54e61b74104ff4c '
            '5f28fc0e865a4b9f7dab27b8d54e61b74104ff4c release notes.md',
        '? untracked.md',
      ]),
    );

    test('the entries cannot be changed behind the status', () {
      // Freezed compares element-wise but does not copy the collection, so
      // the producer is what keeps it unmodifiable.
      expect(
        () => status.entries.add(status.entries.first),
        throwsUnsupportedError,
      );
    });

    test('finds every path, and no extra one', () {
      expect(
        status.entries.map((StatusEntryValueObject e) => e.path.value),
        <String>[
          'a.md',
          'b.md',
          'new-name.md',
          'release notes.md',
          'untracked.md',
        ],
      );
    });

    test('a staged file edited again is staged, and shows the staged side', () {
      final StatusEntryValueObject entry = entryFor(status, 'a.md');

      expect(entry.state, FileStateEnum.modified);
      expect(entry.isStaged, isTrue);
    });

    test('an unstaged edit is not staged', () {
      expect(entryFor(status, 'b.md').isStaged, isFalse);
    });

    test('a rename keeps where the file came from', () {
      final StatusEntryValueObject entry = entryFor(status, 'new-name.md');

      expect(entry.state, FileStateEnum.renamed);
      expect(entry.isStaged, isTrue);
      expect(entry.previousPath, RepoRelativePathValueObject('old-name.md'));
    });

    test('the path after a rename is not read as its own entry', () {
      expect(
        status.entries.where(
          (StatusEntryValueObject e) => e.path.value == 'old-name.md',
        ),
        isEmpty,
      );
    });

    test('a copy is an addition, and the source is not where it came from', () {
      final GitStatusValueObject copied = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '2 C. N... 100644 100644 100644 '
              'c2a29eb94540613517391de898c9f944c08748be '
              'c2a29eb94540613517391de898c9f944c08748be C75 copy.md',
          'origin.md',
        ]),
      );

      final StatusEntryValueObject entry = entryFor(copied, 'copy.md');
      expect(entry.state, FileStateEnum.added);
      expect(entry.previousPath, isNull);
    });

    test('the source of a copy is not read as its own entry either', () {
      final GitStatusValueObject copied = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '2 C. N... 100644 100644 100644 '
              'c2a29eb94540613517391de898c9f944c08748be '
              'c2a29eb94540613517391de898c9f944c08748be C75 copy.md',
          'origin.md',
        ]),
      );

      expect(
        copied.entries.map((StatusEntryValueObject e) => e.path.value),
        <String>['copy.md'],
      );
    });

    test('a deletion in the working tree', () {
      final StatusEntryValueObject entry = entryFor(status, 'release notes.md');

      expect(entry.state, FileStateEnum.deleted);
      expect(entry.isStaged, isFalse);
    });

    test('a path with a space survives, which is why -z is used', () {
      expect(
        entryFor(status, 'release notes.md').path.value,
        'release notes.md',
      );
    });

    test('an untracked file is never staged', () {
      final StatusEntryValueObject entry = entryFor(status, 'untracked.md');

      expect(entry.state, FileStateEnum.untracked);
      expect(entry.isStaged, isFalse);
    });

    test('a conflicted path from a real stopped merge', () {
      final GitStatusValueObject merging = parser.parse(
        porcelain(<String>[
          '# branch.head other',
          'u UU N... 100644 100644 100644 100644 '
              'df967b96a579e45a18b8251732d16804b2e56a55 '
              '0fa2621178dfa495bb0d1b0fd329e30eb5d953bb '
              '21d65f9bcc9b45c737fa7ba476aeb90a0d296cbd a.md',
        ]),
      );

      expect(merging.entries.single.state, FileStateEnum.conflicted);
      expect(merging.entries.single.path, RepoRelativePathValueObject('a.md'));
      expect(merging.entries.single.isStaged, isFalse);
    });
  });

  group('hasStagedChanges', () {
    test('false when nothing is in the index', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head main', '? untracked.md']),
      );

      expect(status.hasStagedChanges, isFalse);
    });

    test('true once something is', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '1 A. N... 000000 100644 100644 '
              '0000000000000000000000000000000000000000 '
              '97d5e3908a59a1d69b6ffb314d975c9fa8c8a937 new.md',
        ]),
      );

      expect(status.hasStagedChanges, isTrue);
      expect(status.entries.single.state, FileStateEnum.added);
    });
  });

  group('what it refuses to guess at', () {
    test('an empty status is a clean repository, not a failure', () {
      expect(parser.parse('').entries, isEmpty);
    });

    test('a truncated record is skipped, not thrown over', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '1 MM N... 100644',
          '? ok.md',
        ]),
      );

      expect(status.entries.single.path, RepoRelativePathValueObject('ok.md'));
    });

    test('an unknown record type is ignored', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head main', '9 something new', '? ok.md']),
      );

      expect(status.entries.single.path, RepoRelativePathValueObject('ok.md'));
    });

    test('an ignored file is not an entry', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head main', '! build/output.md']),
      );

      expect(status.entries, isEmpty);
    });

    test('a malformed ahead/behind leaves the counts at zero', () {
      final GitStatusValueObject status = parser.parse(
        porcelain(<String>['# branch.head main', '# branch.ab nonsense']),
      );

      expect(status.ahead, 0);
      expect(status.behind, 0);
    });
  });
}
