/// One document the index matched.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_hit_dto.freezed.dart';

/// The key that matched, and the stretch of text that made it match.
///
/// No score: the order the hits arrive in *is* the ranking, so nothing above
/// this has to know what the index measures relevance in.
@freezed
abstract class SearchHitDto with _$SearchHitDto {
  /// Creates a hit.
  const factory SearchHitDto({
    /// The key the document was indexed under.
    required String key,

    /// The matching stretch of the text, with `…` where it was cut.
    required String excerpt,
  }) = _SearchHitDto;
}
