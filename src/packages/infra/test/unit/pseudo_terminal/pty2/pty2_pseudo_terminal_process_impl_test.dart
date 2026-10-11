/// [Pty2PseudoTerminalProcessImpl] over a terminal that only records: the
/// wiring between text and bytes, with no pty opened.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pty2/pty2.dart' as pty;
import 'package:test/test.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Terminal terminal;
  late Pty2PseudoTerminalProcessImpl process;

  setUp(() {
    terminal = _Terminal();
    process = Pty2PseudoTerminalProcessImpl.over('/bin/zsh', terminal);
  });

  test('it names the shell it was given', () {
    expect(process.executable, '/bin/zsh');
  });

  test('what the terminal prints comes out as UTF-8 bytes', () async {
    final Future<List<Uint8List>> heard = process.output.toList();

    terminal.printed.add('olá');
    await terminal.printed.close();

    expect((await heard).single, utf8.encode('olá'));
  });

  test('bytes written are decoded, a broken one leniently', () {
    process
      ..write(Uint8List.fromList(utf8.encode('ls\n')))
      ..write(Uint8List.fromList(<int>[0x61, 0xff]));

    expect(terminal.written, <String>['ls\n', 'a�']);
  });

  test('resizing and the exit go straight through', () async {
    process.resize(120, 40);
    terminal.exit.complete(3);

    expect(terminal.sizes, <(int, int)>[(120, 40)]);
    expect(await process.exitCode, 3);
  });

  test('a close is a hangup, which a shell does not ignore', () {
    process.kill();

    expect(
      terminal.signals.single,
      Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sighup,
    );
  });
}

final class _Terminal implements pty.PseudoTerminal {
  // ignore: close_sinks, closed by the test that feeds it.
  final StreamController<String> printed = StreamController<String>();
  final Completer<int> exit = Completer<int>();
  final List<String> written = <String>[];
  final List<(int, int)> sizes = <(int, int)>[];
  final List<ProcessSignal> signals = <ProcessSignal>[];

  @override
  Stream<String> get out => printed.stream;

  @override
  Future<int> get exitCode => exit.future;

  @override
  void write(String input) => written.add(input);

  @override
  void resize(int width, int height) => sizes.add((width, height));

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    signals.add(signal);
    return true;
  }

  @override
  void init() {}

  @override
  void ackProcessed() {}
}
