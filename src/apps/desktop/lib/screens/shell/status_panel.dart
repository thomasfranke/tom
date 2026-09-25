/// The status bar's content: where the space is, and what is open in it.
library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What the status bar says: the space, the open document, the branch and
/// its drift.
///
/// Every item is absent rather than empty, since a zero has to be read
/// twice to be ignored; with no space open it uses Home's own words.
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
          // Unsaved is said in words here and as a dot in the mode bar, so
          // work is never lost quietly.
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

  /// What git is worth saying, in order, leaving out what is nothing.
  ///
  /// A detached `HEAD` is named rather than left blank: it is a state to get
  /// out of, not a missing value.
  static List<String> _gitItems(GitStatusValueObject? git) {
    if (git == null) {
      return const <String>[];
    }
    final int changes = git.entries.length;
    // One item, the way the design writes it.
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

  /// The save shortcut in the platform's own spelling, read the same way the
  /// editor picks the binding so the words and the key cannot come apart.
  static String get _saveShortcut =>
      defaultTargetPlatform == TargetPlatform.macOS
      ? '⌘S to save'
      : 'Ctrl+S to save';

  /// [path] with the home folder written as `~`, as the design shows it;
  /// left alone when there is no home to shorten against.
  static String _shortened(String path) {
    final String? home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty || !path.startsWith(home)) {
      return path;
    }
    return '~${path.substring(home.length)}';
  }
}
