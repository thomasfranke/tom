/// One path git reports, with the checkbox that stages it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/widgets/file_state_mark_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One change: what happened, to what, and whether it is going in.
///
/// The checkbox is the staging, whole files and nothing finer
/// (`docs/product/git-workflow/commit/the-changes-list/doc.md`); the path is the
/// repository's, not the space's (see `ChangesPanel`).
class ChangesRowWidget extends ConsumerWidget {
  /// Creates the row for [entry].
  const ChangesRowWidget({
    required this.entry,
    required this.isBusy,
    super.key,
  });

  /// The change this row shows.
  final StatusEntryValueObject entry;

  /// Whether git is already doing something.
  final bool isBusy;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<StatusEntryValueObject>('entry', entry))
      ..add(DiagnosticsProperty<bool>('isBusy', isBusy));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
      child: SizedBox(
        height: ChangesDesign.rowHeight,
        child: Row(
          children: <Widget>[
            TomCheckWidget(
              isChecked: entry.isStaged,
              onChanged: isBusy
                  ? null
                  : (bool staged) => unawaited(
                      ref
                          .read(changesProvider.notifier)
                          .setStaged(entry.path, staged),
                    ),
            ),
            const SizedBox(width: 10),
            FileStateMarkWidget(state: entry.state),
            const SizedBox(width: 10),
            Expanded(
              child: Tooltip(
                message: entry.path.value,
                // The name, then the folder under it: two files called
                // `doc.md` are the normal case in this repository, and a
                // column of them says nothing until the folder is there
                // (`design/screens/desktop/git-commit/committing-dark.svg`).
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.path.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ChangesDesign.row,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (_folder case final String folder when folder.isNotEmpty)
                      Text(
                        folder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ChangesDesign.folder,
                          height: 1.4,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The folder the file is in, or empty at the repository's own root.
  String get _folder {
    final int cut = entry.path.value.lastIndexOf('/');
    return cut < 0 ? '' : entry.path.value.substring(0, cut);
  }
}
