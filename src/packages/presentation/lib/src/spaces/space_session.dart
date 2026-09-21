/// What every panel shares about the space that is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'space_session.freezed.dart';

/// The open space, and what the whole window is looking at inside it.
///
/// **The single source of truth in presentation** ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)):
/// panels derive from this with `select` and never fetch space state of
/// their own, and an operation that changes the space writes here.
///
/// It holds what more than one panel needs. Anything one panel alone cares
/// about — a scroll offset, which folders are collapsed — stays in that
/// panel's notifier.
///
/// M1 adds the current branch, the `GitStatus` and ahead/behind here, for
/// the same reason [openDocument] is here: three answers to "which branch is
/// this" is the failure mode.
@freezed
abstract class SpaceSessionState with _$SpaceSessionState {
  /// Opens [space], with nothing being read yet.
  const factory SpaceSessionState({
    /// The folder the user opened, and the repository that encloses it.
    required Space space,

    /// The document the editor and the preview are showing, or null when
    /// none has been chosen.
    ///
    /// Null is the state a space opens in, not an error. It is a
    /// [SpaceRelativePath] because that is what the app navigates in — git's
    /// spelling is [Space.toRepoRelative]'s to produce, and nobody else's.
    SpaceRelativePath? openDocument,
  }) = _SpaceSessionState;
}
