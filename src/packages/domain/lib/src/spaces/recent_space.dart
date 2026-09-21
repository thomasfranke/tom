/// A space the user opened before.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_space.freezed.dart';

/// One entry in Home's recent list.
///
/// Deliberately **not** a `Space`. A space carries `repositoryRoot`, and
/// knowing that means having asked git — which means touching the disk for
/// every row of a list the user may not click. A recent entry is what can be
/// remembered without asking anything: where it was, what it was called, and
/// when it was last opened.
///
/// It also survives the folder going away, which a `Space` should not: a
/// removable disk, a network share, a folder renamed outside TOM. Home
/// offers to forget those rather than reporting a fault
/// (`docs/product/home/doc.md`), and it can only offer that if it still has
/// the row.
@freezed
abstract class RecentSpace with _$RecentSpace {
  /// Creates an entry.
  const factory RecentSpace({
    /// The absolute path of the folder that was opened; its identity.
    required String root,

    /// What it was called the last time it was open.
    ///
    /// Stored rather than re-derived so the list reads the same as the app
    /// did, even for a folder that is no longer there to ask.
    required String name,

    /// When it was last opened, in UTC.
    ///
    /// Only used to order the list. An instant rather than a position,
    /// because two windows can open two spaces and neither should have to
    /// renumber the other's.
    required DateTime lastOpened,
  }) = _RecentSpace;
}
