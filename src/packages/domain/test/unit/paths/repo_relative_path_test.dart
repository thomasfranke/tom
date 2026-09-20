import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('a path git would print is accepted', () {
    expect(
      RepoRelativePath('docs/product/README.md').value,
      'docs/product/README.md',
    );
  });

  test('name is the last segment', () {
    expect(RepoRelativePath('docs/product/README.md').name, 'README.md');
    expect(RepoRelativePath('README.md').name, 'README.md');
  });

  test('a space in a filename is ordinary', () {
    expect(RepoRelativePath.tryParse('release notes.md'), isNotNull);
  });

  test('two paths with the same text are the same path', () {
    expect(RepoRelativePath('a.md'), RepoRelativePath('a.md'));
  });

  group('tryParse refuses what is not repository-relative', () {
    test('empty', () => expect(RepoRelativePath.tryParse(''), isNull));

    test('an absolute POSIX path', () {
      // The bug this type exists to prevent: an absolute path standing in
      // for one git reported.
      expect(RepoRelativePath.tryParse('/Users/thf/space/a.md'), isNull);
    });

    test('a Windows separator, which git never prints', () {
      expect(RepoRelativePath.tryParse(r'docs\a.md'), isNull);
    });

    test('a Windows drive, which is absolute without a leading slash', () {
      expect(RepoRelativePath.tryParse('C:/space/a.md'), isNull);
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
        expect(RepoRelativePath.tryParse(escape), isNull, reason: escape);
      }
    });

    test('a current-directory segment, which git never prints', () {
      expect(RepoRelativePath.tryParse('./a.md'), isNull);
      expect(RepoRelativePath.tryParse('docs/./a.md'), isNull);
    });

    test('an empty segment, however it is spelled', () {
      // A trailing slash used to pass and left `name` empty.
      expect(RepoRelativePath.tryParse('docs/'), isNull);
      expect(RepoRelativePath.tryParse('docs//a.md'), isNull);
    });
  });

  test('a filename that merely starts with a dot is ordinary', () {
    // `..` is refused as a whole segment, not as a substring: a dotfile is a
    // real document and `a..b.md` is a real filename.
    expect(RepoRelativePath.tryParse('.gitignore'), isNotNull);
    expect(RepoRelativePath.tryParse('docs/a..b.md'), isNotNull);
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(() => RepoRelativePath('/absolute.md'), throwsArgumentError);
  });
}
