/// One place in a document's text where the words being looked for are.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'occurrence_value_object.freezed.dart';

/// Where a match is, and what it reads.
///
/// It carries [matched] beside [start] so a replacement can check the text is
/// still what it was before writing: a position found before a keystroke has
/// moved, and writing at a stale one corrupts the document rather than
/// missing it (`docs/product/search/replacing/doc.md`).
@freezed
abstract class OccurrenceValueObject with _$OccurrenceValueObject {
  /// A match of [matched] starting at [start].
  const factory OccurrenceValueObject({
    /// Where it begins, as an offset into the whole text.
    required int start,

    /// What the text reads there — the match as found, in its own case.
    required String matched,

    /// Which line it is on, zero-based, for showing it in context.
    required int line,

    /// The nearest heading at or above it, without its hashes; empty when
    /// the match is above the document's first one.
    required String heading,

    /// The stretch of the line around the match, cut with `…` where it was
    /// cut, and holding [matched] itself at [excerptStart].
    required String excerpt,

    /// Where [matched] begins inside [excerpt], so the surface can colour it
    /// without searching the excerpt again — and without disagreeing with
    /// what was found.
    required int excerptStart,
  }) = _OccurrenceValueObject;

  const OccurrenceValueObject._();

  /// Where it ends, exclusive.
  int get end => start + matched.length;
}
