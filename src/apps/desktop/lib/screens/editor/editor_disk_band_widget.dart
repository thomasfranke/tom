/// The band that says a file changed on disk under unsaved edits.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Above the tab on screen while its file changed under its edits — found
/// by a save that asked the disk first, for any document — offering
/// `Reload` and `Keep mine` (`docs/product/editor/source-mode/doc.md`).
///
/// At the screen's top level because the shell mounts it, beside the other
/// bands; in `modified`, the role the unsaved buffer already wears.
class EditorDiskBandWidget extends ConsumerWidget {
  /// Creates the band.
  const EditorDiskBandWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? name = ref.watch(
      editorProvider.select(
        (EditorState state) => switch (state) {
          EditorReady(changedOnDisk: true, :final DocumentEntity saved) =>
            saved.name,
          _ => null,
        },
      ),
    );
    if (name == null) {
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final EditorNotifier editor = ref.read(editorProvider.notifier);
    return NoticeBandWidget(
      sentence: l10n.preferencesChangedOnDisk(name),
      ink: colors.modified,
      fill: colors.modifiedSoft,
      alternative: l10n.preferencesKeepMine,
      onAlternative: editor.keepMine,
      action: l10n.commonReload,
      onAction: () => unawaited(editor.reload()),
    );
  }
}
