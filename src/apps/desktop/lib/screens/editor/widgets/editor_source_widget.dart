/// The buffer, as text somebody can type into.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/editor_highlight.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_bands_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_completion_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_lens_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
import 'package:tom_domain/tom_domain.dart';
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

  /// What `[[` is offering, or null while nothing is
  /// (`docs/product/wikilinks/doc.md`).
  WikilinkCompletionValueObject? _offer;

  /// The row Enter would insert.
  int _chosen = 0;

  /// Where the offer hangs from, in the pane: under the `[[` it completes.
  Offset _offerAt = Offset.zero;

  /// The caret a `[[` is open at, kept while the space's listing is still
  /// being read so the offer can open once it arrives.
  int? _wanted;

  /// Set while a choice is written, so the write does not offer again.
  bool _inserting = false;

  final OverlayPortalController _offerPortal = OverlayPortalController();
  final LayerLink _pane = LayerLink();

  /// The tree's listing, which is what `[[` offers; kept alive from the first
  /// `[[` on, because a tree nobody watches is disposed and read again.
  ProviderSubscription<FileTreeState>? _tree;

  /// The buffer as it stands the moment this is mounted.
  String get _opened => switch (ref.read(editorProvider)) {
    EditorReady(source: final String source) => source,
    _ => '',
  };

  /// Whether the buffer is not markdown — the preferences file, or any other
  /// text — so drawn plain and offered no `[[`; read once, because the pane
  /// is keyed by its path.
  late final bool _isPlain = !ref.read(editorProvider).isRendered;

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
    _tree?.close();
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
    // The island's own fill, as the 1b boards draw both panes: the rule
    // between them is what separates source from preview, not a well
    // (`design/screens/desktop/editor/merged-rows-dark.svg`).
    final Widget pane = ColoredBox(
      color: colors.surfaceRaised,
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
          // Over the editor, because the choices are pressed; they hit-test
          // only where their words are, so every other touch reaches it.
          Positioned.fill(
            child: switch (_lines) {
              final CodeIndicatorValueNotifier lines => EditorLensWidget(
                notifier: lines,
                marks: marks,
                onChoose: _accept,
              ),
              null => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
    // In the overlay, so the offer is not clipped by the pane near its foot.
    return OverlayPortal(
      controller: _offerPortal,
      overlayChildBuilder: _offerView,
      child: CompositedTransformTarget(link: _pane, child: pane),
    );
  }

  /// The offer, hung under the `[[` it completes.
  Widget _offerView(BuildContext context) {
    final WikilinkCompletionValueObject? offer = _offer;
    if (offer == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      child: CompositedTransformFollower(
        link: _pane,
        offset: _offerAt,
        child: Align(
          alignment: Alignment.topLeft,
          // The editor's own group, so a click on a row keeps its focus.
          child: CodeEditorTapRegion(
            onTapOutside: (_) {
              _wanted = null;
              _closeOffer();
            },
            child: EditorCompletionWidget(
              candidates: _rowsOf(offer),
              chosen: _chosen,
              onChoose: _insert,
            ),
          ),
        ),
      ),
    );
  }

  /// The editor itself, transparent so the bands under it show through.
  ///
  /// The arrows and Enter go to the offer while it is open: `re_editor` asks
  /// the `Actions` above it before doing its own, which is how its own
  /// autocomplete takes them.
  Widget _editor(BuildContext context, TomColors colors, EditorMarks marks) =>
      Actions(
        actions: <Type, Action<Intent>>{
          CodeShortcutCursorMoveIntent:
              _OfferAction<CodeShortcutCursorMoveIntent>(
                isOpen: () => _offer != null,
                consumes: (CodeShortcutCursorMoveIntent intent) =>
                    intent.direction == AxisDirection.up ||
                    intent.direction == AxisDirection.down,
                onInvoke: (CodeShortcutCursorMoveIntent intent) {
                  _step(intent.direction == AxisDirection.up ? -1 : 1);
                  return null;
                },
              ),
          CodeShortcutNewLineIntent: _OfferAction<CodeShortcutNewLineIntent>(
            isOpen: () => _offer != null,
            onInvoke: (CodeShortcutNewLineIntent intent) {
              _insert(_chosen);
              return null;
            },
          ),
        },
        child: _codeEditor(context, colors, marks),
      );

  Widget _codeEditor(
    BuildContext context,
    TomColors colors,
    EditorMarks marks,
  ) => CodeEditor(
    controller: _controller,
    scrollController: _scroll,
    // A deleted file's last version: shown, never typed into
    // (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
    readOnly: ref.watch(
      editorProvider.select((EditorState state) => state.isReadOnly),
    ),
    shortcutsActivatorsBuilder: const _EditorKeys(),
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
      // Escape closes the offer first; otherwise it is the package's own,
      // which only ever drops a selection.
      CodeShortcutEscIntent: _EscapeAction(
        isEnabledNow: () =>
            _offer != null || !_controller.selection.isCollapsed,
        onInvoke: (CodeShortcutEscIntent intent) {
          if (_offer != null) {
            _wanted = null;
            _closeOffer();
          } else {
            _controller.cancelSelection();
          }
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
                // Unbounded to the left: the package sizes the numbers to the
                // longest one and refuses a box narrower than that, and the
                // column is the board's 32 whatever the document's length.
                OverflowBox(
                  alignment: Alignment.topRight,
                  maxWidth: double.infinity,
                  child: DefaultCodeLineNumber(
                    controller: controller,
                    notifier: notifier,
                    minNumberCount: 1,
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
    // and the boards put the first character eighteen past them.
    padding: const EdgeInsets.only(
      left: EditorDesign.numbersToCode,
      right: TomMetrics.pad,
    ),
    onChanged: (CodeLineEditingValue value) {
      // Typed is the text changing under this pane; a caret that only moved,
      // or a buffer somebody else wrote, closes the offer.
      final bool typed = _controller.text != _pushed;
      _pushed = _controller.text;
      final (int, int) at = _flatten(value);
      ref.read(editorProvider.notifier).edit(_pushed, start: at.$1, end: at.$2);
      _offerFor(typed && !_inserting && at.$1 == at.$2 ? at.$2 : null);
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
      codeTheme: _isPlain
          ? null
          : editorHighlightOf(colors, Theme.of(context).brightness),
    ),
  );

  /// Opens, narrows or closes the offer for the caret at [caret]; null is a
  /// change that was not typed here, which always closes it.
  void _offerFor(int? caret) {
    const WikilinkCompletionService completion = WikilinkCompletionService();
    // Asked first with no listing, so a pane nobody types `[[` in never
    // makes the tree exist.
    if (caret == null ||
        _isPlain ||
        completion.complete(_pushed, caret, const <SpaceEntryValueObject>[]) ==
            null) {
      _wanted = null;
      _closeOffer();
      return;
    }
    _wanted = caret;
    _tree ??= ref.listenManual<FileTreeState>(fileTreeProvider, (
      FileTreeState? previous,
      FileTreeState next,
    ) {
      if (_wanted case final int at) {
        _offerFor(at);
      }
    });
    final List<SpaceEntryValueObject> entries = switch (_tree!.read()) {
      FileTreeReady(entries: final List<SpaceEntryValueObject> entries) =>
        entries,
      _ => const <SpaceEntryValueObject>[],
    };
    final WikilinkCompletionValueObject? offer = completion.complete(
      _pushed,
      caret,
      entries,
    );
    // Nothing matching is not drawn: no board says how it would read.
    if (offer == null || offer.candidates.isEmpty) {
      _closeOffer();
      return;
    }
    setState(() {
      _offer = offer;
      _chosen = 0;
    });
    _offerPortal.show();
    // Placed once the editor has laid the new text out.
    WidgetsBinding.instance.addPostFrameCallback((_) => _placeOffer());
  }

  /// The rows the offer shows, best first.
  static List<WikilinkCandidateValueObject> _rowsOf(
    WikilinkCompletionValueObject offer,
  ) => offer.candidates.take(EditorCompletionWidget.maxRows).toList();

  void _closeOffer() {
    if (_offer == null) {
      return;
    }
    setState(() => _offer = null);
    _offerPortal.hide();
  }

  /// Hangs the offer under the `[[`, read off the editor's own layout.
  void _placeOffer() {
    final WikilinkCompletionValueObject? offer = _offer;
    final CodeIndicatorValue? layout = _lines?.value;
    if (!mounted || offer == null || layout == null) {
      return;
    }
    final (int line, int column) = _positionOf(offer.from - 2);
    for (final CodeLineRenderParagraph paragraph in layout.paragraphs) {
      if (paragraph.index != line) {
        continue;
      }
      final Offset? at = paragraph.paragraph.getOffset(
        TextPosition(offset: column),
      );
      if (at == null) {
        return;
      }
      // The paragraph's offset already carries the padding and the scroll;
      // the field starts where the numbers end, as the lens says.
      final Offset anchor = Offset(
        EditorDesign.numbers + paragraph.offset.dx + at.dx,
        paragraph.top +
            at.dy +
            paragraph.preferredLineHeight +
            EditorCompletionWidget.drop,
      );
      if (anchor != _offerAt) {
        setState(() => _offerAt = anchor);
      }
      return;
    }
  }

  /// Moves the chosen row by [by], round the ends.
  void _step(int by) {
    final WikilinkCompletionValueObject? offer = _offer;
    if (offer == null) {
      return;
    }
    final int rows = _rowsOf(offer).length;
    setState(() => _chosen = (_chosen + by) % rows);
  }

  /// Writes row [index]'s target between the brackets and closes them,
  /// leaving the caret after the `]]`.
  ///
  /// A `]]` already after the caret — `re_editor` closes a bracket as it is
  /// typed — is kept rather than doubled.
  void _insert(int index) {
    final WikilinkCompletionValueObject? offer = _offer;
    if (offer == null || index >= _rowsOf(offer).length) {
      return;
    }
    final String target = offer.candidates[index].target;
    final int caret = offer.from + offer.query.length;
    final bool closed = _pushed.startsWith(']]', caret);
    final (int line, int start) = _positionOf(offer.from);
    final (int _, int end) = _positionOf(caret);
    _wanted = null;
    _closeOffer();
    _inserting = true;
    try {
      _controller
        ..replaceSelection(
          closed ? target : '$target]]',
          CodeLineSelection(
            baseIndex: line,
            baseOffset: start,
            extentIndex: line,
            extentOffset: end,
          ),
        )
        ..selection = CodeLineSelection.collapsed(
          index: line,
          offset: start + target.length + 2,
        );
    } finally {
      _inserting = false;
    }
  }

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

  /// Keeps [choice]'s side of the conflict that opens on [line].
  ///
  /// The preview's own rule: an edit, not a save, read from the buffer as it
  /// stands, with the caret left where the region was
  /// (`docs/product/editor/conflicted-document/doc.md`).
  void _accept(int line, ConflictChoiceEnum choice) {
    if (ref.read(editorProvider) case EditorReady(
      source: final String source,
    )) {
      const ConflictScannerService scanner = ConflictScannerService();
      for (final ConflictRegionValueObject region in scanner.scan(source)) {
        final String before = source.substring(0, region.start);
        if ('\n'.allMatches(before).length == line) {
          ref
              .read(editorProvider.notifier)
              .edit(
                scanner.resolve(source, region, choice),
                start: region.start,
                end: region.start,
              );
          return;
        }
      }
    }
  }
}

/// A key the offer takes while it is open, and leaves to the editor when
/// it is not.
///
/// A `CallbackAction`, because that is the only kind `re_editor` invokes
/// when it asks the `Actions` above it.
class _OfferAction<T extends Intent> extends CallbackAction<T> {
  _OfferAction({
    required this._isOpen,
    required super.onInvoke,
    this._consumes,
  });

  final bool Function() _isOpen;
  final bool Function(T intent)? _consumes;

  @override
  bool get isActionEnabled => _isOpen();

  @override
  bool consumesKey(T intent) => _consumes?.call(intent) ?? true;
}

/// The package's keys, less ⌥⌘F — its own find-and-replace, which has no
/// panel here and would swallow the window's way to open replace.
class _EditorKeys extends DefaultCodeShortcutsActivatorsBuilder {
  const _EditorKeys();

  @override
  List<ShortcutActivator>? build(CodeShortcutType type) =>
      type == CodeShortcutType.replace ? null : super.build(type);
}

/// Escape, enabled only when there is something for it to close.
class _EscapeAction extends CallbackAction<CodeShortcutEscIntent> {
  _EscapeAction({required this._isEnabledNow, required super.onInvoke});

  final bool Function() _isEnabledNow;

  @override
  bool isEnabled(CodeShortcutEscIntent intent) => _isEnabledNow();
}
