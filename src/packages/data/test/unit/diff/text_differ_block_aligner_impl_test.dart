import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  /// A document whose blocks are [sources].
  ParsedDocumentValueObject documentOf(List<String> sources) =>
      ParsedDocumentValueObject(
        document: DocumentEntity(
          path: SpaceRelativePathValueObject('guides/writing.md'),
          content: sources.join('\n\n'),
        ),
        blocks: <BlockValueObject>[
          for (int index = 0; index < sources.length; index++)
            BlockValueObject(
              startLine: index,
              endLine: index,
              source: sources[index],
              kind: BlockKindEnum.paragraph,
            ),
        ],
        linkDefinitions: '',
      );

  /// The aligner over a differ answering [answer].
  TextDifferBlockAlignerImpl alignerOf(
    Result<List<TextEditDto>, TextDifferFailure> answer, {
    _Differ? differ,
  }) => TextDifferBlockAlignerImpl(
    differ: TextDifferDataSource(differ: differ ?? _Differ(answer: answer)),
  );

  group('what crosses the contract', () {
    test('the differ is handed each block source, in order', () async {
      final _Differ differ = _Differ(
        answer: const Success<List<TextEditDto>, TextDifferFailure>(
          <TextEditDto>[],
        ),
      );

      await alignerOf(
        const Success<List<TextEditDto>, TextDifferFailure>(<TextEditDto>[]),
        differ: differ,
      ).align(
        documentOf(<String>['# Title', 'Prose.']),
        documentOf(<String>['# Title', 'More prose.']),
        threshold: 0.5,
      );

      expect(differ.before, <String>['# Title', 'Prose.']);
      expect(differ.after, <String>['# Title', 'More prose.']);
      expect(differ.threshold, 0.5);
    });

    test('each verdict arrives in the domain vocabulary', () async {
      final Result<List<SequenceEditValueObject>, DocumentFailure> result =
          await alignerOf(
            const Success<List<TextEditDto>, TextDifferFailure>(<TextEditDto>[
              TextEditDto(
                kind: TextEditKindEnum.equal,
                beforeIndex: 0,
                afterIndex: 0,
              ),
              TextEditDto(
                kind: TextEditKindEnum.changed,
                beforeIndex: 1,
                afterIndex: 1,
              ),
              TextEditDto(kind: TextEditKindEnum.removed, beforeIndex: 2),
              TextEditDto(kind: TextEditKindEnum.added, afterIndex: 2),
            ]),
          ).align(
            documentOf(<String>['a', 'b', 'c']),
            documentOf(<String>['a', 'B', 'd']),
            threshold: 0.5,
          );

      expect(
        (result as Success<List<SequenceEditValueObject>, DocumentFailure>)
            .value
            .map((SequenceEditValueObject edit) => edit.kind),
        <SequenceEditKindEnum>[
          SequenceEditKindEnum.equal,
          SequenceEditKindEnum.changed,
          SequenceEditKindEnum.removed,
          SequenceEditKindEnum.added,
        ],
      );
    });

    test('the positions cross untouched', () async {
      final Result<List<SequenceEditValueObject>, DocumentFailure> result =
          await alignerOf(
            const Success<List<TextEditDto>, TextDifferFailure>(<TextEditDto>[
              TextEditDto(kind: TextEditKindEnum.removed, beforeIndex: 3),
              TextEditDto(kind: TextEditKindEnum.added, afterIndex: 7),
            ]),
          ).align(
            documentOf(<String>['a']),
            documentOf(<String>['a']),
            threshold: 0.5,
          );

      final List<SequenceEditValueObject> edits =
          (result as Success<List<SequenceEditValueObject>, DocumentFailure>)
              .value;
      expect(edits.first.beforeIndex, 3);
      expect(edits.first.afterIndex, isNull);
      expect(edits.last.beforeIndex, isNull);
      expect(edits.last.afterIndex, 7);
    });
  });

  group('a differ that broke', () {
    test(
      'is the document on screen, failing in the product vocabulary',
      () async {
        const TextDifferFailure reported = TextDifferFailed('out of memory');

        final Result<List<SequenceEditValueObject>, DocumentFailure> result =
            await alignerOf(
              const Failure<List<TextEditDto>, TextDifferFailure>(reported),
            ).align(
              documentOf(<String>['a']),
              documentOf(<String>['b']),
              threshold: 0.5,
            );

        final DocumentFailure failure =
            (result as Failure<List<SequenceEditValueObject>, DocumentFailure>)
                .failure;
        expect(
          failure,
          const DocumentOperationFailed('guides/writing.md', cause: reported),
        );
        expect(failure.diagnostics, contains('out of memory'));
      },
    );
  });
}

/// A differ that answers what it was told to, and records what it was asked.
final class _Differ implements TextDiffer {
  _Differ({required this.answer});

  final Result<List<TextEditDto>, TextDifferFailure> answer;

  /// What the last caller handed over.
  List<String>? before;
  List<String>? after;
  double? threshold;

  @override
  Future<Result<List<TextEditDto>, TextDifferFailure>> align(
    List<String> before,
    List<String> after, {
    required double threshold,
  }) async {
    this.before = before;
    this.after = after;
    this.threshold = threshold;
    return answer;
  }
}
