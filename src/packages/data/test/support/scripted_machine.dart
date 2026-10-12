/// A machine of the test's own: a temporary folder whose `bin/` is the
/// whole `PATH`, so the real capabilities start programs the test wrote and
/// never this machine's `gh` or `ssh`, which would name its owner.
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// The folder, its programs and what they were asked.
final class ScriptedMachine {
  /// A machine with the real git on it — under an empty configuration —
  /// and a repository at [clone].
  ScriptedMachine()
    : root = Directory.systemTemp.createTempSync('tom_scripted_machine_') {
    Directory('${root.path}/bin').createSync();
    File('${root.path}/.gitconfig').writeAsStringSync('');
    // The real git by its own path, so its folder — which holds the real
    // `ssh`, and on some machines the real `gh` — stays off the `PATH`.
    program('git', 'exec "${_which('git')}" "\$@"', logged: false);
    // A space in the name: the clone is a person's folder.
    Directory(clone).createSync();
    git(<String>['init', '--quiet', '.']);
  }

  /// The machine's folder.
  final Directory root;

  /// The repository the tools are asked in.
  String get clone => '${root.path}/my clone';

  /// What every program is started with: nothing of the real machine's.
  Map<String, String> get environment => <String, String>{
    'HOME': root.path,
    'PATH': '${root.path}/bin',
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': '${root.path}/.gitconfig',
  };

  /// Puts [name] on the `PATH`: a shell script that, when [logged], writes
  /// one line per call to its log — the token it was started with, then its
  /// arguments — and runs [answer].
  void program(String name, String answer, {bool logged = true}) {
    final File script = File('${root.path}/bin/$name')
      ..writeAsStringSync(
        '#!/bin/sh\n'
        '${logged ? 'echo "\$GH_TOKEN|\$*" >> "${root.path}/$name.log"\n' : ''}'
        '$answer\n',
      );
    Process.runSync('chmod', <String>['+x', script.path]);
  }

  /// Every call [name] received, oldest first, as `token|arguments`.
  List<String> asked(String name) {
    final File log = File('${root.path}/$name.log');
    return log.existsSync() ? log.readAsLinesSync() : const <String>[];
  }

  /// Runs the real git in [clone], for what a test sets up.
  void git(List<String> arguments) {
    final ProcessResult result = Process.runSync(
      '${root.path}/bin/git',
      arguments,
      workingDirectory: clone,
      environment: environment,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  /// Gives [clone] a credential helper of its own answering [login] and
  /// [password].
  void credentialHelper({required String login, required String password}) =>
      git(<String>[
        'config',
        'credential.helper',
        '!f() { echo username=$login; echo password=$password; }; f',
      ]);

  /// The real credentials capability, on this machine.
  CommandLineCredentialsImpl credentials({
    CommandGate gate = const OpenCommandGateImpl(),
  }) => CommandLineCredentialsImpl(
    environment: environment,
    includeParentEnvironment: false,
    commandGate: gate,
  );

  /// The real `gh` capability, on this machine.
  GhCliGithubApiImpl api({CommandGate gate = const OpenCommandGateImpl()}) =>
      GhCliGithubApiImpl(
        environment: environment,
        includeParentEnvironment: false,
        commandGate: gate,
      );

  /// Removes the machine.
  void dispose() => root.deleteSync(recursive: true);
}

/// A gate that refuses the commands whose line holds [refused] and lets the
/// rest through — the port is ours, so this is an implementation of it and
/// not a stand-in for one.
final class RefusingGate implements CommandGate {
  /// Creates the gate.
  const RefusingGate(this.refused);

  /// What a refused command's line holds.
  final String refused;

  @override
  CommandPlan plan(List<CommandRequest> commands) => _Plan(
    commands.map((CommandRequest it) => it.commandLine).toList(),
    refused,
  );
}

final class _Plan implements CommandPlan {
  _Plan(this._lines, this._refused);

  final List<String> _lines;
  final String _refused;
  int _next = 0;

  @override
  Future<CommandVerdict> next() async => _lines[_next++].contains(_refused)
      ? const CommandVerdict.denied()
      : const CommandVerdict.run();

  @override
  void close() {}
}

/// Where [program] is on the real machine's `PATH`.
String _which(String program) =>
    (Process.runSync('which', <String>[program]).stdout as String)
        .split('\n')
        .first
        .trim();
