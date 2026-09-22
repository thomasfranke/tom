/// One block-level construct, as the parser found it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_infra/src/markdown_parser/markdown_span_kind.dart';

part 'markdown_span.freezed.dart';

/// Where a block-level construct sits in the text, and what it is.
///
/// Positions and a kind, never a parse tree: the package's node type dies
/// inside this capability, which is what lets a second implementation owe
/// the same answer. `Block` is the domain's word for this, and `tom_data`
/// is what turns one into the other.
@freezed
abstract class MarkdownSpan with _$MarkdownSpan {
  /// Creates a span.
  const factory MarkdownSpan({
    /// The first line of the construct, zero-based and inclusive.
    required int startLine,

    /// The last line of the construct, zero-based and inclusive.
    required int endLine,

    /// What kind of construct it is.
    required MarkdownSpanKind kind,
  }) = _MarkdownSpan;
}
