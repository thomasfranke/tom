/// The source after a formatting command, and where the caret went.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'formatted_source_value_object.freezed.dart';

/// The whole text and the selection inside it.
///
/// The selection travels with the text because a command that only handed
/// back a string would drop the caret to the top of the document: somebody
/// who bolds a word is still typing that sentence.
@freezed
abstract class FormattedSourceValueObject with _$FormattedSourceValueObject {
  /// A formatted document.
  const factory FormattedSourceValueObject({
    /// The whole source, not the changed part.
    required String text,

    /// Where the selection begins, as an offset into [text].
    required int start,

    /// Where it ends, exclusive; equal to [start] for a caret.
    required int end,
  }) = _FormattedSourceValueObject;

  const FormattedSourceValueObject._();

  /// Whether nothing is selected, which is a caret rather than a range.
  bool get isCaret => start == end;
}
