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

  /// The text this pane last sent to the buffer.
  ///
  /// What comes back equal to it is this pane's own keystroke echoing; what
  /// differs was written by somebody else — a replacement, a branch switch,
  /// a discarded edit — and belongs on screen.
  late String _pushed = _opened;

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
    // A buffer this pane did not write is one somebody else did — a
    // replacement, a branch switch, a discarded edit — so the pane follows
    // it whether or not it is dirty. Assigning the text is revocable in
    // `re_editor`, which is what makes ⌘Z put a replacement back
    // (`docs/product/search/replacing/doc.md`).
    ref.listen<EditorState>(editorProvider, (
      EditorState? previous,
      EditorState next,
    ) {
      if (next case EditorReady(source: final String source)) {
        if (source != _pushed && _controller.text != source) {
          _pushed = source;
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
      // Right-aligned in a column of its own so the first character of source
      // is at the same place whatever the document's length — the package
      // otherwise sizes the column to the digits it happens to be showing.
      indicatorBuilder:
          (
            BuildContext context,
            CodeLineEditingController controller,
            CodeChunkController chunks,
            CodeIndicatorValueNotifier notifier,
          ) => SizedBox(
            width: EditorDesign.numbers,
            child: Align(
              alignment: Alignment.topRight,
              child: DefaultCodeLineNumber(
                controller: controller,
                notifier: notifier,
                textStyle: _numberStyle(colors.textMuted),
                // The line with the caret is brighter and never bigger: a
                // number that grows moves the column the rest sit in.
                focusedTextStyle: _numberStyle(colors.textSecondary),
              ),
            ),
          ),
      // Left of the code only: the line numbers are the pane's left inset,
      // and the boards put the first character ten past them.
      padding: const EdgeInsets.only(
        left: EditorDesign.numbersToCode,
        right: TomMetrics.pad,
      ),
      onChanged: (CodeLineEditingValue value) {
        _pushed = _controller.text;
        ref.read(editorProvider.notifier).edit(_pushed);
      },
      style: CodeEditorStyle(
        fontSize: EditorDesign.code,
        fontHeight: EditorDesign.codeHeight,
        fontFamily: TomFonts.mono,
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

  /// A line number in [ink], on the line the source itself stands on.
  static TextStyle _numberStyle(Color ink) => TextStyle(
    fontSize: EditorDesign.lineNumber,
    // The source's line box, not its own: the two columns have to keep step
    // or the numbers drift away from the lines they count.
    height:
        EditorDesign.code * EditorDesign.codeHeight / EditorDesign.lineNumber,
    fontFamily: TomFonts.mono,
    color: ink,
  );

  /// Writes the buffer to disk.
  void _save() => unawaited(ref.read(editorProvider.notifier).save());
}
