/// The domain's line alignment contract, fulfilled by the text-diff
/// capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_dto.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_kind_enum.dart';
import 'package:tom_data/src/diff/text_differ_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [LineAlignerPort] over [TextDifferDataSource]: the lines go to the differ
/// as they are, and positions come back as the domain's edits.
final class TextDifferLineAlignerImpl implements LineAlignerPort {
  /// Creates an aligner over [differ].
  const TextDifferLineAlignerImpl({required this.differ});

  /// Where the alignment comes from.
  final TextDifferDataSource differ;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  }) => differ
      .align(before, after, threshold: threshold)
      .map(
        (List<TextEditDto> edits) => List<SequenceEditValueObject>.unmodifiable(
          <SequenceEditValueObject>[
            for (final TextEditDto edit in edits)
              SequenceEditValueObject(
                kind: switch (edit.kind) {
                  TextEditKindEnum.equal => SequenceEditKindEnum.equal,
                  TextEditKindEnum.changed => SequenceEditKindEnum.changed,
                  TextEditKindEnum.added => SequenceEditKindEnum.added,
                  TextEditKindEnum.removed => SequenceEditKindEnum.removed,
                },
                beforeIndex: edit.beforeIndex,
                afterIndex: edit.afterIndex,
              ),
          ],
        ),
      )
      .mapFailure(
        (TextDifferFailure failure) => switch (failure) {
          TextDifferFailed() => DocumentOperationFailed(
            path.value,
            cause: failure,
          ),
        },
      );
}
