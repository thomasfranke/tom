/// The space's shell, drawn — the one file that knows `xterm`.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/terminal/terminal_design.dart';
import 'package:tom_desktop/screens/terminal/terminal_look.dart';
import 'package:tom_desktop/screens/terminal/terminal_sequence_filter.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
// The emulator's own `TerminalState` is its parser's, not the tab's.
import 'package:xterm/xterm.dart' hide TerminalState;

/// An emulator over [TerminalNotifier]: what the shell drew so far is
/// replayed into it, what it draws next is streamed, and what is typed goes
/// back (`docs/product/workspace/terminal/doc.md`).
///
/// A new emulator per panel, because the panel is built only while its tab
/// is chosen; the shell and its transcript are the notifier's.
class TerminalEmulatorWidget extends ConsumerStatefulWidget {
  /// Creates the emulator.
  const TerminalEmulatorWidget({super.key});

  @override
  ConsumerState<TerminalEmulatorWidget> createState() =>
      _TerminalEmulatorWidgetState();
}

class _TerminalEmulatorWidgetState
    extends ConsumerState<TerminalEmulatorWidget> {
  late final TerminalNotifier _notifier = ref.read(terminalProvider.notifier);
  final Terminal _terminal = Terminal(
    maxLines: TerminalDesign.scrollback,
    platform: _platformOf(defaultTargetPlatform),
    inputHandler: const _LeavesTheAppItsKeys(),
  );
  // What `xterm` reads wrongly is rewritten before it sees it.
  final TerminalSequenceFilter _filter = TerminalSequenceFilter();
  final FocusNode _focus = FocusNode(debugLabel: 'terminal');
  StreamSubscription<String>? _output;

  @override
  void initState() {
    super.initState();
    // Replayed before anything listens to what the emulator answers: a
    // question the shell asked long ago must not be answered into it again.
    _terminal.write(_filter.filter(_notifier.transcript));
    _output = _notifier.output.listen(
      (String text) => _terminal.write(_filter.filter(text)),
    );
    _terminal
      ..onOutput = _notifier.write
      ..onResize = _resized;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (ref.read(terminalProvider) case TerminalExited(:final int code)) {
        _sayEnded(code);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_output?.cancel());
    _focus.dispose();
    super.dispose();
  }

  /// Called while the view lays out; the shell is told after the frame,
  /// since starting it changes state the frame is still building from.
  void _resized(int columns, int rows, int _, int _) => scheduleMicrotask(() {
    if (mounted) {
      unawaited(
        _notifier.show(TerminalSizeValueObject(columns: columns, rows: rows)),
      );
    }
  });

  /// The shell ended: said in the terminal itself, in the muted grey.
  void _sayEnded(int code) => _terminal.write(
    '\r\n\x1b[90m${context.l10n.terminalExited(code)}\x1b[39m\r\n',
  );

  @override
  Widget build(BuildContext context) {
    ref.listen<TerminalState>(terminalProvider, (_, TerminalState next) {
      if (next case TerminalExited(:final int code)) {
        _sayEnded(code);
      }
    });
    return TerminalView(
      _terminal,
      focusNode: _focus,
      padding: TerminalDesign.padding,
      theme: terminalThemeOf(Theme.of(context).brightness),
      textStyle: terminalStyleOf(defaultTargetPlatform),
    );
  }
}

TerminalTargetPlatform _platformOf(TargetPlatform platform) =>
    switch (platform) {
      TargetPlatform.macOS => TerminalTargetPlatform.macos,
      TargetPlatform.windows => TerminalTargetPlatform.windows,
      TargetPlatform.linux => TerminalTargetPlatform.linux,
      _ => TerminalTargetPlatform.unknown,
    };

/// Every key the shell can read goes to it — Ctrl+C, Tab, the arrows,
/// Escape — except `Ctrl+J` off macOS, which closes this panel and is the
/// one way out the keyboard has.
///
/// On macOS nothing needs taking back: `⌘` never reaches a shell, so `⌘J`,
/// `⌘K`, `⌘S` and `⌘W` fall through to the window, and `⌘C`, `⌘V`, `⌘A`
/// are the emulator's own copy, paste and select-all.
class _LeavesTheAppItsKeys implements TerminalInputHandler {
  const _LeavesTheAppItsKeys();

  @override
  String? call(TerminalKeyboardEvent event) =>
      event.platform != TerminalTargetPlatform.macos &&
          event.ctrl &&
          !event.alt &&
          !event.shift &&
          event.key == TerminalKey.keyJ
      ? null
      : defaultInputHandler(event);
}
