import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('GitFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(GitFailure failure) => switch (failure) {
      GitNotInstalled() => 'Git is not installed',
      NotARepository(path: final String path) => 'Not a repository: $path',
      MergeConflict(conflictedFiles: final List<String> files) =>
        '${files.length} conflicted files',
      AuthenticationFailed() => 'Authentication failed',
      DetachedHead() => 'Detached HEAD',
      GitCommandFailed(command: final String command) => 'Failed: $command',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const GitNotInstalled()), isNotEmpty);
      expect(headline(const NotARepository('/tmp/space')), contains('/tmp'));
      expect(headline(const MergeConflict(<String>['a.md'])), startsWith('1'));
      expect(headline(const AuthenticationFailed()), 'Authentication failed');
      expect(headline(const DetachedHead()), 'Detached HEAD');
      expect(
        headline(const GitCommandFailed('git push', 'rejected')),
        'Failed: git push',
      );
    });
  });

  group('failures compare by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these tests pass even with no `==` at all.
    MergeConflict conflictOver(List<String> files) =>
        MergeConflict(files.toList());

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
        const NotARepository('/tmp/space'),
        isNot(const MergeConflict(<String>[])),
      );
    });
  });

  group('NotARepository compares by value', () {
    NotARepository at(String path) => NotARepository(path);

    test('same path', () {
      expect(at('/tmp/space'), at('/tmp/space'));
      expect(at('/tmp/space').hashCode, at('/tmp/space').hashCode);
    });

    test('different path', () {
      expect(at('/tmp/space'), isNot(at('/tmp/other')));
    });
  });

  group('GitCommandFailed compares by value', () {
    GitCommandFailed commandOver(String command, String stderr) =>
        GitCommandFailed(command, stderr);

    test('same command, same stderr', () {
      expect(
        commandOver('git push', 'rejected'),
        commandOver('git push', 'rejected'),
      );
      expect(
        commandOver('git push', 'rejected').hashCode,
        commandOver('git push', 'rejected').hashCode,
      );
    });

    test('same command, different stderr', () {
      expect(
        commandOver('git push', 'rejected'),
        isNot(commandOver('git push', 'timed out')),
      );
    });
  });
}
