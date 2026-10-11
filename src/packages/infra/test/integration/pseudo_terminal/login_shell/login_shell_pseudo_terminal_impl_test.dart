/// [LoginShellPseudoTerminalImpl] over this machine's real shells, started
/// through `dart:io` pipes rather than a pseudo-terminal.
///
/// What is proven is the shell it names, the arguments, the folder and the
/// environment — on a real process. The pseudo-terminal itself (the size and
/// its argument order, the hangup, a `startFailed` from a refused pty) is the
/// plugin's, lives in the composition root and stays the scenario's, *Runs a
/// command in the terminal*.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory home;
  late List<_PipedProcess> spawned;

  setUp(() {
    home = Directory.systemTemp.createTempSync('tom_login_shell_');
    spawned = <_PipedProcess>[];
  });

  tearDown(() async {
    // No shell outlives its test, whatever the test did.
    for (final _PipedProcess process in spawned) {
      process.kill();
      await process.exitCode;
    }
    home.deleteSync(recursive: true);
  });

  PseudoTerminalProcess spawn(
    String executable, {
    required List<String> arguments,
    required String workingDirectory,
    required Map<String, String> environment,
    required int columns,
    required int rows,
  }) {
    final _PipedProcess process = _PipedProcess(
      executable,
      arguments,
      Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: false,
      ),
    );
    spawned.add(process);
    return process;
  }

  /// An environment of the test's own: a home nobody's profile is in, so the
  /// shell reads the system's and nothing of the developer's.
  Map<String, String> bare({String shell = '/bin/sh', String? lang}) =>
      <String, String>{
        'SHELL': shell,
        'HOME': home.path,
        'ZDOTDIR': home.path,
        'PATH': '/usr/bin:/bin',
        'LANG': ?lang,
      };

  LoginShellPseudoTerminalImpl terminal(Map<String, String> environment) =>
      LoginShellPseudoTerminalImpl(spawn: spawn, environment: environment);

  /// Starts the shell in [folder], types [script], and answers what it wrote
  /// and how it ended.
  Future<(String, int)> typed(
    LoginShellPseudoTerminalImpl terminal,
    String folder,
    String script,
  ) async {
    final Result<PseudoTerminalProcess, PseudoTerminalFailure> started =
        await terminal.start(folder: folder, columns: 100, rows: 12);
    final PseudoTerminalProcess process =
        (started as Success<PseudoTerminalProcess, PseudoTerminalFailure>)
            .value;
    final Future<String> output = utf8.decoder
        .bind(process.output.cast<List<int>>())
        .join();
    process.write(Uint8List.fromList(utf8.encode(script)));
    final int exit = await process.exitCode.timeout(
      const Duration(seconds: 20),
    );
    return (await output, exit);
  }

  group('the shell it names', () {
    test('on this machine, with nothing handed in, is a file that is '
        'there', () {
      final LoginShellPseudoTerminalImpl own = LoginShellPseudoTerminalImpl(
        spawn: spawn,
      );

      final (String executable, List<String> arguments) = own.shell();

      expect(File(executable).existsSync(), isTrue);
      expect(arguments, Platform.isMacOS ? <String>['-l'] : isEmpty);
    });

    test(r'is $SHELL when the disk holds it', () {
      final (String executable, _) = terminal(bare()).shell();

      expect(executable, '/bin/sh');
    });

    test(r'falls back when $SHELL names a file that is gone, to one that '
        'is there', () {
      final (String executable, _) = terminal(
        bare(shell: '${home.path}/bin/fish'),
      ).shell();

      expect(executable, isNot('${home.path}/bin/fish'));
      expect(File(executable).existsSync(), isTrue);
    });

    test(r'falls back when $SHELL is a folder', () {
      final (String executable, _) = terminal(bare(shell: home.path)).shell();

      expect(executable, isNot(home.path));
      expect(File(executable).existsSync(), isTrue);
    });
  }, skip: Platform.isWindows ? 'POSIX shells' : false);

  group('started', () {
    test('runs in the folder it was given, a name with a space and an '
        'accent', () async {
      final Directory folder = Directory('${home.path}/My docs ação')
        ..createSync();

      final (String output, int exit) = await typed(
        terminal(bare()),
        folder.path,
        'pwd -P\nexit 7\n',
      );

      expect(
        Directory(output.trim().split('\n').last).resolveSymbolicLinksSync(),
        folder.resolveSymbolicLinksSync(),
      );
      expect(exit, 7);
    });

    test('is told it draws on a colour terminal that speaks UTF-8', () async {
      final (String output, _) = await typed(
        terminal(bare()),
        home.path,
        r'printf "%s|%s|%s|%s\n" "$TERM" "$COLORTERM" "$TERM_PROGRAM" "$LANG"'
        '\nexit\n',
      );

      expect(
        output.trim().split('\n').last,
        'xterm-256color|truecolor|TOM|en_US.UTF-8',
      );
    });

    test('keeps the language the person set', () async {
      final (String output, _) = await typed(
        terminal(bare(lang: 'pt_BR.UTF-8')),
        home.path,
        r'printf "%s\n" "$LANG"'
        '\nexit\n',
      );

      expect(output.trim().split('\n').last, 'pt_BR.UTF-8');
    });

    test('hands on the environment the app was started with', () async {
      final (String output, _) = await typed(
        terminal(<String, String>{...bare(), 'TOM_PROBE': 'handed on'}),
        home.path,
        r'printf "%s|%s\n" "$TOM_PROBE" "$HOME"'
        '\nexit\n',
      );

      expect(output.trim().split('\n').last, 'handed on|${home.path}');
    });

    test(
      'on macOS is a login shell, which is what reads the profile',
      () async {
        File('${home.path}/.profile').writeAsStringSync(
          'TOM_PROFILE="read by a login shell"\nexport TOM_PROFILE\n',
        );

        final (String output, _) = await typed(
          terminal(bare()),
          home.path,
          r'printf "%s\n" "$TOM_PROFILE"'
          '\nexit\n',
        );

        expect(output.trim().split('\n').last, 'read by a login shell');
      },
      skip: Platform.isMacOS ? false : 'a login shell on macOS only',
    );

    test('this machine\'s own shell starts in the folder and ends when '
        'told to', () async {
      final String? own = Platform.environment['SHELL'];
      final Directory folder = Directory('${home.path}/docs')..createSync();

      final (String output, int exit) = await typed(
        terminal(bare(shell: own ?? '/bin/sh')),
        folder.path,
        'pwd\nexit 3\n',
      );

      expect(
        output,
        contains(folder.resolveSymbolicLinksSync().split('/').last),
      );
      expect(exit, 3);
    });

    test('is ended by kill, and nothing is left running', () async {
      final Result<PseudoTerminalProcess, PseudoTerminalFailure> started =
          await terminal(
            bare(),
          ).start(folder: home.path, columns: 80, rows: 24);
      final PseudoTerminalProcess process =
          (started as Success<PseudoTerminalProcess, PseudoTerminalFailure>)
              .value;

      final Future<int> ended = (process..kill()).exitCode;
      final int exit = await ended.timeout(const Duration(seconds: 20));

      expect(exit, isNot(0));
      expect(process.executable, '/bin/sh');
    });
  }, skip: Platform.isWindows ? 'POSIX shells' : false);

  group('a shell that is not where the machine says', () {
    // Windows' rules asked of this disk: neither PowerShell nor the command
    // interpreter is under a system root that does not exist.
    test('is unavailable, naming the executable, and nothing is '
        'started', () async {
      final LoginShellPseudoTerminalImpl windows = LoginShellPseudoTerminalImpl(
        spawn: spawn,
        operatingSystem: 'windows',
        environment: <String, String>{
          'SystemRoot': '${home.path}/Windows',
          'ComSpec': '${home.path}/Windows/System32/cmd.exe',
        },
      );

      final Result<PseudoTerminalProcess, PseudoTerminalFailure> started =
          await windows.start(folder: home.path, columns: 80, rows: 24);

      expect(
        (started as Failure<PseudoTerminalProcess, PseudoTerminalFailure>)
            .failure,
        PseudoTerminalUnavailable('${home.path}/Windows/System32/cmd.exe'),
      );
      expect(spawned, isEmpty);
    }, skip: Platform.isWindows ? 'asks a POSIX disk' : false);
  });
}

