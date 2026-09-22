/// One entry of a space's file tree.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';
import 'package:tom_domain/src/spaces/space_entry_type_enum.dart';

part 'space_entry_value_object.freezed.dart';

/// A path the space holds, and what lives at it.
///
/// What the file tree is built from. Deliberately not a `DocumentEntity`: a
/// listing knows where things are, not what is in them, and reading every
/// file of a space to draw its tree is the kind of work a documentation
/// repository cannot afford.
@freezed
abstract class SpaceEntryValueObject with _$SpaceEntryValueObject {
  /// Creates an entry.
  const factory SpaceEntryValueObject({
    /// Where it is, relative to the space root.
    required SpaceRelativePathValueObject path,

    /// What it is.
    required SpaceEntryTypeEnum type,
  }) = _SpaceEntryValueObject;

  const SpaceEntryValueObject._();

  /// What the tree shows for this entry — the last segment.
  String get name => path.name;

  /// Whether this is a file the editor can open.
  ///
  /// A link is never one, however it is named: it may point outside the
  /// space, or at nothing at all, and the listing did not follow it to find
  /// out.
  bool get isDocument => type == SpaceEntryTypeEnum.file && path.isMarkdown;
}
