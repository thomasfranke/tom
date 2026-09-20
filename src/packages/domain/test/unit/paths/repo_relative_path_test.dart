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
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(() => RepoRelativePath('/absolute.md'), throwsArgumentError);
  });
}
