/// What lines two versions of a document up, block against block.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/diff/sequence_edit_value_object.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';

/// Which block of one version is which block of the other.
///
/// A port rather than a domain service, because an alignment is a published
/// algorithm ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md));
/// `BlockDifferService` is the product's rule on top of it.
abstract interface class BlockAlignerPort {
  /// How the blocks of [before] and [after] line up, in reading order.
  ///
  /// The format: every block of both versions appears in exactly one edit;
  /// `equal` and `changed` carry both positions, `added` only `afterIndex`,
  /// `removed` only `beforeIndex`, placed where the block used to be. Two
  /// blocks pair when at least [threshold] (0 to 1) alike; the number is the
  /// caller's policy and what "alike" measures is the implementation's.
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  });
}
