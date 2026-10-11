/// [CommandLineCredentialsImpl] against real processes: a `gh` and an `ssh`
/// of the test's own on a `PATH` of its own, answering what the real ones
/// answer — which would name this machine's owner — and the real git under
/// an empty configuration.
@TestOn('!windows')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory machine;

  setUp(() {
    machine = Directory.systemTemp.createTempSync('tom_credentials_programs_');
    Directory('${machine.path}/bin').createSync();
    File('${machine.path}/.gitconfig').writeAsStringSync('');
  });

  tearDown(() => machine.deleteSync(recursive: true));

  /// Puts [program] on the test's `PATH`: it writes down its arguments and
  /// what it was started with, then runs [answer].
  void program(String program, String answer, {bool executable = true}) {
    final File script = File('${machine.path}/bin/$program')
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'PATH=/usr/bin:/bin\n'
        'out="${machine.path}/$program"\n'
        r'for a in "$@"; do printf "%s\n" "$a"; done >> "$out.arguments"'
        '\n'
        r'printf "%s|%s|%s|%s|%s" "$LC_ALL" "$LANG" "$LC_MESSAGES" '
        r'"$GH_PROMPT_DISABLED" "$SSH_ASKPASS_REQUIRE" > "$out.environment"'
        '\n'
        r'echo $$ > "$out.pid"'
        '\n'
        '$answer\n',
      );
    if (executable) {
      Process.runSync('chmod', <String>['+x', script.path]);
    }
  }

  /// A machine holding only the test's own programs — and, with [git],
  /// the real git under a configuration that is empty.
  CommandLineCredentialsImpl credentials({
    Duration timeout = const Duration(seconds: 10),
    bool git = false,
    Map<String, String> more = const <String, String>{},
    CommandLog log = const SilentCommandLogImpl(),
    CommandGate gate = const OpenCommandGateImpl(),
  }) => CommandLineCredentialsImpl(
    environment: <String, String>{
      'HOME': machine.path,
      'PATH': <String>[
        '${machine.path}/bin',
        if (git) File(_which('git')).parent.path,
      ].join(':'),
      'GIT_CONFIG_NOSYSTEM': '1',
      'GIT_CONFIG_GLOBAL': '${machine.path}/.gitconfig',
      ...more,
    },
    includeParentEnvironment: false,
    timeout: timeout,
    commandLog: log,
    commandGate: gate,
  );

  String asked(String program, String what) =>
      File('${machine.path}/$program.$what').readAsStringSync();

  bool ran(String program) =>
      File('${machine.path}/$program.arguments').existsSync();

  group('the accounts gh holds', () {
    test('are its JSON, as it printed it', () async {
      const String json =
          '{"hosts":{"github.com":[{"state":"success","active":true,'
          '"host":"github.com","login":"ada","tokenSource":"keyring"}]}}';
      program('gh', "echo '$json'");

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghAccounts('github.com');

      expect((answer as Success<String, CredentialsFailure>).value, '$json\n');
      expect(asked('gh', 'arguments').trim().split('\n'), <String>[
        'auth',
        'status',
        '--hostname',
        'github.com',
        '--json',
        'hosts',
      ]);
    });

    test('from a gh too old for --json are its report, asked a second time '
        'and read off both streams', () async {
      program(
        'gh',
        'case "\$*" in\n'
            '  *--json*) echo "unknown flag: --json" >&2; exit 1 ;;\n'
            'esac\n'
            'echo "github.com" >&2\n'
            'echo "  ✓ Logged in to github.com as ada (oauth_token)" >&2\n'
            'echo "on the output"',
      );

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghAccounts('github.com');

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        'on the output\n\n'
        'github.com\n'
        '  ✓ Logged in to github.com as ada (oauth_token)',
      );
      expect(asked('gh', 'arguments').trim().split('\n'), <String>[
        ...<String>['auth', 'status', '--hostname', 'github.com'],
        ...<String>['--json', 'hosts'],
        ...<String>['auth', 'status', '--hostname', 'github.com'],
      ]);
    });

    test('with nobody signed in are what gh printed for that, not a '
        'failure', () async {
      program(
        'gh',
        "echo '{\"hosts\":{}}'\n"
            'echo "You are not logged into any GitHub hosts." >&2\n'
            'exit 1',
      );

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghAccounts('github.com');

      expect(
        (answer as Success<String, CredentialsFailure>).value.trim(),
        '{"hosts":{}}',
      );
    });

    test('are asked in C whatever the person speaks, and with no question '
        'to answer', () async {
      program('gh', 'echo "{}"');

      await credentials(
        more: <String, String>{
          'LANG': 'pt_BR.UTF-8',
          'LC_MESSAGES': 'de_DE.UTF-8',
          'LC_ALL': 'pt_BR.UTF-8',
        },
      ).ghAccounts('github.com');

      expect(asked('gh', 'environment'), 'C|pt_BR.UTF-8|de_DE.UTF-8|1|never');
    });

    test(
      'a gh that reads its input is not waited on: the input is closed',
      () async {
        program('gh', 'cat > /dev/null\necho "{}"');

        final Result<String, CredentialsFailure> answer = await credentials(
          timeout: const Duration(seconds: 5),
        ).ghAccounts('github.com');

        expect((answer as Success<String, CredentialsFailure>).value, '{}\n');
      },
    );
  });

  group('the token gh holds', () {
    test('is what it printed, trimmed, asked for the login', () async {
      program('gh', 'echo "  gho_tok-of-ada  "');

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghToken('github.com', 'ada');

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        'gho_tok-of-ada',
      );
      expect(asked('gh', 'arguments').trim().split('\n'), <String>[
        'auth',
        'token',
        '--hostname',
        'github.com',
        '--user',
        'ada',
      ]);
    });

    test('is empty when gh refuses, and nothing a refusal printed is '
        'carried', () async {
      program(
        'gh',
        'echo "gho_printed-on-a-refusal"\n'
            'echo "no oauth token found for github.com account ada" >&2\n'
            'exit 1',
      );

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghToken('github.com', 'ada');

      expect((answer as Success<String, CredentialsFailure>).value, '');
    });

    test('never reaches the list of commands, which still names the '
        'question', () async {
      program('gh', 'echo "gho_tok-of-ada"');
      final _Recorded log = _Recorded();

      await credentials(log: log).ghToken('github.com', 'ada');

      final CommandRecord record = log.records.single;
      expect(record.executable, 'gh');
      expect(record.arguments, containsAllInOrder(<String>['auth', 'token']));
      expect(record.exitCode, 0);
      expect(record.output, isNot(contains('gho_tok-of-ada')));
    });
  });

  group('a program that cannot answer', () {
    test('gh outliving its time is timed out by name, and killed', () async {
      program('gh', 'exec sleep 30');

      final Result<String, CredentialsFailure> answer = await credentials(
        timeout: const Duration(milliseconds: 600),
      ).ghAccounts('github.com');

      expect(answer.failureOrNull, const CredentialsTimedOut('gh'));
      expect(await _gone(asked('gh', 'pid').trim()), isTrue);
    });

    test('ssh outliving its time is timed out by name, and killed', () async {
      program('ssh', 'exec sleep 30');

      final Result<String, CredentialsFailure> answer = await credentials(
        timeout: const Duration(milliseconds: 600),
      ).sshGreeting('github.com');

      expect(answer.failureOrNull, const CredentialsTimedOut('ssh'));
      expect(await _gone(asked('ssh', 'pid').trim()), isTrue);
    });

    test('gh that may not be executed is a failure naming it — not "no '
        'account"', () async {
      program('gh', 'echo "{}"', executable: false);

      final Result<String, CredentialsFailure> answer = await credentials()
          .ghAccounts('github.com');

      expect(
        answer.failureOrNull,
        isA<CredentialsOperationFailed>().having(
          (CredentialsOperationFailed it) => it.description,
          'description',
          startsWith('gh: '),
        ),
      );
      expect(ran('gh'), isFalse);
    });

    test(
      'a folder that is gone is a failure naming git — not "git is not '
      'installed"',
      () async {
        final Result<String, CredentialsFailure> answer = await credentials(
          git: true,
        ).gitCredential('github.com', folder: '${machine.path}/gone');

        expect(
          answer.failureOrNull,
          isA<CredentialsOperationFailed>().having(
            (CredentialsOperationFailed it) => it.description,
            'description',
            startsWith('git: '),
          ),
        );
      },
      skip:
          'defect S7-CRED-1: a working folder that is gone makes '
          '`Process.start` throw with errno 2, the same code as a program '
          'that is not on the PATH, so `_ask` answers "not installed" — an '
          'empty success — for a git that is there',
    );

    test('a machine with no sign-in draws no failed record', () async {
      program(
        'gh',
        'echo "You are not logged into any GitHub hosts." >&2\nexit 1',
      );
      final _Recorded log = _Recorded();

      final CommandLineCredentialsImpl signedOut = credentials(
        git: true,
        log: log,
      );
      await signedOut.ghAccounts('github.com');
      await signedOut.ghToken('github.com', 'ada');
      // No `ssh` on this machine's PATH at all.
      await signedOut.sshGreeting('github.com');
      await signedOut.gitCredential('github.com', folder: machine.path);

      expect(log.records, hasLength(greaterThanOrEqualTo(4)));
      expect(
        log.records.where((CommandRecord it) => it.failed),
        isEmpty,
        reason: log.records
            .map((CommandRecord it) => it.commandLine)
            .join('\n'),
      );
      expect(log.records.where((CommandRecord it) => it.answered), isNotEmpty);
    });

    test('a question refused at the gate starts nothing', () async {
      program('gh', 'echo "gho_tok-of-ada"');

      final Result<String, CredentialsFailure> answer = await credentials(
        gate: const _ClosedGate(),
      ).ghToken('github.com', 'ada');

      expect(
        answer.failureOrNull,
        isA<CredentialsCommandDenied>().having(
          (CredentialsCommandDenied it) => it.command,
          'command',
          startsWith('gh auth token'),
        ),
      );
      expect(ran('gh'), isFalse);
    });

    test('ssh is never asked about at the gate', () async {
      program(
        'ssh',
        'echo "Hi ada! You\'ve successfully authenticated." >&2\nexit 1',
      );

      final Result<String, CredentialsFailure> answer = await credentials(
        gate: const _ClosedGate(),
      ).sshGreeting('github.com');

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        startsWith('Hi ada!'),
      );
    });
  });

  group("ssh's greeting", () {
    test('is its error stream when GitHub knows the key, exit 1 — asked in '
        'batch mode', () async {
      program(
        'ssh',
        'echo "printed, and not the greeting"\n'
            'echo "Hi ada! You\'ve successfully authenticated, but GitHub '
            'does not provide shell access." >&2\n'
            'exit 1',
      );

      final Result<String, CredentialsFailure> answer = await credentials()
          .sshGreeting('github.com');

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        "Hi ada! You've successfully authenticated, but GitHub does not "
        'provide shell access.',
      );
      expect(asked('ssh', 'arguments').trim().split('\n'), <String>[
        '-T',
        '-o',
        'BatchMode=yes',
        '-o',
        'ConnectTimeout=5',
        'git@github.com',
      ]);
    });

    test('is its refusal when GitHub knows no key, exit 255', () async {
      program(
        'ssh',
        'echo "git@github.com: Permission denied (publickey)." >&2\n'
            'exit 255',
      );

      final Result<String, CredentialsFailure> answer = await credentials()
          .sshGreeting('github.com');

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        'git@github.com: Permission denied (publickey).',
      );
    });
  });

  group("git's credential helper", () {
    late String repository;

    void git(List<String> arguments) {
      final ProcessResult result = Process.runSync(
        'git',
        arguments,
        workingDirectory: repository,
        environment: <String, String>{
          'HOME': machine.path,
          'PATH': File(_which('git')).parent.path,
          'GIT_CONFIG_NOSYSTEM': '1',
          'GIT_CONFIG_GLOBAL': '${machine.path}/.gitconfig',
        },
        includeParentEnvironment: false,
      );
      if (result.exitCode != 0) {
        throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
      }
    }

    setUp(() {
      // A space in the name: the folder is a person's.
      repository = '${machine.path}/my repo';
      Directory(repository).createSync();
      git(<String>['init', '--quiet', '.']);
    });

    test('is asked in the repository, whatever its folder is called, for '
        'the host over https', () async {
      git(<String>[
        'config',
        'credential.helper',
        '!f() { /bin/cat > "${machine.path}/helper.input"; echo username=ada; '
            'echo password=tok-from-helper; }; f',
      ]);

      final Result<String, CredentialsFailure> answer = await credentials(
        git: true,
      ).gitCredential('github.com', folder: repository);

      expect(
        (answer as Success<String, CredentialsFailure>).value,
        allOf(contains('username=ada'), contains('password=tok-from-helper')),
      );
      expect(
        File('${machine.path}/helper.input').readAsStringSync(),
        allOf(contains('protocol=https'), contains('host=github.com')),
      );
    });

    test('with no helper is an empty answer in any language, and nothing '
        'of what git said is carried', () async {
      final _Recorded log = _Recorded();

      final Result<String, CredentialsFailure> answer = await credentials(
        git: true,
        log: log,
        more: <String, String>{'LANG': 'pt_BR.UTF-8', 'LANGUAGE': 'pt_BR'},
      ).gitCredential('github.com', folder: repository);

      expect((answer as Success<String, CredentialsFailure>).value, '');
      expect(log.records.single.exitCode, isNot(0));
    });

    test('a helper that holds a password never puts it in the list of '
        'commands', () async {
      git(<String>[
        'config',
        'credential.helper',
        '!f() { echo username=ada; echo password=tok-from-helper; }; f',
      ]);
      final _Recorded log = _Recorded();

      await credentials(
        git: true,
        log: log,
      ).gitCredential('github.com', folder: repository);

      expect(log.records.single.output, isNot(contains('tok-from-helper')));
    });

    test('a helper that never answers is timed out by name', () async {
      // Short on purpose: killing git does not end what its helper started,
      // so this sleep outlives the test by its own length.
      git(<String>['config', 'credential.helper', '!f() { /bin/sleep 4; }; f']);

      final Result<String, CredentialsFailure> answer = await credentials(
        git: true,
        timeout: const Duration(milliseconds: 800),
      ).gitCredential('github.com', folder: repository);

      expect(answer.failureOrNull, const CredentialsTimedOut('git'));
    });
  });
}

