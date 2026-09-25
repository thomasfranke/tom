/// A space the user opened before.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_space_entity.freezed.dart';

/// One entry in Home's recent list.
///
/// Not a `SpaceEntity`: that carries `repositoryRoot`, which means asking git
/// for every row of a list the user may not click, and this one must survive
/// its folder going away so Home can offer to forget it
/// (`docs/product/home/doc.md`).
@freezed
abstract class RecentSpaceEntity with _$RecentSpaceEntity {
  /// An entry.
  const factory RecentSpaceEntity({
    /// The absolute path of the folder that was opened; its identity.
    required String root,

    /// What it was called the last time it was open.
    ///
    /// Stored rather than re-derived, so the list reads the same for a folder
    /// that is no longer there to ask.
    required String name,

    /// When it was last opened, in UTC; what orders the list.
    ///
    /// An instant rather than a position, so two windows opening two spaces
    /// never renumber each other's.
    required DateTime lastOpened,
  }) = _RecentSpaceEntity;
}
