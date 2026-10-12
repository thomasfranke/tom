/// Who opens a space, and who moves the window to another document.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';

part 'space_session_notifier.g.dart';

/// The open space, or null while the window shows Home ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Kept alive on purpose: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out.
@Riverpod(keepAlive: true)
class SpaceSessionNotifier extends _$SpaceSessionNotifier {
  @override
  SpaceSessionState? build() => null;

  /// Opens [space], with no document showing yet.
  ///
  /// A space already open is replaced whole: [SpaceSessionState.openDocument]
  /// names a file inside *a* space, and the new one may not hold it.
  ///
  /// [locating] says git has not yet been asked where the repository is:
  /// the files show now and [located] completes the space.
  void open(SpaceEntity space, {bool locating = false}) =>
      state = SpaceSessionState(space: space, locatingRepository: locating);

  /// Completes the space opened with `locating`: [space] is the same folder
  /// with the repository git found, or none.
  void located(SpaceEntity space) {
    if (state case final SpaceSessionState session
        when session.locatingRepository && session.space.root == space.root) {
      state = session.copyWith(space: space, locatingRepository: false);
    }
  }

  /// Leaves the space, which is what puts Home back on the window.
  ///
  /// No space is the whole of it: the window draws Home on a null session,
  /// so nothing else has to be told (`docs/product/workspace/leaving-a-space/doc.md`).
  void close() => state = null;

  /// Shows the working copy of [document]; nothing with no space open.
  ///
  /// A tab already open is chosen. Otherwise the document opens in
  /// *preview*: it takes the place of the tab in preview, or is added at the
  /// end when every tab is kept — somebody reading through a folder ends
  /// with one tab, not thirty (`docs/product/editor/tabs/doc.md`).
  ///
  /// A commit is a version *of one file*, so the version being read never
  /// carries across to another document.
  void show(SpaceRelativePathValueObject document) =>
      choose(DocumentTab.inSpace(document));

  /// Shows [file], a changed file of the repository outside the space, the
  /// way [show] shows a document
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  void showOutside(RepoRelativePathValueObject file) =>
      choose(DocumentTab.outside(file));

  /// Puts [tab]'s document on screen, by the rules [show] gives.
  void choose(DocumentTab tab) {
    if (tab case PreferencesDocumentTab(
      :final SpaceRelativePathValueObject path,
    )) {
      openPreferencesFile(path);
      return;
    }
    if (state case final SpaceSessionState session) {
      final List<DocumentTab> tabs = session.tabs.toList();
      DocumentTab? preview = session.previewTab;
      if (!tabs.contains(tab)) {
        final int replaced = preview == null ? -1 : tabs.indexOf(preview);
        if (replaced < 0) {
          tabs.add(tab);
        } else {
          tabs[replaced] = tab;
        }
        preview = tab;
      }
      // Choosing a document is leaving the pull request: the page is one
      // reading position, and a row of the tree is another.
      state = session.copyWith(
        openDocument: switch (tab) {
          SpaceDocumentTab(:final SpaceRelativePathValueObject path) => path,
          _ => null,
        },
        outsideDocument: switch (tab) {
          OutsideDocumentTab(:final RepoRelativePathValueObject path) => path,
          _ => null,
        },
        readingVersion: null,
        tabs: List<DocumentTab>.unmodifiable(tabs),
        previewTab: preview,
        pullRequest: null,
      );
    }
  }

