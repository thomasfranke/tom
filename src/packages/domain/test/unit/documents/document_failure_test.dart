import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('DocumentFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(DocumentFailure failure) => switch (failure) {
      DocumentNotFound(path: final String path) => 'Not found: $path',
      DocumentPermissionDenied(path: final String path) => 'Denied: $path',
      DocumentNotUtf8(path: final String path) => 'Not UTF-8: $path',
      DocumentOperationFailed(path: final String path) => 'Failed: $path',
      DocumentExternalChangeConflict(path: final String path) =>
        'Conflict: $path',
    };

    test('every variant has a headline, with no default branch', () {
      expect(
        headline(const DocumentNotFound('notes/a.md')),
        'Not found: notes/a.md',
      );
      expect(
        headline(const DocumentPermissionDenied('notes/a.md')),
        'Denied: notes/a.md',
      );
      expect(
        headline(const DocumentNotUtf8('notes/a.md')),
        'Not UTF-8: notes/a.md',
      );
      expect(
        headline(const DocumentExternalChangeConflict('notes/a.md')),
        'Conflict: notes/a.md',
      );
      expect(
        headline(const DocumentOperationFailed('notes/a.md', 'EIO')),
        'Failed: notes/a.md',
      );
    });
  });

  group('failures compare by value', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make these tests pass even with no `==` at all.
    DocumentNotFound notFoundAt(String path) => DocumentNotFound(path);
    DocumentPermissionDenied deniedAt(String path) =>
        DocumentPermissionDenied(path);
    DocumentExternalChangeConflict conflictAt(String path) =>
        DocumentExternalChangeConflict(path);
    DocumentNotUtf8 notUtf8At(String path) => DocumentNotUtf8(path);
    DocumentOperationFailed failedAt(String path, String description) =>
        DocumentOperationFailed(path, description);

    test('same variant, same path', () {
      expect(notFoundAt('notes/a.md'), notFoundAt('notes/a.md'));
      expect(
        notFoundAt('notes/a.md').hashCode,
        notFoundAt('notes/a.md').hashCode,
      );
      expect(deniedAt('notes/a.md'), deniedAt('notes/a.md'));
      expect(deniedAt('notes/a.md').hashCode, deniedAt('notes/a.md').hashCode);
      expect(conflictAt('notes/a.md'), conflictAt('notes/a.md'));
      expect(
        conflictAt('notes/a.md').hashCode,
        conflictAt('notes/a.md').hashCode,
      );
      expect(notUtf8At('notes/a.md'), notUtf8At('notes/a.md'));
      expect(
        notUtf8At('notes/a.md').hashCode,
        notUtf8At('notes/a.md').hashCode,
      );
    });

    test('same variant, different path', () {
      expect(notFoundAt('notes/a.md'), isNot(notFoundAt('notes/b.md')));
      expect(deniedAt('notes/a.md'), isNot(deniedAt('notes/b.md')));
      expect(conflictAt('notes/a.md'), isNot(conflictAt('notes/b.md')));
      expect(notUtf8At('notes/a.md'), isNot(notUtf8At('notes/b.md')));
      expect(
        failedAt('notes/a.md', 'EIO'),
        isNot(failedAt('notes/a.md', 'ENOSPC')),
      );
    });

    test('the same path under a different variant is a different failure', () {
      expect(notFoundAt('notes/a.md'), isNot(deniedAt('notes/a.md')));
      expect(deniedAt('notes/a.md'), isNot(conflictAt('notes/a.md')));
      expect(notUtf8At('notes/a.md'), isNot(deniedAt('notes/a.md')));
    });
  });
}
