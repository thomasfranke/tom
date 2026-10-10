/// One path git reports, with the checkbox that stages it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_discard_widget.dart';
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
    final ChangesNotifier changes = ref.read(changesProvider.notifier);
    // What the commit in flight is about to change goes quiet, so the press
    // is seen to have landed (`git-workflow/commit/confirming/doc.md`).
    final bool isDimmed =
        entry.isStaged &&
        ref.watch(
          changesProvider.select(
            (ChangesState state) => state is ChangesReady && state.isCommitting,
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: TomCheckWidget.box,
            child: OverflowBox(
              maxWidth: TomCheckWidget.target,
              maxHeight: TomCheckWidget.target,
              child: TomCheckWidget(
                alignment: Alignment.center,
                isChecked: entry.isStaged,
                onChanged: isBusy
                    ? null
                    : (bool staged) => unawaited(
                        ref
                            .read(changesProvider.notifier)
                            .setStaged(entry.path, staged),
                      ),
              ),
            ),
          ),
          const SizedBox(width: ChangesDesign.rowGap),
          FileStateMarkWidget(state: entry.state),
          const SizedBox(width: ChangesDesign.rowGap),
          // The name, then the folder beside it: two files called `doc.md`
          // are the normal case in this repository, and a column of them
          // says nothing until the folder is there. Pressing it opens the
          // document with the diff on, when it is one the app opens.
          Expanded(
            child: Tooltip(
              message: entry.path.value,
              child: InkWell(
                onTap: changes.canOpen(entry)
                    ? () => unawaited(changes.open(entry))
                    : null,
                borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        entry.path.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ChangesDesign.row,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: isDimmed
                              ? colors.textMuted
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    if (_folder case final String folder
                        when folder.isNotEmpty) ...<Widget>[
                      const SizedBox(width: ChangesDesign.folderGap),
                      Flexible(
                        child: Text(
                          folder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ChangesDesign.folder,
                            height: 1.4,
                            color: isDimmed
                                ? colors.textMuted.withValues(alpha: _dimmed)
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: ChangesDesign.rowGap),
          // A file already on its way into a commit has nothing to put back.
          if (isDimmed)
            const SizedBox.square(dimension: ChangesDesign.discard)
          else
            ChangesDiscardWidget(entry: entry, isBusy: isBusy),
        ],
      ),
    );
  }

  /// How much of `text_muted` a dimmed folder keeps: the folder already wears
  /// the quietest role, so it steps below it rather than staying put.
  static const double _dimmed = 0.6;

  /// The folder the file is in, or empty at the repository's own root.
  String get _folder {
    final int cut = entry.path.value.lastIndexOf('/');
    return cut < 0 ? '' : entry.path.value.substring(0, cut);
  }
}