  /// Opens the preferences file at [file] in a tab of its own, after the
  /// documents', and puts it on screen
  /// (`docs/product/preferences/where-it-is-stored/doc.md`).
  ///
  /// [file] is relative to the app's own folder, not the space; it is on
  /// screen because no document is
  /// ([SpaceSessionState.isShowingPreferencesFile]).
  void openPreferencesFile(SpaceRelativePathValueObject file) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(
        appFiles: session.appFiles.contains(file)
            ? session.appFiles
            : List<SpaceRelativePathValueObject>.unmodifiable(
                <SpaceRelativePathValueObject>[...session.appFiles, file],
              ),
        appFile: file,
        openDocument: null,
        outsideDocument: null,
        readingVersion: null,
        pullRequest: null,
      );
    }
  }

  /// Puts [branch]'s pull request draft in the document area, proposed onto
  /// [base] (`docs/product/git-workflow/pull-request/the-control/doc.md`).
  void proposeBranch(BranchNameValueObject branch, BranchNameValueObject base) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(
        pullRequest: branch,
        pullRequestBase: base,
        readingVersion: null,
      );
    }
  }

  /// Proposes the pull request onto [base] instead; the draft stays as it is.
  void proposeOnto(BranchNameValueObject base) {
    if (state case final SpaceSessionState session
        when session.pullRequest != null) {
      state = session.copyWith(pullRequestBase: base);
    }
  }

  /// Leaves the pull request, back to the tab that was on screen.
  void leavePullRequest() {
    if (state case final SpaceSessionState session
        when session.pullRequest != null) {
      state = session.copyWith(pullRequest: null);
    }
  }

  /// Keeps [tab]: the italic goes, and the next click opens a tab of its
  /// own. Editing, saving or a double click says it.
  void keep(DocumentTab tab) {
    if (state case final SpaceSessionState session
        when session.previewTab == tab) {
      state = session.copyWith(previewTab: null);
    }
  }

  /// Closes [tab], and shows the one to its right — or its left when it was
  /// the last — if it was the one on screen.
  ///
  /// Nothing is asked here: whether its edits may go is the caller's
  /// question, put before this is called. The preferences file's tab closes
  /// the same way, its left neighbour being the last document's.
  void closeTab(DocumentTab tab) {
    if (state case final SpaceSessionState session) {
      if (tab case PreferencesDocumentTab(
        :final SpaceRelativePathValueObject path,
      )) {
        final int at = session.appFiles.indexOf(path);
        if (at < 0) {
          return;
        }
        final List<SpaceRelativePathValueObject> files =
            session.appFiles.toList()..removeAt(at);
        final bool wasShown =
            session.isShowingPreferencesFile && session.appFile == path;
        // Its left neighbour takes the area: the app file before it, or
        // the last document.
        final SpaceRelativePathValueObject? neighbour = at > 0
            ? files[at - 1]
            : files.firstOrNull;
        final DocumentTab? last = !wasShown
            ? session.onScreen
            : at > 0
            ? null
            : session.tabs.lastOrNull;
        state = _showing(
          session.copyWith(
            appFiles: List<SpaceRelativePathValueObject>.unmodifiable(files),
            appFile: session.appFile == path ? neighbour : session.appFile,
          ),
          last,
        );
        return;
      }
      final int at = session.tabs.indexOf(tab);
      if (at < 0) {
        return;
      }
      final List<DocumentTab> tabs = session.tabs.toList()..removeAt(at);
      // The tab to the right is the preferences file's when this was the
      // last document's; it is on screen once no document is.
      final bool rightIsPreferences =
          at == tabs.length && session.appFiles.isNotEmpty;
      final DocumentTab? next = session.onScreen != tab
          ? session.onScreen
          : tabs.isEmpty || rightIsPreferences
          ? null
          : tabs[at < tabs.length ? at : tabs.length - 1];
      state = _showing(
        session.copyWith(
          tabs: List<DocumentTab>.unmodifiable(tabs),
          previewTab: session.previewTab == tab ? null : session.previewTab,
          readingVersion: next == session.onScreen
              ? session.readingVersion
              : null,
        ),
        next,
      );
    }
  }

  /// [session] with [tab]'s document on screen, or none.
  static SpaceSessionState _showing(
    SpaceSessionState session,
    DocumentTab? tab,
  ) => session.copyWith(
    openDocument: switch (tab) {
      SpaceDocumentTab(:final SpaceRelativePathValueObject path) => path,
      _ => null,
    },
    outsideDocument: switch (tab) {
      OutsideDocumentTab(:final RepoRelativePathValueObject path) => path,
      _ => null,
    },
  );

  /// Reads the open document as [commit] left it, or the working copy when
  /// [commit] is null — the only way back, so "back to now" has one meaning
  /// (`docs/product/git-workflow/file-history/doc.md`).
  void read(CommitEntity? commit) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(readingVersion: commit);
    }
  }

  /// Compares the working copy against [base], or against `HEAD` when it is
  /// null — written by `DiffBaseNotifier`, never by a person
  /// (`docs/product/diff/branch-diff/doc.md`).
  void compare(DiffBaseValueObject? base) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(comparingAgainst: base);
    }
  }

  /// Records where the repository stands, for everyone who draws from it.
  void observe(GitStatusValueObject? status) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(git: status);
    }
  }

  /// Records whether a merge is in progress, and what git drafted for it.
  ///
  /// Separate from [observe] because it is a separate reading: the status is
  /// re-read after everything that writes, the merge only when something
  /// could have started or ended one.
  void observeMerge(MergeStateValueObject? merge) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(merge: merge);
    }
  }

  /// Looks at the document area in [mode].
  ///
  /// The mode outlives the document: someone reading in preview is still
  /// reading when they click the next file.
  void look(DocumentModeEnum mode) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(mode: mode);
    }
  }

  /// Draws what changed, or stops drawing it.
  ///
  /// The base is left alone: turning the marks off is a reading position,
  /// and turning them on again brings back what was being compared
  /// (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
  void decorate({required bool showing}) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(showingDiff: showing);
    }
  }

  /// The `Diff` chip's press: the marks off when they are on, and back.
  void toggleDiff() {
    if (state case final SpaceSessionState session) {
      decorate(showing: !session.showingDiff);
    }
  }
}
