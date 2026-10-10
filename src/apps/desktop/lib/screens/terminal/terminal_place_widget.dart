/// What the terminal says after the tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/terminal/terminal_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `zsh · ~/work/docs` — the shell, and the folder it opened in with the
/// home folder spelled `~`; nothing until a shell has answered.
class TerminalPlaceWidget extends ConsumerWidget {
  /// Creates the line.
  const TerminalPlaceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (String, String)? place = switch (ref.watch(terminalProvider)) {
      TerminalRunning(:final String shell, :final String folder) ||
      TerminalExited(
        :final String shell,
        :final String folder,
      ) => (shell, folder),
      _ => null,
    };
    if (place == null) {
      return const SizedBox.shrink();
    }
    final (String shell, String folder) = place;
    return Text(
      context.l10n.terminalPlace(
        shell,
        terminalPlaceOf(folder, ref.watch(homeFolderProvider)),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: TerminalDesign.place,
        height: 1.3,
        color: TomColors.of(context).textMuted,
      ),
    );
  }
}
