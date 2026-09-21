/// One entry of a space's file tree.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path.dart';
import 'package:tom_domain/src/spaces/space_entry_type.dart';

part 'space_entry.freezed.dart';

/// A path the space holds, and what lives at it.
///
/// What the file tree is built from. Deliberately not a `Document`: a
/// listing knows where things are, not what is in them, and reading every
/// file of a space to draw its tree is the kind of work a documentation
/// repository cannot afford.
@freezed
abstract class SpaceEntry with _$SpaceEntry {
  /// Creates an entry.
  const factory SpaceEntry({
    /// Where it is, relative to the space root.
    required SpaceRelativePath path,

    /// What it is.
    required SpaceEntryType type,
  }) = _SpaceEntry;

  const SpaceEntry._();

  /// What the tree shows for this entry — the last segment.
  String get name => path.name;

  /// Whether this is a file the editor can open.
  ///
  /// A link is never one, however it is named: it may point outside the
  /// space, or at nothing at all, and the listing did not follow it to find
  /// out.
  bool get isDocument => type == SpaceEntryType.file && path.isMarkdown;
}
