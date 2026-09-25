/// One entry of a space's file tree.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';
import 'package:tom_domain/src/spaces/space_entry_type_enum.dart';

part 'space_entry_value_object.freezed.dart';

/// A path the space holds, and what lives at it; the file tree's line.
///
/// Not a `DocumentEntity`: a listing knows where things are, not what is in
/// them, and reading every file to draw a tree is unaffordable.
@freezed
abstract class SpaceEntryValueObject with _$SpaceEntryValueObject {
  /// An entry.
  const factory SpaceEntryValueObject({
    /// Where it is, relative to the space root.
    required SpaceRelativePathValueObject path,

    /// What it is.
    required SpaceEntryTypeEnum type,
  }) = _SpaceEntryValueObject;

  const SpaceEntryValueObject._();

  /// The last segment, which is what the tree shows.
  String get name => path.name;

  /// Whether this is a file the editor can open.
  ///
  /// Never a link, however it is named: the listing did not follow it.
  bool get isDocument => type == SpaceEntryTypeEnum.file && path.isMarkdown;
}
