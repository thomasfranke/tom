/// [LoginShellPseudoTerminalImpl] per platform, over a pseudo-terminal that
/// only records: which shell, with which arguments, environment and size.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late List<_Spawned> spawned;
  late Error? refusal;

  setUp(() {
    spawned = <_Spawned>[];
    refusal = null;
  });

  PseudoTerminalProcess spawn(
    String executable, {
    required List<String> arguments,
    required String workingDirectory,
    required Map<String, String> environment,
    required int columns,
    required int rows,
  }) {
    if (refusal case final Error thrown) {
      throw thrown;
    }
    final _Spawned it = _Spawned(
      executable,
      arguments,
      workingDirectory,
      environment,
      columns,
      rows,
    );
    spawned.add(it);
    return _FakeProcess(executable);
  }

  LoginShellPseudoTerminalImpl on(
    String platform, {
    Map<String, String> environment = const <String, String>{},
    Set<String> present = const <String>{},
  }) => LoginShellPseudoTerminalImpl(
    spawn: spawn,
    operatingSystem: platform,
    environment: environment,
    exists: present.contains,
  );

  Future<Result<PseudoTerminalProcess, PseudoTerminalFailure>> started(
    LoginShellPseudoTerminalImpl terminal,
  ) => terminal.start(folder: '/work/docs', columns: 100, rows: 12);

  group('the shell', () {
    test(r'on macOS is $SHELL, as a login shell', () async {
      await started(
        on(
          'macos',
          environment: <String, String>{'SHELL': '/opt/homebrew/bin/fish'},
          present: <String>{'/opt/homebrew/bin/fish'},
        ),
      );

      expect(spawned.single.executable, '/opt/homebrew/bin/fish');
      expect(spawned.single.arguments, <String>['-l']);
    });

    test(r'on macOS falls back to zsh when $SHELL is not set', () async {
      await started(on('macos', present: <String>{'/bin/zsh'}));

      expect(spawned.single.executable, '/bin/zsh');
      expect(spawned.single.arguments, <String>['-l']);
    });

    test(r'on Linux is $SHELL, and not a login shell', () async {
      await started(
        on(
          'linux',
          environment: <String, String>{'SHELL': '/usr/bin/zsh'},
          present: <String>{'/usr/bin/zsh'},
        ),
      );

      expect(spawned.single.executable, '/usr/bin/zsh');
      expect(spawned.single.arguments, isEmpty);
    });

    test(r'on Linux falls back to bash, then sh', () async {
      await started(on('linux', present: <String>{'/bin/bash', '/bin/sh'}));
      await started(on('linux', present: <String>{'/bin/sh'}));

      expect(spawned.map((_Spawned it) => it.executable), <String>[
        '/bin/bash',
        '/bin/sh',
      ]);
    });

    test('on Windows is PowerShell when it is there', () async {
      const String powerShell =
          r'D:\Win\System32\WindowsPowerShell\v1.0\powershell.exe';
      await started(
        on(
          'windows',
          environment: <String, String>{'SystemRoot': r'D:\Win'},
          present: <String>{powerShell},
        ),
      );

      expect(spawned.single.executable, powerShell);
      expect(spawned.single.arguments, <String>['-NoLogo']);
    });

    test(r'on Windows without PowerShell is %ComSpec%', () async {
      const String cmd = r'C:\Windows\System32\cmd.exe';
      await started(
        on(
          'windows',
          environment: <String, String>{'ComSpec': cmd},
          present: <String>{cmd},
        ),
      );

      expect(spawned.single.executable, cmd);
      expect(spawned.single.arguments, isEmpty);
    });

    test('is missing, and says which one', () async {
      final Result<PseudoTerminalProcess, PseudoTerminalFailure> result =
          await started(
            on('macos', environment: <String, String>{'SHELL': '/bin/gone'}),
          );

      expect(
        result,
        isA<Failure<PseudoTerminalProcess, PseudoTerminalFailure>>().having(
          (Failure<PseudoTerminalProcess, PseudoTerminalFailure> it) =>
              it.failure,
          'failure',
          const PseudoTerminalUnavailable('/bin/zsh'),
        ),
      );
      expect(spawned, isEmpty);
    });
  });

  test('starts in the folder, at the size asked', () async {
    await started(on('macos', present: <String>{'/bin/zsh'}));

    expect(spawned.single.folder, '/work/docs');
    expect((spawned.single.columns, spawned.single.rows), (100, 12));
  });

  group('the environment', () {
    test('is the app\'s, whole, said to be a colour terminal', () async {
      await started(
        on(
          'macos',
          environment: <String, String>{
            'PATH': '/usr/bin',
            'SSH_AUTH_SOCK': '/tmp/agent',
            'TERM': 'dumb',
          },
          present: <String>{'/bin/zsh'},
        ),
      );

      expect(
        spawned.single.environment,
        allOf(
          containsPair('PATH', '/usr/bin'),
          containsPair('SSH_AUTH_SOCK', '/tmp/agent'),
          containsPair('TERM', 'xterm-256color'),
          containsPair('COLORTERM', 'truecolor'),
        ),
      );
    });

    test('speaks UTF-8 when the app was given no language', () async {
      await started(on('macos', present: <String>{'/bin/zsh'}));

      expect(spawned.single.environment['LANG'], 'en_US.UTF-8');
    });

    test('keeps the language the person set', () async {
      await started(
        on(
          'macos',
          environment: <String, String>{'LANG': 'pt_BR.UTF-8'},
          present: <String>{'/bin/zsh'},
        ),
      );

      expect(spawned.single.environment['LANG'], 'pt_BR.UTF-8');
    });
  });

  test('a pty the platform refuses is a failure, not a throw', () async {
    refusal = StateError('Failed to create PTY: out of ptys');

    final Result<PseudoTerminalProcess, PseudoTerminalFailure> result =
        await started(on('macos', present: <String>{'/bin/zsh'}));

    expect(
      result,
      isA<Failure<PseudoTerminalProcess, PseudoTerminalFailure>>().having(
        (Failure<PseudoTerminalProcess, PseudoTerminalFailure> it) =>
            it.failure,
        'failure',
        const PseudoTerminalStartFailed('Failed to create PTY: out of ptys'),
      ),
    );
  });
}

/// What one spawn was asked for.
final class _Spawned {
  _Spawned(
    this.executable,
    this.arguments,
    this.folder,
    this.environment,
    this.columns,
    this.rows,
  );

  final String executable;
  final List<String> arguments;
  final String folder;
  final Map<String, String> environment;
  final int columns;
  final int rows;
}

/// A process that never runs.
final class _FakeProcess implements PseudoTerminalProcess {
  _FakeProcess(this.executable);

  @override
  final String executable;

  @override
  Stream<Uint8List> get output => const Stream<Uint8List>.empty();

  @override
  Future<int> get exitCode => Completer<int>().future;

  @override
  void kill() {}

  @override
  void resize(int columns, int rows) {}

  @override
  void write(Uint8List data) {}
}
