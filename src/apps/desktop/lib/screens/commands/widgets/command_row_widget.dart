/// One command in the panel, and its output when it is open.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// When it ran, whether it worked, the command, how long it took — and,
/// under the pointer, the glyph that copies the command line.
///
/// A press opens it onto what the command printed. Read-only on purpose:
/// nothing here runs a command again (`docs/product/workspace/commands/doc.md`).
class CommandRowWidget extends StatefulWidget {
  /// Creates the row for [row], open onto its output while [isOpen].
  const CommandRowWidget({
    required this.row,
    required this.isOpen,
    required this.onToggle,
    super.key,
  });

  /// What ran.
  final CommandRow row;

  /// Whether its output is showing.
  final bool isOpen;

  /// Opens it, or closes it.
  final VoidCallback onToggle;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CommandRow>('row', row))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(ObjectFlagProperty<VoidCallback>.has('onToggle', onToggle));
  }

  @override
  State<CommandRowWidget> createState() => _CommandRowWidgetState();
}

class _CommandRowWidgetState extends State<CommandRowWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final CommandRecord record = widget.row.record;
    final bool failed = record.failed;
    final TextStyle small = TextStyle(
      fontFamily: TomFonts.mono,
      fontSize: CommandsDesign.small,
      height: 1.3,
      color: colors.textMuted,
    );
    // Hover wins over the failure's tint, so the row under the pointer reads
    // the same whatever it holds.
    final Color? fill = _hovering
        ? colors.control
        : (failed ? colors.removedSoft : null);
    final String took = durationOf(l10n, record.duration);
    final Widget line = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: SizedBox(
          height: CommandsDesign.rowHeight,
          child: Stack(
            children: <Widget>[
              if (fill != null)
                Positioned.fill(
                  left: CommandsDesign.rowInset,
                  right: CommandsDesign.rowInset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(
                        CommandsDesign.rowRadius,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: CommandsDesign.timeLeft,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(_clock(record.startedAt), style: small),
                ),
              ),
              Positioned(
                left: CommandsDesign.statusCentre - CommandsDesign.check / 2,
                width: CommandsDesign.check,
                top: 0,
                bottom: 0,
                // An exit the app asked for as an answer is neither: no mark,
                // no tint, only its code.
                child: Center(
                  child: switch ((failed, record.answered)) {
                    (true, _) => TomGlyphWidget(
                      glyph: TomGlyphEnum.close,
                      color: colors.removed,
                      size: CommandsDesign.cross,
                    ),
                    (false, true) => const SizedBox.shrink(),
                    (false, false) => TomGlyphWidget(
                      glyph: TomGlyphEnum.check,
                      color: colors.added,
                      size: CommandsDesign.check,
                    ),
                  },
                ),
              ),
              Positioned(
                left: CommandsDesign.commandLeft,
                right: CommandsDesign.durationRight,
                top: 0,
                bottom: 0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        record.commandLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: small.copyWith(
                          fontSize: CommandsDesign.command,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: CommandsDesign.copy),
                    Text(
                      failed || record.answered
                          ? '${_ending(l10n, record)} · $took'
                          : took,
                      maxLines: 1,
                      style: small.copyWith(
                        fontFamily: TomFonts.sans,
                        color: failed ? colors.removed : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hovering)
                Positioned(
                  right: CommandsDesign.copyRight - CommandsDesign.copy,
                  width: CommandsDesign.copy,
                  top: 0,
                  bottom: 0,
                  child: Tooltip(
                    message: l10n.commandsCopy,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => unawaited(
                        Clipboard.setData(
                          ClipboardData(text: record.commandLine),
                        ),
                      ),
                      child: Center(
                        child: TomGlyphWidget(
                          glyph: TomGlyphEnum.copy,
                          color: colors.textSecondary,
                          size: CommandsDesign.copy,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (!widget.isOpen) {
      return line;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        line,
        Padding(
          padding: const EdgeInsets.only(
            left: CommandsDesign.commandLeft,
            right: CommandsDesign.outputRight,
            top: CommandsDesign.outputAbove,
            bottom: CommandsDesign.outputBelow,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(CommandsDesign.rowRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(CommandsDesign.outputPadding),
              child: SelectableText(
                record.output.isEmpty
                    ? l10n.commandsPrintedNothing
                    : record.output,
                style: small.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// `HH:MM:SS`, on the machine's clock.
  static String _clock(DateTime at) => <int>[
    at.hour,
    at.minute,
    at.second,
  ].map((int it) => '$it'.padLeft(2, '0')).join(':');

  /// How a failure ended: its exit code, or that it never did.
  static String _ending(AppLocalizations l10n, CommandRecord record) =>
      switch (record.exitCode) {
        final int code => l10n.commandsExit(code),
        null when !record.ran => l10n.commandsDidNotRun,
        null => l10n.commandsUnfinished,
      };
}

/// [took] as the boards write it: `38 ms` under a second, `1.2 s` under a
/// minute, `2 min 5 s` past it.
@visibleForTesting
String durationOf(AppLocalizations l10n, Duration took) {
  if (took < const Duration(seconds: 1)) {
    return l10n.commandsMilliseconds(took.inMilliseconds);
  }
  if (took < const Duration(minutes: 1)) {
    return l10n.commandsSeconds((took.inMilliseconds / 100).round() / 10);
  }
  return l10n.commandsMinutes(took.inMinutes, took.inSeconds % 60);
}
