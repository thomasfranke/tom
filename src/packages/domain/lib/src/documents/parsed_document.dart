/// A document once it has been split into blocks.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block.dart';
import 'package:tom_domain/src/documents/document.dart';

part 'parsed_document.freezed.dart';

/// The blocks of a document, and the document scope they need to render.
///
/// A block is rendered on its own so the app owns the container around it,
/// which is what the rendered diff needs
/// ([flows](../../../../../../docs/technical/flows.md#the-preview-is-assembled-block-by-block)).
/// Rendering alone costs exactly one thing: link reference definitions are
/// declared at document scope, so they travel here.
@freezed
abstract class ParsedDocument with _$ParsedDocument {
  /// Creates a parsed document.
  const factory ParsedDocument({
    /// The document these blocks came from, source and all.
    required Document document,

    /// The top-level blocks, in document order.
    ///
    /// Handed over unmodifiable, never copied: Freezed compares collections
    /// element-wise and copies nothing.
    required List<Block> blocks,

    /// Every link reference definition in the document, as its own lines.
    ///
    /// What makes `[text][ref]` resolve in a block that does not hold the
    /// definition. **Footnotes do not survive the same way** and are M2's
    /// problem, with a failing case waiting in Decision 19.
    required String linkDefinitions,
  }) = _ParsedDocument;
}