/// A shell on `dart:io` pipes: both of its streams as one output, as a
/// pseudo-terminal would hand them.
final class _PipedProcess implements PseudoTerminalProcess {
  _PipedProcess(this.executable, this.arguments, this._started) {
    unawaited(
      _started.then((Process process) async {
        await Future.wait(<Future<void>>[
          process.stdout.forEach(_add),
          process.stderr.forEach(_add),
        ]);
        await _output.close();
      }),
    );
  }

  final Future<Process> _started;
  final StreamController<Uint8List> _output = StreamController<Uint8List>();

  /// What the shell was started with.
  final List<String> arguments;

  @override
  final String executable;

  void _add(List<int> chunk) => _output.add(Uint8List.fromList(chunk));

  @override
  Stream<Uint8List> get output => _output.stream;

  @override
  Future<int> get exitCode =>
      _started.then((Process process) => process.exitCode);

  @override
  void write(Uint8List data) => unawaited(
    _started.then((Process process) {
      process.stdin.add(data);
      // A shell that has ended closes its end; that is not this test's news.
      unawaited(process.stdin.done.catchError((Object _) {}));
    }),
  );

  // Pipes have no size; the order of the two numbers is the scenario's.
  @override
  void resize(int columns, int rows) {}

  @override
  void kill() => unawaited(_started.then((Process process) => process.kill()));
}
