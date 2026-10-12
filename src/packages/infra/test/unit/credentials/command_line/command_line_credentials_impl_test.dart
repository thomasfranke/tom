/// [CommandLineCredentialsImpl] against programs that only record: a test
/// that asked the real `gh` would read whoever runs the suite.
library;

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late List<String> ran;
  late List<String?> inputs;
  late Map<String, ProcessResult> answers;
  late Set<String> missing;
  late bool hangs;
  late List<CommandRecord> written;
  late _Gate gate;

  setUp(() {
    ran = <String>[];
    inputs = <String?>[];
    answers = <String, ProcessResult>{};
    missing = <String>{};
    hangs = false;
    written = <CommandRecord>[];
    gate = _Gate();
  });

  CommandLineCredentialsImpl credentials() => CommandLineCredentialsImpl(
    commandLog: _Kept(written),
    commandGate: gate,
    run:
        (
          String executable,
          List<String> arguments, {
          String? input,
          String? workingDirectory,
        }) async {
          if (missing.contains(executable)) {
            throw ProcessException(executable, arguments, 'not found', 2);
          }
          if (hangs) {
            throw TimeoutException('killed');
          }
          final String line = <String>[executable, ...arguments].join(' ');
          ran.add(
            workingDirectory == null ? line : '$line in $workingDirectory',
          );
          inputs.add(input);
          return answers[executable] ?? ProcessResult(0, 0, '', '');
        },
  );

  String valueOf(Result<String, CredentialsFailure> result) =>
      (result as Success<String, CredentialsFailure>).value;

  group('gh', () {
    test('its accounts are asked for as JSON', () async {
      answers['gh'] = ProcessResult(0, 0, '{"hosts":{}}', '');

      expect(
        valueOf(await credentials().ghAccounts('github.com')),
        '{"hosts":{}}',
      );
      expect(ran, <String>[
        'gh auth status --hostname github.com --json hosts',
      ]);
    });

    test('a gh from before --json is asked for its text report', () async {
      answers['gh'] = ProcessResult(0, 1, '', 'unknown flag: --json\n');

      await credentials().ghAccounts('github.com');

      expect(ran.last, 'gh auth status --hostname github.com');
    });

    test('not installed is no account, not a failure', () async {
      missing.add('gh');

      expect(valueOf(await credentials().ghAccounts('github.com')), '');
      expect(valueOf(await credentials().ghToken('github.com', 'ada')), '');
    });

    test('the token is asked for by login', () async {
      answers['gh'] = ProcessResult(0, 0, 'gho_secret\n', '');

      expect(
        valueOf(await credentials().ghToken('github.com', 'ada')),
        'gho_secret',
      );
      expect(ran.single, 'gh auth token --hostname github.com --user ada');
    });

    test('a login gh holds no token for is an empty answer', () async {
      answers['gh'] = ProcessResult(0, 1, '', 'no oauth token found');

      expect(valueOf(await credentials().ghToken('github.com', 'ada')), '');
    });
  });

  group("git's credential", () {
    test('is asked for HTTPS on the host, in the repository', () async {
      answers['git'] = ProcessResult(0, 0, 'password=tok\n', '');

      expect(
        valueOf(
          await credentials().gitCredential('github.com', folder: '/code/app'),
        ),
        'password=tok',
      );
      expect(ran.single, contains('credential fill in /code/app'));
      expect(inputs.single, 'protocol=https\nhost=github.com\n\n');
    });

    test(
      "a helper that has nothing is empty, and git's words are not kept",
      () async {
        answers['git'] = ProcessResult(
          0,
          128,
          'password=half-written',
          'fatal: could not read Username: terminal prompts disabled',
        );

        expect(
          valueOf(await credentials().gitCredential('github.com', folder: '/')),
          '',
        );
      },
    );
  });

  group('ssh', () {
    test('is asked in batch mode, and its greeting comes back', () async {
      answers['ssh'] = ProcessResult(
        0,
        1,
        '',
        "Hi ada! You've successfully authenticated\n",
      );

      expect(
        valueOf(await credentials().sshGreeting('github.com')),
        "Hi ada! You've successfully authenticated",
      );
      expect(ran.single, contains('BatchMode=yes'));
      expect(ran.single, endsWith('git@github.com'));
    });
  });

  test('a program that outlives its time is a failure that names it', () async {
    hangs = true;

    expect(
      (await credentials().ghAccounts('github.com')
              as Failure<String, CredentialsFailure>)
          .failure,
      const CredentialsTimedOut('gh'),
    );
  });

  group('the command log', () {
    test("keeps gh's token out, and still says what was asked", () async {
      answers['gh'] = ProcessResult(0, 0, 'gho_abcdef0123456789\n', '');

      await credentials().ghToken('github.com', 'ada');

      expect(
        written.single.commandLine,
        'gh auth token --hostname github.com --user ada',
      );
      expect(written.single.output, CommandRecord.hidden);
    });

    test("keeps git's credential out, whatever it looks like", () async {
      answers['git'] = ProcessResult(
        0,
        0,
        'protocol=https\nhost=github.com\nusername=ada\npassword=hunter2\n',
        '',
      );

      await credentials().gitCredential('github.com', folder: '/');

      expect(written.single.output, CommandRecord.hidden);
      expect(written.single.output, isNot(contains('ada')));
    });

    test('an account list is written down as gh gave it', () async {
      answers['gh'] = ProcessResult(0, 0, '{"hosts":{}}', '');

      await credentials().ghAccounts('github.com');

      expect(written.single.output, '{"hosts":{}}');
    });

    test(
      'a program not installed is never run and an answer, not red',
      () async {
        missing
          ..add('gh')
          ..add('ssh');

        await credentials().ghAccounts('github.com');
        await credentials().sshGreeting('github.com');

        expect(written.map((CommandRecord it) => it.failed), <bool>[
          false,
          false,
        ]);
        expect(written.map((CommandRecord it) => it.answered), <bool>[
          true,
          true,
        ]);
        expect(written.first.ran, isFalse);
        expect(written.first.exitCode, 127);
        expect(written.first.output, 'not found');
      },
    );

    test('nobody signed in is an answer, not a failure', () async {
      answers['gh'] = ProcessResult(0, 1, '', 'not logged in');
      answers['ssh'] = ProcessResult(0, 255, '', 'Permission denied');

      await credentials().ghAccounts('github.com');
      await credentials().sshGreeting('github.com');

      expect(written.map((CommandRecord it) => it.answered), <bool>[
        true,
        true,
      ]);
      expect(written.any((CommandRecord it) => it.failed), isFalse);
    });
  });

  group('the gate', () {
    test('is asked about gh and git, each by its key', () async {
      await credentials().ghAccounts('github.com');
      await credentials().ghToken('github.com', 'ada');
      await credentials().gitCredential('github.com', folder: '/code/app');

      expect(gate.asked.map((CommandRequest it) => it.key), <String>[
        'gh auth status --hostname <host> --json hosts',
        'gh auth token --hostname <host> --user <login>',
        'git -c credential.interactive=false credential fill',
      ]);
      expect(gate.asked.any((CommandRequest it) => it.isWrite), isFalse);
      expect(written.map((CommandRecord it) => it.ticket), everyElement(7));
    });

    test('the older gh is a question of its own', () async {
      answers['gh'] = ProcessResult(0, 1, '', 'unknown flag: --json\n');

      await credentials().ghAccounts('github.com');

      expect(gate.asked.last.key, 'gh auth status --hostname <host>');
    });

    test('ssh is never asked about: it is neither git nor gh', () async {
      await credentials().sshGreeting('github.com');

      expect(gate.asked, isEmpty);
      expect(ran.single, startsWith('ssh '));
      expect(written.single.ticket, isNull);
    });

    test('a refused question starts nothing, and is not an error', () async {
      gate.allows = false;

      final CredentialsFailure refused =
          (await credentials().ghToken('github.com', 'ada')
                  as Failure<String, CredentialsFailure>)
              .failure;

      expect(refused, isA<CredentialsCommandDenied>());
      expect(refused.isDenial, isTrue);
      expect(ran, isEmpty);
      expect(written, isEmpty);
    });

    test(
      'refusing the JSON report does not go on to ask for the text',
      () async {
        gate.allows = false;

        await credentials().ghAccounts('github.com');

        expect(gate.asked, hasLength(1));
      },
    );

    test('no two keys are the same', () {
      final List<String> templates = CredentialsCommandKeyEnum.values
          .map((CredentialsCommandKeyEnum it) => it.template)
          .toList();

      expect(templates.toSet(), hasLength(templates.length));
    });
  });
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}

/// A gate that says yes or no to everything, and remembers what it was asked.
final class _Gate implements CommandGate, CommandPlan {
  final List<CommandRequest> asked = <CommandRequest>[];
  bool allows = true;

  @override
  CommandPlan plan(List<CommandRequest> commands) {
    asked.addAll(commands);
    return this;
  }

  @override
  Future<CommandVerdict> next() async => allows
      ? const CommandVerdict.run(ticket: 7)
      : const CommandVerdict.denied();

  @override
  void close() {}
}
