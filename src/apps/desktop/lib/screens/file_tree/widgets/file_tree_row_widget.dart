/// One entry of the tree, as the design draws it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_centred_widget.dart';
import 'package:tom_desktop/widgets/file_state_mark_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One entry, as the design draws it.
///
/// A file the editor cannot open is muted *and* has no hover, because colour
/// is never the only signal
/// (`docs/product/navigation/file-tree/change-marks/doc.md`).
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
  final bool isDirty;

  /// How much of the right edge the name may not reach into.
  ///
  /// Whichever mark this row carries: an unsaved dot sits further in than
  /// git's letter, so it is the one that reserves the most.
  double get _rightInset {
    if (isDirty) {
      return FileTreeDesign.dirtyDotRight + FileTreeDesign.dirtyDot + 8;
    }
    if (row.change != null) {
      return FileTreeDesign.rowInset + TomMetrics.mark + 8;
    }
    if (row.holdsChange) {
      return FileTreeDesign.rowInset + FileTreeDesign.dirtyDot * 2 + 8;
    }
    return FileTreeDesign.rowInset;
  }

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
            child: TomChevronWidget(
              isOpen: row.isExpanded,
              color: colors.textMuted,
            ),
          ),
        // Git's letter, at the right of the row, in the changes column's own
        // alphabet — the tree and that column never disagree about a file.
        if (row.change != null)
          Positioned(
            right: FileTreeDesign.rowInset,
            top: 0,
            height: FileTreeDesign.rowHeight,
            child: Center(child: FileStateMarkWidget(state: row.change!)),
          ),
        // A folder cannot show letters for rows it is not showing, so it
        // shows that there is something to open.
        if (row.holdsChange)
          Positioned(
            right: FileTreeDesign.rowInset + FileTreeDesign.dirtyDot,
            top: 0,
            height: FileTreeDesign.rowHeight,
            child: Center(
              child: SizedBox(
                width: FileTreeDesign.dirtyDot,
                height: FileTreeDesign.dirtyDot,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
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
          // The name stops before whatever is at the right: an ellipsis is a
          // smaller loss than a mark nobody can see.
          right: _rightInset,
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
