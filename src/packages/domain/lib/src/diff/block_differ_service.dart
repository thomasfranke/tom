/// Comparing two versions of a document, block by block.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/diff/block_aligner_port.dart';
import 'package:tom_domain/src/diff/diff_block_value_object.dart';
import 'package:tom_domain/src/diff/document_diff_value_object.dart';
import 'package:tom_domain/src/diff/sequence_edit_kind_enum.dart';
import 'package:tom_domain/src/diff/sequence_edit_value_object.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';

/// Two parsed versions in, classified blocks out.
///
/// A domain service rather than a port: the alignment is the seam under it
/// ([BlockAlignerPort]), but what counts as a *modified* block rather than a
/// removal standing beside an addition is the product's rule, and this is
/// where the product's rules live.
final class BlockDifferService {
  /// Creates a differ over [aligner].
  const BlockDifferService({required this.aligner});

  /// How the two block lists are lined up.
  final BlockAlignerPort aligner;

  /// How alike two blocks have to be to be the same block, rewritten.
  ///
  /// Half the text. Below that, calling it a modification asks the reader to
  /// diff two unrelated paragraphs in their head, and a removal beside an
  /// addition is the honest drawing. Blocks have **no identity** to fall
  /// back on — heading paths repeat ([Decision
  /// 19](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
  static const double pairingThreshold = 0.5;

  /// What changed from [before] to [after].
  ///
  /// Total: a document compared against itself is every block unchanged, and
  /// a document that is not in the old version at all is every block added —
  /// neither is a failure, and only a broken aligner is.
  Future<Result<DocumentDiffValueObject, DocumentFailure>> diff({
    required ParsedDocumentValueObject before,
    required ParsedDocumentValueObject after,
  }) => aligner
      .align(before, after, threshold: pairingThreshold)
      .map(
        (List<SequenceEditValueObject> edits) => DocumentDiffValueObject(
          before: before,
          after: after,
          blocks:
              List<DiffBlockValueObject>.unmodifiable(<DiffBlockValueObject>[
                for (final SequenceEditValueObject edit in edits)
                  _classify(edit, before, after),
              ]),
        ),
      );

  /// [edit] read back against the blocks it came from.
  ///
  /// The indices are the port's promise, so a null one here is a broken
  /// implementation rather than a state: better a crash the tests catch than
  /// a diff quietly missing a block.
  static DiffBlockValueObject _classify(
    SequenceEditValueObject edit,
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after,
  ) => switch (edit.kind) {
    SequenceEditKindEnum.equal => DiffBlockValueObject.unchanged(
      after.blocks[edit.afterIndex!],
    ),
    SequenceEditKindEnum.added => DiffBlockValueObject.added(
      after.blocks[edit.afterIndex!],
    ),
    SequenceEditKindEnum.removed => DiffBlockValueObject.removed(
      before.blocks[edit.beforeIndex!],
    ),
    SequenceEditKindEnum.changed => DiffBlockValueObject.modified(
      before: before.blocks[edit.beforeIndex!],
      after: after.blocks[edit.afterIndex!],
    ),
  };
}
