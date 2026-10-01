/// One document the search found, and why it counts as a match.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'search_hit_value_object.freezed.dart';

/// A document that matched, and the stretch of it that did.
///
/// No score: the order the hits arrive in is the ranking, so nothing above
/// this has to agree with the index about what relevance is measured in.
@freezed
abstract class SearchHitValueObject with _$SearchHitValueObject {
  /// A hit.
  const factory SearchHitValueObject({
    /// Where the document is, relative to the space root.
    required SpaceRelativePathValueObject path,

    /// The matching stretch of its text, with `…` where it was cut.
    required String excerpt,
  }) = _SearchHitValueObject;

  const SearchHitValueObject._();

  /// The file's name, which is what a result row leads with.
  String get name => path.name;
}
