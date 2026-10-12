/// [BranchOverviewService] over a diff the real parser and the real differ
/// produced: the words, the blocks by kind and the reading time of a known
/// pair of versions, counted by hand below.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const BranchOverviewService overview = BranchOverviewService();
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
  const BlockDifferService differ = BlockDifferService(
    aligner: TextDifferBlockAlignerImpl(
      differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
    ),
  );

  /// The diff of two markdown texts of the document at [path].
  Future<DocumentDiffValueObject> diffOf(
    String before,
    String after, {
    String path = 'guides/writing.md',
  }) async {
    Future<ParsedDocumentValueObject> parsed(String markdown) async {
      final Result<ParsedDocumentValueObject, DocumentFailure> read =
          await reader.read(
            DocumentEntity(
              path: SpaceRelativePathValueObject(path),
              content: markdown,
            ),
          );
      return (read as Success<ParsedDocumentValueObject, DocumentFailure>)
          .value;
    }

    final Result<DocumentDiffValueObject, DocumentFailure> result = await differ
        .diff(before: await parsed(before), after: await parsed(after));
    return (result as Success<DocumentDiffValueObject, DocumentFailure>).value;
  }

  /// The overview of [diffs] alone: git's half is the repository's test.
  BranchOverviewValueObject summarised(List<DocumentDiffValueObject> diffs) =>
      overview.summarise(
        commits: const <CommitEntity>[],
        changes: const <BranchChangeValueObject>[],
        diffs: diffs,
      );

  const String before = '''
# Guide

Keep sentences short and plain.

- one
- two

Old closing words here.
''';

  const String after = '''
# Guide

Keep sentences short and readable.

- one
- two
- three

## New

Brand new paragraph of five.
''';

  test('a known pair of versions: the words that changed, the blocks by '
      'kind, and a minute to read', () async {
    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf(before, after),
    ]);

    // Gained: `readable`, `three`, `New`, and the five of the new
    // paragraph. Lost: `plain`, and the four of the old closing line.
    expect(read.wordsAdded, 8);
    expect(read.wordsRemoved, 5);
    // The paragraph rewritten, the one removed and the one added; the list
    // that grew; the heading that arrived. The title did not change.
    expect(read.blocks, <BlockKindEnum, int>{
      BlockKindEnum.paragraph: 3,
      BlockKindEnum.list: 1,
      BlockKindEnum.heading: 1,
    });
    expect(read.blocks.keys.first, BlockKindEnum.paragraph);
    expect(read.readingMinutes, 1);
  });

  test('a version against itself changed no word and takes no time', () async {
    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf(after, after),
    ]);

    expect(read.wordsAdded, 0);
    expect(read.wordsRemoved, 0);
    expect(read.blocks, isEmpty);
    expect(read.readingMinutes, 0);
  });

  test('markdown\'s marks are never words: a paragraph made bold, linked '
      'and fenced costs only what was typed', () async {
    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf(
        'Read the guide before the first commit.\n',
        'Read the **guide** before the [first](https://example.com) '
            'commit.\n',
      ),
    ]);

    // The address is three words to the counter — `https`, `example`,
    // `com` — and the asterisks and brackets are none.
    expect(read.wordsAdded, 3);
    expect(read.wordsRemoved, 0);
    expect(read.blocks, <BlockKindEnum, int>{BlockKindEnum.paragraph: 1});
  });

  test('a document that did not exist is every word added', () async {
    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf('', after),
    ]);

    // Guide · Keep sentences short and readable · one two three · New ·
    // Brand new paragraph of five.
    expect(read.wordsAdded, 15);
    expect(read.wordsRemoved, 0);
    expect(read.blocks, <BlockKindEnum, int>{
      BlockKindEnum.heading: 2,
      BlockKindEnum.paragraph: 2,
      BlockKindEnum.list: 1,
    });
  });

  test('two documents add up, and four hundred and fifty words are three '
      'minutes', () async {
    final String long = <String>[
      for (int paragraph = 0; paragraph < 9; paragraph++)
        List<String>.filled(50, 'word').join(' '),
    ].join('\n\n');

    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf('', long, path: 'guides/long.md'),
      await diffOf(after, after),
    ]);

    expect(read.wordsAdded, 450);
    expect(read.blocks, <BlockKindEnum, int>{BlockKindEnum.paragraph: 9});
    expect(read.readingMinutes, 3);
  });

  test('a code block deleted is counted as code, by the words it '
      'held', () async {
    final BranchOverviewValueObject read = summarised(<DocumentDiffValueObject>[
      await diffOf(
        '# Guide\n\n```dart\nfinal int answer = 42;\n```\n\nDone.\n',
        '# Guide\n\nDone.\n',
      ),
    ]);

    // dart · final · int · answer · 42.
    expect(read.wordsRemoved, 5);
    expect(read.wordsAdded, 0);
    expect(read.blocks, <BlockKindEnum, int>{BlockKindEnum.code: 1});
  });
}
