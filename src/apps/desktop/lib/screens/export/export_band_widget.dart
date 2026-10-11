/// Where the last export went, said above the document.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/widgets/home_relative_path.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The band an export leaves behind, and nothing while there is none
/// (`docs/product/export/doc.md`, `editor-links-export/exported-dark.svg`).
///
/// The same band the remote speaks through, because a confirmation, a
/// refusal and work in flight are one component in three colours.
class ExportBandWidget extends ConsumerWidget {
  /// Creates the band.
  const ExportBandWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    return switch (ref.watch(exportProvider)) {
      ExportIdle() => const SizedBox.shrink(),
      ExportWorking(:final String destination) => NoticeBandWidget(
        sentence: l10n.exportExporting(_name(destination)),
        // Still in flight: neither a refusal nor a result.
        ink: colors.accent,
        fill: colors.accentSoft,
      ),
      ExportExported(:final String destination) => NoticeBandWidget(
        sentence: l10n.exportExported(
          _name(destination),
          homeRelative(ExportNotifier.folderOf(destination)),
        ),
        ink: colors.added,
        fill: colors.addedSoft,
        action: l10n.exportReveal,
        onAction: () => unawaited(ref.read(exportProvider.notifier).reveal()),
      ),
      ExportFailed(:final String destination, :final AppFailure failure) =>
        NoticeBandWidget(
          sentence: l10n.exportFailed(_name(destination), _why(l10n, failure)),
          ink: colors.removed,
          fill: colors.removedSoft,
        ),
    };
  }

  /// The file's own name, which is what the reader chose in the dialog.
  static String _name(String destination) =>
      destination.substring(ExportNotifier.folderOf(destination).length + 1);

  /// What went wrong, in the product's words; a catch-all, because the
  /// document may also fail to be read or parsed on the way.
  static String _why(AppLocalizations l10n, AppFailure failure) =>
      switch (failure) {
        ExportCannotWrite() => l10n.exportCannotWrite,
        ExportTooLarge() => l10n.exportTooLarge,
        ExportUnsupported(:final ExportFormatEnum format) =>
          l10n.exportUnsupported(format.name.toUpperCase()),
        _ => l10n.exportUnreadable,
      };
}
