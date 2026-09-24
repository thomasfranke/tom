/// One entry of the tree, as the design draws it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_centred_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One entry, as the design draws it.
///
/// **The open document takes the accent** — which marks the current thing
/// and nothing else — and a file the editor cannot open is muted *and* has
/// no hover, because colour is never the only signal
/// (`docs/product/navigation/file-tree/doc.md`).
class FileTreeRowWidget extends ConsumerWidget {
  /// Creates the row for [row].
  const FileTreeRowWidget({
    required this.row,
    required this.isOpen,
    this.isDirty = false,
    super.key,
  });

  /// What this row shows.
  final FileTreeRow row;

  /// Whether this is the document the window is showing.
  final bool isOpen;

  /// Whether this document has edits the file on disk does not.
  ///
  /// Drawn where the eye already is — the tree is how a file is chosen, so
  /// it is where a file with unsaved work has to say so.
  final bool isDirty;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FileTreeRow>('row', row))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(DiagnosticsProperty<bool>('isDirty', isDirty));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final double labelLeft =
        FileTreeDesign.labelLeft + row.depth * FileTreeDesign.indent;
    final bool isOpenable = row.isFolder || row.entry.isDocument;
    final Color color = switch ((isOpen, row.isFolder, isOpenable)) {
      (true, _, _) => colors.accent,
      (false, true, _) => colors.textPrimary,
      (false, false, true) => colors.textSecondary,
      (false, false, false) => colors.textMuted,
    };
    final Widget content = Stack(
      children: <Widget>[
        if (isOpen)
          Positioned(
            left: FileTreeDesign.rowInset,
            right: FileTreeDesign.rowInset,
            top: 0,
            height: FileTreeDesign.rowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(FileTreeDesign.radius),
              ),
            ),
          ),
        if (row.isFolder)
          FileTreeCentredWidget(
            left: labelLeft - FileTreeDesign.chevronOffset,
            child: Text(
              row.isExpanded ? '▾' : '▸',
              style: fileTreeRowText(
                size: FileTreeDesign.chevron,
                color: colors.textMuted,
              ),
            ),
          ),
        if (isDirty)
          Positioned(
            right: FileTreeDesign.dirtyDotRight,
            top: 0,
            height: FileTreeDesign.rowHeight,
            child: Center(
              child: SizedBox(
                width: FileTreeDesign.dirtyDot,
                height: FileTreeDesign.dirtyDot,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.modified,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        FileTreeCentredWidget(
          left: labelLeft,
          // The name stops before the dot rather than running under it: an
          // ellipsis is a smaller loss than a mark nobody can see.
          right: isDirty
              ? FileTreeDesign.dirtyDotRight + FileTreeDesign.dirtyDot + 8
              : FileTreeDesign.rowInset,
          child: Text(
            row.entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: fileTreeRowText(
              size: FileTreeDesign.row,
              color: color,
              weight: isOpen
                  ? FontWeight.w600
                  : (row.isFolder ? FontWeight.w500 : FontWeight.w400),
            ),
          ),
        ),
      ],
    );
    if (!isOpenable) {
      return content;
    }
    return InkWell(
      onTap: () => ref.read(fileTreeProvider.notifier).activate(row.entry),
      child: content,
    );
  }
}
