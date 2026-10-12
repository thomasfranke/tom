/// Tests for the link check of `cli rules`, each over a small tree written
/// for it: the rule takes the root it is pointed at, so nothing here reads
/// this repository's own docs.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/rule.dart';
import '../../../tool/src/rules/link_rules.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('tom-links-');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  /// Writes [content] at [path] under the root, folders included.
  void write(String path, String content) {
    File('${root.path}/$path')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  List<Offence> check() => linksResolve(root).toList();

  group('linksResolve — files', () {
    test('holds when every link names a file that is there', () {
      write('docs/a.md', 'See [b](b.md), [up](../AGENTS.md) and [c](sub/).');
      write('docs/b.md', '# B');
      write('docs/sub/c.md', '# C');
      write('AGENTS.md', 'Read [a](docs/a.md).');

      expect(check(), isEmpty);
    });

    test('names the file, the line and the target of a link to nothing', () {
      write('docs/a.md', '# A\n\nA line.\nSee [gone](sub/gone.md) for more.');

      final List<Offence> found = check();

      expect(found, hasLength(1));
      expect(found.single.where, 'docs/a.md:4');
      expect(found.single.detail, contains('sub/gone.md'));
      expect(found.single.detail, contains('docs/sub/gone.md'));
    });

    test('reads the skills and the three files at the root', () {
      write('.ai/skills/one/SKILL.md', '[x](gone.md)');
      write('AGENTS.md', '[x](gone.md)');
      write('CONTRIBUTING.md', '[x](gone.md)');
      write('README.md', '[x](gone.md)');
      // Not part of the record: a note somebody keeps beside it.
      write('notes/scratch.md', '[x](gone.md)');

      expect(check().map((Offence offence) => offence.where), <String>[
        '.ai/skills/one/SKILL.md:1',
        'AGENTS.md:1',
        'CONTRIBUTING.md:1',
        'README.md:1',
      ]);
    });

    test('follows an image, a definition and an HTML attribute', () {
      write(
        'docs/a.md',
        '![shot](shots/a.svg)\n'
            '[label]: shots/b.svg\n'
            '<img src="shots/c.svg">\n'
            '[^1]: a footnote, which is text and not a target\n',
      );

      expect(check().map((Offence offence) => offence.where), <String>[
        'docs/a.md:1',
        'docs/a.md:2',
        'docs/a.md:3',
      ]);
    });

    test('does not ask the network, nor any address with a scheme', () {
      write(
        'docs/a.md',
        '[w](https://example.com/gone.md) [m](mailto:a@b.c) '
            '[h](http://example.com) [t](tel:+100)',
      );

      expect(check(), isEmpty);
    });

    test('skips what a fence or a code span holds', () {
      write(
        'docs/a.md',
        'Written as `[text](gone.md)`.\n'
            '\n'
            '```markdown\n'
            '[text](gone.md)\n'
            '```\n'
            '\n'
            '~~~~\n'
            '```\n'
            '[text](gone.md)\n'
            '~~~~\n'
            '[real](gone.md)\n',
      );

      expect(check().map((Offence offence) => offence.where), <String>[
        'docs/a.md:11',
      ]);
    });

    test('reads a title, angle brackets and an encoded space', () {
      write('docs/with space.md', '# S');
      write('docs/b.md', '# B');
      write(
        'docs/a.md',
        '[t](b.md "the title") [s](<with space.md>) [e](with%20space.md)',
      );

      expect(check(), isEmpty);
    });

    test('reads a leading slash from the repository root', () {
      write('docs/deep/a.md', '[c](/CONTRIBUTING.md) [g](/gone.md)');
      write('CONTRIBUTING.md', '# C');

      final List<Offence> found = check();

      expect(found, hasLength(1));
      expect(found.single.detail, contains('/gone.md'));
    });

    test('refuses a name spelled in another case', () {
      // macOS and Windows would find it; GitHub and the Linux runner do not.
      write('docs/Guide.md', '# G');
      write('docs/a.md', '[g](guide.md)');

      expect(check(), hasLength(1));
    });
  });

  group('linksResolve — headings', () {
    test('holds when the heading is there, in the file or in another', () {
      write(
        'docs/a.md',
        '# A\n\n## Open questions\n\n[here](#open-questions) [b](b.md#phases)',
      );
      write('docs/b.md', '# B\n\n## Phases\n');

      expect(check(), isEmpty);
    });

    test('names a heading the file does not have', () {
      write('docs/a.md', '[b](b.md#gone)\n[top](b.md#)');
      write('docs/b.md', '# B\n');

      final List<Offence> found = check();

      expect(found, hasLength(1));
      expect(found.single.where, 'docs/a.md:1');
      expect(found.single.rule, contains('heading'));
      expect(found.single.detail, contains('#gone'));
    });

    test('asks for no heading of a file that is not markdown', () {
      write('docs/a.md', '[l](code.dart#L10)');
      write('docs/code.dart', '// code');

      expect(check(), isEmpty);
    });
  });

  group('slugOf', () {
    test('spells a heading as GitHub does', () {
      expect(slugOf('Open questions'), 'open-questions');
      expect(
        slugOf('Non-goals (equally important)'),
        'non-goals-equally-important',
      );
      expect(
        slugOf('Skills — load on the matching trigger'),
        'skills--load-on-the-matching-trigger',
      );
      expect(slugOf('The `cli` tool'), 'the-cli-tool');
      expect(slugOf('See [the roadmap](roadmap.md)'), 'see-the-roadmap');
      expect(slugOf('Ação & reação'), 'ação--reação');
    });
  });

  group('anchorsIn', () {
    test('numbers a heading said twice', () {
      expect(
        anchorsIn(<String>['# Rules', '', '## Rules', '', '## Rules']),
        containsAll(<String>['rules', 'rules-1', 'rules-2']),
      );
    });

    test('reads a setext heading and an anchor written as HTML', () {
      expect(
        anchorsIn(<String>['Title', '=====', '', '<a id="Here"></a>']),
        containsAll(<String>['title', 'here']),
      );
    });

    test('takes no heading out of a fence', () {
      expect(anchorsIn(<String>['```', '# not one', '```']), isEmpty);
    });
  });

  group('splitTarget', () {
    test('answers null for what is not a place in the repository', () {
      expect(splitTarget('https://example.com'), isNull);
      expect(splitTarget('mailto:a@b.c'), isNull);
      expect(splitTarget(''), isNull);
    });

    test('separates the path from the heading and drops a query', () {
      expect(splitTarget('a.md#b'), (path: 'a.md', anchor: 'b'));
      expect(splitTarget('#b'), (path: '', anchor: 'b'));
      expect(splitTarget('a.svg?raw=1'), (path: 'a.svg', anchor: null));
    });
  });
}
