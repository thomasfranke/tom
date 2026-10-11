/// [DesktopRepositoryImpl] over the real [DartIoDesktopShellImpl] and real
/// processes, with no window opened: programs of the test's own on a `PATH`
/// of its own, and another platform's, which this machine does not have.
@TestOn('!windows')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory machine;

  setUp(() {
    machine = Directory.systemTemp.createTempSync('tom_desktop_repository_');
    Directory('${machine.path}/bin').createSync();
  });

  tearDown(() => machine.deleteSync(recursive: true));

  /// Puts [program] on the test's `PATH`: it writes its arguments, one to a
  /// line, and its folder, then says [stderr] and exits with [exit].
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

  /// The folder [program] was started in, once it has said.
  Future<String> folderOf(String program) async {
    final File said = File('${machine.path}/$program.folder');
    for (int i = 0; i < 200 && !said.existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    return Directory(said.readAsStringSync().trim()).resolveSymbolicLinksSync();
  }

  /// The repository as the composition root builds it, for [platform], its
  /// processes real and its `PATH` the test's own.
  DesktopRepositoryImpl on(String platform) => DesktopRepositoryImpl(
    source: DesktopDataSource(
      shell: DartIoDesktopShellImpl(
        operatingSystem: platform,
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
      ),
    ),
  );

  /// The failure [result] holds, or a failure of the test if it succeeded.
  AppFailure failureOf(Result<void, AppFailure> result) => switch (result) {
    Failure<void, AppFailure>(failure: final AppFailure failure) => failure,
    Success<void, AppFailure>() => throw StateError(
      'expected a failure, got a success',
    ),
  };

  test('reveal reaches the file manager with the folder', () async {
    install('xdg-open');

    final Result<void, AppFailure> revealed = await on(
      'linux',
    ).reveal('/code/my docs');

    expect(revealed, isA<Success<void, AppFailure>>());
    expect(asked('xdg-open'), <String>['/code/my docs']);
  });

  test('openTerminal starts the terminal in the folder', () async {
    install('x-terminal-emulator');
    final Directory folder = Directory('${machine.path}/my docs')..createSync();

    final Result<void, AppFailure> opened = await on(
      'linux',
    ).openTerminal(folder.path);

    expect(opened, isA<Success<void, AppFailure>>());
    expect(
      await folderOf('x-terminal-emulator'),
      folder.resolveSymbolicLinksSync(),
    );
  });

  test('openUrl reaches the browser with the address whole', () async {
    install('xdg-open');
    final Uri address = Uri.parse(
      'https://github.com/acme/docs/compare/main...feat/x?expand=1&title=A%26B',
    );

    final Result<void, AppFailure> opened = await on('linux').openUrl(address);

    expect(opened, isA<Success<void, AppFailure>>());
    expect(asked('xdg-open'), <String>['$address']);
  });

  test('a program that refuses comes through as the capability said '
      'it', () async {
    install('xdg-open', exit: 4, stderr: 'no method available');
    final DesktopRepositoryImpl desktop = on('linux');

    final Result<void, AppFailure> revealed = await desktop.reveal('/code');
    final Result<void, AppFailure> opened = await desktop.openUrl(
      Uri.parse('https://example.com/'),
    );

    expect(
      failureOf(revealed),
      const DesktopShellOperationFailed('xdg-open: no method available'),
    );
    expect(
      failureOf(opened),
      const DesktopShellOperationFailed('xdg-open: no method available'),
    );
  });

  test('a platform whose programs are not here is unavailable, for all '
      'three, naming each', () async {
    // The `PATH` holds nothing, so the names are looked for and not found.
    final DesktopRepositoryImpl desktop = on('linux');

    expect(
      failureOf(await desktop.reveal('/code')),
      const DesktopShellUnavailable('xdg-open'),
    );
    expect(
      failureOf(await desktop.openTerminal(machine.path)),
      const DesktopShellUnavailable('x-terminal-emulator'),
    );
    expect(
      failureOf(await desktop.openUrl(Uri.parse('https://example.com/'))),
      const DesktopShellUnavailable('xdg-open'),
    );
  });
}
