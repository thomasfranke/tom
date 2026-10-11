import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The rendered diff over the real parser and the real differ, on what real
/// documents do to it: line endings, a section moved, a fence deleted, a
/// table, a footnote, and a document long enough to be slow.
void main() {
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
  const BlockDifferService differ = BlockDifferService(
    aligner: TextDifferBlockAlignerImpl(
      differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
    ),
  );

  /// [markdown] split into blocks, or the test failing.
  Future<ParsedDocumentValueObject> parsed(String markdown) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> result =
        await reader.read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guides/writing.md'),
            content: markdown,
          ),
        );
    return switch (result) {
      Success<ParsedDocumentValueObject, DocumentFailure>(
        value: final ParsedDocumentValueObject document,
      ) =>
        document,
      Failure<ParsedDocumentValueObject, DocumentFailure>(
        failure: final DocumentFailure failure,
      ) =>
        fail('parsing failed: ${failure.diagnostics}'),
    };
  }

  /// The diff of two markdown texts.
  Future<DocumentDiffValueObject> diffOf(String before, String after) async {
    final Result<DocumentDiffValueObject, DocumentFailure> result = await differ
        .diff(before: await parsed(before), after: await parsed(after));
    return switch (result) {
      Success<DocumentDiffValueObject, DocumentFailure>(
        value: final DocumentDiffValueObject diff,
      ) =>
        diff,
      Failure<DocumentDiffValueObject, DocumentFailure>(
        failure: final DocumentFailure failure,
      ) =>
        fail('diffing failed: ${failure.diagnostics}'),
    };
  }

  /// [diff] as `verdict kind` per block, which is what the assertions read.
  List<String> spelled(DocumentDiffValueObject diff) => <String>[
    for (final DiffBlockValueObject block in diff.blocks)
      switch (block) {
        DiffBlockUnchanged() => 'unchanged ${block.drawn.kind.name}',
        DiffBlockAdded() => 'added ${block.drawn.kind.name}',
        DiffBlockRemoved() => 'removed ${block.drawn.kind.name}',
        DiffBlockModified() => 'modified ${block.drawn.kind.name}',
      },
  ];

  /// The blocks of [diff] that carry a mark.
  Iterable<DiffBlockValueObject> changesOf(DocumentDiffValueObject diff) =>
      diff.blocks.where((DiffBlockValueObject block) => block.isChange);

  const String document = '''
# Writing

Documentation is a product, and it is read far more often than it is
written.[^often]

## Style

Keep sentences short.

| Rule | Why |
|---|---|
| Short sentences | They are read |
| One idea a bullet | They are scanned |

## Example

```dart
final int answer = 42;
```

Done.

[^often]: Measured on this repository's own history.
''';

  /// [text] with every line ending as Windows writes it.
  String crlf(String text) => text.replaceAll('\n', '\r\n');

  group('line endings', () {
    // Decision #50 (D-34): a document committed in LF and on disk in CRLF
    // says the same thing, and the diff ignores the difference.
    test('the same text in CRLF and in LF shows no change at all', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        crlf(document),
      );

      expect(spelled(diff), everyElement(startsWith('unchanged')));
      expect(diff.isUnchanged, isTrue);
    });

    test('a CRLF document against itself shows no change at all', () async {
      final DocumentDiffValueObject diff = await diffOf(
        crlf(document),
        crlf(document),
      );

      expect(diff.isUnchanged, isTrue);
    });

    test('a CRLF document is cut into the blocks its LF version has', () async {
      final ParsedDocumentValueObject windows = await parsed(crlf(document));
      final ParsedDocumentValueObject unix = await parsed(document);

      expect(
        <String>[
          for (final BlockValueObject block in windows.blocks)
            '${block.kind.name} ${block.startLine}..${block.endLine}',
        ],
        <String>[
          for (final BlockValueObject block in unix.blocks)
            '${block.kind.name} ${block.startLine}..${block.endLine}',
        ],
      );
    });

    test(
      'one paragraph edited in a CRLF document is one modified block',
      () async {
        final DocumentDiffValueObject diff = await diffOf(
          crlf(document),
          crlf(document).replaceAll('sentences short.', 'sentences shorter.'),
        );

        expect(changesOf(diff), hasLength(1));
        final DiffBlockModified changed = diff.blocks
            .whereType<DiffBlockModified>()
            .single;
        expect(changed.after.source.trimRight(), 'Keep sentences shorter.');
        expect(changed.after.kind, BlockKindEnum.paragraph);
      },
    );

    test('a final newline removed is no change', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.trimRight(),
      );

      expect(diff.isUnchanged, isTrue);
    });
  });

  group('a section moved', () {
    test('is removed where it was and added where it went, and nothing '
        'between the two is touched', () async {
      const String style =
          '## Style\n\nKeep sentences short.\n\n'
          '| Rule | Why |\n|---|---|\n'
          '| Short sentences | They are read |\n'
          '| One idea a bullet | They are scanned |\n\n';
      final String moved = document
          .replaceFirst(style, '')
          .replaceFirst('Done.\n', 'Done.\n\n$style');
      expect(moved, isNot(document), reason: 'the fixture moved nothing');

      final DocumentDiffValueObject diff = await diffOf(document, moved);

      expect(spelled(diff), <String>[
        'unchanged heading',
        'unchanged paragraph',
        'removed heading',
        'removed paragraph',
        'removed table',
        'unchanged heading',
        'unchanged code',
        'unchanged paragraph',
        'added heading',
        'added paragraph',
        'added table',
      ]);
    });
  });

  group('a code block deleted', () {
    test('is one removed block, fences and all, and its neighbours '
        'stay', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceFirst('```dart\nfinal int answer = 42;\n```\n\n', ''),
      );

      expect(changesOf(diff), hasLength(1));
      final DiffBlockRemoved removed = diff.blocks
          .whereType<DiffBlockRemoved>()
          .single;
      expect(removed.block.kind, BlockKindEnum.code);
      expect(removed.block.source, '```dart\nfinal int answer = 42;\n```');
      // Where it used to be: after the heading it stood under.
      final int at = diff.blocks.indexOf(removed);
      expect(diff.blocks[at - 1].drawn.source, '## Example');
      expect(diff.blocks[at + 1].drawn.source, 'Done.');
    });
  });

  group('a table', () {
    test('with one row edited is one modified block, the whole '
        'table', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceFirst('They are scanned', 'They are skimmed'),
      );

      expect(changesOf(diff), hasLength(1));
      final DiffBlockModified changed = diff.blocks
          .whereType<DiffBlockModified>()
          .single;
      expect(changed.after.kind, BlockKindEnum.table);
      expect(changed.before.source, contains('They are scanned'));
      expect(changed.after.source, contains('They are skimmed'));
      expect(changed.after.source, startsWith('| Rule | Why |'));
    });

    test('with a row added is still that one block, modified', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceFirst(
          '| One idea a bullet | They are scanned |\n',
          '| One idea a bullet | They are scanned |\n'
              '| No jargon | It is looked up |\n',
        ),
      );

      expect(
        spelled(diff).where((String it) => !it.startsWith('unchanged')),
        <String>['modified table'],
      );
    });
  });

  group('a footnote', () {
    test('rewritten reaches both versions with its own text, and marks no '
        'block', () async {
      // Decision 31: a note's text is in the model and produces no block,
      // so the diff carries both readings and decorates neither.
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceFirst(
          "Measured on this repository's own history.",
          'Counted over a year of commits.',
        ),
      );

      expect(
        diff.before.footnotes.single.text,
        "Measured on this repository's own history.",
      );
      expect(
        diff.after.footnotes.single.text,
        'Counted over a year of commits.',
      );
      expect(diff.isUnchanged, isTrue);
    });

    test('whose marker is taken out of the prose is that paragraph '
        'modified', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceFirst('written.[^often]', 'written.'),
      );

      expect(
        spelled(diff).where((String it) => !it.startsWith('unchanged')),
        <String>['modified paragraph'],
      );
    });
  });

  group('a long document', () {
    test('two thousand blocks with every other one rewritten are each '
        'paired with themselves, inside half a minute', () async {
      String paragraph(int index, {required bool rewritten}) =>
          'Paragraph number $index explains the rule called rule$index '
          'in ${rewritten ? 'new' : 'plain'} words.';
      final String before = <String>[
        for (int index = 0; index < 2000; index++)
          paragraph(index, rewritten: false),
      ].join('\n\n');
      final String after = <String>[
        for (int index = 0; index < 2000; index++)
          paragraph(index, rewritten: index.isOdd),
      ].join('\n\n');

      final Stopwatch watch = Stopwatch()..start();
      final DocumentDiffValueObject diff = await diffOf(before, after);
      watch.stop();

      expect(diff.blocks, hasLength(2000));
      for (int index = 0; index < 2000; index++) {
        expect(
          diff.blocks[index],
          index.isOdd ? isA<DiffBlockModified>() : isA<DiffBlockUnchanged>(),
          reason: 'block $index',
        );
      }
      // A second on a laptop; the bound is for a loaded CI machine, and
      // what it guards is an alignment that went quadratic.
      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });
  });
}
