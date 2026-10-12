/// The ↶ at the end of a row of the changes list.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Puts one file back, after asking — always drawn, because a control that
/// appears on hover is one nobody finds
/// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
///
/// The question says how far back the file goes, which the row decides
/// ([DiscardKindEnum.of]); a conflicted row draws nothing here.
class ChangesDiscardWidget extends ConsumerWidget {
  /// Creates the control for [entry].
  const ChangesDiscardWidget({
    required this.entry,
    required this.isBusy,
    super.key,
  });

  /// The change it puts back.
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
    final DiscardKindEnum? kind = DiscardKindEnum.of(entry);
    if (kind == null) {
      return const SizedBox.square(dimension: ChangesDesign.discard);
    }
    final AppLocalizations l10n = context.l10n;
    final String label = kind == DiscardKindEnum.delete
        ? l10n.changesDelete
        : l10n.changesDiscardChanges;
    // The glyph sits where the board draws it and the press reaches past
    // it, the way the checkbox's does at the other end of the row.
    return SizedBox.square(
      dimension: ChangesDesign.discard,
      child: OverflowBox(
        maxWidth: TomMetrics.mark,
        maxHeight: TomMetrics.mark,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: isBusy
                ? null
                : () => unawaited(_confirm(context, ref, kind, label)),
            customBorder: const CircleBorder(),
            child: Center(
              child: TomGlyphWidget(
                glyph: TomGlyphEnum.discard,
                size: ChangesDesign.discard,
                color: TomColors.of(context).textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Asks before [kind] goes ahead, naming the file and what it costs.
  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    DiscardKindEnum kind,
    String action,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final String name = entry.path.name;
    final bool? discard = await TomDialogWidget.show<bool>(
      context,
      title: kind == DiscardKindEnum.delete
          ? l10n.changesDeleteFile(name)
          : l10n.changesDiscardChangesTo(name),
      body: <String>[
        switch (kind) {
          DiscardKindEnum.toStaged => l10n.changesDiscardKeepsStaged,
          DiscardKindEnum.toLastCommit => l10n.changesDiscardSinceCommit,
          DiscardKindEnum.delete => l10n.changesDeleteNeverCommitted,
        },
      ],
      actions: (void Function(bool) answer) => <TomDialogAction>[
        TomDialogAction(
          label: l10n.changesDiscardCancel,
          onPressed: () => answer(false),
        ),
        TomDialogAction(
          label: action,
          onPressed: () => answer(true),
          destructive: true,
        ),
      ],
    );
    // Dismissed without choosing is *do nothing*, never a default.
    if (discard ?? false) {
      await ref.read(changesProvider.notifier).discard(entry);
    }
  }
}
