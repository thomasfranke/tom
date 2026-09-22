/// Every visible row, scrolling as one.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_note_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Every visible row, scrolling as one.
///
/// Which rows are visible is the state's answer, not this widget's: a closed
/// folder is filtered out before it ever gets here.
class FileTreeRowsWidget extends ConsumerWidget {
  /// Creates the list of [rows].
  const FileTreeRowsWidget({required this.rows, super.key});

  /// What to draw, top-level first.
  final List<FileTreeRow> rows;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<FileTreeRow>('rows', rows));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rows.isEmpty) {
      return const FileTreeNoteWidget('This folder holds nothing yet.');
    }
    final SpaceRelativePathValueObject? open = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    return ListView.builder(
      // The design's pitch, and what lets the list build lazily: a space
      // with a thousand documents lays out the dozen rows on screen.
      itemExtent: FileTreeDesign.rowPitch,
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) => FileTreeRowWidget(
        row: rows[index],
        isOpen: rows[index].entry.path == open,
      ),
    );
  }
}
