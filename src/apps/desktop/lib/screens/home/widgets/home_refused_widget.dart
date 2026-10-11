/// What Home says when a folder does not open.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_primary_button_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// Why a folder did not open: gone, no git on the machine, or anything else.
///
/// No recent list, as the design draws it: a state to move on from in one
/// click, and a second list of choices would make the retry look optional.
class HomeRefusedWidget extends ConsumerWidget {
  /// Creates the refusal explaining [failure].
  const HomeRefusedWidget({required this.failure, super.key});

  /// Why the folder did not open.
  final AppFailure failure;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppFailure>('failure', failure));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final (String headline, String? path, String explanation) said =
        // No case for a folder outside a repository: it opens
        // (`docs/product/workspace/without-a-repository/doc.md`).
        switch (failure) {
          SpaceFolderMissing(root: final String root) => (
            l10n.homeRefusedFolderMissing,
            root,
            l10n.homeRefusedFolderMissingWhy,
          ),
          GitNotInstalled() => (
            l10n.homeRefusedNoGit,
            null,
            l10n.homeRefusedNoGitWhy,
          ),
          GitTooOld(found: final String found) => (
            l10n.homeRefusedGitTooOld,
            null,
            l10n.homeRefusedGitTooOldWhy(found),
          ),
          _ => (l10n.homeRefusedUnopened, null, l10n.homeRefusedUnopenedWhy),
        };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          said.$1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        if (said.$2 case final String path) ...<Widget>[
          const SizedBox(height: HomeDesign.headingToPath),
          // A box, because the path reads as quoted.
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
            ),
            // Padded to the design's height rather than given it: a box told
            // its height needs something to centre the text, and anything
            // that centres takes every pixel of width it is offered.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TomMetrics.pad,
                vertical: (HomeDesign.pathBox - HomeDesign.pathLine) / 2,
              ),
              child: SelectableText(
                path,
                style: TextStyle(
                  fontFamily: TomFonts.mono,
                  fontSize: 13.5,
                  height: HomeDesign.pathLine / 13.5,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: HomeDesign.pathToBody),
        SizedBox(
          width: HomeDesign.body,
          child: Text(
            said.$3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: colors.textSecondary,
            ),
          ),
        ),
        // No other folder would open either, so no way to choose one is
        // offered (`docs/product/home/opening-a-space/doc.md`).
        if (failure is! GitTooOld) ...<Widget>[
          const SizedBox(height: HomeDesign.bodyToRetry),
          HomePrimaryButtonWidget(
            label: l10n.homeChooseAnotherFolder,
            width: HomeDesign.retry,
            onPressed: () => chooseFolder(ref),
          ),
        ],
      ],
    );
  }
}
