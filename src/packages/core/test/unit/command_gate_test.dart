import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';

void main() {
  final DateTime at = DateTime(2026, 10, 9, 9, 30);

  group('a request', () {
    test('carries its key and whether it writes', () {
      final CommandRequest request = CommandRequest.of(
        key: _Key.restore,
        executable: 'git',
        arguments: const <String>['restore', '--worktree', '--', 'a.md'],
      );

      expect(request.key, 'git restore --worktree -- <file>');
      expect(request.isWrite, isTrue);
      expect(request.commandLine, 'git restore --worktree -- a.md');
    });

    test('never holds a secret, as a record never does', () {
      final CommandRequest request = CommandRequest.of(
        key: _Key.status,
        executable: 'git',
        arguments: const <String>[
          'clone',
          'https://me:pw@github.com/a/b',
          'gho_abc123',
          '--format=%H\u001f%s',
        ],
      );

      expect(request.arguments, <String>[
        'clone',
        'https://me:••••@github.com/a/b',
        '••••',
        '--format=%H%x1f%s',
      ]);
      expect(request.isWrite, isFalse);
    });

    test('is quoted the way a terminal needs', () {
      final CommandRequest request = CommandRequest.of(
        key: _Key.restore,
        executable: 'git',
        arguments: const <String>['commit', '--message', "it's done"],
      );

      expect(request.commandLine, r"git commit --message 'it'\''s done'");
    });
  });

  group('a record before the command has ended', () {
    final CommandRequest request = CommandRequest.of(
      key: _Key.status,
      executable: 'git',
      arguments: const <String>['status'],
    );

    test('asked for, it waits and has neither failed nor answered', () {
      final CommandRecord waiting = CommandRecord.asked(request, at: at);

      expect(waiting.stage, CommandStageEnum.waiting);
      expect(waiting.commandLine, 'git status');
      expect(waiting.startedAt, at);
      expect(waiting.failed, isFalse, reason: 'no exit yet is not a failure');
      expect(waiting.answered, isFalse);
    });

    test('running, denied and cancelled have not failed either', () {
      final CommandRecord waiting = CommandRecord.asked(request, at: at);

      for (final CommandStageEnum stage in <CommandStageEnum>[
        CommandStageEnum.running,
        CommandStageEnum.denied,
        CommandStageEnum.cancelled,
      ]) {
        expect(
          waiting.copyWith(stage: stage).failed,
          isFalse,
          reason: '$stage',
        );
      }
    });

    test('a record written once the process is over has ended', () {
      final CommandRecord ended = CommandRecord.of(
        executable: 'git',
        arguments: const <String>['status'],
        startedAt: at,
        duration: Duration.zero,
        exitCode: 128,
        ticket: 7,
      );

      expect(ended.stage, CommandStageEnum.ended);
      expect(ended.failed, isTrue);
      expect(ended.ticket, 7);
    });

    test('only the three that end a command are over', () {
      expect(CommandStageEnum.waiting.isOver, isFalse);
      expect(CommandStageEnum.running.isOver, isFalse);
      expect(CommandStageEnum.ended.isOver, isTrue);
      expect(CommandStageEnum.denied.isOver, isTrue);
      expect(CommandStageEnum.cancelled.isOver, isTrue);
    });
  });

  group('the open gate', () {
    final CommandRequest request = CommandRequest.of(
      key: _Key.status,
      executable: 'git',
      arguments: const <String>['status'],
    );

    test('lets a single command through, with nothing to find again', () async {
      expect(
        await const OpenCommandGateImpl().ask(request),
        const CommandVerdict.run(),
      );
    });

    test('lets every command of a plan through, and closes freely', () async {
      final CommandPlan plan = const OpenCommandGateImpl().plan(
        <CommandRequest>[request, request],
      );

      expect(await plan.next(), const CommandVerdict.run());
      expect(await plan.next(), const CommandVerdict.run());
      expect(plan.close, returnsNormally);
    });
  });

  group('a denial', () {
    test('is told from any other failure by its marker', () {
      expect(const _Denied().isDenial, isTrue);
      expect(const UnexpectedFailure('boom').isDenial, isFalse);
    });

    test('is still one under the failures it was translated into', () {
      const AppFailure wrapped = UnexpectedFailure(
        'could not read the draft',
        cause: UnexpectedFailure('git said no', cause: _Denied()),
      );

      expect(wrapped.isDenial, isTrue);
    });
  });

  test('a timed command hands its ticket back with its record', () {
    final _Kept log = _Kept();

    log.started('git', <String>['push'], ticket: 12)(0);

    expect(log.records.single.ticket, 12);
    expect(log.records.single.stage, CommandStageEnum.ended);
  });
}

enum _Key implements CommandKey {
  status('git status', isWrite: false),
  restore('git restore --worktree -- <file>', isWrite: true);

  const _Key(this.template, {required this.isWrite});

  @override
  final String template;

  @override
  final bool isWrite;
}

final class _Denied implements CommandDenial {
  const _Denied();

  @override
  AppFailure? get cause => null;
}

final class _Kept implements CommandLog {
  final List<CommandRecord> records = <CommandRecord>[];

  @override
  void record(CommandRecord record) => records.add(record);
}
