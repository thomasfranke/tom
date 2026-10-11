/// Something is happening and there is nothing to decide yet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Something is happening and there is nothing to decide yet — or, when a
/// command waits in the Commands panel, that it is the person being waited
/// for.
///
/// Text rather than a spinner: a spinner animates forever when the read
/// never finishes, which makes a stuck app look busy and hangs
/// `pumpAndSettle` in an end-to-end run.
class HomeWorkingWidget extends ConsumerWidget {
  /// Creates the line.
  const HomeWorkingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isWaiting = ref.watch(
      commandsProvider.select((CommandsState it) => it.waiting > 0),
    );
    return Text(
      isWaiting
          ? context.l10n.homeWaitingForApproval
          : context.l10n.homeOpening,
      style: TextStyle(fontSize: 13, color: TomColors.of(context).textMuted),
    );
  }
}
