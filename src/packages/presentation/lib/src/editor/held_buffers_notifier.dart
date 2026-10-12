/// The buffers of the tabs that are open and not on screen.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'held_buffers_notifier.g.dart';

/// Every unsaved buffer a tab holds while another is on screen, by path
/// (`docs/product/editor/tabs/doc.md`).
///
/// The editor still has one buffer, the one on screen; choosing another tab
/// puts a dirty one here and takes the next one back out, so switching tabs
/// never throws work away. Emptied with the space, because a buffer belongs
/// to a folder.
///
/// Typed [EditorState] rather than `EditorReady` because the generator
/// cannot see a class Freezed declares in a part; only ready buffers are
/// ever put here.
@Riverpod(keepAlive: true)
class HeldBuffersNotifier extends _$HeldBuffersNotifier {
  @override
  Map<DocumentTab, EditorState> build() {
    ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    return const <DocumentTab, EditorState>{};
  }

  /// Keeps [buffer] for when its tab is chosen again.
  void hold(EditorReady buffer) {
    state = Map<DocumentTab, EditorState>.unmodifiable(
      <DocumentTab, EditorState>{...state, buffer.tab!: buffer},
    );
  }

  /// The buffer held for [tab], taken out; null when there is none.
  EditorReady? take(DocumentTab tab) {
    final EditorState? held = state[tab];
    if (held == null) {
      return null;
    }
    drop(tab);
    return held is EditorReady ? held : null;
  }

  /// Forgets [tab]'s buffer — the tab closed, or its edits discarded.
  void drop(DocumentTab tab) {
    if (state.containsKey(tab)) {
      state = Map<DocumentTab, EditorState>.unmodifiable(
        <DocumentTab, EditorState>{...state}..remove(tab),
      );
    }
  }

  /// Forgets every buffer, which is what *discard* means for all of them.
  void clear() => state = const <DocumentTab, EditorState>{};
}

/// Every tab with edits the disk does not have: the held buffers and the
/// one on screen. What the tab strip and the tree mark with a dot.
@riverpod
Set<DocumentTab> unsavedDocuments(Ref ref) {
  final Map<DocumentTab, EditorState> held = ref.watch(heldBuffersProvider);
  final EditorState editor = ref.watch(editorProvider);
  return <DocumentTab>{
    for (final MapEntry<DocumentTab, EditorState> entry in held.entries)
      if (entry.value.isDirty) entry.key,
    if (editor case final EditorReady open when open.isDirty && !open.isDraft)
      open.tab!,
  };
}
