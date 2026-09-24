/// What every panel shares about the space that is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';

part 'space_session.freezed.dart';

/// The open space, and what the whole window is looking at inside it.
///
/// **The single source of truth in presentation** ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)):
/// panels derive from this with `select` and never fetch space state of
/// their own, and an operation that changes the space writes here.
///
/// It holds what more than one panel needs. Anything one panel alone cares
/// about — a scroll offset, which folders are collapsed, a commit message
/// being typed — stays in that panel's notifier.
@freezed
abstract class SpaceSessionState with _$SpaceSessionState {
  /// Opens [space], with nothing being read yet.
  const factory SpaceSessionState({
    /// The folder the user opened, and the repository that encloses it.
    required SpaceEntity space,

    /// The document the editor and the preview are showing, or null when
    /// none has been chosen.
    ///
    /// Null is the state a space opens in, not an error. It is a
    /// [SpaceRelativePathValueObject] because that is what the app navigates
    /// in — git's spelling is [SpaceEntity.toRepoRelative]'s to produce, and
    /// nobody else's.
    SpaceRelativePathValueObject? openDocument,

    /// How the document area is being looked at.
    ///
    /// Here rather than in a panel because it decides which panels the
    /// region draws at all: the bar that offers the three modes and the
    /// shell that obeys them are two readers, and two readers is what this
    /// state is for.
    ///
    /// Split is where a space opens — the product's own claim is that
    /// source and preview belong side by side.
    @Default(DocumentModeEnum.split) DocumentModeEnum mode,

    /// Where the repository stands, or null while nobody has read it yet.
    ///
    /// Here because three panels ask: the changes panel draws the list, the
    /// status bar says the branch and the counts, and M2's diff will want
    /// the same reading. Three answers to "which branch is this" is the
    /// failure mode this state exists to prevent.
    ///
    /// A reading, not a subscription — stale as soon as anything writes to
    /// disk, and re-read after every operation that changes the tree.
    GitStatusValueObject? git,

    /// The commit whose version of [openDocument] is being read, or null
    /// when the working copy is.
    ///
    /// Here because three panels ask: the preview renders that version
    /// rather than the buffer, the bar above the document says which commit
    /// is on screen and offers the way back, and the shell draws no source
    /// pane at all — nothing types into the past.
    ///
    /// The whole commit rather than its sha, because the bar names the
    /// author and the date and a second lookup to say so would be a second
    /// answer that can disagree with the list.
    CommitEntity? readingVersion,
  }) = _SpaceSessionState;
}
