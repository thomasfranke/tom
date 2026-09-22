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
  /// Creates the body for [state].
  const FileTreeBodyWidget({required this.state, super.key});

  /// What the file tree is showing.
  final FileTreeState state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FileTreeState>('state', state));
  }

  @override
  Widget build(BuildContext context) => switch (state) {
    // Nothing at all with no space open: the shell only shows with one, so
    // an explanation here would be for a state nobody reaches.
    FileTreeInitial() => const SizedBox.shrink(),
    FileTreeLoading() => const FileTreeNoteWidget('Reading the folder…'),
    FileTreeFailed(failure: final AppFailure failure) => FileTreeNoteWidget(
      _explain(failure),
    ),
    final FileTreeReady ready => FileTreeRowsWidget(rows: ready.rows),
  };

  /// What to say about a folder that could not be read.
  ///
  /// Only the space's own folder gets here; one unreadable folder inside it
  /// costs that folder, not the tree. The catch-all is because this switches
  /// over [AppFailure] itself, and silence would be worse than a vague line.
  static String _explain(AppFailure failure) => switch (failure) {
    SpaceFolderMissing() => 'This folder is no longer there.',
    SpaceAccessDenied() => 'TOM is not allowed to read this folder.',
    _ => 'This folder could not be read.',
  };
}
