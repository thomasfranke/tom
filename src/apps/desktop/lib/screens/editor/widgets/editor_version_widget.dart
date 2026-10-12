/// A past version's source, to read and never to type into.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/editor_highlight.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_scroll_port.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The text of the version being read, in the source pane's own look.
///
/// Drawn from the preview's reading rather than from the editor's buffer: the
/// buffer is the working copy and stays untouched under it, so `Back to now`
/// finds it as it was left. Nothing here writes, marks or offers
/// (`docs/product/git-workflow/file-history/doc.md`).
class EditorVersionWidget extends ConsumerStatefulWidget {
  /// Creates the pane over whatever version the preview has read.
  const EditorVersionWidget({this.link, super.key});

  /// The link to the preview beside this pane — that version's rendering —
  /// or null while it has the area to itself.
  final DocumentScrollLink? link;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DocumentScrollLink?>('link', link));
  }

  @override
  ConsumerState<EditorVersionWidget> createState() =>
      _EditorVersionWidgetState();
}

class _EditorVersionWidgetState extends ConsumerState<EditorVersionWidget> {
  final CodeLineEditingController _controller =
      CodeLineEditingController.fromText('');
  final CodeScrollController _scroll = CodeScrollController();

  /// This pane's end of the link to the version's rendering.
  late final EditorScrollPort _port = EditorScrollPort(
    scroll: _scroll,
    lineCount: () => _controller.lineCount,
  );

  /// The text the controller was last given, so it is set only when another
  /// version arrives.
  String? _shown;

  static String? _contentOf(PreviewState state) =>
      state is PreviewReady ? state.document.document.content : null;

  void _show(String? text) {
    if (text != null && text != _shown) {
      _shown = text;
      _controller.text = text;
    }
  }

  @override
  void initState() {
    super.initState();
    _port.link = widget.link;
    _show(_contentOf(ref.read(previewProvider)));
    // Listened to rather than watched in `build`: the controller notifies
    // the editor, which may not be told while it is building.
    ref.listenManual<String?>(
      previewProvider.select(_contentOf),
      (String? _, String? next) => _show(next),
    );
  }

  @override
  void didUpdateWidget(EditorVersionWidget old) {
    super.didUpdateWidget(old);
    _port.link = widget.link;
  }

  @override
  void dispose() {
    _port.dispose();
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return ColoredBox(
      color: colors.surfaceRaised,
      child: CodeEditor(
        controller: _controller,
        scrollController: _scroll,
        readOnly: true,
        wordWrap: true,
        indicatorBuilder:
            (
              BuildContext context,
              CodeLineEditingController controller,
              CodeChunkController chunks,
              CodeIndicatorValueNotifier notifier,
            ) {
              // Handed over inside the editor's build, as in the source pane.
              _port.takeLines(notifier);
              return SizedBox(
                width: EditorDesign.numbers,
                // A `Stack` hands its child loose constraints, which is what
                // the numbers column needs to size itself (as in the source
                // pane).
                child: Stack(
                  children: <Widget>[
                    OverflowBox(
                      alignment: Alignment.topRight,
                      maxWidth: double.infinity,
                      child: DefaultCodeLineNumber(
                        controller: controller,
                        notifier: notifier,
                        minNumberCount: 1,
                        textStyle: _numberStyle(colors.textMuted),
                        focusedTextStyle: _numberStyle(colors.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            },
        padding: const EdgeInsets.only(
          left: EditorDesign.numbersToCode,
          right: TomMetrics.pad,
        ),
        style: CodeEditorStyle(
          fontSize: EditorDesign.code,
          fontHeight: EditorDesign.codeHeight,
          fontFamily: TomFonts.mono,
          textColor: colors.textPrimary,
          backgroundColor: Colors.transparent,
          cursorColor: colors.accent,
          selectionColor: colors.accentSoft,
          codeTheme: editorHighlightOf(colors, Theme.of(context).brightness),
        ),
      ),
    );
  }

  /// The source pane's number, so the two keep step.
  static TextStyle _numberStyle(Color ink) => TextStyle(
    fontSize: EditorDesign.lineNumber,
    height:
        EditorDesign.code * EditorDesign.codeHeight / EditorDesign.lineNumber,
    fontFamily: TomFonts.mono,
    color: ink,
  );
}
