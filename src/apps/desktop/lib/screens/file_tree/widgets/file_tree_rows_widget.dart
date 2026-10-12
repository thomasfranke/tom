/// Every visible row, scrolling as one.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_draft_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_note_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Every visible row, scrolling as one; which rows are visible is the
/// state's answer, not this widget's.
class FileTreeRowsWidget extends ConsumerWidget {
  /// Creates the list of [rows], with a new document's field at [draftAt].
  const FileTreeRowsWidget({
    required this.rows,
    this.draftAt,
    this.draftDepth = 0,
    this.isDraftFolder = false,
    this.isDraftRefused = false,
    super.key,
  });

  /// Whether the field names a folder rather than a document.
  final bool isDraftFolder;

  /// What to draw, top-level first.
  final List<FileTreeRow> rows;

  /// Where among [rows] the field goes, or null with none.
  final int? draftAt;

  /// How deep the field sits.
  final int draftDepth;

  /// Whether the name last typed in the field was refused.
  final bool isDraftRefused;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<FileTreeRow>('rows', rows))
      ..add(IntProperty('draftAt', draftAt))
      ..add(IntProperty('draftDepth', draftDepth))
      ..add(DiagnosticsProperty<bool>('isDraftFolder', isDraftFolder))
      ..add(DiagnosticsProperty<bool>('isDraftRefused', isDraftRefused));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? at = draftAt;
    if (rows.isEmpty && at == null) {
      return FileTreeNoteWidget(context.l10n.fileTreeEmpty);
    }
    final SpaceRelativePathValueObject? open = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    // Every tab's edits, not only the open one's; read once here rather than
    // in every row (`editor/tabs/doc.md`).
    final Set<DocumentTab> unsaved = ref.watch(unsavedDocumentsProvider);
    return ListView.builder(
      itemExtent: FileTreeDesign.rowPitch,
      itemCount: rows.length + (at == null ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == at) {
          return FileTreeDraftWidget(
            // By kind, so a folder's field never inherits a document's text.
            key: ValueKey<bool>(isDraftFolder),
            depth: draftDepth,
            isFolder: isDraftFolder,
            isRefused: isDraftRefused,
          );
        }
        final FileTreeRow row =
            rows[at != null && index > at ? index - 1 : index];
        return FileTreeRowWidget(
          row: row,
          isOpen: row.entry.path == open,
          isDirty: unsaved.contains(DocumentTab.inSpace(row.entry.path)),
        );
      },
    );
  }
}
