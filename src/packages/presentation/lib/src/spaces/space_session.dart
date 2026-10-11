/// What every panel shares about the space that is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';

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

    /// Whether git has not yet said which repository encloses [space] — the
    /// folder is on screen and its files are shown while a command that
    /// asks first waits in the Commands panel. [SpaceEntity.hasRepository]
    /// is false meanwhile and means "not known yet", not "none".
    @Default(false) bool locatingRepository,

    /// The document the editor and the preview are showing, or null when
    /// none has been chosen — the state a space opens in, not an error.
    ///
    /// Space-relative because that is what the app navigates in; git's
    /// spelling is [SpaceEntity.toRepoRelative]'s to produce.
    SpaceRelativePathValueObject? openDocument,

    /// A changed file of the repository outside the space, on screen in
    /// [openDocument]'s place — never both set — or null.
    ///
    /// A field of its own so every reader of [openDocument] (the tree's open
    /// row, the index, history, export) sees no document without being told
    /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
    RepoRelativePathValueObject? outsideDocument,

    /// The documents open as tabs, left to right; the one [onScreen] names is
    /// one of them whenever it is set (`docs/product/editor/tabs/doc.md`).
    ///
    /// A session's, not a repository's: what somebody has been in, which a
    /// commit does not empty.
    @Default(<DocumentTab>[]) List<DocumentTab> tabs,

    /// The app's own files open as tabs — `preferences.json` and
    /// `git-approvals.json` beside it, in the order they were opened — by
    /// their paths in the app's folder, never the space's.
    ///
    /// Tabs after [tabs] rather than among them, because what reads [tabs]
    /// takes each for a file of the space or its repository
    /// (`docs/product/preferences/where-it-is-stored/doc.md`).
    @Default(<SpaceRelativePathValueObject>[])
    List<SpaceRelativePathValueObject> appFiles,

    /// The one of [appFiles] that has the document area while no document
    /// does ([isShowingPreferencesFile]); null exactly when none is open.
    SpaceRelativePathValueObject? appFile,

    /// The tab opened by a click and not yet kept — italic, and replaced by
    /// the next click rather than joined by it — or null when every tab is
    /// kept.
    DocumentTab? previewTab,

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

    /// The branch the checked-out one came from and where it left it — the
    /// working copy is compared at that fork point — or null for `HEAD`: on
    /// that branch itself, when detached, or before anybody read it.
    ///
    /// Nobody chooses it: `DiffBaseNotifier` reads it whenever git is read
    /// (`docs/product/diff/branch-diff/doc.md`). Here because three things
    /// read it: the preview, the label beside the `Diff` chip, and the pull
    /// request's first base.
    DiffBaseValueObject? comparingAgainst,

    /// Whether the preview decorates what changed, which it does until
    /// somebody presses the `Diff` chip.
    ///
    /// Here rather than in the preview because the chip that switches it is
    /// in the bar and the marks are in the panel, and one of them has to
    /// hold the answer. Off is a reading position, not a comparison: turning
    /// the marks back on brings the same base back
    /// (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
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

    /// The branch whose pull request is being written, or null when the
    /// document area is [openDocument]'s.
    ///
    /// One more reading position beside [openDocument], the way
    /// [readingVersion] is: set, the editor holds the branch's draft and the
    /// tab strip gives way to the status row; the tabs keep what they hold
    /// and come back as they were ([Decision
    /// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
    BranchNameValueObject? pullRequest,

    /// The branch the pull request is proposed onto, which starts at the
    /// remote's own and is chosen in the right column.
    ///
    /// Here and not in the column because the draft is seeded from it and
    /// the status row reads it too.
    BranchNameValueObject? pullRequestBase,
  }) = _SpaceSessionState;

  const SpaceSessionState._();

  /// Whether the document area holds the preferences file: its tab is open
  /// and no document or pull request has the area instead.
  ///
  /// Derived, so every reader of [openDocument] — the tree's open row, the
  /// diff, the index, the `Diff` chip — sees no document without being told.
  bool get isShowingPreferencesFile =>
      appFile != null &&
      openDocument == null &&
      outsideDocument == null &&
      pullRequest == null;

  /// The tab whose document has the area — [openDocument] or
  /// [outsideDocument] — or null when neither does.
  DocumentTab? get onScreen => switch ((openDocument, outsideDocument)) {
    (final SpaceRelativePathValueObject path, _) => DocumentTab.inSpace(path),
    (null, final RepoRelativePathValueObject path) => DocumentTab.outside(path),
    (null, null) => null,
  };

  /// The tabs of the app's own files, in [appFiles]' order.
  List<DocumentTab> get appTabs => <DocumentTab>[
    for (final SpaceRelativePathValueObject file in appFiles)
      DocumentTab.preferences(file),
  ];

  /// The tab of the app's file that has the area, or null while a document
  /// has it or none is open.
  DocumentTab? get shownAppTab =>
      isShowingPreferencesFile ? DocumentTab.preferences(appFile!) : null;

  /// Whether the document area holds a file with no page to render — the
  /// preferences file, or any file that is not markdown — so `Split` and
  /// `Preview` are unavailable
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  bool get isSourceOnly =>
      isShowingPreferencesFile ||
      (pullRequest == null && !(onScreen?.kind.isMarkdown ?? true));

  /// The mode the document area is drawn in: [mode], except source for a
  /// file that is not markdown ([isSourceOnly]).
  DocumentModeEnum get drawnMode =>
      isSourceOnly ? DocumentModeEnum.source : mode;

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
