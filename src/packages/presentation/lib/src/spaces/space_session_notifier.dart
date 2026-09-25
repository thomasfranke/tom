/// Who opens a space, and who moves the window to another document.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
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
  void open(SpaceEntity space) => state = SpaceSessionState(space: space);

  /// Shows the working copy of [document]; nothing with no space open.
  ///
  /// A commit is a version *of one file*, so the version being read never
  /// carries across to another document.
  void show(SpaceRelativePathValueObject document) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(openDocument: document, readingVersion: null);
    }
  }

  /// Reads the open document as [commit] left it, or the working copy when
  /// [commit] is null — the only way back, so "back to now" has one meaning
  /// (`docs/product/git-workflow/file-history/doc.md`).
  void read(CommitEntity? commit) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(readingVersion: commit);
    }
  }

  /// Compares the document against [revision], or against the default when
  /// [revision] is null — the only way back, as with [read], so "stop
  /// comparing" has one meaning (`docs/product/diff/branch-diff/doc.md`).
  void compare(RevisionValueObject? revision) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(comparingAgainst: revision);
    }
  }

  /// Records where the repository stands, for everyone who draws from it.
  void observe(GitStatusValueObject? status) {
    if (state case final SpaceSessionState session) {
      state = session.copyWith(git: status);
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
}
