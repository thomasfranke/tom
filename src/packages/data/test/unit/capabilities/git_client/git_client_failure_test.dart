import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';

void main() {
  group('GitClientFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(GitClientFailure failure) => switch (failure) {
      GitClientExecutableNotFound() => 'No git',
      GitClientNotARepository(path: final String path) => 'Not a repo: $path',
      GitClientMergeConflict(conflictedPaths: final List<String> paths) =>
        'Conflicts: ${paths.length}',
      GitClientAuthenticationFailed() => 'Auth',
      GitClientPushRejected() => 'Rejected',
      GitClientTimedOut(timeout: final Duration timeout) =>
        'Timed out after ${timeout.inSeconds}s',
      GitClientCommandFailed(exitCode: final int exitCode) => 'Exit $exitCode',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const GitClientExecutableNotFound()), 'No git');
      expect(
        headline(const GitClientNotARepository('/tmp/docs')),
        contains('/tmp/docs'),
      );
      expect(
        headline(const GitClientMergeConflict(<String>['a.md', 'b.md'])),
        'Conflicts: 2',
      );
      expect(headline(const GitClientAuthenticationFailed('denied')), 'Auth');
      expect(
        headline(const GitClientPushRejected('non-fast-forward')),
        'Rejected',
      );
      expect(
        headline(const GitClientTimedOut('git push', Duration(seconds: 30))),
        'Timed out after 30s',
      );
      expect(
        headline(const GitClientCommandFailed('git commit', 1, 'nothing')),
        'Exit 1',
      );
    });
  });

  group('GitClientMergeConflict compares by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these tests pass even with no `==` at all.
    GitClientMergeConflict over(List<String> paths) =>
        GitClientMergeConflict(paths);

    test('element-wise, not by list identity', () {
      expect(over(<String>['a.md']), over(<String>['a.md']));
      expect(over(<String>['a.md']).hashCode, over(<String>['a.md']).hashCode);
    });

    test('different paths', () {
      expect(over(<String>['a.md']), isNot(over(<String>['b.md'])));
    });
  });

  group('GitClientCommandFailed compares by value', () {
    GitClientCommandFailed over(int exitCode, String stderr) =>
        GitClientCommandFailed('git commit', exitCode, stderr);

    test('same command, same exit code, same stderr', () {
      expect(over(1, 'nothing to commit'), over(1, 'nothing to commit'));
      expect(
        over(1, 'nothing to commit').hashCode,
        over(1, 'nothing to commit').hashCode,
      );
    });

    test('different exit code', () {
      expect(
        over(1, 'nothing to commit'),
        isNot(over(128, 'nothing to commit')),
      );
    });
  });

  group('GitClientTimedOut compares by value', () {
    GitClientTimedOut after(Duration timeout) =>
        GitClientTimedOut('git fetch', timeout);

    test('same command, same timeout', () {
      expect(
        after(const Duration(seconds: 30)),
        after(const Duration(seconds: 30)),
      );
    });

    test('different timeout', () {
      expect(
        after(const Duration(seconds: 30)),
        isNot(after(const Duration(minutes: 2))),
      );
    });
  });

  test('the same path under a different variant is a different failure', () {
    expect(
      const GitClientNotARepository('/tmp/docs'),
      isNot(const GitClientCommandFailed('/tmp/docs', 128, '')),
    );
  });
}
