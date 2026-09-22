import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  DocumentEntity documentAt(String path, String content) => DocumentEntity(
    path: SpaceRelativePathValueObject(path),
    content: content,
  );

  group('name', () {
    test('is the file name', () {
      expect(documentAt('adr/001-git.md', '# Git').name, '001-git.md');
    });
  });

  group('content', () {
    test('is kept exactly as it was read', () {
      // A document written back with its line endings or its trailing
      // newline changed produces a diff the user did not make.
      const String source = '# Title\r\n\r\nBody\n\n';
      expect(documentAt('a.md', source).content, source);
    });
  });

  group('equality', () {
    // Built at runtime: const instances are canonicalised.
    test('compares by value', () {
      expect(documentAt('a.md', '# A'), documentAt('a.md', '# A'));
      expect(
        documentAt('a.md', '# A').hashCode,
        documentAt('a.md', '# A').hashCode,
      );
    });

    test('the same content at a different path is a different document', () {
      expect(documentAt('a.md', '# A'), isNot(documentAt('b.md', '# A')));
    });

    test('a changed body is a different document', () {
      expect(documentAt('a.md', '# A'), isNot(documentAt('a.md', '# B')));
    });
  });
}
