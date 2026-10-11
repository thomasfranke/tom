/// [MarkdownPackageParserImpl] against documents nobody wrote for a test:
/// this repository's own `docs/`, and the inputs that break a parser —
/// Windows line endings, a fence never closed, nesting past the stack, a
/// megabyte on one line.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const MarkdownPackageParserImpl parser = MarkdownPackageParserImpl();

  /// The outline of [markdown], or a failed test.
  Future<MarkdownOutlineDto> outlineOf(String markdown) async {
    final Result<MarkdownOutlineDto, MarkdownParserFailure> result =
        await parser.outline(markdown);
    return switch (result) {
      Success<MarkdownOutlineDto, MarkdownParserFailure>(
        value: final MarkdownOutlineDto outline,
      ) =>
        outline,
      Failure<MarkdownOutlineDto, MarkdownParserFailure>(
        failure: final MarkdownParserFailure failure,
      ) =>
        fail('the parser failed: $failure'),
    };
  }

  /// Every span of [markdown] as `kind start..end`.
  Future<List<String>> spansOf(String markdown) async => <String>[
    for (final MarkdownSpanDto span in (await outlineOf(markdown)).spans)
      '${span.kind.name} ${span.startLine}..${span.endLine}',
  ];

  /// Holds [spans] to the contract's format over [markdown]: in document
  /// order, never overlapping, inside the line count, and neither starting
  /// nor ending on a blank line.
  void expectTheFormat(
    List<MarkdownSpanDto> spans,
    String markdown, {
    required String of,
  }) {
    final List<String> lines = markdown.split('\n');
    int previousEnd = -1;
    for (final MarkdownSpanDto span in spans) {
      final String where =
          '$of: ${span.kind.name} ${span.startLine}..${span.endLine}';
      expect(span.startLine, greaterThan(previousEnd), reason: where);
      expect(span.endLine, greaterThanOrEqualTo(span.startLine), reason: where);
      expect(span.endLine, lessThan(lines.length), reason: where);
      expect(lines[span.startLine].trim(), isNotEmpty, reason: where);
      expect(lines[span.endLine].trim(), isNotEmpty, reason: where);
      previousEnd = span.endLine;
    }
  }

  group('this repository\'s own documentation', () {
    // Found from wherever the suite was started: the package's folder, the
    // workspace's, or the repository's.
    Directory docs() {
      Directory at = Directory.current.absolute;
      while (true) {
        final Directory candidate = Directory('${at.path}/docs');
        if (File('${candidate.path}/about.md').existsSync() &&
            File('${at.path}/AGENTS.md').existsSync()) {
          return candidate;
        }
        if (at.parent.path == at.path) {
          fail('no docs/ above ${Directory.current.path}');
        }
        at = at.parent;
      }
    }

    List<File> corpus() =>
        docs()
            .listSync(recursive: true)
            .whereType<File>()
            .where((File file) => file.path.endsWith('.md'))
            .toList()
          ..sort((File a, File b) => a.path.compareTo(b.path));

    test('every document is outlined, none fails, and every outline keeps '
        'the format the contract promises', () async {
      final List<File> files = corpus();
      // A corpus that was not found must not pass as one that parsed.
      expect(files.length, greaterThan(50));

      int spans = 0;
      for (final File file in files) {
        final String markdown = file.readAsStringSync();
        final Result<MarkdownOutlineDto, MarkdownParserFailure> result =
            await parser.outline(markdown);

        expect(
          result,
          isA<Success<MarkdownOutlineDto, MarkdownParserFailure>>(),
          reason: file.path,
        );
        final MarkdownOutlineDto outline =
            (result as Success<MarkdownOutlineDto, MarkdownParserFailure>)
                .value;
        expectTheFormat(outline.spans, markdown, of: file.path);
        spans += outline.spans.length;
      }
      expect(spans, greaterThan(files.length));
    }, timeout: const Timeout(Duration(minutes: 3)));

    test('every document that is not empty opens on something, and a '
        'document that starts with a hash starts with a heading', () async {
      for (final File file in corpus()) {
        final String markdown = file.readAsStringSync();
        if (markdown.trim().isEmpty) {
          continue;
        }
        final List<MarkdownSpanDto> spans = (await outlineOf(markdown)).spans;

        expect(spans, isNotEmpty, reason: file.path);
        if (markdown.startsWith('# ')) {
          expect(spans.first.startLine, 0, reason: file.path);
          expect(
            spans.first.kind,
            MarkdownSpanKindEnum.heading,
            reason: file.path,
          );
        }
      }
    }, timeout: const Timeout(Duration(minutes: 3)));

    test(
      'no paragraph opens on a line that is a hash heading',
      () async {
        for (final File file in corpus()) {
          final String markdown = file.readAsStringSync();
          final List<String> lines = markdown.split('\n');
          for (final MarkdownSpanDto span in (await outlineOf(
            markdown,
          )).spans) {
            // Only what stands alone at the margin: a hash inside a list, a
            // quote or a fence is that block's text.
            if (span.kind != MarkdownSpanKindEnum.paragraph) {
              continue;
            }
            expect(
              lines[span.startLine],
              isNot(matches(RegExp(r'^#{1,6} \S'))),
              reason: '${file.path}:${span.startLine} is a paragraph',
            );
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });

  group('Windows line endings', () {
    const String unix =
        '# Title\n\nProse.\n\n- a\n- b\n\n'
        '| a | b |\n|---|---|\n| 1 | 2 |\n\n'
        '```\ncode\n```\n';

    test('a CRLF document has the outline of its LF version', () async {
      expect(await spansOf(unix.replaceAll('\n', '\r\n')), await spansOf(unix));
    });

    test('a CRLF document never fails, and its spans keep their '
        'order', () async {
      final String windows = unix.replaceAll('\n', '\r\n');

      final List<MarkdownSpanDto> spans = (await outlineOf(windows)).spans;

      expect(spans, isNotEmpty);
      int previousEnd = -1;
      for (final MarkdownSpanDto span in spans) {
        expect(span.startLine, greaterThan(previousEnd));
        expect(span.endLine, lessThan(windows.split('\n').length));
        previousEnd = span.endLine;
      }
    });
  });

  group('what a document can hold that is not prose', () {
    test('a fence never closed runs to the last line that says '
        'something', () async {
      expect(
        await spansOf('# T\n\n```dart\nvoid main() {}\n\nstill code\n\n'),
        <String>['heading 0..0', 'code 2..5'],
      );
    });

    test('an HTML comment across blank lines is one span, and the prose '
        'after it its own', () async {
      expect(await spansOf('<!-- a\n\nb\n-->\n\nProse.\n'), <String>[
        'html 0..3',
        'paragraph 5..5',
      ]);
    });

    test('a link written inside an HTML comment is not a link', () async {
      expect(
        (await outlineOf('<!--\n[[hidden]]\n-->\n\n[[seen]]\n')).wikilinks,
        <String>['seen'],
      );
    });

    test('front matter never fails, and the title under it is still a '
        'heading on its own line', () async {
      const String markdown = '---\ntitle: X\ntags: [a]\n---\n\n# Title\n';

      final List<MarkdownSpanDto> spans = (await outlineOf(markdown)).spans;

      expectTheFormat(spans, markdown, of: 'front matter');
      expect(spans.last.kind, MarkdownSpanKindEnum.heading);
      expect(spans.last.startLine, 5);
      expect(spans.last.endLine, 5);
    });

    test('a byte order mark before the first line never fails, and the '
        'lines keep their numbers', () async {
      final List<MarkdownSpanDto> spans = (await outlineOf(
        '﻿# Title\n\nProse.\n',
      )).spans;

      expect(spans.map((MarkdownSpanDto span) => span.startLine), <int>[0, 2]);
    });

    test('a wikilink is read in a heading, a list, a quote and a table '
        'cell, and each block is still one span', () async {
      const String markdown =
          '# About [[one]]\n\n'
          '- item [[two]]\n\n'
          '> quoted [[three]]\n\n'
          '| a | b |\n|---|---|\n| [[four]] | x |\n';

      final MarkdownOutlineDto outline = await outlineOf(markdown);

      expect(outline.wikilinks, <String>['one', 'two', 'three', 'four']);
      expect(
        outline.spans.map((MarkdownSpanDto span) => span.kind.name),
        <String>['heading', 'list', 'quote', 'table'],
      );
    });

    test('a note cited twice is one note, and a note of several lines '
        'keeps them', () async {
      final MarkdownOutlineDto outline = await outlineOf(
        'First[^a], again[^a], then[^b].\n\n'
        '[^a]: One line.\n'
        '[^b]: Two lines,\n    the second indented.\n',
      );

      expect(
        outline.footnotes.map(
          (MarkdownFootnoteDto note) => '${note.number} ${note.label}',
        ),
        <String>['1 a', '2 b'],
      );
      expect(outline.footnotes.first.text, 'One line.');
      expect(outline.footnotes.last.text, startsWith('Two lines,\n'));
      expect(outline.footnotes.last.text, endsWith('the second indented.'));
      // The definitions are scope: the prose is the only span.
      expect(outline.spans, hasLength(1));
    });
  });

  group('a document large enough to be slow', () {
    // Each bound is many times what a laptop takes; it is there for a
    // loaded CI machine, and what it guards is a parse that went quadratic.
    const Duration bound = Duration(seconds: 30);

    test('ten thousand lines are outlined inside half a minute, every '
        'block where it is', () async {
      final String markdown = <String>[
        for (int index = 0; index < 2500; index++) ...<String>[
          '## Heading $index',
          '',
          'Paragraph $index links to [[document $index]].',
          '',
        ],
      ].join('\n');

      final Stopwatch watch = Stopwatch()..start();
      final MarkdownOutlineDto outline = await outlineOf(markdown);
      watch.stop();

      expect(outline.spans, hasLength(5000));
      expect(outline.wikilinks, hasLength(2500));
      expect(outline.spans[4998].kind, MarkdownSpanKindEnum.heading);
      expect(outline.spans[4998].startLine, 9996);
      expect(outline.spans[4999].startLine, 9998);
      expectTheFormat(outline.spans, markdown, of: 'ten thousand lines');
      expect(watch.elapsed, lessThan(bound));
    });

    test('a megabyte of words on one line is one paragraph, inside half a '
        'minute', () async {
      final String markdown = 'word ' * 210000;
      expect(markdown.length, greaterThan(1 << 20));

      final Stopwatch watch = Stopwatch()..start();
      final List<String> spans = await spansOf(markdown);
      watch.stop();

      expect(spans, <String>['paragraph 0..0']);
      expect(watch.elapsed, lessThan(bound));
    });

    test('a megabyte on one line of a fence is one code span, inside half '
        'a minute', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<String> spans = await spansOf(
        '```\n${'x' * (1 << 20)}\n```\n',
      );
      watch.stop();

      expect(spans, <String>['code 0..2']);
      expect(watch.elapsed, lessThan(bound));
    });

    test('forty thousand characters with no space between them are one '
        'paragraph, inside five seconds', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<String> spans = await spansOf('x' * 40000);
      watch.stop();

      expect(spans, <String>['paragraph 0..0']);
      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    }, timeout: const Timeout(Duration(minutes: 10)));

    test('a megabyte of letters with no space is one paragraph too', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<String> spans = await spansOf('x' * (1 << 20));
      watch.stop();

      expect(spans, <String>['paragraph 0..0']);
      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    });

    test('a long run that something follows keeps what follows its own '
        'syntax', () async {
      final MarkdownOutlineDto outline = await outlineOf(
        '${'x' * 700}[[target]] after',
      );

      expect(outline.wikilinks, <String>['target']);
    });

    test('fifty thousand opening brackets with nothing to close them are '
        'text, and no link', () async {
      final Stopwatch watch = Stopwatch()..start();
      final MarkdownOutlineDto outline = await outlineOf('[[' * 50000);
      watch.stop();

      expect(outline.wikilinks, isEmpty);
      expect(outline.spans, hasLength(1));
      expect(watch.elapsed, lessThan(bound));
    });

    test('fifty thousand links on one line are fifty thousand '
        'links', () async {
      final Stopwatch watch = Stopwatch()..start();
      final MarkdownOutlineDto outline = await outlineOf('[[a]] ' * 50000);
      watch.stop();

      expect(outline.wikilinks, hasLength(50000));
      expect(outline.wikilinks.toSet(), <String>{'a'});
      expect(watch.elapsed, lessThan(bound));
    });
  });

  group('nesting', () {
    test('five hundred quotes inside one another are one quote', () async {
      expect(await spansOf('${'> ' * 500}deep\n'), <String>['quote 0..0']);
    });

    test(
      'five hundred lists inside one another are one list',
      () async {
        final String markdown = <String>[
          for (int depth = 0; depth < 500; depth++) '${'  ' * depth}- item',
        ].join('\n');

        expect(await spansOf(markdown), <String>['list 0..499']);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('five thousand quotes inside one another break the parser, and '
        'that is a failure — never a crash', () async {
      final Result<MarkdownOutlineDto, MarkdownParserFailure> result =
          await parser.outline('${'> ' * 5000}deep\n');

      expect(
        result,
        isA<Failure<MarkdownOutlineDto, MarkdownParserFailure>>().having(
          (Failure<MarkdownOutlineDto, MarkdownParserFailure> it) => it.failure,
          'failure',
          isA<MarkdownParserFailed>().having(
            (MarkdownParserFailed it) => it.description,
            'description',
            contains('Stack Overflow'),
          ),
        ),
      );
    });

    test(
      'and the parser that just failed outlines the next document',
      () async {
        await parser.outline('${'> ' * 5000}deep\n');

        expect(await spansOf('# Title\n\nProse.\n'), <String>[
          'heading 0..0',
          'paragraph 2..2',
        ]);
      },
    );
  });
}
