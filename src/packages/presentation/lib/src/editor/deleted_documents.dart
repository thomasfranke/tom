/// The open tabs whose file is gone from the disk.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'deleted_documents.g.dart';

/// Every open tab whose file git reports deleted, and the one on screen when
/// the editor found it gone — what the strip strikes through and calls
/// `(deleted)` (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// Git's reading rather than each tab's buffer, because a tab that is not on
/// screen holds no buffer to ask.
@riverpod
Set<DocumentTab> deletedDocuments(Ref ref) {
  final ({
    SpaceEntity? space,
    List<DocumentTab> tabs,
    GitStatusValueObject? git,
  })
  session = ref.watch(
    spaceSessionProvider.select(
      (SpaceSessionState? session) => (
        space: session?.space,
        tabs: session?.tabs ?? const <DocumentTab>[],
        git: session?.git,
      ),
    ),
  );
  final DocumentTab? onScreen = ref.watch(
    editorProvider.select(
      (EditorState editor) => switch (editor) {
        EditorReady(isDeleted: true) => editor.tab,
        _ => null,
      },
    ),
  );
  final SpaceEntity? space = session.space;
  if (space == null) {
    return const <DocumentTab>{};
  }
  final Set<DocumentTab> gone = <DocumentTab>{
    for (final StatusEntryValueObject entry
        in session.git?.entries ?? const <StatusEntryValueObject>[])
      if (entry.state == FileStateEnum.deleted)
        DocumentTab.of(space, entry.path),
    ?onScreen,
  };
  return Set<DocumentTab>.unmodifiable(gone.intersection(session.tabs.toSet()));
}
