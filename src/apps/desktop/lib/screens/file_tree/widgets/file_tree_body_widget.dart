/// The tree itself, or the one line that explains why there is none.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_note_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_rows_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The tree itself, or the one line that explains why there is none.
class FileTreeBodyWidget extends StatelessWidget {
  /// Creates the body for [state], marked by [changes].
  const FileTreeBodyWidget({
    required this.state,
    this.changes = const FileTreeChanges.none(),
    super.key,
  });

  /// What the file tree is showing.
  final FileTreeState state;

  /// What git says about the rows, by path.
  final FileTreeChanges changes;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FileTreeState>('state', state))
      ..add(DiagnosticsProperty<FileTreeChanges>('changes', changes));
  }

  @override
  Widget build(BuildContext context) => switch (state) {
    // The shell only shows with a space open, so nobody reaches this state.
    FileTreeInitial() => const SizedBox.shrink(),
    FileTreeLoading() => const FileTreeNoteWidget('Reading the folder…'),
    FileTreeFailed(failure: final AppFailure failure) => FileTreeNoteWidget(
      _explain(failure),
    ),
    final FileTreeReady ready => FileTreeRowsWidget(
      rows: ready.rowsWith(changes),
    ),
  };

  /// What to say about a space folder that could not be read; an unreadable
  /// folder inside it costs that folder, not the tree.
  ///
  /// A catch-all, because this switches over [AppFailure] itself.
  static String _explain(AppFailure failure) => switch (failure) {
    SpaceFolderMissing() => 'This folder is no longer there.',
    SpaceAccessDenied() => 'TOM is not allowed to read this folder.',
    _ => 'This folder could not be read.',
  };
}
