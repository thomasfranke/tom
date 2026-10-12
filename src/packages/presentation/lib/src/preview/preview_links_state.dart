/// What the wikilinks of the document on screen point at.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'preview_links_state.freezed.dart';

/// Each wikilink of the previewed document, and its answer.
///
/// Asked by the link as written, so a surface that meets `[[…]]` in a block
/// reads it with `WikilinkValueObject.tryParse` and looks it up here — the
/// answer depends on the link and the space, never on where it sits.
@freezed
abstract class PreviewLinksState with _$PreviewLinksState {
  /// The answers, empty until the document and the space's listing are both
  /// read.
  const factory PreviewLinksState({
    /// Every distinct link of the document, with what it points at.
    @Default(<WikilinkValueObject, WikilinkTargetValueObject>{})
    Map<WikilinkValueObject, WikilinkTargetValueObject> targets,
  }) = _PreviewLinksState;

  const PreviewLinksState._();

  /// What [link] points at, or null when nothing is known about it yet.
  ///
  /// Null is not missing: a link drawn as broken while the listing is still
  /// being read would flash red on every space that opens.
  WikilinkTargetValueObject? targetOf(WikilinkValueObject link) =>
      targets[link];
}
