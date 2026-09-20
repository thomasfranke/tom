/// [GitStatusParser] over fixtures of real `git status --porcelain=v2 -z`.
///
/// Unit, not integration: the parser is pure, and the records below were
/// captured from a real repository put into each state rather than written
/// from the manual — a hand-invented fixture proves the parser agrees with
/// whoever wrote it.
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
  StatusEntry entryFor(GitStatus status, String name) =>
      status.entries.firstWhere(
        (StatusEntry entry) => entry.path.name == name,
        orElse: () => fail(
          'no entry for $name in '
          '${status.entries.map((StatusEntry e) => e.path.value)}',
        ),
      );

  group('headers', () {
    test('reads the branch', () {
      final GitStatus status = parser.parse(
        porcelain(<String>[
          '# branch.oid 0cc54f652f648ff6d6b9f2516b3b4bc7005a5455',
          '# branch.head main',
        ]),
      );

      expect(status.branch, BranchName('main'));
      expect(status.isDetached, isFalse);
      expect(status.isClean, isTrue);
    });

    test('a branch name this version cannot read is not a detached HEAD', () {
      // Both answers used to be `branch == null`. Reading the unparseable
      // one as detachment would warn about a detached HEAD on a repository
      // sitting on a perfectly ordinary branch.
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head feat/weird~name']),
      );

      expect(status.branch, isNull);
      expect(status.isDetached, isFalse);
    });

    test('a status git said nothing about is not detached either', () {
      expect(parser.parse('').isDetached, isFalse);
    });

    test('a detached HEAD has no branch', () {
      final GitStatus status = parser.parse(
        porcelain(<String>[
          '# branch.oid 0cc54f652f648ff6d6b9f2516b3b4bc7005a5455',
          '# branch.head (detached)',
        ]),
      );

      expect(status.branch, isNull);
      expect(status.isDetached, isTrue);
    });

    test('reads the upstream and how far it has drifted', () {
      final GitStatus status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '# branch.upstream origin/main',
          '# branch.ab +2 -3',
        ]),
      );

      expect(status.upstream, BranchName('origin/main'));
      expect(status.ahead, 2);
      expect(status.behind, 3);
    });

    test('no upstream means no drift, not unknown drift', () {
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head main']),
      );

      expect(status.upstream, isNull);
      expect(status.ahead, 0);
      expect(status.behind, 0);
    });
  });

  group('entries', () {
    /// Every shape one working tree produced at once.
    final GitStatus status = parser.parse(
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
      // the producer is what makes the status say the same thing tomorrow.
      expect(
        () => status.entries.add(status.entries.first),
        throwsUnsupportedError,
      );
    });

    test('finds every path, and no extra one', () {
      expect(status.entries.map((StatusEntry e) => e.path.value), <String>[
        'a.md',
        'b.md',
        'new-name.md',
        'release notes.md',
        'untracked.md',
      ]);
    });

    test('a staged file edited again is staged, and shows the staged side', () {
      final StatusEntry entry = entryFor(status, 'a.md');

      expect(entry.state, FileState.modified);
      expect(entry.isStaged, isTrue);
    });

    test('an unstaged edit is not staged', () {
      expect(entryFor(status, 'b.md').isStaged, isFalse);
    });

    test('a rename keeps where the file came from', () {
      final StatusEntry entry = entryFor(status, 'new-name.md');

      expect(entry.state, FileState.renamed);
      expect(entry.isStaged, isTrue);
      expect(entry.previousPath, RepoRelativePath('old-name.md'));
    });

    test('the path after a rename is not read as its own entry', () {
      expect(
        status.entries.where((StatusEntry e) => e.path.value == 'old-name.md'),
        isEmpty,
      );
    });

    test('a copy is an addition, and the source is not where it came from', () {
      // Git spends a `2` record on a copy as well as a rename, and the
      // domain has no `copied`. `previousPath` means "the file came from
      // here", which for a copy is false: the source is still on disk.
      final GitStatus copied = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '2 C. N... 100644 100644 100644 '
              'c2a29eb94540613517391de898c9f944c08748be '
              'c2a29eb94540613517391de898c9f944c08748be C75 copy.md',
          'origin.md',
        ]),
      );

      final StatusEntry entry = entryFor(copied, 'copy.md');
      expect(entry.state, FileState.added);
      expect(entry.previousPath, isNull);
    });

    test('the source of a copy is not read as its own entry either', () {
      final GitStatus copied = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '2 C. N... 100644 100644 100644 '
              'c2a29eb94540613517391de898c9f944c08748be '
              'c2a29eb94540613517391de898c9f944c08748be C75 copy.md',
          'origin.md',
        ]),
      );

      expect(copied.entries.map((StatusEntry e) => e.path.value), <String>[
        'copy.md',
      ]);
    });

    test('a deletion in the working tree', () {
      final StatusEntry entry = entryFor(status, 'release notes.md');

      expect(entry.state, FileState.deleted);
      expect(entry.isStaged, isFalse);
    });

    test('a path with a space survives, which is why -z is used', () {
      expect(
        entryFor(status, 'release notes.md').path.value,
        'release notes.md',
      );
    });

    test('an untracked file is never staged', () {
      final StatusEntry entry = entryFor(status, 'untracked.md');

      expect(entry.state, FileState.untracked);
      expect(entry.isStaged, isFalse);
    });

    test('a conflicted path from a real stopped merge', () {
      final GitStatus merging = parser.parse(
        porcelain(<String>[
          '# branch.head other',
          'u UU N... 100644 100644 100644 100644 '
              'df967b96a579e45a18b8251732d16804b2e56a55 '
              '0fa2621178dfa495bb0d1b0fd329e30eb5d953bb '
              '21d65f9bcc9b45c737fa7ba476aeb90a0d296cbd a.md',
        ]),
      );

      expect(merging.entries.single.state, FileState.conflicted);
      expect(merging.entries.single.path, RepoRelativePath('a.md'));
      // Not staged: a conflict is something to resolve, not something a
      // commit would record as it stands.
      expect(merging.entries.single.isStaged, isFalse);
    });
  });

  group('hasStagedChanges', () {
    test('false when nothing is in the index', () {
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head main', '? untracked.md']),
      );

      expect(status.hasStagedChanges, isFalse);
    });

    test('true once something is', () {
      final GitStatus status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '1 A. N... 000000 100644 100644 '
              '0000000000000000000000000000000000000000 '
              '97d5e3908a59a1d69b6ffb314d975c9fa8c8a937 new.md',
        ]),
      );

      expect(status.hasStagedChanges, isTrue);
      expect(status.entries.single.state, FileState.added);
    });
  });

  group('what it refuses to guess at', () {
    test('an empty status is a clean repository, not a failure', () {
      expect(parser.parse('').entries, isEmpty);
    });

    test('a truncated record is skipped, not thrown over', () {
      final GitStatus status = parser.parse(
        porcelain(<String>[
          '# branch.head main',
          '1 MM N... 100644',
          '? ok.md',
        ]),
      );

      // The point of a total parser: one unreadable line costs that line.
      expect(status.entries.single.path, RepoRelativePath('ok.md'));
    });

    test('an unknown record type is ignored', () {
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head main', '9 something new', '? ok.md']),
      );

      expect(status.entries.single.path, RepoRelativePath('ok.md'));
    });

    test('an ignored file is not an entry', () {
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head main', '! build/output.md']),
      );

      expect(status.entries, isEmpty);
    });

    test('a malformed ahead/behind leaves the counts at zero', () {
      final GitStatus status = parser.parse(
        porcelain(<String>['# branch.head main', '# branch.ab nonsense']),
      );

      expect(status.ahead, 0);
      expect(status.behind, 0);
    });
  });
}
