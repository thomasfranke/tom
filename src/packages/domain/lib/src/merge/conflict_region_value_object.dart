/// One stretch of a document where git left both sides of a merge.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'conflict_region_value_object.freezed.dart';

/// Where a conflict is in the text, and what each side of it reads.
///
/// It carries the whole span — the three marker lines included — because
/// resolving is rewriting that span, and it carries the sides separately
/// because the preview renders them as markdown while the source shows the
/// markers as git wrote them
/// (`docs/product/editor/conflicted-document/doc.md`).
@freezed
abstract class ConflictRegionValueObject with _$ConflictRegionValueObject {
  /// A conflict spanning [start] to [end] in the document's text.
  const factory ConflictRegionValueObject({
    /// Where `<<<<<<<` begins, as an offset into the whole text.
    required int start,

    /// Where the line after `>>>>>>>` begins, exclusive.
    required int end,

    /// What the side already on this branch reads, without its markers.
    required String current,

    /// What the side being merged in reads, without its markers.
    required String incoming,

    /// What `<<<<<<<` names — usually `HEAD`, kept because git does not
    /// promise that and the label is the user's only clue which is which.
    required String currentLabel,

    /// What `>>>>>>>` names, normally the branch or commit being merged.
    required String incomingLabel,
  }) = _ConflictRegionValueObject;

  const ConflictRegionValueObject._();

  /// The text this region becomes when the current side is kept.
  String get keepingCurrent => current;

  /// The text this region becomes when the incoming side is kept.
  String get keepingIncoming => incoming;

  /// The text this region becomes when both are kept, current first.
  ///
  /// In the order the file already had them, because a merge that turns out
  /// not to be a disagreement is two additions and the earlier one came
  /// first.
  String get keepingBoth {
    if (current.isEmpty) {
      return incoming;
    }
    if (incoming.isEmpty) {
      return current;
    }
    return '$current\n$incoming';
  }
}
