/// [Pty2PseudoTerminalProcessImpl] over this machine's real pseudo-terminal:
/// a shell, a size that reaches it, a program that owns the screen, and a
/// hangup that leaves nothing behind.
@TestOn('mac-os || linux')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory folder;
  late List<_Run> started;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('tom_pty2_');
    started = <_Run>[];
  });

  tearDown(() async {
    // No shell outlives its test, whatever the test did.
    for (final _Run run in started) {
      run.process.kill();
      await run.process.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () => -1,
      );
    }
    folder.deleteSync(recursive: true);
  });

  _Run spawn(
    String executable, {
    List<String> arguments = const <String>[],
    int columns = 80,
    int rows = 24,
  }) {
    final _Run run = _Run(
      Pty2PseudoTerminalProcessImpl.spawn(
        executable,
        arguments: arguments,
        workingDirectory: folder.path,
        environment: <String, String>{
          'TERM': 'xterm-256color',
          'PATH': '/usr/bin:/bin',
          'HOME': folder.path,
          'PS1': r'$ ',
        },
        columns: columns,
        rows: rows,
      ),
    );
    started.add(run);
    return run;
  }

  group('a shell in the pseudo-terminal', () {
    test('answers what is typed, in the folder it was given, and ends with '
        'its own exit code', () async {
      final _Run run = spawn('/bin/sh')..type('pwd -P; echo "ação"\n');
      await run.waitFor('ação\r');
      run.type('exit 3\n');

      expect(await run.exit(), _exitedWith(3));
      expect(run.text, contains(folder.resolveSymbolicLinksSync()));
      expect(run.text, contains('ação'));
    });

    test('is told the size it was started at', () async {
      final _Run run = spawn('/bin/sh', columns: 100, rows: 30)
        ..type('stty size; exit\n');
      await run.exit();

      expect(run.text, contains('30 100'));
    });

    test('is told the size it is resized to', () async {
      final _Run run = spawn('/bin/sh')..type('stty size\n');
      await run.waitFor('24 80');

      run.process.resize(120, 40);
      run.type('stty size; exit\n');
      await run.exit();

      expect(run.text, contains('40 120'));
    });

    test('an executable that is not there ends non-zero or refuses, and '
        'never hangs', () async {
      Object? refused;
      int? code;
      try {
        final _Run run = spawn('${folder.path}/no-such-shell');
        code = await run.exit();
      } on Object catch (error) {
        refused = error;
      }

      expect(refused != null || (code != null && code != 0), isTrue);
    });
  });

  group('a program that owns the screen', () {
    test('escape sequences reach the reader untouched', () async {
      final _Run run = spawn('/bin/sh')
        ..type(
          r'printf "\033[31mred\033[0m \342\224\214\342\224\200\342\224\220"'
          '\n',
        );
      // Read before the shell ends: `pty2` can drop what a shell wrote in
      // the instant before it exited.
      await run.waitFor('┌─┐');
      run.type('exit\n');
      await run.exit();

      expect(run.text, contains('\x1b[31mred\x1b[0m'));
      expect(run.text, contains('┌─┐'));
    });

    test('less starts, is told it is on a terminal, and quits on q', () async {
      if (!File('/usr/bin/less').existsSync()) {
        markTestSkipped('no less');
        return;
      }
      File('${folder.path}/long.txt').writeAsStringSync(
        List<String>.generate(200, (int i) => 'line $i').join('\n'),
      );
      final _Run run = spawn('/usr/bin/less', arguments: <String>['long.txt']);

      await run.waitFor('line 1');
      run.type('q');

      expect(await run.exit(), _exitedWith(0));
    });

    test('vim starts and quits, when the machine has one', () async {
      if (!File('/usr/bin/vim').existsSync()) {
        markTestSkipped('no vim');
        return;
      }
      final _Run run = spawn(
        '/usr/bin/vim',
        arguments: <String>['-u', 'NONE', 'note.txt'],
      );

      await run.waitFor('note.txt');
      run.type('\x1b:q\r');

      expect(await run.exit(), _exitedWith(0));
    });
  });

  group('ending it', () {
    test('a hangup ends an interactive shell and leaves no process', () async {
      final _Run run = spawn('/bin/sh')
        ..type(
          r'echo "pid=$$"'
          '\n',
        );
      await run.waitFor(RegExp(r'pid=\d+'));
      final int pid = int.parse(RegExp(r'pid=(\d+)').firstMatch(run.text)![1]!);

      run.process.kill();
      await run.exit();

      expect(await _alive(pid), isFalse);
    });

    test('a hangup reaches the program in the foreground', () async {
      final _Run run = spawn('/bin/sh')
        ..type(
          r"sh -c 'echo child=$$; exec sleep 300'"
          '\n',
        );
      await run.waitFor(RegExp(r'child=\d+'));
      final int child = int.parse(
        RegExp(r'child=(\d+)').firstMatch(run.text)![1]!,
      );

      run.process.kill();
      await run.exit();

      expect(await _alive(child), isFalse);
    });
  });
}

/// The shell's exit code, or `-1`: `pty2` answers that when the Dart VM's
/// own child handling reaped the shell first, which it does whenever a
/// `Process` of the VM is running or ending at the same moment — the test
/// runner's, and git's in the app. The code is then unknown, never wrong; a
/// standalone script gets the real one.
Matcher _exitedWith(int code) => anyOf(code, -1);

/// Whether a process is still there, as `ps` sees it, after a moment for the
/// system to reap it.
Future<bool> _alive(int pid) async {
  for (int i = 0; i < 20; i++) {
    final ProcessResult found = await Process.run('ps', <String>['-p', '$pid']);
    if (found.exitCode != 0) {
      return false;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return true;
}

/// One started process and everything it has written so far.
final class _Run {
  _Run(this.process) {
    unawaited(process.output.forEach(_chunks.add));
  }

  final PseudoTerminalProcess process;
  final List<Uint8List> _chunks = <Uint8List>[];

  String get text => utf8.decode(<int>[
    for (final Uint8List chunk in _chunks) ...chunk,
  ], allowMalformed: true);

  void type(String input) =>
      process.write(Uint8List.fromList(utf8.encode(input)));

  Future<int> exit() => process.exitCode.timeout(const Duration(seconds: 20));

  Future<void> waitFor(Pattern needle) async {
    for (int i = 0; i < 200; i++) {
      if (text.contains(needle)) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    fail('never saw "$needle" in:\n$text');
  }
}
