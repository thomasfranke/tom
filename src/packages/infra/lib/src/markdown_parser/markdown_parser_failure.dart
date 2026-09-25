/// What parsing markdown can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'markdown_parser_failure.freezed.dart';

/// A parse that did not complete.
///
/// One variant, the fallback: markdown has no invalid input, so what is left
/// is a parser that broke, a bug and not a state the product has words for.
@freezed
sealed class MarkdownParserFailure
    with _$MarkdownParserFailure
    implements AppFailure {
  /// The parser threw.
  const factory MarkdownParserFailure.failed(
    /// What it reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = MarkdownParserFailed;
}
