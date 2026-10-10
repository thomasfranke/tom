/// [DartIoDesktopShellImpl] per platform, against programs that only record:
/// a test that opened Finder would open it on whoever runs the suite.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late List<String> ran;
  late List<String> started;
  late int exitCode;
  late ProcessException? missing;
  late List<CommandRecord> written;

  setUp(() {
    ran = <String>[];
    started = <String>[];
    exitCode = 0;
    missing = null;
    written = <CommandRecord>[];
  });

  DartIoDesktopShellImpl on(String platform) => DartIoDesktopShellImpl(
    operatingSystem: platform,
    commandLog: _Kept(written),
    run:
        (
          String executable,
          List<String> arguments, {
          String? workingDirectory,
        }) async {
          if (missing case final ProcessException error) {
            throw error;
          }
          ran.add(<String>[executable, ...arguments].join(' '));
          return ProcessResult(0, exitCode, '', 'refused');
        },
    start:
        (
          String executable,
          List<String> arguments, {
          String? workingDirectory,
        }) async {
          if (missing case final ProcessException error) {
            throw error;
          }
          started.add(
            <String>[
              executable,
              ...arguments,
              'in $workingDirectory',
            ].join(' '),
          );
        },
  );

  group('revealing a folder', () {
    test('macOS opens it in Finder', () async {
      await on('macos').reveal('/code/docs');

      expect(ran, <String>['open /code/docs']);
    });

    test('Windows opens it in Explorer, whatever Explorer answers', () async {
      // Explorer answers 1 when it worked.
      exitCode = 1;

      final Result<void, DesktopShellFailure> result = await on(
        'windows',
      ).reveal(r'C:\code\docs');

      expect(ran, <String>[r'explorer C:\code\docs']);
      expect(result, isA<Success<void, DesktopShellFailure>>());
    });

    test('Linux asks xdg-open', () async {
      await on('linux').reveal('/code/docs');

      expect(ran, <String>['xdg-open /code/docs']);
    });

    test('a refusal is a failure, with what the program said', () async {
      exitCode = 1;

      final Result<void, DesktopShellFailure> result = await on(
        'macos',
      ).reveal('/gone');

      expect(
        (result as Failure<void, DesktopShellFailure>).failure,
        isA<DesktopShellOperationFailed>(),
      );
    });

    test('a program that is not installed is named', () async {
      missing = const ProcessException('xdg-open', <String>[], 'not found', 2);

      final Result<void, DesktopShellFailure> result = await on(
        'linux',
      ).reveal('/code/docs');

      expect(
        (result as Failure<void, DesktopShellFailure>).failure,
        const DesktopShellUnavailable('xdg-open'),
      );
    });
  });

  group('opening a terminal', () {
    test('macOS opens Terminal at the folder', () async {
      await on('macos').openTerminal('/code');

      expect(ran, <String>['open -a Terminal /code']);
    });

    test('Windows starts a console in the folder', () async {
      await on('windows').openTerminal(r'C:\code');

      expect(started, <String>[r'cmd /c start cmd in C:\code']);
    });

    test('Linux starts the default terminal in the folder', () async {
      await on('linux').openTerminal('/code');

      expect(started, <String>['x-terminal-emulator in /code']);
    });
  });

  group('the command log', () {
    test('writes down what ran and how it ended', () async {
      exitCode = 1;

      await on('macos').reveal('/code/docs');

      expect(written.single.commandLine, 'open /code/docs');
      expect(written.single.exitCode, 1);
      expect(written.single.output, 'refused');
    });

    test('a program left running is written down as started', () async {
      await on('linux').openTerminal('/code');

      expect(written.single.commandLine, 'x-terminal-emulator');
      expect(written.single.exitCode, 0);
    });

    test('a program not installed is written down as never run', () async {
      missing = const ProcessException('xdg-open', <String>[], 'gone', 2);

      await on('linux').reveal('/code');

      expect(written.single.exitCode, isNull);
      expect(written.single.ran, isFalse);
    });

    test("Explorer's 1 is an answer, since nobody reads it", () async {
      exitCode = 1;

      await on('windows').reveal(r'C:\code');

      expect(written.single.answered, isTrue);
      expect(written.single.failed, isFalse);
    });
  });
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}
