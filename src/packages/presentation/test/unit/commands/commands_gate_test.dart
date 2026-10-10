/// [CommandsNotifier] as the gate the capabilities ask: who waits, who runs,
/// and what one refusal stops (`docs/product/git-workflow/approvals/doc.md`).
library;

import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Preferences stored;
  late _Approvals list;
  late ProviderContainer container;

  const String statusKey =
      'git status --porcelain=v2 --branch --untracked-files=all -z';

  CommandRequest request(String key, {bool isWrite = true}) => CommandRequest(
    key: key,
    executable: 'git',
    arguments: key.split(' ').skip(1).toList(),
    isWrite: isWrite,
  );

  final CommandRequest reset = request('git reset --quiet');
  final CommandRequest restore = request('git restore --worktree -- :/');
  final CommandRequest push = request('git push');
  final CommandRequest status = request(statusKey, isWrite: false);

  setUp(() {
    stored = _Preferences();
    list = _Approvals();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: stored),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: stored,
            observability: const _Silent(),
          ),
        ),
        readApprovalsProvider.overrideWithValue(
          ReadApprovalsUseCase(approvals: list),
        ),
        allowCommandProvider.overrideWithValue(
          AllowCommandUseCase(approvals: list, observability: const _Silent()),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  void mode(GitApprovalModeEnum chosen) =>
      stored.held = PreferencesValueObject(gitApprovals: chosen);

  CommandsNotifier commands() => container.read(commandsProvider.notifier);

  CommandsState state() => container.read(commandsProvider);

  List<CommandStageEnum> stages() =>
      state().rows.map((CommandRow it) => it.stage).toList();

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// The record a capability writes once the command behind [ticket] ended.
  CommandRecord ended(
    CommandRequest command, {
    int? ticket,
    int exitCode = 0,
  }) => CommandRecord.of(
    executable: command.executable,
    arguments: command.arguments,
    startedAt: DateTime(2026, 10, 9),
    duration: const Duration(milliseconds: 12),
    exitCode: exitCode,
    ticket: ticket,
  );

  /// Asks about [command] as a capability does, and waits for the row.
  Future<Future<CommandVerdict>> ask(CommandRequest command) async {
    final Future<CommandVerdict> verdict = commands().ask(command);
    await settle();
    return verdict;
  }

  group('automatic', () {
    test('lets every command through, with nothing to find again', () async {
      expect(await commands().ask(push), const CommandVerdict.run());
      expect(await commands().ask(status), const CommandVerdict.run());
    });

    test('lists a command once it ended, as before there was a gate', () async {
      await commands().ask(push);

      expect(state().rows, isEmpty);

      commands().record(ended(push));

      expect(stages(), <CommandStageEnum>[CommandStageEnum.ended]);
      expect(state().rows.single.plan, isNull);
      expect(state().waiting, 0);
    });

    test('never opens the panel', () async {
      await commands().ask(push);

      expect(container.read(workspaceProvider).showingBottom, isFalse);
    });

    test('a whole plan runs, and closing it changes nothing', () async {
      final CommandPlan plan = commands().plan(<CommandRequest>[
        reset,
        restore,
      ]);

      expect(await plan.next(), const CommandVerdict.run());
      expect(await plan.next(), const CommandVerdict.run());
      plan.close();
      await settle();

      expect(state().rows, isEmpty);
    });
  });

  group('manual', () {
    setUp(() => mode(GitApprovalModeEnum.manual));

    test('a command waits, as a row that says what will run', () async {
      await ask(push);

      final CommandRow row = state().rows.single;
      expect(row.stage, CommandStageEnum.waiting);
      expect(row.record.commandLine, 'git push');
      expect(row.key, 'git push');
      expect(row.isWrite, isTrue);
      expect(row.isAllowed, isFalse);
      expect(state().waiting, 1);
      expect(state().isApprovable(row), isTrue);
      expect(row.record.failed, isFalse, reason: 'waiting is not failing');
    });

    test('a read waits too, and the list is never consulted', () async {
      list.held[statusKey] = true;

      await ask(status);

      expect(stages(), <CommandStageEnum>[CommandStageEnum.waiting]);
      expect(state().rows.single.isWrite, isFalse);
      expect(list.reads, 0);
    });

    test('the panel opens by itself, on the commands', () async {
      await ask(push);

      final WorkspaceState workspace = container.read(workspaceProvider);
      expect(workspace.showingBottom, isTrue);
      expect(workspace.bottomPanel, CommandsNotifier.panel);
    });

    test('Run lets it start, and it is the same row once it ended', () async {
      final Future<CommandVerdict> verdict = await ask(push);
      final int id = state().rows.single.id;

      commands().run(id);

      expect(await verdict, CommandVerdict.run(ticket: id));
      expect(stages(), <CommandStageEnum>[CommandStageEnum.running]);
      expect(state().waiting, 0);

      commands().record(ended(push, ticket: id));

      expect(stages(), <CommandStageEnum>[CommandStageEnum.ended]);
      expect(state().rows.single.id, id);
      expect(state().rows.single.record.duration.inMilliseconds, 12);
      expect(state().total, 1, reason: 'one command, one row');
    });

    test('Deny refuses it: it never starts, and has not failed', () async {
      final Future<CommandVerdict> verdict = await ask(push);

      commands().deny(state().rows.single.id);

      expect(await verdict, const CommandVerdict.denied());
      expect(stages(), <CommandStageEnum>[CommandStageEnum.denied]);
      expect(state().rows.single.record.failed, isFalse);
      expect(commands().revealLastFailure(), isFalse);
    });

    test('a command that failed is still told from one refused', () async {
      final Future<CommandVerdict> verdict = await ask(push);
      final int id = state().rows.single.id;
      commands().run(id);
      await verdict;

      commands().record(ended(push, ticket: id, exitCode: 1));

      expect(state().rows.single.record.failed, isTrue);
      expect(commands().revealLastFailure(), isTrue);
    });

    group('a plan of two', () {
      late CommandPlan plan;
      late Future<CommandVerdict> first;

      setUp(() async {
        plan = commands().plan(<CommandRequest>[reset, restore]);
        first = plan.next();
        await settle();
      });

      test('lists both at once, and only the first can be answered', () {
        final List<CommandRow> rows = state().rows;

        expect(stages(), <CommandStageEnum>[
          CommandStageEnum.waiting,
          CommandStageEnum.waiting,
        ]);
        expect(rows.first.plan, rows.last.plan);
        expect(state().planOf(rows.first.plan!), hasLength(2));
        expect(state().isApprovable(rows.first), isTrue);
        expect(state().isApprovable(rows.last), isFalse);
        expect(state().waiting, 2);
      });

      test('the one under it cannot be run or refused ahead', () {
        commands()
          ..run(state().rows.last.id)
          ..deny(state().rows.last.id);

        expect(stages(), <CommandStageEnum>[
          CommandStageEnum.waiting,
          CommandStageEnum.waiting,
        ]);
      });

      test(
        'the next becomes the one that waits once the first ended',
        () async {
          final int one = state().rows.first.id;
          final int two = state().rows.last.id;
          commands().run(one);
          await first;

          expect(
            state().isApprovable(state().rows.last),
            isFalse,
            reason: 'the first is still running',
          );

          commands().record(ended(reset, ticket: one));
          final Future<CommandVerdict> second = plan.next();
          await settle();

          expect(state().isApprovable(state().rows.last), isTrue);

          commands().run(two);

          expect(await second, CommandVerdict.run(ticket: two));
        },
      );

      test('refusing the first cancels the second, and nothing ran', () async {
        final int planId = state().rows.first.plan!;

        commands().deny(state().rows.first.id);

        expect(await first, const CommandVerdict.denied());
        expect(stages(), <CommandStageEnum>[
          CommandStageEnum.denied,
          CommandStageEnum.cancelled,
        ]);
        expect(await plan.next(), const CommandVerdict.denied());
        expect(state().isStopped(planId), isTrue);
        expect(state().ranIn(planId), 0);
        expect(state().waiting, 0);
      });

      test('refusing the second leaves what ran: one of two', () async {
        final int planId = state().rows.first.plan!;
        final int one = state().rows.first.id;
        commands().run(one);
        await first;
        commands().record(ended(reset, ticket: one));
        final Future<CommandVerdict> second = plan.next();
        await settle();

        commands().deny(state().rows.last.id);

        expect(await second, const CommandVerdict.denied());
        expect(stages(), <CommandStageEnum>[
          CommandStageEnum.ended,
          CommandStageEnum.denied,
        ]);
        expect(state().ranIn(planId), 1);
        expect(state().planOf(planId), hasLength(2));
        expect(state().isStopped(planId), isTrue);
      });

      test(
        'a first that failed cancels the rest when the plan closes',
        () async {
          final int one = state().rows.first.id;
          commands().run(one);
          await first;
          commands().record(ended(reset, ticket: one, exitCode: 128));

          plan.close();
          await settle();

          expect(stages(), <CommandStageEnum>[
            CommandStageEnum.ended,
            CommandStageEnum.cancelled,
          ]);
          expect(
            state().isStopped(state().rows.first.plan!),
            isFalse,
            reason: 'nobody refused anything',
          );
        },
      );
    });

    group('an action', () {
      test('names its plan, and what is asked inside it is one plan', () async {
        late Future<CommandVerdict> first;
        late Future<CommandVerdict> second;
        await CommandScope.run(CommandActionEnum.readRepository, () async {
          first = commands().ask(status);
          await settle();
          commands().run(state().rows.single.id);
          await first;
          commands().record(ended(status, ticket: state().rows.single.id));
          // Asked after an await, still inside the action.
          second = commands().ask(request('git rev-parse MERGE_HEAD'));
          await settle();
        });

        final List<CommandRow> rows = state().rows;
        expect(rows, hasLength(2));
        expect(rows.first.plan, rows.last.plan);
        expect(
          rows.map((CommandRow it) => it.action),
          everyElement(CommandActionEnum.readRepository),
        );
        expect(state().isApprovable(rows.last), isTrue);
        commands().deny(rows.last.id);
        expect(await second, const CommandVerdict.denied());
      });

      test('run twice is two plans', () async {
        for (int run = 0; run < 2; run++) {
          await CommandScope.run(CommandActionEnum.push, () async {
            unawaited(commands().ask(push));
            await settle();
          });
        }

        final List<CommandRow> rows = state().rows;
        expect(rows.first.plan, isNot(rows.last.plan));
        expect(state().isApprovable(rows.first), isTrue);
        expect(state().isApprovable(rows.last), isTrue);
      });

      test('says it waits, then that it runs, then neither', () async {
        late Future<CommandVerdict> verdict;
        await CommandScope.run(CommandActionEnum.push, () async {
          verdict = commands().ask(push);
          await settle();
        });
        final int id = state().rows.single.id;

        expect(state().isWaitingOn(CommandActionEnum.push), isTrue);
        expect(state().isRunning(CommandActionEnum.push), isFalse);
        expect(state().isWaitingOn(CommandActionEnum.pull), isFalse);

        commands().run(id);
        await verdict;

        expect(state().isWaitingOn(CommandActionEnum.push), isFalse);
        expect(state().isRunning(CommandActionEnum.push), isTrue);

        commands().record(ended(push, ticket: id));

        expect(state().isRunning(CommandActionEnum.push), isFalse);
      });

      test('once refused, what it asks next never runs nor waits', () async {
        late Future<CommandVerdict> later;
        await CommandScope.run(CommandActionEnum.discardAll, () async {
          final Future<CommandVerdict> first = commands().ask(reset);
          await settle();
          commands().deny(state().rows.single.id);
          await first;
          later = commands().ask(restore);
          await settle();
        });

        expect(await later, const CommandVerdict.denied());
        expect(stages(), <CommandStageEnum>[
          CommandStageEnum.denied,
          CommandStageEnum.cancelled,
        ]);
        expect(state().waiting, 0);
      });

      test(
        'outside any, a command is a plan of its own with no name',
        () async {
          await ask(push);

          expect(state().rows.single.action, isNull);
          expect(state().rows.single.plan, isNotNull);
        },
      );
    });

    group('Always allow', () {
      test('runs nothing: it asks whether to leave Manual', () async {
        final Future<CommandVerdict> verdict = await ask(push);
        final int id = state().rows.single.id;
        bool answered = false;
        unawaited(verdict.then((CommandVerdict _) => answered = true));

        await commands().alwaysAllow(id);
        await settle();

        expect(state().pendingSwitch, id);
        expect(stages(), <CommandStageEnum>[CommandStageEnum.waiting]);
        expect(answered, isFalse);
        expect(list.held, isEmpty);
      });

      test(
        'Stay in Manual keeps the mode and the question on the row',
        () async {
          await ask(push);
          final int id = state().rows.single.id;
          await commands().alwaysAllow(id);

          commands().stayInManual();

          expect(state().pendingSwitch, isNull);
          expect(
            container.read(preferencesProvider).gitApprovals,
            GitApprovalModeEnum.manual,
          );
          expect(state().isApprovable(state().rows.single), isTrue);
          expect(list.held, isEmpty);
        },
      );

      test('switching allows that one command, and runs it', () async {
        final Future<CommandVerdict> verdict = await ask(push);
        final Future<CommandVerdict> other = await ask(status);
        final int id = state().rows.first.id;
        bool otherAnswered = false;
        unawaited(other.then((CommandVerdict _) => otherAnswered = true));
        await commands().alwaysAllow(id);

        await commands().switchToSemiAndAllow();
        await settle();

        expect(await verdict, CommandVerdict.run(ticket: id));
        expect(state().pendingSwitch, isNull);
        expect(
          container.read(preferencesProvider).gitApprovals,
          GitApprovalModeEnum.semi,
        );
        expect(stored.held.gitApprovals, GitApprovalModeEnum.semi);
        expect(list.held, <String, bool>{'git push': true});
        expect(otherAnswered, isFalse, reason: 'every other stays false');
        expect(state().rows.last.stage, CommandStageEnum.waiting);
      });

      test('a row refused meanwhile takes its question with it', () async {
        await ask(push);
        final int id = state().rows.single.id;
        await commands().alwaysAllow(id);

        commands().deny(id);
        await commands().switchToSemiAndAllow();

        expect(state().pendingSwitch, isNull);
        expect(stages(), <CommandStageEnum>[CommandStageEnum.denied]);
        expect(
          container.read(preferencesProvider).gitApprovals,
          GitApprovalModeEnum.manual,
        );
      });
    });
  });

  group('semi-automatic', () {
    setUp(() => mode(GitApprovalModeEnum.semi));

    test('a command the file allows runs at once, and says so', () async {
      list.held['git push'] = true;

      final Future<CommandVerdict> verdict = await ask(push);
      final CommandRow row = state().rows.single;

      expect(await verdict, CommandVerdict.run(ticket: row.id));
      expect(row.stage, CommandStageEnum.running);
      expect(row.isAllowed, isTrue);
      expect(container.read(workspaceProvider).showingBottom, isFalse);

      commands().record(ended(push, ticket: row.id));

      expect(state().rows.single.stage, CommandStageEnum.ended);
      expect(state().rows.single.isAllowed, isTrue);
    });

    test('anything else waits: a missing key is false', () async {
      list.held['git fetch'] = true;

      await ask(push);

      expect(stages(), <CommandStageEnum>[CommandStageEnum.waiting]);
      expect(state().rows.single.isAllowed, isFalse);
      expect(container.read(workspaceProvider).showingBottom, isTrue);
    });

    test('flags are part of the key', () async {
      list.held['git restore --staged -- <files>'] = true;

      await ask(request('git restore --worktree -- <file>'));

      expect(stages(), <CommandStageEnum>[CommandStageEnum.waiting]);
    });

    test('the file is read at every question, so a save applies', () async {
      await ask(push);
      expect(stages().last, CommandStageEnum.waiting);

      list.held['git push'] = true;
      final Future<CommandVerdict> again = await ask(push);

      expect(stages().last, CommandStageEnum.running);
      expect(await again, isA<CommandRun>());
    });

    test('Always allow writes true beside the key and runs it', () async {
      final Future<CommandVerdict> verdict = await ask(push);
      final int id = state().rows.single.id;

      await commands().alwaysAllow(id);

      expect(await verdict, CommandVerdict.run(ticket: id));
      expect(list.held, <String, bool>{'git push': true});
      expect(state().pendingSwitch, isNull);
    });

    test('and the same command waiting elsewhere runs too', () async {
      final Future<CommandVerdict> first = await ask(push);
      final Future<CommandVerdict> second = await ask(push);

      await commands().alwaysAllow(state().rows.first.id);
      await settle();

      expect(await first, isA<CommandRun>());
      expect(await second, CommandVerdict.run(ticket: state().rows.last.id));
      expect(state().rows.last.isAllowed, isTrue);
    });

    test('Run lets one through and writes nothing', () async {
      final Future<CommandVerdict> verdict = await ask(push);

      commands().run(state().rows.single.id);

      expect(await verdict, isA<CommandRun>());
      expect(list.held, isEmpty);
    });

    test('an allowed command waits its turn behind one that is not', () async {
      list.held[restore.key] = true;
      final CommandPlan plan = commands().plan(<CommandRequest>[
        reset,
        restore,
      ]);
      final Future<CommandVerdict> first = plan.next();
      await settle();

      expect(stages(), <CommandStageEnum>[
        CommandStageEnum.waiting,
        CommandStageEnum.waiting,
      ]);
      expect(state().rows.last.isAllowed, isTrue);

      final int one = state().rows.first.id;
      commands().run(one);
      await first;
      commands().record(ended(reset, ticket: one));

      expect(
        await plan.next(),
        CommandVerdict.run(ticket: state().rows.last.id),
      );
    });
  });

  group('changing the mode while commands wait', () {
    test('to Automatic runs what waits', () async {
      mode(GitApprovalModeEnum.manual);
      final Future<CommandVerdict> verdict = await ask(push);

      container
          .read(preferencesProvider.notifier)
          .chooseGitApprovals(GitApprovalModeEnum.automatic);
      await settle();

      expect(await verdict, isA<CommandRun>());
      expect(stages(), <CommandStageEnum>[CommandStageEnum.running]);
      expect(state().rows.single.isAllowed, isTrue);
    });

    test('to Automatic runs a plan in its order, not all at once', () async {
      mode(GitApprovalModeEnum.manual);
      final CommandPlan plan = commands().plan(<CommandRequest>[
        reset,
        restore,
      ]);
      final Future<CommandVerdict> first = plan.next();
      await settle();

      container
          .read(preferencesProvider.notifier)
          .chooseGitApprovals(GitApprovalModeEnum.automatic);
      await settle();
      await first;

      expect(stages(), <CommandStageEnum>[
        CommandStageEnum.running,
        CommandStageEnum.waiting,
      ]);

      commands().record(ended(reset, ticket: state().rows.first.id));

      expect(await plan.next(), isA<CommandRun>());
    });

    test('from Manual to Semi runs only what the file allows', () async {
      mode(GitApprovalModeEnum.manual);
      list.held['git push'] = true;
      final Future<CommandVerdict> allowed = await ask(push);
      await ask(status);

      container
          .read(preferencesProvider.notifier)
          .chooseGitApprovals(GitApprovalModeEnum.semi);
      await settle();

      expect(await allowed, isA<CommandRun>());
      expect(stages(), <CommandStageEnum>[
        CommandStageEnum.running,
        CommandStageEnum.waiting,
      ]);
    });

    test('from Semi to Manual, an allowed one not yet started waits', () async {
      mode(GitApprovalModeEnum.semi);
      list.held[restore.key] = true;
      final CommandPlan plan = commands().plan(<CommandRequest>[
        reset,
        restore,
      ]);
      final Future<CommandVerdict> first = plan.next();
      await settle();

      container
          .read(preferencesProvider.notifier)
          .chooseGitApprovals(GitApprovalModeEnum.manual);
      await settle();
      final int one = state().rows.first.id;
      commands().run(one);
      await first;
      commands().record(ended(reset, ticket: one));
      bool started = false;
      unawaited(plan.next().then((CommandVerdict _) => started = true));
      await settle();

      expect(state().rows.last.isAllowed, isFalse);
      expect(started, isFalse);
      expect(state().isApprovable(state().rows.last), isTrue);
    });

    test('a file saved by hand is judged again when asked to', () async {
      mode(GitApprovalModeEnum.semi);
      final Future<CommandVerdict> verdict = await ask(push);

      list.held['git push'] = true;
      await commands().reconsider();

      expect(await verdict, isA<CommandRun>());
    });
  });

  test('a command asked while the window opens is judged by the stored '
      'mode, not by the default', () async {
    mode(GitApprovalModeEnum.manual);
    stored.reading = Completer<void>();
    bool answered = false;

    unawaited(commands().ask(push).then((CommandVerdict _) => answered = true));
    await settle();

    expect(answered, isFalse, reason: 'the preferences are still out');
    expect(state().rows, isEmpty);

    stored.reading!.complete();
    await settle();

    expect(answered, isFalse);
    expect(stages(), <CommandStageEnum>[CommandStageEnum.waiting]);
  });

  test('leaving the space cancels what waits there', () async {
    mode(GitApprovalModeEnum.manual);
    final SpaceEntity docs = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );
    container.read(spaceSessionProvider.notifier).open(docs);
    final Future<CommandVerdict> verdict = await ask(push);

    container.read(spaceSessionProvider.notifier).close();

    expect(await verdict, const CommandVerdict.denied());
    expect(stages(), <CommandStageEnum>[CommandStageEnum.cancelled]);
  });

  test('a row that still waits is never dropped off the top', () async {
    mode(GitApprovalModeEnum.manual);
    await ask(push);
    final int id = state().rows.single.id;

    for (int i = 0; i < CommandsNotifier.kept + 10; i++) {
      commands().record(ended(status));
    }

    expect(state().rows, hasLength(CommandsNotifier.kept));
    expect(state().rows.first.id, id);
    expect(state().rows.first.stage, CommandStageEnum.waiting);
    expect(state().total, CommandsNotifier.kept + 11);
  });

  test('a window that goes answers whoever still waits with no', () async {
    mode(GitApprovalModeEnum.manual);
    final Future<CommandVerdict> verdict = await ask(push);

    container.dispose();

    expect(await verdict, const CommandVerdict.denied());
  });

  group('the scope', () {
    test('is nothing outside an action', () {
      expect(CommandScope.current, isNull);
    });

    test('is the action inside it, across an await', () async {
      await CommandScope.run(CommandActionEnum.commit, () async {
        final CommandScope? before = CommandScope.current;
        await Future<void>.delayed(Duration.zero);

        expect(CommandScope.current?.action, CommandActionEnum.commit);
        expect(CommandScope.current, same(before));
      });

      expect(CommandScope.current, isNull);
    });

    test('hands back what the action answered', () async {
      expect(await CommandScope.run(CommandActionEnum.fetch, () async => 7), 7);
    });
  });
}

/// The preferences a machine holds, read as slowly as a test wants.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  /// What a read waits on, when a test holds it back.
  Completer<void>? reading;

  @override
  Future<PreferencesValueObject> read() async {
    await reading?.future;
    return held;
  }

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

/// `git-approvals.json`, in memory.
final class _Approvals implements ApprovalsRepository {
  final Map<String, bool> held = <String, bool>{};
  int reads = 0;

  @override
  Future<ApprovalsValueObject> read() async {
    reads++;
    return ApprovalsValueObject(Map<String, bool>.of(held));
  }

  @override
  Future<Result<void, AppFailure>> write(
    String key, {
    required bool allowed,
  }) async {
    held[key] = allowed;
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> seed() async =>
      const Success<void, AppFailure>(null);
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
