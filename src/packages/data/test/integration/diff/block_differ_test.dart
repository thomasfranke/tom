import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The rendered diff's core, over the real parser and the real differ.
///
/// Unit tests above hand the service an alignment; this one asks markdown
/// what it becomes — which is the only place the block granularity, the
/// pairing and the classification are answered together.
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

  /// [diff] as one word per block, which is what the assertions read.
  List<String> spelled(DocumentDiffValueObject diff) => <String>[
    for (final DiffBlockValueObject block in diff.blocks)
      switch (block) {
        DiffBlockUnchanged() => 'unchanged',
        DiffBlockAdded() => 'added',
        DiffBlockRemoved() => 'removed',
        DiffBlockModified() => 'modified',
      },
  ];

  const String document = '''
# Writing

Documentation is a product, and it is read far more often than it is
written.

## Style

Keep sentences short.

- One idea per bullet
- No nesting past two levels

Done.
''';

  group('a document against itself', () {
    test('shows no change at all', () async {
      final DocumentDiffValueObject diff = await diffOf(document, document);

      expect(diff.isUnchanged, isTrue);
      expect(spelled(diff), everyElement('unchanged'));
    });
  });

  group('an edit inside one block', () {
    test('is one modified block and nothing else', () async {
      final DocumentDiffValueObject diff = await diffOf(
        document,
        document.replaceAll('Keep sentences short.', 'Keep sentences shorter.'),
      );

      expect(
        diff.blocks.where((DiffBlockValueObject block) => block.isChange),
        hasLength(1),
      );
      final DiffBlockModified changed = diff.blocks
          .whereType<DiffBlockModified>()
          .single;
      expect(changed.before.source, 'Keep sentences short.');
      expect(changed.after.source, 'Keep sentences shorter.');
    });

    test(
      'a bullet added rewrites the whole list, because a list is one block',
      () async {
        final DocumentDiffValueObject diff = await diffOf(
          document,
          document.replaceAll(
            '- No nesting past two levels',
            '- No nesting past two levels\n- One link per claim',
          ),
        );

        // Granularity is top level (Decision 19): the list is the block, so an
        // added bullet is a modification of it rather than an added block.
        final DiffBlockModified changed = diff.blocks
            .whereType<DiffBlockModified>()
            .single;
        expect(changed.after.kind, BlockKindEnum.list);
        expect(changed.after.source, contains('One link per claim'));
      },
    );
  });

  group('blocks that arrived and went', () {
    test(
      'a new paragraph is added, and its neighbours are untouched',
      () async {
        final DocumentDiffValueObject diff = await diffOf(
          document,
          document.replaceAll(
            'Done.',
            'A paragraph nobody wrote before.\n\nDone.',
          ),
        );

        expect(
          diff.blocks.whereType<DiffBlockAdded>().single.block.source,
          'A paragraph nobody wrote before.',
        );
        expect(diff.blocks.whereType<DiffBlockRemoved>(), isEmpty);
        expect(diff.blocks.whereType<DiffBlockModified>(), isEmpty);
      },
    );

    test(
      'a deleted section is removed, and what went is still readable',
      () async {
        final DocumentDiffValueObject diff = await diffOf(
          document,
          document.replaceAll('## Style\n\nKeep sentences short.\n\n', ''),
        );

        // The removed blocks carry their own text, which is what lets the
        // preview draw a struck-through paragraph that is not on disk.
        expect(
          diff.blocks.whereType<DiffBlockRemoved>().map(
            (DiffBlockRemoved block) => block.block.source,
          ),
          <String>['## Style', 'Keep sentences short.'],
        );
      },
    );

    test('what went is drawn before what arrived', () async {
      final DocumentDiffValueObject diff = await diffOf(
        '# Title\n\nThe old opening paragraph, about one thing.\n',
        '# Title\n\nSomething else entirely, on another subject.\n',
      );

      expect(spelled(diff), <String>['unchanged', 'removed', 'added']);
    });
  });

  group('a document git has never seen', () {
    test('is every block added', () async {
      final DocumentDiffValueObject diff = await diffOf('', document);

      expect(diff.blocks, isNotEmpty);
      expect(spelled(diff), everyElement('added'));
      expect(diff.isUnchanged, isFalse);
    });
  });
}
