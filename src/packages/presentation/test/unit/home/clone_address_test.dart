import 'package:test/test.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  group('the folder a clone creates', () {
    for (final (String url, String? name) in <(String, String?)>[
      ('https://github.com/acme/handbook.git', 'handbook'),
      ('https://github.com/acme/handbook', 'handbook'),
      ('https://github.com/acme/handbook/', 'handbook'),
      ('git@github.com:acme/handbook.git', 'handbook'),
      ('git@github.com:handbook.git', 'handbook'),
      ('/work/remotes/docs.git', 'docs'),
      ('/work/remotes/docs/.git', 'docs'),
      (r'C:\remotes\docs.git', 'docs'),
      // Only the host left is what git names it too.
      ('https://github.com/', 'github.com'),
      ('/', null),
      ('.git', null),
    ]) {
      test('$url → $name', () {
        expect(cloneFolderNameOf(url), name);
      });
    }
  });

  group('the host an address points at', () {
    for (final (String url, String? host) in <(String, String?)>[
      ('https://github.com/acme/handbook.git', 'github.com'),
      ('ssh://git@gitlab.example.org/acme/handbook.git', 'gitlab.example.org'),
      ('git@github.com:acme/handbook.git', 'github.com'),
      ('/work/remotes/docs.git', null),
      ('file:///work/remotes/docs.git', null),
      (r'C:\remotes\docs.git', null),
    ]) {
      test('$url → $host', () {
        expect(cloneHostOf(url), host);
      });
    }
  });

  group('the destination', () {
    test('is the name inside the folder chosen', () {
      expect(cloneDestinationIn('/work', 'handbook'), '/work/handbook');
      expect(cloneDestinationIn('/work/', 'handbook'), '/work/handbook');
    });

    test('in the separator the folder is written in', () {
      expect(cloneDestinationIn(r'C:\work', 'handbook'), r'C:\work\handbook');
    });
  });
}
