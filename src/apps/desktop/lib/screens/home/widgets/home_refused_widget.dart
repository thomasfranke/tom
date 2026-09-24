/// The one way opening a folder fails, and everything else.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_primary_button_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The one way opening a folder fails, and everything else.
///
/// No recent list: the design draws this screen with the retry and the one
/// line about repositories, and nothing else. It is a state to move on from
/// in one click, and a second list of choices underneath would make the
/// first one look optional.
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
    final (String headline, String? path, String explanation) said =
        switch (failure) {
          GitNotARepository(path: final String folder) => (
            'That folder is not inside a Git repository',
            folder,
            'TOM works on documentation that is already versioned. Open a '
                'folder inside a repository — the repository root, or any '
                'folder within it.',
          ),
          SpaceFolderMissing(root: final String root) => (
            'That folder is no longer there',
            root,
            'It may be on a disk that is not connected, or it was moved or '
                'renamed outside TOM.',
          ),
          GitNotInstalled() => (
            'TOM cannot find git on this machine',
            null,
            'TOM drives the git you already have. Install it, or make sure it '
                'is on your PATH, and try again.',
          ),
          _ => ('That folder could not be opened', null, failure.toString()),
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
          // A box, not a bare line: the folder is the one piece of this
          // screen the user did not write, and it reads as quoted.
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
            ),
            // Padded to the design's height rather than given it: a box
            // that is *told* how tall it is needs something inside to
            // centre the text, and anything that centres also takes every
            // pixel of width it is offered — which drew the quote as a band
            // across the window.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TomMetrics.pad,
                vertical: (HomeDesign.pathBox - HomeDesign.pathLine) / 2,
              ),
              child: SelectableText(
                path,
                style: TextStyle(
                  fontFamily: 'Menlo',
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
        const SizedBox(height: HomeDesign.bodyToRetry),
        HomePrimaryButtonWidget(
          label: 'Choose another folder…',
          width: HomeDesign.retry,
          onPressed: () => chooseFolder(ref),
        ),
        const SizedBox(height: HomeDesign.retryToHint),
        // The line the product insists on: TOM never creates a repository on
        // the user's behalf, and says so rather than leaving them looking
        // for the button.
        Text(
          'Creating a repository is not something TOM does.',
          style: TextStyle(fontSize: 13, height: 1.5, color: colors.textMuted),
        ),
      ],
    );
  }
}
