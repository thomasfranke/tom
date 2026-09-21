import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('SpaceRelativePath.tryParse', () {
    test('accepts a plain relative path', () {
      expect(SpaceRelativePath.tryParse('notes/a.md')?.value, 'notes/a.md');
    });

    test('refuses what would escape the space', () {
      // The reason the type exists: joined onto the space root, these reach
      // outside the folder the user opened.
      expect(SpaceRelativePath.tryParse('../secrets.md'), isNull);
      expect(SpaceRelativePath.tryParse('notes/../../x.md'), isNull);
      expect(SpaceRelativePath.tryParse('./a.md'), isNull);
    });

    test('refuses what is absolute in any spelling', () {
      expect(SpaceRelativePath.tryParse('/etc/passwd'), isNull);
      expect(SpaceRelativePath.tryParse(r'C:\notes\a.md'), isNull);
      expect(SpaceRelativePath.tryParse('C:/notes/a.md'), isNull);
    });

    test('refuses an empty segment, however it is spelled', () {
      expect(SpaceRelativePath.tryParse(''), isNull);
      expect(SpaceRelativePath.tryParse('notes//a.md'), isNull);
      expect(SpaceRelativePath.tryParse('notes/'), isNull);
    });

    test('refuses a backslash even in the middle', () {
      expect(SpaceRelativePath.tryParse(r'notes\a.md'), isNull);
    });
  });

  group('SpaceRelativePath()', () {
    test('throws on what tryParse refuses', () {
      expect(() => SpaceRelativePath('../a.md'), throwsArgumentError);
    });

    test('wraps what tryParse accepts', () {
      expect(SpaceRelativePath('a.md').value, 'a.md');
    });
  });

  group('name', () {
    test('is the last segment', () {
      expect(SpaceRelativePath('notes/deep/a.md').name, 'a.md');
      expect(SpaceRelativePath('a.md').name, 'a.md');
    });
  });

  group('isMarkdown', () {
    test('answers on the extension, whatever its case', () {
      expect(SpaceRelativePath('a.md').isMarkdown, isTrue);
      expect(SpaceRelativePath('a.MD').isMarkdown, isTrue);
      expect(SpaceRelativePath('notes/a.md').isMarkdown, isTrue);
    });

    test('is false for anything else', () {
      expect(SpaceRelativePath('a.txt').isMarkdown, isFalse);
      expect(SpaceRelativePath('md').isMarkdown, isFalse);
      expect(SpaceRelativePath('a.markdown').isMarkdown, isFalse);
    });
  });

  group('the two relative-path types do not mix', () {
    test('both accept the same syntax, from the same rule', () {
      expect(SpaceRelativePath.tryParse('notes/a.md'), isNotNull);
      expect(RepoRelativePath.tryParse('notes/a.md'), isNotNull);
      expect(SpaceRelativePath.tryParse('../a.md'), isNull);
      expect(RepoRelativePath.tryParse('../a.md'), isNull);
    });
  });
}
