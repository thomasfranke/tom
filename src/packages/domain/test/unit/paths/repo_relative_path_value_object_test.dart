import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('a path git would print is accepted', () {
    expect(
      RepoRelativePathValueObject('docs/product/README.md').value,
      'docs/product/README.md',
    );
  });

  test('name is the last segment', () {
    expect(
      RepoRelativePathValueObject('docs/product/README.md').name,
      'README.md',
    );
    expect(RepoRelativePathValueObject('README.md').name, 'README.md');
  });

  test('a space in a filename is ordinary', () {
    expect(RepoRelativePathValueObject.tryParse('release notes.md'), isNotNull);
  });

  test('two paths with the same text are the same path', () {
    expect(
      RepoRelativePathValueObject('a.md'),
      RepoRelativePathValueObject('a.md'),
    );
  });

  group('tryParse refuses what is not repository-relative', () {
    test(
      'empty',
      () => expect(RepoRelativePathValueObject.tryParse(''), isNull),
    );

    test('an absolute POSIX path', () {
      // The bug this type exists to prevent: an absolute path standing in
      // for one git reported.
      expect(
        RepoRelativePathValueObject.tryParse('/Users/thf/space/a.md'),
        isNull,
      );
    });

    test('a Windows separator, which git never prints', () {
      expect(RepoRelativePathValueObject.tryParse(r'docs\a.md'), isNull);
    });

    test('a Windows drive, which is absolute without a leading slash', () {
      expect(RepoRelativePathValueObject.tryParse('C:/space/a.md'), isNull);
    });

    test('a parent segment, which would leave the repository', () {
      // The guarantee the type carries: joined onto a repository root, it
      // cannot address anything outside it.
      for (final String escape in const <String>[
        '../secrets.env',
        '../../etc/passwd',
        'docs/../../outside.md',
        '..',
      ]) {
        expect(
          RepoRelativePathValueObject.tryParse(escape),
          isNull,
          reason: escape,
        );
      }
    });

    test('a current-directory segment, which git never prints', () {
      expect(RepoRelativePathValueObject.tryParse('./a.md'), isNull);
      expect(RepoRelativePathValueObject.tryParse('docs/./a.md'), isNull);
    });

    test('an empty segment, however it is spelled', () {
      // A trailing slash used to pass and left `name` empty.
      expect(RepoRelativePathValueObject.tryParse('docs/'), isNull);
      expect(RepoRelativePathValueObject.tryParse('docs//a.md'), isNull);
    });
  });

  test('a filename that merely starts with a dot is ordinary', () {
    // `..` is refused as a whole segment, not as a substring: a dotfile is a
    // real document and `a..b.md` is a real filename.
    expect(RepoRelativePathValueObject.tryParse('.gitignore'), isNotNull);
    expect(RepoRelativePathValueObject.tryParse('docs/a..b.md'), isNotNull);
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(
      () => RepoRelativePathValueObject('/absolute.md'),
      throwsArgumentError,
    );
  });
}
