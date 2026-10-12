/// A heading the preview has been asked to bring into view.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'preview_anchor.freezed.dart';

/// The `#anchor` of a followed wikilink, waiting for [document] to be drawn.
///
/// Carries its document because the link is pressed in one document and the
/// heading lives in the next: the preview reads it only once that one is on
/// screen.
@freezed
abstract class PreviewAnchor with _$PreviewAnchor {
  /// [anchor], as written after the `#`, in [document].
  const factory PreviewAnchor({
    /// The document the heading is looked for in.
    required SpaceRelativePathValueObject document,

    /// What was written after the `#`.
    required String anchor,
  }) = _PreviewAnchor;
}
