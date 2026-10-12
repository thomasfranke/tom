/// [CommandLineCredentialsImpl] against the real git and a credential helper
/// of the test's own — never the machine's, which would read its owner.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory home;
  late String repository;

  /// The environment of a machine with git and nothing else: no global
  /// config, no system config, and a `PATH` holding only git's folder.
  Map<String, String> bare() => <String, String>{
    'HOME': home.path,
    'PATH': File(_which('git')).parent.path,
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': '${home.path}/.gitconfig',
  };

  void git(List<String> arguments) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repository,
      environment: bare(),
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  setUp(() {
    home = Directory.systemTemp.createTempSync('tom_credentials_test_');
    repository = '${home.path}/repo';
    Directory(repository).createSync();
    File('${home.path}/.gitconfig').writeAsStringSync('');
    git(<String>['init', '--quiet', '.']);
  });

  tearDown(() => home.deleteSync(recursive: true));

  CommandLineCredentialsImpl credentials() => CommandLineCredentialsImpl(
    environment: bare(),
    includeParentEnvironment: false,
  );

  test("a repository's own helper answers, without a question", () async {
    git(<String>[
      'config',
      'credential.helper',
      '!f() { echo username=ada; echo password=tok-from-helper; }; f',
    ]);

    final Result<String, CredentialsFailure> answer = await credentials()
        .gitCredential('github.com', folder: repository);

    expect(
      (answer as Success<String, CredentialsFailure>).value,
      contains('password=tok-from-helper'),
    );
  });

  test('no helper is an empty answer, and nothing waits on a prompt', () async {
    final Result<String, CredentialsFailure> answer = await credentials()
        .gitCredential('github.com', folder: repository);

    expect((answer as Success<String, CredentialsFailure>).value, '');
  });

  test('gh and ssh missing from PATH are no account', () async {
    final CommandLineCredentialsImpl none = CommandLineCredentialsImpl(
      environment: <String, String>{'HOME': home.path, 'PATH': home.path},
      includeParentEnvironment: false,
    );

    expect(
      (await none.ghAccounts('github.com')
              as Success<String, CredentialsFailure>)
          .value,
      '',
    );
    expect(
      (await none.sshGreeting('github.com')
              as Success<String, CredentialsFailure>)
          .value,
      '',
    );
  });
}

/// Where [program] is on this machine's `PATH`.
String _which(String program) =>
    (Process.runSync(Platform.isWindows ? 'where' : 'which', <String>[
              program,
            ]).stdout
            as String)
        .split('\n')
        .first
        .trim();
