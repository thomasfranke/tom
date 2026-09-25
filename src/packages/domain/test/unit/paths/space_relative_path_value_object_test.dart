import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('SpaceRelativePathValueObject.tryParse', () {
    test('accepts a plain relative path', () {
      expect(
        SpaceRelativePathValueObject.tryParse('notes/a.md')?.value,
        'notes/a.md',
      );
    });

    test('refuses what would escape the space', () {
      expect(SpaceRelativePathValueObject.tryParse('../secrets.md'), isNull);
      expect(SpaceRelativePathValueObject.tryParse('notes/../../x.md'), isNull);
      expect(SpaceRelativePathValueObject.tryParse('./a.md'), isNull);
    });

    test('refuses what is absolute in any spelling', () {
      expect(SpaceRelativePathValueObject.tryParse('/etc/passwd'), isNull);
      expect(SpaceRelativePathValueObject.tryParse(r'C:\notes\a.md'), isNull);
      expect(SpaceRelativePathValueObject.tryParse('C:/notes/a.md'), isNull);
    });

    test('refuses an empty segment, however it is spelled', () {
      expect(SpaceRelativePathValueObject.tryParse(''), isNull);
      expect(SpaceRelativePathValueObject.tryParse('notes//a.md'), isNull);
      expect(SpaceRelativePathValueObject.tryParse('notes/'), isNull);
    });

    test('refuses a backslash even in the middle', () {
      expect(SpaceRelativePathValueObject.tryParse(r'notes\a.md'), isNull);
    });
  });

  group('SpaceRelativePathValueObject()', () {
    test('throws on what tryParse refuses', () {
      expect(
        () => SpaceRelativePathValueObject('../a.md'),
        throwsArgumentError,
      );
    });

    test('wraps what tryParse accepts', () {
      expect(SpaceRelativePathValueObject('a.md').value, 'a.md');
    });
  });

  group('name', () {
    test('is the last segment', () {
      expect(SpaceRelativePathValueObject('notes/deep/a.md').name, 'a.md');
      expect(SpaceRelativePathValueObject('a.md').name, 'a.md');
    });
  });

  group('isMarkdown', () {
    test('answers on the extension, whatever its case', () {
      expect(SpaceRelativePathValueObject('a.md').isMarkdown, isTrue);
      expect(SpaceRelativePathValueObject('a.MD').isMarkdown, isTrue);
      expect(SpaceRelativePathValueObject('notes/a.md').isMarkdown, isTrue);
    });

    test('is false for anything else', () {
      expect(SpaceRelativePathValueObject('a.txt').isMarkdown, isFalse);
      expect(SpaceRelativePathValueObject('md').isMarkdown, isFalse);
      expect(SpaceRelativePathValueObject('a.markdown').isMarkdown, isFalse);
    });
  });

  group('resolve', () {
    final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
      'guides/writing.md',
    );

    test('reads a sibling from the document\'s own folder', () {
      expect(writing.resolve('reviewing.md')?.value, 'guides/reviewing.md');
      expect(writing.resolve('./reviewing.md')?.value, 'guides/reviewing.md');
    });

    test('climbs with .. and stays inside the space', () {
      expect(writing.resolve('../about.md')?.value, 'about.md');
      expect(writing.resolve('../adr/001.md')?.value, 'adr/001.md');
      expect(
        writing.resolve('sub/../reviewing.md')?.value,
        'guides/reviewing.md',
      );
    });

    test('starts from the root for a reference that says so', () {
      expect(writing.resolve('/adr/001.md')?.value, 'adr/001.md');
    });

    test('answers null for a reference that leaves the space', () {
      expect(writing.resolve('../../secret.md'), isNull);
      expect(writing.resolve('/../secret.md'), isNull);
    });

    test('a bare . or nothing at all is the document\'s own folder', () {
      expect(writing.resolve('.')?.value, 'guides');
      expect(writing.resolve('')?.value, 'guides');
    });

    test('answers null for what is not a path at all', () {
      expect(writing.resolve(r'..\a.md'), isNull);
    });

    test('works from a document at the root', () {
      final SpaceRelativePathValueObject readme = SpaceRelativePathValueObject(
        'README.md',
      );
      expect(readme.resolve('guides/writing.md')?.value, 'guides/writing.md');
      expect(readme.resolve('../x.md'), isNull);
    });
  });

  group('the two relative-path types do not mix', () {
    test('both accept the same syntax, from the same rule', () {
      expect(SpaceRelativePathValueObject.tryParse('notes/a.md'), isNotNull);
      expect(RepoRelativePathValueObject.tryParse('notes/a.md'), isNotNull);
      expect(SpaceRelativePathValueObject.tryParse('../a.md'), isNull);
      expect(RepoRelativePathValueObject.tryParse('../a.md'), isNull);
    });
  });
}
