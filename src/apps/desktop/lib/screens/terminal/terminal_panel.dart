/// The person's own shell, under the document.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/terminal/widgets/terminal_emulator_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The `Terminal` tab of the panel under the document
/// (`docs/product/workspace/terminal/doc.md`).
///
/// One emulator per space, keyed by it: a space opened from the breadcrumb
/// keeps the shell on screen, and the old space's text must not stay there.
class TerminalPanel extends ConsumerWidget {
  /// Creates the panel.
  const TerminalPanel({super.key});

  /// The id it is registered under.
  static const String id = 'tom.terminal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space.root,
      ),
    );
    final AppFailure? failure = ref.watch(
      terminalProvider.select(
        (TerminalState it) => it is TerminalFailed ? it.failure : null,
      ),
    );
    if (failure != null) {
      final TextStyle muted = TextStyle(
        fontSize: 12.5,
        color: TomColors.of(context).textMuted,
      );
      // The cause is shown under the sentence: without it a build that
      // cannot load its native library reads like a machine without a shell.
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.terminalFailed, style: muted),
            const SizedBox(height: 6),
            SelectableText(
              '$failure',
              textAlign: TextAlign.center,
              style: muted.copyWith(fontFamily: TomFonts.mono, fontSize: 11),
            ),
          ],
        ),
      );
    }
    return TerminalEmulatorWidget(key: ValueKey<String?>(space));
  }
}
