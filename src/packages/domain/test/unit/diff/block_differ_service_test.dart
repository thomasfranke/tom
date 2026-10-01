import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  /// A document whose blocks are [sources], one paragraph per line.
  ParsedDocumentValueObject documentOf(List<String> sources) =>
      ParsedDocumentValueObject(
        document: DocumentEntity(
          path: SpaceRelativePathValueObject('guides/writing.md'),
          content: sources.join('\n\n'),
        ),
        blocks: <BlockValueObject>[
          for (int index = 0; index < sources.length; index++)
            BlockValueObject(
              startLine: index * 2,
              endLine: index * 2,
              source: sources[index],
              kind: BlockKindEnum.paragraph,
            ),
        ],
        linkDefinitions: '',
      );

  /// One edit, spelled the way the aligner answers.
  SequenceEditValueObject editOf(
    SequenceEditKindEnum kind, {
    int? before,
    int? after,
  }) => SequenceEditValueObject(
    kind: kind,
    beforeIndex: before,
    afterIndex: after,
  );

  /// The diff of two documents over an aligner answering [edits].
  Future<DocumentDiffValueObject> diffOf(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after,
    List<SequenceEditValueObject> edits,
  ) async {
    final Result<DocumentDiffValueObject, DocumentFailure> result =
        await BlockDifferService(
          aligner: _Aligner(
            answer: Success<List<SequenceEditValueObject>, DocumentFailure>(
              edits,
            ),
          ),
        ).diff(before: before, after: after);
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

  group('what the alignment becomes', () {
    test('each verdict becomes its own kind of block', () async {
      final ParsedDocumentValueObject before = documentOf(<String>[
        'kept',
        'gone',
        'old wording',
      ]);
      final ParsedDocumentValueObject after = documentOf(<String>[
        'kept',
        'new wording',
        'arrived',
      ]);

      final DocumentDiffValueObject diff =
          await diffOf(before, after, <SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.removed, before: 1),
            editOf(SequenceEditKindEnum.changed, before: 2, after: 1),
            editOf(SequenceEditKindEnum.added, after: 2),
          ]);

      expect(diff.blocks, <Matcher>[
        isA<DiffBlockUnchanged>(),
        isA<DiffBlockRemoved>(),
        isA<DiffBlockModified>(),
        isA<DiffBlockAdded>(),
      ]);
    });

    test(
      'a removal carries the old block and an addition the new one',
      () async {
        final ParsedDocumentValueObject before = documentOf(<String>['gone']);
        final ParsedDocumentValueObject after = documentOf(<String>['arrived']);

        final DocumentDiffValueObject diff =
            await diffOf(before, after, <SequenceEditValueObject>[
              editOf(SequenceEditKindEnum.removed, before: 0),
              editOf(SequenceEditKindEnum.added, after: 0),
            ]);

        expect((diff.blocks.first as DiffBlockRemoved).block.source, 'gone');
        expect((diff.blocks.last as DiffBlockAdded).block.source, 'arrived');
      },
    );

    test('a modification carries both sides', () async {
      final ParsedDocumentValueObject before = documentOf(<String>['old']);
      final ParsedDocumentValueObject after = documentOf(<String>['new']);

      final DocumentDiffValueObject diff = await diffOf(
        before,
        after,
        <SequenceEditValueObject>[
          editOf(SequenceEditKindEnum.changed, before: 0, after: 0),
        ],
      );

      final DiffBlockModified block = diff.blocks.single as DiffBlockModified;
      expect(block.before.source, 'old');
      expect(block.after.source, 'new');
      expect(block.drawn.source, 'new');
    });

    test('both versions travel with the blocks', () async {
      final ParsedDocumentValueObject before = documentOf(<String>['a']);
      final ParsedDocumentValueObject after = documentOf(<String>['a']);

      final DocumentDiffValueObject diff = await diffOf(
        before,
        after,
        <SequenceEditValueObject>[
          editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
        ],
      );

      expect(diff.before, before);
      expect(diff.after, after);
    });
  });

  group('what the preview asks it', () {
    test('a document compared against itself changed nothing', () async {
      final ParsedDocumentValueObject document = documentOf(<String>[
        'one',
        'two',
      ]);

      final DocumentDiffValueObject diff =
          await diffOf(document, document, <SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.equal, before: 1, after: 1),
          ]);

      expect(diff.isUnchanged, isTrue);
      expect(
        diff.blocks.every((DiffBlockValueObject block) => !block.isChange),
        isTrue,
      );
    });

    test('one changed block is enough to stop being unchanged', () async {
      final ParsedDocumentValueObject before = documentOf(<String>['a', 'b']);
      final ParsedDocumentValueObject after = documentOf(<String>['a', 'c']);

      final DocumentDiffValueObject diff =
          await diffOf(before, after, <SequenceEditValueObject>[
            editOf(SequenceEditKindEnum.equal, before: 0, after: 0),
            editOf(SequenceEditKindEnum.changed, before: 1, after: 1),
          ]);

      expect(diff.isUnchanged, isFalse);
    });
  });

  group('the rule the service owns', () {
    test(
      'blocks are paired at half their text, and the aligner is told so',
      () async {
        final _Aligner aligner = _Aligner(
          answer: const Success<List<SequenceEditValueObject>, DocumentFailure>(
            <SequenceEditValueObject>[],
          ),
        );
        final ParsedDocumentValueObject document = documentOf(<String>[]);

        await BlockDifferService(
          aligner: aligner,
        ).diff(before: document, after: document);

        expect(aligner.threshold, BlockDifferService.pairingThreshold);
        expect(BlockDifferService.pairingThreshold, 0.5);
      },
    );

    test('an aligner that broke is reported, not swallowed', () async {
      final ParsedDocumentValueObject document = documentOf(<String>['a']);
      const DocumentFailure reported = DocumentOperationFailed(
        'guides/writing.md',
      );

      final Result<DocumentDiffValueObject, DocumentFailure> result =
          await BlockDifferService(
            aligner: _Aligner(
              answer:
                  const Failure<List<SequenceEditValueObject>, DocumentFailure>(
                    reported,
                  ),
            ),
          ).diff(before: document, after: document);

      expect(
        result,
        isA<Failure<DocumentDiffValueObject, DocumentFailure>>().having(
          (Failure<DocumentDiffValueObject, DocumentFailure> failed) =>
              failed.failure,
          'failure',
          reported,
        ),
      );
    });
  });
}

/// An aligner that answers what it was told to, and records what it was asked.
final class _Aligner implements BlockAlignerPort {
  _Aligner({required this.answer});

  final Result<List<SequenceEditValueObject>, DocumentFailure> answer;

  /// What the last caller asked two blocks to be worth.
  double? threshold;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async {
    this.threshold = threshold;
    return answer;
  }
}
