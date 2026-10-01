/// One footnote of a document: what it is called, what it says, and which.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'footnote_value_object.freezed.dart';

/// A note taken out of the prose, and the number that stands for it.
///
/// **Document scope, like the link definitions** — the reference and the note
/// are in different blocks, so a block rendered alone can resolve neither
/// without the document saying so
/// ([runtime](../../../../../../docs/technical/runtime/preview.md)).
///
/// It carries [number] rather than leaving it to whoever draws it, because
/// the number is a fact about the **document**: it is the order the notes are
/// first cited in, and a block cannot see the citations in other blocks.
@freezed
abstract class FootnoteValueObject with _$FootnoteValueObject {
  /// A footnote.
  const factory FootnoteValueObject({
    /// What the author called it — `a` in `[^a]`.
    ///
    /// Never shown: it is how the two halves find each other, and a reader
    /// sees [number] instead, which is what every markdown renderer draws.
    required String label,

    /// Which one it is, counting from one in citation order.
    required int number,

    /// What the note says, as markdown, without the `[^label]:` that
    /// introduced it.
    required String text,
  }) = _FootnoteValueObject;

  const FootnoteValueObject._();

  /// Whether the note has nothing to say, which a definition may have.
  bool get isEmpty => text.trim().isEmpty;
}