extension _Failed<T, F extends AppFailure> on Result<T, F> {
  /// What it failed with, or null when it worked.
  F? get failureOrNull => fold((T _) => null, (F failure) => failure);
}

/// Whether the process [pid] has ended, given a moment to.
Future<bool> _gone(String pid) async {
  for (int attempt = 0; attempt < 40; attempt++) {
    if (Process.runSync('kill', <String>['-0', pid]).exitCode != 0) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return false;
}

/// Where [program] is on this machine's `PATH`.
String _which(String program) =>
    (Process.runSync('which', <String>[program]).stdout as String)
        .split('\n')
        .first
        .trim();

/// The list of commands, kept — the port is ours, so this is an
/// implementation of it and not a stand-in for one.
final class _Recorded implements CommandLog {
  final List<CommandRecord> records = <CommandRecord>[];

  @override
  void record(CommandRecord record) => records.add(record);
}

/// A gate at which somebody says no.
final class _ClosedGate implements CommandGate {
  const _ClosedGate();

  @override
  CommandPlan plan(List<CommandRequest> commands) => const _RefusedPlan();
}

final class _RefusedPlan implements CommandPlan {
  const _RefusedPlan();

  @override
  Future<CommandVerdict> next() =>
      Future<CommandVerdict>.value(const CommandVerdict.denied());

  @override
  void close() {}
}
