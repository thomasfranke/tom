import 'package:test/test.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  group('FilesystemFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(FilesystemFailure failure) => switch (failure) {
      FilesystemEntryNotFound(path: final String path) => 'Not found: $path',
      FilesystemAccessDenied(path: final String path) => 'Denied: $path',
      FilesystemOperationFailed(description: final String description) =>
        'Failed: $description',
    };

    test('every variant has a headline, with no default branch', () {
      expect(
        headline(const FilesystemEntryNotFound('/tmp/a.md')),
        contains('/tmp'),
      );
      expect(
        headline(const FilesystemAccessDenied('/tmp/a.md')),
        startsWith('Denied'),
      );
      expect(
        headline(const FilesystemOperationFailed('/tmp/a.md', 'disk full')),
        contains('disk full'),
      );
    });
  });

  group('FilesystemEntryNotFound compares by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these tests pass even with no `==` at all.
    FilesystemEntryNotFound at(String path) => FilesystemEntryNotFound(path);

    test('same path', () {
      expect(at('/tmp/a.md'), at('/tmp/a.md'));
      expect(at('/tmp/a.md').hashCode, at('/tmp/a.md').hashCode);
    });

    test('different path', () {
      expect(at('/tmp/a.md'), isNot(at('/tmp/b.md')));
    });
  });

  group('FilesystemAccessDenied compares by value', () {
    FilesystemAccessDenied at(String path) => FilesystemAccessDenied(path);

    test('same path', () {
      expect(at('/tmp/a.md'), at('/tmp/a.md'));
      expect(at('/tmp/a.md').hashCode, at('/tmp/a.md').hashCode);
    });

    test('different path', () {
      expect(at('/tmp/a.md'), isNot(at('/tmp/b.md')));
    });
  });

  group('FilesystemOperationFailed compares by value', () {
    FilesystemOperationFailed failureOver(String path, String description) =>
        FilesystemOperationFailed(path, description);

    test('same path, same description', () {
      expect(
        failureOver('/tmp/a.md', 'disk full'),
        failureOver('/tmp/a.md', 'disk full'),
      );
      expect(
        failureOver('/tmp/a.md', 'disk full').hashCode,
        failureOver('/tmp/a.md', 'disk full').hashCode,
      );
    });

    test('same path, different description', () {
      expect(
        failureOver('/tmp/a.md', 'disk full'),
        isNot(failureOver('/tmp/a.md', 'permission')),
      );
    });
  });

  test('the same path under a different variant is a different failure', () {
    expect(
      const FilesystemEntryNotFound('/tmp/a.md'),
      isNot(const FilesystemAccessDenied('/tmp/a.md')),
    );
  });
}
