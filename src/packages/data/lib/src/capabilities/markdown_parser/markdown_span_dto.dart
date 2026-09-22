/// One block-level construct, as the parser found it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_kind_enum.dart';

part 'markdown_span_dto.freezed.dart';

/// Where a block-level construct sits in the text, and what it is.
///
/// A DTO because it exists to cross the contract and is not a domain type
/// ([Decision
/// 21](../../../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md)):
/// the domain's word is `Block`, and this package may not name one.
///
/// Positions and a kind, never a parse tree — that is what lets a second
/// implementation owe the same answer.
@freezed
abstract class MarkdownSpanDto with _$MarkdownSpanDto {
  /// Creates a span.
  const factory MarkdownSpanDto({
    /// The first line of the construct, zero-based and inclusive.
    required int startLine,

    /// The last line of the construct, zero-based and inclusive.
    required int endLine,

    /// What kind of construct it is.
    required MarkdownSpanKindEnum kind,
  }) = _MarkdownSpanDto;
}
