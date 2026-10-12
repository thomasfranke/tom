/// How an update found at opening is announced, quietly.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/about/about_dialog_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A dot in `accent` on the gear while a newer version is known; nothing
/// otherwise (`docs/product/about/doc.md`).
class UpdateDotWidget extends ConsumerWidget {
  /// Creates the dot.
  const UpdateDotWidget({super.key});

  /// Its diameter.
  static const double size = 7;

  /// Its centre's place in the gear's 24 box — 22 across and 3 down on the
  /// boards, which is past the box's corner (`an-update-is-waiting-dark.svg`).
  static const double top = -0.5;

  /// The dot's right edge past the box's right edge.
  static const double right = -1.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isNewer = ref.watch(
      updatesProvider.select((UpdatesState state) => state is UpdatesNewer),
    );
    if (!isNewer) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: top,
      right: right,
      child: Container(
        key: const Key('updateDot'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: TomColors.of(context).accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// `Update available: <version>` in the status bar, in `accent`, pressed to
/// open the dialog; nothing while no newer version is known.
class UpdateNoticeWidget extends ConsumerWidget {
  /// Creates the notice.
  const UpdateNoticeWidget({super.key});

  /// The dot's diameter.
  static const double noticeDot = 6;

  /// The dot to the sentence.
  static const double noticeGap = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? version = ref.watch(
      updatesProvider.select(
        (UpdatesState state) => switch (state) {
          UpdatesNewer(:final String version) => version,
          _ => null,
        },
      ),
    );
    if (version == null) {
      return const SizedBox.shrink();
    }
    final Color accent = TomColors.of(context).accent;
    return InkWell(
      onTap: () => unawaited(AboutDialogWidget.show(context)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The dot says it before the words do (`an-update-is-waiting`).
          Container(
            key: const Key('updateNoticeDot'),
            width: noticeDot,
            height: noticeDot,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: noticeGap),
          Text(
            context.l10n.shellUpdateAvailable(version),
            style: TextStyle(fontSize: 12, color: accent),
          ),
        ],
      ),
    );
  }
}
