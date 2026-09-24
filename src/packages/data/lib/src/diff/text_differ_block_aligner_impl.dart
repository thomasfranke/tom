/// The domain's alignment contract, fulfilled by the text-diff capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_dto.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_kind_enum.dart';
import 'package:tom_data/src/diff/text_differ_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [BlockAlignerPort] over [TextDifferDataSource].
///
/// Two translations and nothing else. Blocks into the text the differ
/// compares — **a block's own source, nothing derived** — and positions back
/// into the domain's edits, which is why the capability never has to know
/// what a block is.
final class TextDifferBlockAlignerImpl implements BlockAlignerPort {
  /// Creates an aligner over [differ].
  const TextDifferBlockAlignerImpl({required this.differ});

  /// Where the alignment comes from.
  final TextDifferDataSource differ;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) => differ
      .align(_sourcesOf(before), _sourcesOf(after), threshold: threshold)
      .map(
        (List<TextEditDto> edits) => List<SequenceEditValueObject>.unmodifiable(
          <SequenceEditValueObject>[
            for (final TextEditDto edit in edits) _asSequenceEdit(edit),
          ],
        ),
      )
      .mapFailure(
        (TextDifferFailure failure) =>
            _asDocumentFailure(failure, after.document.path),
      );

  /// The text the differ compares: one entry per block, in order.
  static List<String> _sourcesOf(ParsedDocumentValueObject document) =>
      <String>[
        for (final BlockValueObject block in document.blocks) block.source,
      ];

  /// The same edit, in the domain's vocabulary.
  ///
  /// One to one today, and still written out: the two enums answer to
  /// different owners, and the day a differ reports something the domain has
  /// no word for, this is where the compiler says so.
  static SequenceEditValueObject _asSequenceEdit(TextEditDto edit) =>
      SequenceEditValueObject(
        kind: switch (edit.kind) {
          TextEditKindEnum.equal => SequenceEditKindEnum.equal,
          TextEditKindEnum.changed => SequenceEditKindEnum.changed,
          TextEditKindEnum.added => SequenceEditKindEnum.added,
          TextEditKindEnum.removed => SequenceEditKindEnum.removed,
        },
        beforeIndex: edit.beforeIndex,
        afterIndex: edit.afterIndex,
      );

  /// What the capability reported, about the document on screen.
  ///
  /// Exhaustive over [TextDifferFailure] with no default branch. A differ
  /// that broke is not something the product has words for, so it lands on
  /// the fallback rather than being dressed up as a file problem.
  static DocumentFailure _asDocumentFailure(
    TextDifferFailure failure,
    SpaceRelativePathValueObject path,
  ) => switch (failure) {
    TextDifferFailed() => DocumentOperationFailed(path.value, cause: failure),
  };
}
