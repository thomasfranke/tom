/// Fetch and Push, where the design puts them.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Fetch and Push, and how far the branch has drifted from its remote.
///
/// Two buttons and never a combined Sync, since that is one name for three
/// risks (`docs/product/git-workflow/push-pull/the-controls/doc.md`); Pull is the remedy
/// inside the rejection, where the design draws it.
class ShellRemoteActionsWidget extends ConsumerWidget {
  /// Creates the actions.
  const ShellRemoteActionsWidget({super.key});

  /// The wireframe's button box and the gap before it.
  static const double _buttonWidth = 120;
  static const double _buttonHeight = 28;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GitStatusValueObject? git = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    if (git == null) {
      // Nothing has read git yet: a button that cannot say what it would do
      // is worse than no button.
      return const SizedBox.shrink();
    }
    final RemoteState remote = ref.watch(remoteProvider);
    return Row(
      children: <Widget>[
        _DriftWidget(git: git),
        const SizedBox(width: _gap * 2),
        _ActionWidget(
          label: 'Fetch',
          action: RemoteActionEnum.fetch,
          remote: remote,
          onPressed: () => unawaited(ref.read(remoteProvider.notifier).fetch()),
        ),
        const SizedBox(width: _gap),
        _ActionWidget(
          label: 'Push',
          action: RemoteActionEnum.push,
          remote: remote,
          // Nothing to publish is said by the button, not reported after.
          onPressed: git.ahead == 0
              ? null
              : () => unawaited(ref.read(remoteProvider.notifier).push()),
        ),
      ],
    );
  }
}

/// How far ahead of and behind its remote the branch is; one item as the
/// design writes it, absent when there is nothing to count.
class _DriftWidget extends StatelessWidget {
  const _DriftWidget({required this.git});

  final GitStatusValueObject git;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GitStatusValueObject>('git', git));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    if (git.ahead == 0 && git.behind == 0) {
      return const SizedBox.shrink();
    }
    return Text(
      <String>[
        if (git.ahead > 0) '↑ ${git.ahead}',
        if (git.behind > 0) '↓ ${git.behind}',
      ].join('  '),
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        // Behind is the half that needs doing something about, so it is the
        // half allowed a colour.
        color: git.behind > 0 ? colors.modified : colors.textSecondary,
      ),
    );
  }
}

/// One remote action, disabled while any of them is running.
class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    required this.label,
    required this.action,
    required this.remote,
    required this.onPressed,
  });

  final String label;
  final RemoteActionEnum action;
  final RemoteState remote;
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(EnumProperty<RemoteActionEnum>('action', action))
      ..add(DiagnosticsProperty<RemoteState>('remote', remote))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final bool isThisOne =
        remote is RemoteWorking && (remote as RemoteWorking).action == action;
    return SizedBox(
      width: ShellRemoteActionsWidget._buttonWidth,
      height: ShellRemoteActionsWidget._buttonHeight,
      child: OutlinedButton(
        // All wait on one another: git serializes them per space underneath,
        // so a second press would only queue.
        onPressed: remote.isBusy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textSecondary,
          disabledForegroundColor: colors.textMuted,
          side: BorderSide(color: colors.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        // The one that is working says so; the others wait.
        child: Text(isThisOne ? '$label…' : label),
      ),
    );
  }
}
