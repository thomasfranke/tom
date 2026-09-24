/// The buffer, as text somebody can type into.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The source of the open document, editable.
///
/// `re_editor` rather than a `TextField`, decided by measurement ([Decision
/// 18](../../../../../../../docs/technical/decisions/018-source-mode-uses-re-editor.md)):
/// the field lays the whole document out as one paragraph on every
/// keystroke and misses 96% of its frames at 2853 lines.
///
/// **The controller is the buffer while this is on screen** — seeded once
/// from the state and pushing every edit up from there. Read rather than
/// watched, and mounted under a key that is the document's path: another
/// file is another controller, and nothing re-seeds this one underneath
/// somebody's cursor.
///
/// The one thing that does re-seed it is the *same* document being read off
/// the disk again — what a branch switch leaves behind, and what discarding
/// an edit is. The key cannot catch that, because the path did not change;
/// the state can, because a buffer that matches the disk and not what is
/// typed here is one this pane did not produce.
class EditorSourceWidget extends ConsumerStatefulWidget {
  /// Creates the editor over whatever buffer is open.
  const EditorSourceWidget({super.key});

  @override
  ConsumerState<EditorSourceWidget> createState() => _EditorSourceWidgetState();
}

class _EditorSourceWidgetState extends ConsumerState<EditorSourceWidget> {
  late final CodeLineEditingController _controller =
      CodeLineEditingController.fromText(_opened);
  final CodeScrollController _scroll = CodeScrollController();

  /// The buffer as it stands the moment this is mounted.
  String get _opened => switch (ref.read(editorProvider)) {
    EditorReady(source: final String source) => source,
    _ => '',
  };

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A clean buffer that is not what is on screen was read off the disk by
    // something else — a branch switch, a discarded edit — so the pane
    // follows it. Typing cannot land here: it leaves the buffer dirty, and a
    // save leaves it equal to what is already shown.
    ref.listen<EditorState>(editorProvider, (
      EditorState? previous,
      EditorState next,
    ) {
      if (next case EditorReady(source: final String source)) {
        if (!next.isDirty && _controller.text != source) {
          _controller.text = source;
        }
      }
    });
    final TomColors colors = TomColors.of(context);
    return CodeEditor(
      controller: _controller,
      scrollController: _scroll,
      // The package already binds ⌘S / Ctrl+S per platform and dispatches
      // an intent nothing answers; what was missing was the answer. A
      // `Shortcuts` wrapper of our own would lose the race — the editor has
      // the focus, so it sees the key first.
      shortcutOverrideActions: <Type, Action<Intent>>{
        CodeShortcutSaveIntent: CallbackAction<CodeShortcutSaveIntent>(
          onInvoke: (CodeShortcutSaveIntent intent) {
            _save();
            return null;
          },
        ),
      },
      // Prose, not code: a paragraph that ran off the right edge would have
      // to be scrolled to be read.
      wordWrap: true,
      // The same gutter the caption above it and the preview beside it sit
      // in: the two panes are one rhythm.
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
      onChanged: (CodeLineEditingValue value) =>
          ref.read(editorProvider.notifier).edit(_controller.text),
      style: CodeEditorStyle(
        fontSize: EditorDesign.code,
        fontHeight: EditorDesign.codeHeight,
        fontFamily: 'Menlo',
        textColor: colors.textPrimary,
        backgroundColor: colors.surface,
        cursorColor: colors.accent,
        selectionColor: colors.accentSoft,
        codeTheme: CodeHighlightTheme(
          languages: <String, CodeHighlightThemeMode>{
            'markdown': CodeHighlightThemeMode(mode: langMarkdown),
          },
          theme: Theme.of(context).brightness == Brightness.dark
              ? atomOneDarkTheme
              : atomOneLightTheme,
        ),
      ),
    );
  }

  /// Writes the buffer to disk.
  void _save() => unawaited(ref.read(editorProvider.notifier).save());
}
