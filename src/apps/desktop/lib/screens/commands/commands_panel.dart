/// Every command the app ran this session, as it ran it.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_design.dart';
import 'package:tom_desktop/screens/commands/widgets/command_row_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The `Commands` tab of the panel under the document
/// (`docs/product/workspace/commands/doc.md`).
///
/// Newest at the bottom, and the list stays there as rows arrive: it is
/// anchored at its end, so a reader who scrolled up is left where they are.
class CommandsPanel extends ConsumerStatefulWidget {
  /// Creates the panel.
  const CommandsPanel({super.key});

  /// The id it is registered under, which a failure's `Show the command`
  /// opens the region on — the list's own, since it opens the region by
  /// itself when a command starts waiting.
  static const String id = CommandsNotifier.panel;

  @override
  ConsumerState<CommandsPanel> createState() => _CommandsPanelState();
}

class _CommandsPanelState extends ConsumerState<CommandsPanel> {
  /// One key per row the list holds, so a reveal can scroll to it.
  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    // A reveal asked for before the panel existed is answered on its first
    // frame — that is the usual case, since the band opens the panel too.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  /// Scrolls to the row asked for, then says it has.
  void _reveal() {
    if (!mounted) {
      return;
    }
    final int? id = ref.read(commandsProvider).revealing;
    if (id == null) {
      return;
    }
    final BuildContext? row = _keys[id]?.currentContext;
    // Alignment 0 is the viewport's leading edge, which a list anchored at
    // its end puts at the bottom: the row and its output end there, with
    // what ran before it above.
    if (row != null) {
      unawaited(Scrollable.ensureVisible(row));
    }
    ref.read(commandsProvider.notifier).revealed();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(
      commandsProvider.select((CommandsState it) => it.revealing),
      (_, int? next) {
        if (next != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
        }
      },
    );
    final CommandsState state = ref.watch(commandsProvider);
    final TomColors colors = TomColors.of(context);
    if (state.rows.isEmpty) {
      return Center(
        child: Text(
          context.l10n.commandsNoneYet,
          style: TextStyle(fontSize: 12.5, color: colors.textMuted),
        ),
      );
    }
    _keys.removeWhere((int id, _) => id < state.rows.first.id);
    final CommandsNotifier notifier = ref.read(commandsProvider.notifier);
    return SingleChildScrollView(
      // Anchored at the end: the newest row is the one in view, and a row
      // that arrives while the reader is there keeps them there.
      reverse: true,
      padding: const EdgeInsets.only(top: CommandsDesign.listTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final CommandRow row in state.rows)
            CommandRowWidget(
              key: _keys.putIfAbsent(row.id, GlobalKey.new),
              row: row,
              isOpen: state.expanded.contains(row.id),
              onToggle: () => notifier.toggle(row.id),
            ),
        ],
      ),
    );
  }
}
