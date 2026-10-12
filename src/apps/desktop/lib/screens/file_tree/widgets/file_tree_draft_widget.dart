/// The row a new entry's name is typed into.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The field the `+` puts in the tree, at [depth], holding `untitled.md`
/// with the name selected so typing replaces it
/// (`docs/product/navigation/file-tree/new-document/doc.md`) — or, for the
/// menu's `New folder`, `untitled` with a folder's glyph.
///
/// Enter creates, Escape or a click elsewhere takes the row away; a refused
/// name keeps the row and the keyboard, outlined `removed`.
class FileTreeDraftWidget extends ConsumerStatefulWidget {
  /// Creates the row at [depth], refused while [isRefused].
  const FileTreeDraftWidget({
    required this.depth,
    this.isFolder = false,
    this.isRefused = false,
    super.key,
  });

  /// How deep it sits: one below the folder it creates into.
  final int depth;

  /// Whether a folder is being named rather than a document.
  final bool isFolder;

  /// Whether the last name typed was refused.
  final bool isRefused;

  /// What the field holds when a document is being named.
  static const String suggestion = 'untitled.md';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('depth', depth))
      ..add(DiagnosticsProperty<bool>('isFolder', isFolder))
      ..add(DiagnosticsProperty<bool>('isRefused', isRefused));
  }

  @override
  ConsumerState<FileTreeDraftWidget> createState() => _FileTreeDraftState();
}

class _FileTreeDraftState extends ConsumerState<FileTreeDraftWidget> {
  // `untitled` is what is selected — the whole of a folder's name, a
  // document's without its extension, VS Code's reading.
  late final TextEditingController _controller = TextEditingController(
    text: widget.isFolder ? 'untitled' : FileTreeDraftWidget.suggestion,
  )..selection = const TextSelection(baseOffset: 0, extentOffset: 8);

  late final FocusNode _focus = FocusNode(onKeyEvent: _escape)
    ..addListener(_blurred);

  /// Escape takes the row away, as a click elsewhere does.
  KeyEventResult _escape(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(fileTreeProvider.notifier).cancelDraft();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _blurred() {
    if (!_focus.hasFocus && mounted) {
      ref.read(fileTreeProvider.notifier).cancelDraft();
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_blurred)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final double left =
        FileTreeDesign.labelLeft +
        widget.depth * FileTreeDesign.indent -
        FileTreeDesign.draftInset;
    // As tall as its row, so nothing is left above or below it.
    return Padding(
      padding: EdgeInsets.only(left: left, right: FileTreeDesign.draftRight),
      child: TomFieldBoxWidget(
        height: FileTreeDesign.draftHeight,
        fill: colors.surfaceSunken,
        radius: FileTreeDesign.radius,
        // Accented whatever the focus says: the row exists only while it is
        // being typed in, and losing the keyboard takes it away.
        isFocused: true,
        isRefused: widget.isRefused,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: FileTreeDesign.draftGlyph,
              top: 0,
              bottom: 0,
              child: Center(
                child: TomGlyphWidget(
                  glyph: widget.isFolder
                      ? TomGlyphEnum.folder
                      : TomGlyphEnum.file,
                  color: widget.isFolder
                      ? colors.accentMuted
                      : colors.textMuted,
                  size: FileTreeDesign.glyph,
                ),
              ),
            ),
            Positioned.fill(
              child: TomFieldWidget(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                hint: '',
                fontSize: FileTreeDesign.row,
                fontWeight: FontWeight.w500,
                pad: FileTreeDesign.draftText,
                onSubmit: () => unawaited(
                  ref
                      .read(fileTreeProvider.notifier)
                      .submitDraft(_controller.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
