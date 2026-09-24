/// What lines two versions of a document up, block against block.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/diff/sequence_edit_value_object.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';

/// Says which block of one version is which block of the other.
///
/// A port rather than a domain service: telling two texts apart is a
/// published algorithm, and an algorithm is infrastructure ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// `BlockDifferService` is the product's rule on top of it.
abstract interface class BlockAlignerPort {
  /// How the blocks of [before] and [after] line up, in reading order.
  ///
  /// The format, exactly: every block of both versions appears in exactly
  /// one edit; `equal` and `changed` carry both positions, `added` only its
  /// `afterIndex`, `removed` only its `beforeIndex`; a removal is placed
  /// where the block it names used to be.
  ///
  /// Two blocks pair when they are at least [threshold] alike, from 0 to 1.
  /// **The number is the caller's policy and what "alike" measures is the
  /// implementation's** — blocks carry no identity to pair them by
  /// ([Decision
  /// 19](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  });
}
