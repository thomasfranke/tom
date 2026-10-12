/// [TerminalRepositoryImpl] over the real [LoginShellPseudoTerminalImpl] and
/// a real shell on `dart:io` pipes — the session's text, its end and its
/// silence afterwards. The pseudo-terminal itself is the scenario's, *Runs a
/// command in the terminal*.
@TestOn('!windows')
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory home;
  late List<_PipedProcess> spawned;

  setUp(() {
    home = Directory.systemTemp.createTempSync('tom_terminal_repository_');
    spawned = <_PipedProcess>[];
  });

  tearDown(() async {
    // No shell outlives its test, whatever the test did.
    for (final _PipedProcess process in spawned) {
      process.end();
      await process.exitCode;
    }
    home.deleteSync(recursive: true);
  });

  /// The repository as the composition root builds it, the pseudo-terminal
  /// replaced by pipes and the environment by one of the test's own.
  TerminalRepositoryImpl repository({Map<String, String>? environment}) =>
      TerminalRepositoryImpl(
        source: TerminalDataSource(
          terminal: LoginShellPseudoTerminalImpl(
            environment:
                environment ??
                <String, String>{
                  'SHELL': '/bin/sh',
                  'HOME': home.path,
                  'PATH': '/usr/bin:/bin',
                },
            spawn:
                (
                  String executable, {
                  required List<String> arguments,
                  required String workingDirectory,
                  required Map<String, String> environment,
                  required int columns,
                  required int rows,
                }) {
                  final _PipedProcess process = _PipedProcess(
                    executable,
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
                },
          ),
        ),
      );

  Future<TerminalSessionPort> started(
    TerminalRepositoryImpl repository, {
    String? folder,
  }) async {
    final Result<TerminalSessionPort, AppFailure> session = await repository
        .start(
          folder ?? home.path,
          const TerminalSizeValueObject(columns: 100, rows: 12),
        );
    return (session as Success<TerminalSessionPort, AppFailure>).value;
  }

  test('a session names its shell and the folder it was started in', () async {
    final Directory folder = Directory('${home.path}/my docs')..createSync();

    final TerminalSessionPort session = await started(
      repository(),
      folder: folder.path,
    );
    final Future<String> output = session.output.join();
    session.write('pwd -P\nexit\n');
    await session.exited;

    expect(session.shell, 'sh');
    expect(session.folder, folder.path);
    expect(
      Directory(
        (await output).trim().split('\n').last,
      ).resolveSymbolicLinksSync(),
      folder.resolveSymbolicLinksSync(),
    );
  });

  test('what is typed reaches the shell as UTF-8, and comes back as '
      'text', () async {
    final TerminalSessionPort session = await started(repository());
    final Future<String> output = session.output.join();

    session.write("printf '%s\\n' 'revisão — 日本'\nexit\n");
    await session.exited;

    expect((await output).trim().split('\n').last, 'revisão — 日本');
  });

  test('a character the shell wrote in two halves is one character', () async {
    final TerminalSessionPort session = await started(repository());
    final List<String> chunks = <String>[];
    final Future<void> read = session.output.forEach(chunks.add);

    // `ã` is C3 A3; the pause puts each byte in a write of its own.
    session.write("printf 'a\\303'; sleep 1; printf '\\243o\\n'\nexit\n");
    await session.exited;
    await read;

    expect(chunks.join(), contains('aão'));
    expect(chunks.join(), isNot(contains('�')));
  });

  test('exited completes with the code the shell ended with', () async {
    final TerminalSessionPort session = await started(repository());

    session.write('exit 42\n');

    expect(await session.exited.timeout(const Duration(seconds: 20)), 42);
  });

  test('what is typed after the end is dropped, and so is a resize', () async {
    final TerminalSessionPort session = await started(repository());
    session.write('exit 0\n');
    await session.exited;
    final int typedBefore = spawned.single.typed;

    session
      ..write('echo too late\n')
      ..resize(const TerminalSizeValueObject(columns: 10, rows: 2));

    expect(spawned.single.typed, typedBefore);
    expect(spawned.single.resized, isEmpty);
  });

  test('a resize while it runs hands the two numbers on, columns '
      'first', () async {
    final TerminalSessionPort session = await started(repository());

    session.resize(const TerminalSizeValueObject(columns: 132, rows: 43));

    expect(spawned.single.resized, <(int, int)>[(132, 43)]);
    session.close();
    await session.exited;
  });

  test('close ends a shell that is waiting, once', () async {
    final TerminalSessionPort session = await started(repository());

    session
      ..close()
      ..close();
    final int exit = await session.exited.timeout(const Duration(seconds: 20));

    expect(exit, isNot(0));
    expect(spawned.single.killed, 1);
  });

  test('close after the shell ended on its own kills nothing — its pid '
      'may be another\'s by then', () async {
    final TerminalSessionPort session = await started(repository());
    session.write('exit 0\n');
    await session.exited;

    session.close();

    expect(spawned.single.killed, 0);
  });

  test('a shell that is not on the disk comes through as the capability '
      'said it, and nothing is started', () async {
    final TerminalRepositoryImpl windows = TerminalRepositoryImpl(
      source: TerminalDataSource(
        terminal: LoginShellPseudoTerminalImpl(
          operatingSystem: 'windows',
          environment: <String, String>{
            'SystemRoot': '${home.path}/Windows',
            'ComSpec': '${home.path}/Windows/System32/cmd.exe',
          },
          spawn:
              (
                String executable, {
                required List<String> arguments,
                required String workingDirectory,
                required Map<String, String> environment,
                required int columns,
                required int rows,
              }) => fail('nothing is started for a shell that is not there'),
        ),
      ),
    );

    final Result<TerminalSessionPort, AppFailure> session = await windows.start(
      home.path,
      const TerminalSizeValueObject(columns: 80, rows: 24),
    );

    expect(
      (session as Failure<TerminalSessionPort, AppFailure>).failure,
      PseudoTerminalUnavailable('${home.path}/Windows/System32/cmd.exe'),
    );
  });
}

/// A shell on `dart:io` pipes, which also counts what the session asked of
/// it — the pipes have no size and a kill leaves no trace of its own.
final class _PipedProcess implements PseudoTerminalProcess {
  _PipedProcess(this.executable, this._started) {
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

  /// How many times something was typed.
  int typed = 0;

  /// How many times the session asked for the shell to be ended.
  int killed = 0;

  /// Every size the session handed on.
  final List<(int, int)> resized = <(int, int)>[];

  @override
  final String executable;

  void _add(List<int> chunk) => _output.add(Uint8List.fromList(chunk));

  @override
  Stream<Uint8List> get output => _output.stream;

  @override
  Future<int> get exitCode =>
      _started.then((Process process) => process.exitCode);

  @override
  void write(Uint8List data) {
    typed++;
    unawaited(
      _started.then((Process process) {
        process.stdin.add(data);
        unawaited(process.stdin.done.catchError((Object _) {}));
      }),
    );
  }

  @override
  void resize(int columns, int rows) => resized.add((columns, rows));

  @override
  void kill() {
    killed++;
    end();
  }

  /// Ends the process without counting it — the test's own cleanup.
  void end() => unawaited(_started.then((Process process) => process.kill()));
}
