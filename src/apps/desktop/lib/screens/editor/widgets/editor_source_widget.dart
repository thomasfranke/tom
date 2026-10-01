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
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_bands_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
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

  /// The editor's own layout, kept from the one place it is handed over.
  ///
  /// `indicatorBuilder` is the only hook that receives it, and the tint
  /// behind the lines has to be drawn *outside* the editor — the indicator
  /// column is only as wide as the numbers and the band crosses the text.
  CodeIndicatorValueNotifier? _lines;

  /// The same builder's context, which is the only one below the editor's
  /// own `Actions` — and therefore the only way the buttons above the
  /// document reach `re_editor`'s undo ([EditorHistory]).
  BuildContext? _inside;

  /// The buffer as it stands the moment this is mounted.
  String get _opened => switch (ref.read(editorProvider)) {
    EditorReady(source: final String source) => source,
    _ => '',
  };

  @override
  void dispose() {
    // Taken back after the frame, never inside it: disposing happens while
    // the tree is locked, and notifying the scope there is a build scheduled
    // on a widget that cannot be marked.
    final EditorHistory? history = _history;
    final BuildContext? mine = _inside;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => history?.withdraw(mine),
    );
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Where the way in is left, found once the pane is in a tree.
  EditorHistory? _history;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _history = EditorHistoryScope.read(context);
  }

  /// Takes what the editor hands over, and lets the rest of the pane see it.
  ///
  /// Both arrive inside the *child's* build, so this pane has already built:
  /// the bands would not be drawn until something else rebuilt it, and the
  /// history would be offered in the middle of a frame. One post-frame pass
  /// settles both, and only ever once — the guard is what keeps it from
  /// scheduling a frame on every frame.
  void _took(BuildContext inside, CodeIndicatorValueNotifier lines) {
    if (identical(_inside, inside) && identical(_lines, lines)) {
      return;
    }
    _inside = inside;
    _lines = lines;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _history?.offer(inside);
      setState(() {});
    });
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
      if (next case final EditorReady ready) {
        if (ready.source != _pushed && _controller.text != ready.source) {
          _pushed = ready.source;
          _controller.text = ready.source;
          // The selection comes back with the text: a formatting button
          // rewrites the buffer and says where it left the caret, and a pane
          // that dropped it would send somebody back to the top
          // (`docs/product/editor/formatting-shortcuts/doc.md`).
          _controller.selection = _unflatten(
            ready.selectionStart,
            ready.selectionEnd,
          );
        }
      }
    });
    final TomColors colors = TomColors.of(context);
    final EditorMarks marks = ref.watch(editorMarksProvider);
    // Sunken, which is what the boards draw: the source pane is a well in
    // the document container and the preview is the container itself
    // (`design/screens/desktop/editor/merged-rows-dark.svg`).
    return ColoredBox(
      color: colors.surfaceSunken,
      child: Stack(
        children: <Widget>[
          // Under the editor, which is drawn on nothing: a band behind the
          // text cannot be painted by a widget the text is painted over.
          //
          // Always in the list, empty or not: a `Stack` whose children change
          // in number re-parents the ones after them, and an editor rebuilt
          // from scratch loses its focus and its selection.
          Positioned.fill(
            child: switch (_lines) {
              final CodeIndicatorValueNotifier lines => EditorBandsWidget(
                notifier: lines,
                marks: marks,
              ),
              null => const SizedBox.shrink(),
            },
          ),
          _editor(context, colors, marks),
        ],
      ),
    );
  }

  /// The editor itself, transparent so the bands under it show through.
  Widget _editor(
    BuildContext context,
    TomColors colors,
    EditorMarks marks,
  ) => CodeEditor(
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
    // The marks share the column, in the gutter the boards keep left of it.
    indicatorBuilder:
        (
          BuildContext context,
          CodeLineEditingController controller,
          CodeChunkController chunks,
          CodeIndicatorValueNotifier notifier,
        ) {
          // Kept for what is drawn outside the editor: this is the only
          // hand-over of either the layout or a context below its `Actions`.
          _took(context, notifier);
          return SizedBox(
            width: EditorDesign.numbers,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: EditorMarksWidget(notifier: notifier, marks: marks),
                ),
                Align(
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
              ],
            ),
          );
        },
    // Left of the code only: the line numbers are the pane's left inset,
    // and the boards put the first character ten past them.
    padding: const EdgeInsets.only(
      left: EditorDesign.numbersToCode,
      right: TomMetrics.pad,
    ),
    onChanged: (CodeLineEditingValue value) {
      _pushed = _controller.text;
      final (int, int) at = _flatten(value);
      ref.read(editorProvider.notifier).edit(_pushed, start: at.$1, end: at.$2);
    },
    style: CodeEditorStyle(
      fontSize: EditorDesign.code,
      fontHeight: EditorDesign.codeHeight,
      fontFamily: TomFonts.mono,
      textColor: colors.textPrimary,
      // Transparent, because the bands are painted under it.
      backgroundColor: Colors.transparent,
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

  /// [value]'s selection as two offsets into the whole text.
  ///
  /// The editor counts in lines and columns and the buffer counts in
  /// characters; one of the two has to convert, and the pane is the one that
  /// holds the lines.
  (int, int) _flatten(CodeLineEditingValue value) {
    final CodeLineSelection selection = value.selection;
    return (
      _offsetOf(selection.baseIndex, selection.baseOffset),
      _offsetOf(selection.extentIndex, selection.extentOffset),
    );
  }

  /// The offset of [column] on [line], counting the newlines before it.
  int _offsetOf(int line, int column) {
    int at = 0;
    final int lines = _controller.lineCount;
    for (int index = 0; index < line && index < lines; index++) {
      at += _controller.codeLines[index].text.length + 1;
    }
    return at + column;
  }

  /// [start] and [end] put back into lines and columns.
  CodeLineSelection _unflatten(int start, int end) {
    final (int, int) base = _positionOf(start);
    final (int, int) extent = _positionOf(end);
    return CodeLineSelection(
      baseIndex: base.$1,
      baseOffset: base.$2,
      extentIndex: extent.$1,
      extentOffset: extent.$2,
    );
  }

  /// Which line and column [offset] falls on.
  (int, int) _positionOf(int offset) {
    int left = offset;
    for (int line = 0; line < _controller.lineCount; line++) {
      final int length = _controller.codeLines[line].text.length;
      if (left <= length) {
        return (line, left);
      }
      left -= length + 1;
    }
    final int last = _controller.lineCount - 1;
    return (last, _controller.codeLines[last].text.length);
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
