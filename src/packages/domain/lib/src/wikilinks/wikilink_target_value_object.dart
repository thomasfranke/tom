/// What a wikilink turned out to point at.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'wikilink_target_value_object.freezed.dart';

/// The answer to a lookup: one document, none, or too many.
///
/// Sealed rather than a nullable path, because **ambiguous is not missing**
/// and the preview draws the two differently — a name the space holds twice
/// is a question to the author, and picking one silently answers it wrong
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
@freezed
sealed class WikilinkTargetValueObject with _$WikilinkTargetValueObject {
  /// Exactly one document matched.
  const factory WikilinkTargetValueObject.resolved(
    /// Where it is, relative to the space root.
    SpaceRelativePathValueObject path,
  ) = WikilinkResolved;

  /// Nothing in the space matched.
  ///
  /// Ordinary rather than exceptional: a link is often written before the
  /// document it points at, and the product shows it as unresolved rather
  /// than refusing to render the page.
  const factory WikilinkTargetValueObject.missing() = WikilinkMissing;

  /// More than one document matched, and none of them is *the* answer.
  const factory WikilinkTargetValueObject.ambiguous(
    /// Every match, in the order the listing had them.
    List<SpaceRelativePathValueObject> candidates,
  ) = WikilinkAmbiguous;

  const WikilinkTargetValueObject._();

  /// Where to navigate, or null when there is nowhere to go.
  ///
  /// Ambiguous answers null: the choice belongs to whoever writes the link,
  /// not to whoever clicks it.
  SpaceRelativePathValueObject? get destination => switch (this) {
    WikilinkResolved(path: final SpaceRelativePathValueObject path) => path,
    WikilinkMissing() || WikilinkAmbiguous() => null,
  };
}
