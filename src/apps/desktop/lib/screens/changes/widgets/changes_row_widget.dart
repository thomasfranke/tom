/// One path git reports, with the checkbox that stages it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_mark_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One change: what happened, to what, and whether it is going in.
///
/// **The checkbox is the staging** — whole files, one at a time, and there
/// is no hunk-level staging (`docs/product/git-workflow/commit/doc.md`).
///
/// The path is the repository's, not the space's: a commit records the
/// repository, so a file the space does not contain still has to be
/// visible when it is about to be committed.
class ChangesRowWidget extends ConsumerWidget {
  /// Creates the row for [entry], disabled while [isBusy].
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
            SizedBox(
              width: ChangesDesign.mark,
              height: ChangesDesign.mark,
              child: Checkbox(
                value: entry.isStaged,
                onChanged: isBusy
                    ? null
                    : (bool? staged) => unawaited(
                        ref
                            .read(changesProvider.notifier)
                            .setStaged(entry.path, staged ?? false),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            ChangesMarkWidget(state: entry.state),
            const SizedBox(width: 10),
            Expanded(
              child: Tooltip(
                message: entry.path.value,
                child: Text(
                  // The file's own name leads and the folders trail it,
                  // because the column is narrow and the name is what is
                  // being looked for.
                  entry.path.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ChangesDesign.row,
                    height: 1.4,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
