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
/// A domain service rather than a port: what counts as a *modified* block
/// rather than a removal beside an addition is the product's rule, and the
/// alignment under it is [BlockAlignerPort]'s.
final class BlockDifferService {
  /// A differ over [aligner].
  const BlockDifferService({required this.aligner});

  /// How the two block lists are lined up.
  final BlockAlignerPort aligner;

  /// How alike two blocks have to be to be the same block, rewritten.
  ///
  /// Half the text; below that a removal beside an addition is the honest
  /// drawing, and blocks carry no identity to fall back on ([Decision
  /// 19](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
  static const double pairingThreshold = 0.5;

  /// What changed from [before] to [after].
  ///
  /// Total: a document against itself is every block unchanged, a document
  /// absent from the old version is every block added; only a broken aligner
  /// fails.
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
  /// The indices are the port's promise, so a null one is a broken
  /// implementation rather than a state, and a crash beats a missing block.
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
