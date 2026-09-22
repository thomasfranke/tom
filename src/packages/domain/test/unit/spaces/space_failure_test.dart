import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('SpaceFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(SpaceFailure failure) => switch (failure) {
      SpaceFolderMissing(root: final String root) => 'Gone: $root',
      SpaceAccessDenied(path: final String path) => 'Denied: $path',
      SpaceOperationFailed(path: final String path) => 'Failed: $path',
    };

    test('every variant has a headline, with no default branch', () {
      expect(
        headline(const SpaceFolderMissing('/code/docs')),
        'Gone: /code/docs',
      );
      expect(
        headline(const SpaceAccessDenied('/code/docs/private')),
        'Denied: /code/docs/private',
      );
      expect(
        headline(const SpaceOperationFailed('/code/docs')),
        'Failed: /code/docs',
      );
    });
  });

  group('failures compare by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these pass even with no `==` at all.
    SpaceFolderMissing missingAt(String root) => SpaceFolderMissing(root);
    // The technical detail it used to carry is a cause now, and the cause is
    // part of the value.
    SpaceOperationFailed failedAt(String path, String because) =>
        SpaceOperationFailed(path, cause: UnexpectedFailure(because));

    test('same variant, same data', () {
      expect(missingAt('/code/docs'), missingAt('/code/docs'));
      expect(
        missingAt('/code/docs').hashCode,
        missingAt('/code/docs').hashCode,
      );
    });

    test('same variant, different data', () {
      expect(missingAt('/code/docs'), isNot(missingAt('/code/other')));
      expect(
        failedAt('/code/docs', 'EIO'),
        isNot(failedAt('/code/docs', 'ENOSPC')),
      );
    });

    test('the same path under a different variant is a different failure', () {
      expect(
        missingAt('/code/docs'),
        isNot(const SpaceAccessDenied('/code/docs')),
      );
    });
  });
}
