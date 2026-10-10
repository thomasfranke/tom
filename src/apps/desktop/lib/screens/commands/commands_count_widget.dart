/// What the commands panel says after the tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `N this session` — every command since the window opened, the ones the
/// list has already let go of included.
class CommandsCountWidget extends ConsumerWidget {
  /// Creates the count.
  const CommandsCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    context.l10n.commandsThisSession(
      ref.watch(commandsProvider.select((CommandsState it) => it.total)),
    ),
    maxLines: 1,
    style: TextStyle(
      fontSize: 11.5,
      height: 1.3,
      color: TomColors.of(context).textMuted,
    ),
  );
}
