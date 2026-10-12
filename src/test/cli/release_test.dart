/// `tom release`'s pure logic: the bump and the changelog it writes.
///
/// What it leaves in git — the commit, the tag — is not covered here: both
/// are one `capture('git', …)` call each, and the risk worth a test is the
/// version arithmetic and the grouping, not that `Process.run` works.
library;

import 'package:test/test.dart';

import '../../../tool/src/commands/release.dart';

void main() {
  group('a bump', () {
    test('major resets minor and patch', () {
      expect(const SemVer(1, 4, 7).bump('major'), isSemVer(2, 0, 0));
    });

    test('minor resets patch, keeps major', () {
      expect(const SemVer(1, 4, 7).bump('minor'), isSemVer(1, 5, 0));
    });

    test('patch touches only itself', () {
      expect(const SemVer(1, 4, 7).bump('patch'), isSemVer(1, 4, 8));
    });

    test('reads back what it printed', () {
      expect(SemVer.parse('0.1.0').toString(), '0.1.0');
    });

    test('an unknown word is this CLI\'s own error, not semver\'s', () {
      expect(() => const SemVer(0, 1, 0).bump('nonesuch'), throwsArgumentError);
    });
  });

  group('the changelog', () {
    test('groups breaking, features and fixes, in that order', () {
      final String changelog =
          changelogFor(const SemVer(1, 0, 0), const <CommitMessage>[
            CommitMessage('fix: the caret', ''),
            CommitMessage('feat: a second pane', ''),
            CommitMessage('feat!: drop the old settings file', ''),
          ]);

      expect(
        changelog.indexOf('Breaking'),
        lessThan(changelog.indexOf('Features')),
      );
      expect(
        changelog.indexOf('Features'),
        lessThan(changelog.indexOf('Fixes')),
      );
      expect(changelog, contains('a second pane'));
      expect(changelog, contains('the caret'));
    });

    test('a breaking feature is named once, under Breaking', () {
      final String changelog = changelogFor(
        const SemVer(1, 0, 0),
        const <CommitMessage>[
          CommitMessage('feat!: drop the old settings file', ''),
        ],
      );

      expect('Features'.allMatches(changelog), isEmpty);
      expect(changelog, contains('drop the old settings file'));
    });

    test('a BREAKING CHANGE footer counts, with no ! in the subject', () {
      final String changelog =
          changelogFor(const SemVer(1, 0, 0), const <CommitMessage>[
            CommitMessage(
              'feat: rename the export flag',
              'BREAKING CHANGE: --pdf is now --format=pdf',
            ),
          ]);

      expect(changelog, contains('Breaking'));
      expect('Features'.allMatches(changelog), isEmpty);
      expect(changelog, contains('rename the export flag'));
    });

    test('a chore says nothing — nobody reads it in a release', () {
      final String changelog = changelogFor(
        const SemVer(1, 0, 0),
        const <CommitMessage>[
          CommitMessage('chore: bump a dev dependency', ''),
        ],
      );

      expect(changelog, isNot(contains('bump a dev dependency')));
    });

    test('no commits is still a heading, not an empty string', () {
      expect(
        changelogFor(const SemVer(1, 0, 0), const <CommitMessage>[]),
        '## v1.0.0\n',
      );
    });
  });

  group('the usage error', () {
    test('a missing or unknown bump exits 64, the others do not run', () {
      expect(runRelease(null), completion(64));
      expect(runRelease('nonesuch'), completion(64));
    });
  });
}

/// `SemVer` has no `==` — `tool/` runs no build_runner, and the value this
/// test cares about is the string a release is tagged with anyway.
Matcher isSemVer(int major, int minor, int patch) => predicate<SemVer>(
  (SemVer v) => v.toString() == '$major.$minor.$patch',
  '$major.$minor.$patch',
);
