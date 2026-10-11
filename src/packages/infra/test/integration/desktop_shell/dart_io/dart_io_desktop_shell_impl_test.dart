/// [DartIoDesktopShellImpl] against real processes, with no window opened:
/// another platform's programs, which this machine does not have, and
/// programs of the test's own on a `PATH` of its own that write down what
/// reached them.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// A platform whose programs this machine cannot have.
String get _foreign => Platform.isWindows ? 'linux' : 'windows';

/// Whether [program] is somewhere on this machine's `PATH` — in which case
/// asking for it would open something, and the test stands down.
bool _installed(String program) {
  final String separator = Platform.isWindows ? ';' : ':';
  final List<String> suffixes = Platform.isWindows
      ? <String>['', '.exe', '.cmd', '.bat']
      : <String>[''];
  return (Platform.environment['PATH'] ?? '')
      .split(separator)
      .where((String it) => it.isNotEmpty)
      .any(
        (String folder) => suffixes.any(
          (String suffix) => File(
            '$folder${Platform.pathSeparator}$program$suffix',
          ).existsSync(),
        ),
      );
}

/// Why a test asking for [programs] cannot run here, or false.
Object _unlessInstalled(List<String> programs) {
  final Iterable<String> found = programs.where(_installed);
  return found.isEmpty
      ? false
      : '${found.join(', ')} is installed here, and asking would open it';
}

