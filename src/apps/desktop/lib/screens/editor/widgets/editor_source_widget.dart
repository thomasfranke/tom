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

/// The source of the open document, editable, over `re_editor`
/// ([Decision 18](../../../../../../../docs/technical/decisions/018-source-mode-uses-re-editor.md)).
///
/// The controller is seeded once with `ref.read`, under a key that is the
/// document's path, so nothing re-seeds it under a cursor; the one thing
/// that does is the same document read off the disk again (see `build`).
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
    // A clean buffer that differs from what is on screen was read off the
    // disk by something else (a branch switch, a discarded edit), so the
    // pane follows it. Typing leaves the buffer dirty and a save leaves it
    // equal, so neither lands here.
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
      // The package binds ⌘S / Ctrl+S itself and dispatches an intent nothing
      // answers; a `Shortcuts` wrapper of ours would lose the race, since the
      // editor has the focus. It installs no shortcuts at all on the platform
      // a widget test reports, so the keystroke is proved end to end.
      shortcutOverrideActions: <Type, Action<Intent>>{
        CodeShortcutSaveIntent: CallbackAction<CodeShortcutSaveIntent>(
          onInvoke: (CodeShortcutSaveIntent intent) {
            _save();
            return null;
          },
        ),
      },
      // Prose, not code: a paragraph off the right edge cannot be read.
      wordWrap: true,
      // The caption's and the preview's gutter: the two panes are one rhythm.
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
