/// Who opens a space, and who moves the window to another document.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';

part 'space_session_notifier.g.dart';

/// Holds the open space for as long as one is open, so that every panel
/// reads the same answer ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
/// Null is "no space open", which is what the window shows Home for.
///
/// Kept alive deliberately: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out.
@Riverpod(keepAlive: true)
class SpaceSessionNotifier extends _$SpaceSessionNotifier {
  @override
  SpaceSessionState? build() => null;

  /// Opens [space], with no document showing yet.
  ///
  /// A space already open is replaced whole rather than merged:
  /// [SpaceSessionState.openDocument] names a file inside *a* space, and
  /// carrying it across would point the editor at a path the new space may
  /// not hold.
  void open(SpaceEntity space) => state = SpaceSessionState(space: space);

  /// Shows [document] in the panels that read the session.
  ///
  /// Does nothing with no space open: a path is only meaningful inside the
  /// space it is relative to, and there is nothing to draw it in.
  ///
  /// Another document is always the working copy of it: a commit is a
  /// version *of one file*, and carrying it across would open a revision of
  /// something the user did not ask about.
  void show(SpaceRelativePathValueObject document) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(openDocument: document, readingVersion: null);
    }
  }

  /// Reads the open document as [commit] left it, or the working copy when
  /// [commit] is null.
  ///
  /// Null is the way back, and it is the only one: nothing else here clears
  /// it, so "back to now" cannot end up meaning two different things
  /// (`docs/product/git-workflow/file-history/doc.md`).
  void read(CommitEntity? commit) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(readingVersion: commit);
    }
  }

  /// Records where the repository stands.
  ///
  /// Written by whoever read git and read by everyone who draws from it —
  /// which is what keeps the branch on the status bar and the list in the
  /// changes panel from being two readings that can disagree.
  void observe(GitStatusValueObject? status) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(git: status);
    }
  }

  /// Looks at the document area in [mode].
  ///
  /// The mode outlives the document on purpose: someone who reads in
  /// preview is still reading when they click the next file, and a mode
  /// that reset per document would be a setting nobody could keep.
  void look(DocumentModeEnum mode) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(mode: mode);
    }
  }
}
