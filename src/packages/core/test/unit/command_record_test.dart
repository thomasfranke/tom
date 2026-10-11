import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';

void main() {
  final DateTime at = DateTime(2026, 10, 8, 14, 3, 12);

  CommandRecord of({
    String executable = 'git',
    List<String> arguments = const <String>['status'],
    int? exitCode = 0,
    String stdout = '',
    String stderr = '',
    bool secretOutput = false,
  }) => CommandRecord.of(
    executable: executable,
    arguments: arguments,
    startedAt: at,
    duration: const Duration(milliseconds: 38),
    exitCode: exitCode,
    stdout: stdout,
    stderr: stderr,
    secretOutput: secretOutput,
  );

  group('what it keeps', () {
    test('the program, its arguments and what it printed, in order', () {
      final CommandRecord record = of(
        arguments: <String>['fetch', 'origin'],
        exitCode: 1,
        stdout: 'out\n',
        stderr: 'fatal: no\n',
      );

      expect(record.executable, 'git');
      expect(record.arguments, <String>['fetch', 'origin']);
      expect(record.output, 'out\nfatal: no');
      expect(record.failed, isTrue);
    });

    test('a process that never ended on its own failed', () {
      expect(of(exitCode: null).failed, isTrue);
      expect(of().failed, isFalse);
    });

    test('an exit the caller asked for as an answer is neither', () {
      final CommandRecord unset = CommandRecord.of(
        executable: 'git',
        arguments: const <String>['config', '--get', 'user.name'],
        startedAt: at,
        duration: Duration.zero,
        exitCode: 1,
        answers: const <int>{1},
      );

      expect(unset.failed, isFalse);
      expect(unset.answered, isTrue);
    });

    test('an exit it did not ask for is still a failure', () {
      final CommandRecord broken = CommandRecord.of(
        executable: 'git',
        arguments: const <String>['config', '--get', 'user.name'],
        startedAt: at,
        duration: Duration.zero,
        exitCode: 128,
        answers: const <int>{1},
      );

      expect(broken.failed, isTrue);
      expect(broken.answered, isFalse);
      expect(of().answered, isFalse, reason: 'success is not an answer');
    });

    test('a program that could not start did not run', () {
      final CommandRecord missing = CommandRecord.of(
        executable: 'gh',
        arguments: const <String>['auth', 'status'],
        startedAt: at,
        duration: Duration.zero,
        ran: false,
      );

      expect(missing.ran, isFalse);
      expect(missing.failed, isTrue);
      expect(of().ran, isTrue);
    });

    test('nothing printed is an empty output', () {
      expect(of(stdout: '\n  \n').output, '');
    });

    test('git separators read as lines and spaces', () {
      expect(of(stdout: 'a\u0000b\u001fc\u001e').output, 'a\nb c');
    });

    test('a long answer is cut, and says so', () {
      final String long = List<String>.generate(
        250,
        (int i) => '$i',
      ).join('\n');

      final List<String> lines = of(stdout: long).output.split('\n');

      expect(lines, hasLength(CommandRecord.outputLines + 1));
      expect(lines.last, '…');
    });
  });

  group('no secret is ever kept', () {
    test('a credential program keeps no standard output at all', () {
      final CommandRecord record = of(
        arguments: <String>['credential', 'fill'],
        stdout: 'protocol=https\nhost=github.com\nusername=me\n',
        secretOutput: true,
      );

      expect(record.output, CommandRecord.hidden);
      expect(record.output, isNot(contains('me')));
    });

    test('but still says what went wrong on standard error', () {
      final CommandRecord record = of(
        executable: 'gh',
        arguments: <String>['auth', 'token'],
        exitCode: 1,
        stderr: 'no account for github.com',
        secretOutput: true,
      );

      expect(record.output, 'no account for github.com');
    });

    test('a line holding a password, an oauth word or a token goes whole', () {
      final CommandRecord record = of(
        stdout:
            'username=me\npassword=hunter2\nx-oauth-basic\n'
            'token ghp_abcdefABCDEF0123456789\n'
            'github_pat_11ABC_def\nAuthorization: Bearer x\nkept',
      );

      expect(record.output.split('\n'), <String>[
        'username=me',
        for (int i = 0; i < 5; i++) CommandRecord.hidden,
        'kept',
      ]);
    });

    test("an address's password is hidden, its user kept", () {
      final CommandRecord record = of(
        arguments: <String>['clone', '--', 'https://me:pw@github.com/a/b'],
      );

      expect(record.arguments.last, 'https://me:••••@github.com/a/b');
    });

    test('a token in an argument is hidden', () {
      expect(
        of(arguments: <String>['-c', 'x=gho_abc123']).arguments.last,
        'x=••••',
      );
    });
  });

  group('the command line', () {
    test('is what a terminal would run', () {
      expect(
        of(arguments: <String>['commit', '-m', "it's done"]).commandLine,
        r"git commit -m 'it'\''s done'",
      );
    });

    test('spells a separator the way git formats do', () {
      expect(
        of(arguments: <String>['log', '--format=%H\u001f%s']).commandLine,
        'git log --format=%H%x1f%s',
      );
    });

    test('quotes an empty argument', () {
      expect(of(arguments: <String>['-c', '']).commandLine, "git -c ''");
    });
  });

  test('the silent log takes a record and keeps nothing', () {
    expect(() => const SilentCommandLogImpl().record(of()), returnsNormally);
  });

  test('a timed command is written down once it ends, as it ran', () {
    final _Kept log = _Kept();

    log.started('gh', <String>['auth', 'token'], secretOutput: true)(
      0,
      stdout: 'gho_secret',
    );

    expect(log.records.single.commandLine, 'gh auth token');
    expect(log.records.single.exitCode, 0);
    expect(log.records.single.output, CommandRecord.hidden);
  });

  test('a timed command carries the answers its caller declared', () {
    final _Kept log = _Kept();

    log.started('git', <String>['rev-parse'], answers: <int>{1})(1);
    log.started('gh', <String>['auth'])(null, ran: false);

    expect(log.records.first.answered, isTrue);
    expect(log.records.last.ran, isFalse);
  });
}

final class _Kept implements CommandLog {
  final List<CommandRecord> records = <CommandRecord>[];

  @override
  void record(CommandRecord record) => records.add(record);
}
