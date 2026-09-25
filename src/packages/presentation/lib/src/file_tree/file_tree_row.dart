/// One line of the file tree, as the panel draws it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'file_tree_row.freezed.dart';

/// An entry the tree is showing, with what drawing it needs.
///
/// View state, not domain: [SpaceEntryValueObject] says what the space
/// holds, this says where it lands on screen.
@freezed
abstract class FileTreeRow with _$FileTreeRow {
  /// Creates a row.
  const factory FileTreeRow({
    /// What the space holds here.
    required SpaceEntryValueObject entry,

    /// How far in it is drawn — 0 at the top level.
    ///
    /// Derived from the path rather than counted during the walk, so the
    /// walk cannot indent the tree wrongly.
    required int depth,

    /// Whether this is a folder whose contents are showing; false for a
    /// file.
    required bool isExpanded,
  }) = _FileTreeRow;

  const FileTreeRow._();

  /// Whether this row can be opened and closed.
  bool get isFolder => entry.type == SpaceEntryTypeEnum.directory;
}
