/// The status bar's content: where the space is, and what is open in it.
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// What the status bar says.
///
/// Read, never worked in: it states facts and offers no action. The design
/// gives it the space, the open document and the branch — **the branch and
/// its ahead/behind counter are M1**, and absent beats a counter with
/// nothing to count.
///
/// With no space open it says so in Home's own words: the two bars are one
/// piece of chrome and must not describe one situation two ways.
class StatusPanel extends ConsumerWidget {
  /// Creates the panel.
  const StatusPanel({super.key});

  /// The gap between two items, from the design.
  static const double _gap = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    final TomColors colors = TomColors.of(context);
    final TextStyle style = TextStyle(
      fontSize: 11,
      height: 1.4,
      color: colors.textMuted,
    );
    if (session == null) {
      return Text('no space open', style: style);
    }
    return Row(
      children: <Widget>[
        Text(_shortened(session.space.root), style: style),
        if (session.openDocument
            case final SpaceRelativePath document) ...<Widget>[
          const SizedBox(width: _gap),
          Text(document.value, style: style),
        ],
      ],
    );
  }

  /// [path] with the home folder written as `~`.
  ///
  /// What the design shows, and not only for looks: this is the one place
  /// the whole path is on screen, and an absolute path under a home folder
  /// is mostly the home folder. Left alone when there is no home to shorten
  /// against.
  static String _shortened(String path) {
    final String? home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty || !path.startsWith(home)) {
      return path;
    }
    return '~${path.substring(home.length)}';
  }
}
