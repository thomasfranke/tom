import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('GitFailure', () {
    // Compiles with no default branch only while the hierarchy is sealed, and
    // no headline can reach for a command line or a stderr, since no variant
    // carries one.
    String headline(GitFailure failure) => switch (failure) {
      GitNotInstalled() => 'Git is not installed',
      GitNotARepository(path: final String path) => 'Not a repository: $path',
      GitMergeConflict(conflictedFiles: final List<String> files) =>
        '${files.length} conflicted files',
      GitAuthenticationFailed() => 'Authentication failed',
      GitDetachedHead() => 'Detached HEAD',
      GitPushRejected() => 'The remote moved first',
      GitTimedOut() => 'That took too long',
      GitPathNotInRevision(path: final String path) =>
        'No earlier version of $path',
      GitOperationFailed() => 'Git could not do that',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const GitNotInstalled()), isNotEmpty);
      expect(headline(const GitNotARepository('/tmp/space')), contains('/tmp'));
      expect(
        headline(const GitMergeConflict(<String>['a.md'])),
        startsWith('1'),
      );
      expect(
        headline(const GitAuthenticationFailed()),
        'Authentication failed',
      );
      expect(headline(const GitDetachedHead()), 'Detached HEAD');
      expect(headline(const GitPushRejected()), 'The remote moved first');
      expect(headline(const GitTimedOut()), 'That took too long');
      expect(
        headline(const GitPathNotInRevision('guides/writing.md')),
        contains('guides/writing.md'),
      );
      expect(headline(const GitOperationFailed()), 'Git could not do that');
    });
  });

  group('the cause', () {
    test('is where the technical detail lives', () {
      const UnexpectedFailure reported = UnexpectedFailure(
        'git push: ! [rejected]',
      );

      const GitFailure failure = GitOperationFailed(cause: reported);

      expect(failure.cause, reported);
      expect(failure.chain, <AppFailure>[failure, reported]);
      expect(failure.diagnostics, contains('! [rejected]'));
    });

    test('is absent when nothing was translated', () {
      expect(const GitDetachedHead().cause, isNull);
    });

    test('is part of the value', () {
      // Built through a function so nothing is canonicalised into passing.
      GitOperationFailed failedBecause(String what) =>
          GitOperationFailed(cause: UnexpectedFailure(what));

      expect(failedBecause('a'), failedBecause('a'));
      expect(failedBecause('a'), isNot(failedBecause('b')));
    });
  });

  group('failures compare by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these tests pass even with no `==` at all.
    GitMergeConflict conflictOver(List<String> files) =>
        GitMergeConflict(files.toList());

    test('same variant, same data', () {
      expect(conflictOver(<String>['a.md']), conflictOver(<String>['a.md']));
      expect(
        conflictOver(<String>['a.md']).hashCode,
        conflictOver(<String>['a.md']).hashCode,
      );
    });

    test('same variant, different data', () {
      expect(
        conflictOver(<String>['a.md']),
        isNot(conflictOver(<String>['b.md'])),
      );
    });

    test('order matters — the list comes from git, not from a set', () {
      expect(
        conflictOver(<String>['a.md', 'b.md']),
        isNot(conflictOver(<String>['b.md', 'a.md'])),
      );
    });

    test('the same data under a different variant is a different failure', () {
      expect(
        const GitNotARepository('/tmp/space'),
        isNot(const GitMergeConflict(<String>[])),
      );
    });
  });

  group('GitNotARepository compares by value', () {
    GitNotARepository at(String path) => GitNotARepository(path);

    test('same path', () {
      expect(at('/tmp/space'), at('/tmp/space'));
      expect(at('/tmp/space').hashCode, at('/tmp/space').hashCode);
    });

    test('different path', () {
      expect(at('/tmp/space'), isNot(at('/tmp/other')));
    });
  });

  group('the variants that carry nothing but a cause', () {
    GitTimedOut timedOutFrom(String what) =>
        GitTimedOut(cause: UnexpectedFailure(what));

    test('same cause', () {
      expect(timedOutFrom('git push'), timedOutFrom('git push'));
      expect(
        timedOutFrom('git push').hashCode,
        timedOutFrom('git push').hashCode,
      );
    });

    test('different cause', () {
      expect(timedOutFrom('git push'), isNot(timedOutFrom('git pull')));
    });

    test('no cause at all is still equal to itself', () {
      GitTimedOut bare(AppFailure? cause) => GitTimedOut(cause: cause);

      expect(bare(null), bare(null));
      expect(bare(null).hashCode, bare(null).hashCode);
    });
  });
}
