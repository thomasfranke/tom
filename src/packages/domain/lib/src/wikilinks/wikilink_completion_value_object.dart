/// What `[[` offers while somebody is typing a link.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'wikilink_completion_value_object.freezed.dart';

/// The link being typed, and the documents it could become.
@freezed
abstract class WikilinkCompletionValueObject
    with _$WikilinkCompletionValueObject {
  /// A completion for [query], typed from [from] up to the caret.
  const factory WikilinkCompletionValueObject({
    /// Where the typed target starts: the first character after `[[`, so a
    /// choice replaces from here to the caret.
    required int from,

    /// What was typed after `[[`, as typed.
    required String query,

    /// The documents that match, best first.
    required List<WikilinkCandidateValueObject> candidates,
  }) = _WikilinkCompletionValueObject;
}

/// One document `[[` can offer, and what choosing it writes.
@freezed
abstract class WikilinkCandidateValueObject
    with _$WikilinkCandidateValueObject {
  /// [path], written as [target].
  const factory WikilinkCandidateValueObject({
    /// The document, relative to the space root.
    required SpaceRelativePathValueObject path,

    /// What goes between the brackets: the name when the space holds it
    /// once, the path when it holds it more than once — so what is written
    /// always resolves to the document that was chosen.
    required String target,
  }) = _WikilinkCandidateValueObject;
}
