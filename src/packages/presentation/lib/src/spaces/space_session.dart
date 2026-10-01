/// What every panel shares about the space that is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';

part 'space_session.freezed.dart';

/// The open space, and what the whole window is looking at inside it.
///
/// The single source of truth in presentation ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)):
/// panels derive from it with `select`, an operation that changes the space
/// writes here, and what one panel alone cares about stays in that panel.
@freezed
abstract class SpaceSessionState with _$SpaceSessionState {
  /// Opens [space], with nothing being read yet.
  const factory SpaceSessionState({
    /// The folder the user opened, and the repository that encloses it.
    required SpaceEntity space,

    /// The document the editor and the preview are showing, or null when
    /// none has been chosen — the state a space opens in, not an error.
    ///
    /// Space-relative because that is what the app navigates in; git's
    /// spelling is [SpaceEntity.toRepoRelative]'s to produce.
    SpaceRelativePathValueObject? openDocument,

    /// How the document area is being looked at; split is where a space
    /// opens.
    ///
    /// Here rather than in a panel because two things read it: the bar that
    /// offers the modes and the shell that decides which panels to draw.
    @Default(DocumentModeEnum.split) DocumentModeEnum mode,

    /// Where the repository stands, or null while nobody has read it yet.
    ///
    /// A reading, not a subscription: stale as soon as anything writes to
    /// disk, re-read after every operation that changes the tree. Shared so
    /// the status bar and the changes panel draw from one answer.
    GitStatusValueObject? git,

    /// The commit whose version of [openDocument] is being read, or null
    /// when the working copy is.
    ///
    /// The whole commit rather than its sha, because the bar names the
    /// author and the date and a second lookup could disagree with the list.
    CommitEntity? readingVersion,

    /// The branch or commit the document is compared against, or null for
    /// the default — `HEAD` for the working copy, nothing for a version
    /// being read.
    ///
    /// Here because two things read it: the preview, which builds the diff
    /// against it, and the bar above the document, which says what is being
    /// compared. It survives opening another document on purpose — comparing
    /// a branch is done one file at a time, and a base that reset on every
    /// click would make that a chore (`docs/product/diff/branch-diff/doc.md`).
    RevisionValueObject? comparingAgainst,

    /// Whether the preview decorates what changed, which it does until
    /// somebody turns it off.
    ///
    /// Here rather than in the preview because the chip that switches it is
    /// in the bar and the marks are in the panel, and one of them has to
    /// hold the answer. Off is a reading position, not a comparison: what is
    /// compared is still [comparingAgainst], and turning the marks back on
    /// brings the same base back (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
    @Default(true) bool showingDiff,

    /// The merge a conflicted pull left behind, or null while nobody has
    /// asked git.
    ///
    /// Beside [git] because it is read in the same breath and drawn by the
    /// same panels: the band says the pull stopped, the changes list counts
    /// what is left to resolve, and the message box starts from the draft
    /// git wrote. Read rather than remembered, so closing the window and
    /// opening it again finds the same conflict
    /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
    MergeStateValueObject? merge,
  }) = _SpaceSessionState;

  const SpaceSessionState._();

  /// The documents git still reports as conflicted, in the order it gave.
  ///
  /// Derived rather than stored: the status already answers it, and a count
  /// kept beside it is a count that can disagree with it.
  List<StatusEntryValueObject> get toResolve =>
      git?.entries
          .where(
            (StatusEntryValueObject entry) =>
                entry.state == FileStateEnum.conflicted,
          )
          .toList() ??
      const <StatusEntryValueObject>[];

  /// Whether a merge is in progress and anything is still unresolved.
  bool get isResolvingMerge =>
      (merge?.inProgress ?? false) && toResolve.isNotEmpty;

  /// Whether git reports the document at [path] conflicted.
  ///
  /// Asked of the status already read rather than of the text: a document
  /// holding `<<<<<<<` is conflicted only while a merge is open, which is what
  /// keeps a marker typed into a document *about* merging as plain text
  /// (`docs/product/editor/conflicted-document/doc.md`).
  bool isConflicted(SpaceRelativePathValueObject? path) =>
      path != null &&
      isResolvingMerge &&
      toResolve.any(
        // Through the space's own spelling, because git names a path from the
        // repository root and the space may be a folder inside it.
        (StatusEntryValueObject entry) =>
            space.toSpaceRelative(entry.path) == path,
      );
}
