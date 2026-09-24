/// The status bar's content: where the space is, and what is open in it.
library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What the status bar says.
///
/// Read, never worked in: it states facts and offers no action — the space,
/// the open document, the branch and how far it has drifted from its remote.
///
/// **Every item is absent rather than empty.** A counter with nothing to
/// count, or "in sync" beside two unpushed commits, would be chrome that
/// has to be read twice to be ignored.
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
    final bool isDirty = ref.watch(
      editorProvider.select((EditorState state) => state.isDirty),
    );
    return Row(
      children: <Widget>[
        Text(_shortened(session.space.root), style: style),
        if (session.openDocument
            case final SpaceRelativePathValueObject document) ...<Widget>[
          const SizedBox(width: _gap),
          // The mark in the document's own words, not a symbol: the mode
          // bar's dot says the same thing to whoever is looking there, and
          // the one thing a text editor may never do is lose work quietly.
          Text(
            isDirty ? '${document.value} — unsaved' : document.value,
            style: style,
          ),
          if (isDirty) ...<Widget>[
            const SizedBox(width: _gap),
            Text(_saveShortcut, style: style),
          ],
        ],
        for (final String item in _gitItems(session.git)) ...<Widget>[
          const SizedBox(width: _gap),
          Text(item, style: style),
        ],
      ],
    );
  }

  /// What git is worth saying here, in order, leaving out what is nothing.
  ///
  /// A detached `HEAD` is named as that rather than left blank: "no branch"
  /// is a state somebody has to get out of, not a missing value.
  static List<String> _gitItems(GitStatusValueObject? git) {
    if (git == null) {
      return const <String>[];
    }
    final int changes = git.entries.length;
    // One item, the way the design writes it: how far the branch has
    // drifted is one fact, not two that happen to sit together.
    final String drift = <String>[
      if (git.ahead > 0) '${git.ahead} ahead',
      if (git.behind > 0) '${git.behind} behind',
    ].join(', ');
    return <String>[
      if (git.isDetached)
        'detached HEAD'
      else if (git.branch case final BranchNameValueObject branch)
        branch.value,
      if (changes > 0) '$changes change${changes == 1 ? '' : 's'}',
      if (drift.isNotEmpty) drift,
    ];
  }

  /// What the design puts beside an unsaved document.
  ///
  /// The platform's own spelling, because a Mac user reading `Ctrl+S` would
  /// try it — and read the same way the editor picks the binding, so the
  /// words and the key cannot come apart.
  static String get _saveShortcut =>
      defaultTargetPlatform == TargetPlatform.macOS
      ? '⌘S to save'
      : 'Ctrl+S to save';

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