void main() {
  late Directory machine;
  late List<CommandRecord> written;

  setUp(() {
    machine = Directory.systemTemp.createTempSync('tom_desktop_shell_');
    Directory('${machine.path}/bin').createSync();
    written = <CommandRecord>[];
  });

  tearDown(() => machine.deleteSync(recursive: true));

  /// The failure [result] holds, or a failure of the test if it succeeded.
  DesktopShellFailure failureOf(Result<void, DesktopShellFailure> result) =>
      switch (result) {
        Failure<void, DesktopShellFailure>(
          failure: final DesktopShellFailure failure,
        ) =>
          failure,
        Success<void, DesktopShellFailure>() => throw StateError(
          'expected a failure, got a success',
        ),
      };

  group('a program this machine does not have', () {
    DartIoDesktopShellImpl shell() => DartIoDesktopShellImpl(
      operatingSystem: _foreign,
      commandLog: _Kept(written),
    );
    final String fileManager = _foreign == 'windows' ? 'explorer' : 'xdg-open';
    final String terminal = _foreign == 'windows'
        ? 'cmd'
        : 'x-terminal-emulator';
    final String browser = _foreign == 'windows' ? 'rundll32' : 'xdg-open';

    test(
      'reveal is unavailable, naming the file manager',
      () async {
        final Result<void, DesktopShellFailure> revealed = await shell().reveal(
          machine.path,
        );

        expect(failureOf(revealed), DesktopShellUnavailable(fileManager));
      },
      skip: _unlessInstalled(<String>[fileManager]),
    );

    test(
      'openTerminal is unavailable, naming the terminal',
      () async {
        final Result<void, DesktopShellFailure> opened = await shell()
            .openTerminal(machine.path);

        expect(failureOf(opened), DesktopShellUnavailable(terminal));
      },
      skip: _unlessInstalled(<String>[terminal]),
    );

    test(
      'openUrl is unavailable, naming what would have opened it',
      () async {
        final Result<void, DesktopShellFailure> opened = await shell().openUrl(
          Uri.parse(
            'https://github.com/acme/docs/compare/main...feat?expand=1',
          ),
        );

        expect(failureOf(opened), DesktopShellUnavailable(browser));
      },
      skip: _unlessInstalled(<String>[browser]),
    );

    test(
      'each is written down as a program that never ran',
      () async {
        await shell().reveal(machine.path);
        await shell().openTerminal(machine.path);
        await shell().openUrl(Uri.parse('https://example.com/'));

        expect(written.map((CommandRecord it) => it.executable), <String>[
          fileManager,
          terminal,
          browser,
        ]);
        expect(
          written.map((CommandRecord it) => it.ran),
          everyElement(isFalse),
        );
        expect(
          written.map((CommandRecord it) => it.exitCode),
          everyElement(isNull),
        );
      },
      skip: _unlessInstalled(<String>[fileManager, terminal, browser]),
    );
  });

  group(
    'a program of the test\'s own',
    () {
      /// Puts [program] on the test's `PATH`: it writes its arguments, one to
      /// a line, and its folder, then says [stderr] and exits with [exit].
      void install(String program, {int exit = 0, String stderr = ''}) {
        final File script = File('${machine.path}/bin/$program')
          ..writeAsStringSync(
            '#!/bin/sh\n'
            'PATH=/usr/bin:/bin\n'
            'for argument in "\$@"; do\n'
            '  printf "%s\\n" "\$argument" >> "${machine.path}/$program.asked"\n'
            'done\n'
            'pwd > "${machine.path}/$program.folder.tmp"\n'
            'mv "${machine.path}/$program.folder.tmp" '
            '"${machine.path}/$program.folder"\n'
            '${stderr.isEmpty ? '' : 'echo "$stderr" >&2\n'}'
            'exit $exit\n',
          );
        Process.runSync('chmod', <String>['+x', script.path]);
      }

      /// The arguments [program] was handed, one each.
      List<String> asked(String program) =>
          File('${machine.path}/$program.asked').readAsLinesSync();

      /// The folder [program] was started in, once it has said — a program
      /// left running answers after the call that started it.
      Future<String> folderOf(String program) async {
        final File said = File('${machine.path}/$program.folder');
        for (int i = 0; i < 200 && !said.existsSync(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
        return Directory(
          said.readAsStringSync().trim(),
        ).resolveSymbolicLinksSync();
      }

      // The real `Process`, on a `PATH` holding the test's programs alone,
      // so no program of the machine's can be reached by name.
      DartIoDesktopShellImpl on(String platform) => DartIoDesktopShellImpl(
        operatingSystem: platform,
        commandLog: _Kept(written),
        run:
            (
              String executable,
              List<String> arguments, {
              String? workingDirectory,
            }) => Process.run(
              executable,
              arguments,
              workingDirectory: workingDirectory,
              environment: <String, String>{'PATH': '${machine.path}/bin'},
              includeParentEnvironment: false,
            ),
        start:
            (
              String executable,
              List<String> arguments, {
              String? workingDirectory,
            }) => Process.start(
              executable,
              arguments,
              workingDirectory: workingDirectory,
              environment: <String, String>{'PATH': '${machine.path}/bin'},
              includeParentEnvironment: false,
              mode: ProcessStartMode.detached,
            ),
      );

      test('reveal hands the folder over as one argument, spaces and '
          'all', () async {
        install('xdg-open');
        final Directory folder = Directory(
          '${machine.path}/My docs \u2014 a\u00e7\u00e3o',
        )..createSync();

        final Result<void, DesktopShellFailure> revealed = await on(
          'linux',
        ).reveal(folder.path);

        expect(revealed, isA<Success<void, DesktopShellFailure>>());
        expect(asked('xdg-open'), <String>[folder.path]);
      });

      test('on macOS reveal asks `open`, and a terminal is `open -a '
          'Terminal`', () async {
        install('open');
        final DartIoDesktopShellImpl shell = on('macos');

        await shell.reveal('/code/docs');
        await shell.openTerminal('/code/my docs');

        expect(asked('open'), <String>[
          '/code/docs',
          '-a',
          'Terminal',
          '/code/my docs',
        ]);
      });

      test('openUrl hands the address over whole, query and all', () async {
        install('xdg-open');
        final Uri address = Uri.parse(
          'https://github.com/acme/docs/compare/main...feat/x'
          '?expand=1&title=Release%20notes&body=a%26b',
        );

        final Result<void, DesktopShellFailure> opened = await on(
          'linux',
        ).openUrl(address);

        expect(opened, isA<Success<void, DesktopShellFailure>>());
        expect(asked('xdg-open'), <String>['$address']);
      });

      test('on Windows the address is the second argument, never read by a '
          'shell', () async {
        install('rundll32');
        final Uri address = Uri.parse('https://example.com/?a=1&b=2');

        await on('windows').openUrl(address);

        expect(asked('rundll32'), <String>[
          'url.dll,FileProtocolHandler',
          '$address',
        ]);
      });

      test('openTerminal starts the terminal in the folder and does not '
          'wait for it', () async {
        install('x-terminal-emulator');
        final Directory folder = Directory('${machine.path}/my docs')
          ..createSync();

        final Result<void, DesktopShellFailure> opened = await on(
          'linux',
        ).openTerminal(folder.path);

        expect(opened, isA<Success<void, DesktopShellFailure>>());
        expect(
          await folderOf('x-terminal-emulator'),
          folder.resolveSymbolicLinksSync(),
        );
        expect(written.single.exitCode, 0);
      });

      test('on Windows the terminal is `cmd /c start cmd`, started in the '
          'folder', () async {
        install('cmd');
        final Directory folder = Directory('${machine.path}/docs')
          ..createSync();

        await on('windows').openTerminal(folder.path);

        expect(await folderOf('cmd'), folder.resolveSymbolicLinksSync());
        expect(asked('cmd'), <String>['/c', 'start', 'cmd']);
      });

      test('a program that refuses is an operation that failed, with what '
          'it said', () async {
        install(
          'xdg-open',
          exit: 3,
          stderr: 'xdg-open: no method available for opening it',
        );

        final Result<void, DesktopShellFailure> revealed = await on(
          'linux',
        ).reveal('/code/docs');

        expect(
          failureOf(revealed),
          const DesktopShellOperationFailed(
            'xdg-open: xdg-open: no method available for opening it',
          ),
        );
        expect(written.single.exitCode, 3);
        expect(written.single.failed, isTrue);
        expect(written.single.ran, isTrue);
      });

      test('a refused address fails the same way', () async {
        install('open', exit: 1, stderr: 'no application knows this address');

        final Result<void, DesktopShellFailure> opened = await on(
          'macos',
        ).openUrl(Uri.parse('nothing://here'));

        expect(
          failureOf(opened),
          const DesktopShellOperationFailed(
            'open: no application knows this address',
          ),
        );
      });

      test(
        "Explorer's exit 1 is success, and written down as an answer",
        () async {
          install('explorer', exit: 1);

          final Result<void, DesktopShellFailure> revealed = await on(
            'windows',
          ).reveal(r'C:\code');

          expect(revealed, isA<Success<void, DesktopShellFailure>>());
          expect(asked('explorer'), <String>[r'C:\code']);
          expect(written.single.answered, isTrue);
          expect(written.single.failed, isFalse);
        },
      );

      test('a program the machine will not execute is an operation that '
          'failed, and never ran', () async {
        install('xdg-open');
        install('x-terminal-emulator');
        Process.runSync('chmod', <String>[
          '644',
          '${machine.path}/bin/xdg-open',
          '${machine.path}/bin/x-terminal-emulator',
        ]);

        final Result<void, DesktopShellFailure> revealed = await on(
          'linux',
        ).reveal('/code/docs');
        final Result<void, DesktopShellFailure> opened = await on(
          'linux',
        ).openTerminal(machine.path);

        expect(failureOf(revealed), isA<DesktopShellOperationFailed>());
        expect(failureOf(opened), isA<DesktopShellOperationFailed>());
        expect(written.map((CommandRecord it) => it.ran), <bool>[false, false]);
        expect(File('${machine.path}/xdg-open.asked').existsSync(), isFalse);
      });

      test('a terminal started in a folder that is gone fails rather than '
          'starting elsewhere', () async {
        install('x-terminal-emulator');

        final Result<void, DesktopShellFailure> opened = await on(
          'linux',
        ).openTerminal('${machine.path}/gone');

        expect(failureOf(opened), isA<DesktopShellOperationFailed>());
        expect(
          File('${machine.path}/x-terminal-emulator.folder').existsSync(),
          isFalse,
        );
      });
    },
    skip: Platform.isWindows ? 'the programs are shell scripts' : false,
  );
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}
