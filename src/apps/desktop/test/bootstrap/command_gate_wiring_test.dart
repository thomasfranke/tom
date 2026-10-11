/// The gate as the composition root wires it: real git, a real preferences
/// file and the real list beside it — everything but the widgets
/// ([Decision 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late Directory temp;
  late String repository;
  late File preferences;
  late File list;
  late ProviderContainer container;

  void git(List<String> arguments) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repository,
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  setUp(() {
    temp = Directory.systemTemp.createTempSync('tom_gate_wiring_');
    repository = '${temp.resolveSymbolicLinksSync()}/repo';
    Directory(repository).createSync();
    git(<String>['init', '--quiet', '.']);
    File('$repository/a.md').writeAsStringSync('# A\n');
    preferences = File('${temp.path}/app/preferences.json');
    list = File('${temp.path}/app/${ApprovalsRepository.fileName}');
    container = ProviderContainer(
      overrides: <Override>[
        ...appOverrides,
        settingsProvider.overrideWith(
          (Ref ref) => JsonFileSettingsImpl(
            filesystem: ref.watch(filesystemProvider),
            path: preferences.path,
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
  });

  /// Has the machine's preferences file say who approves.
  void mode(String name) => preferences
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      jsonEncode(<String, Object?>{
        'app.preferences': <String, Object?>{'gitApprovals': name},
      }),
    );

  List<CommandRow> rows() => container.read(commandsProvider).rows;

  /// Waits until the list holds [count] rows, as a person would see them.
  Future<void> listed(int count) async {
    for (int tries = 0; rows().length < count && tries < 200; tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(rows(), hasLength(count));
  }

  test('every command that asks is listed once, flags and all', () {
    expect(gatedCommandKeys.toSet(), hasLength(gatedCommandKeys.length));
    expect(
      gatedCommandKeys,
      containsAll(<String>[
        'git restore --staged -- <files>',
        'git restore --worktree -- <file>',
        'gh pr create --repo <host>/<repository> --base <branch> '
            '--head <branch> --title <title> --body-file -',
        'gh auth token --hostname <host> --user <login>',
      ]),
    );
  });

  test('the list is a file beside the preferences, every command '
      'false', () async {
    await container.read(approvalsRepositoryProvider).seed();

    final Map<String, Object?> held =
        jsonDecode(list.readAsStringSync()) as Map<String, Object?>;
    expect(held.keys.toList(), gatedCommandKeys);
    expect(held.values, everyElement(isFalse));
  });

  test('Automatic asks nobody: git runs, and is listed once it '
      'ended', () async {
    final Result<String, GitClientFailure> status = await container
        .read(gitClientForProvider)(repository)
        .status();

    expect(status, isA<Success<String, GitClientFailure>>());
    expect(rows().single.stage, CommandStageEnum.ended);
    expect(rows().single.plan, isNull);
    expect(container.read(workspaceProvider).showingBottom, isFalse);
  });

  test('in Manual a read waits at the list, and git runs only once it is '
      'let', () async {
    mode('manual');

    final Future<Result<String, GitClientFailure>> status = container
        .read(gitClientForProvider)(repository)
        .status();
    await listed(1);

    final CommandRow waiting = rows().single;
    expect(waiting.stage, CommandStageEnum.waiting);
    expect(waiting.key, GitCommandKeyEnum.status.template);
    expect(waiting.isWrite, isFalse);
    expect(container.read(workspaceProvider).showingBottom, isTrue);
    expect(
      container.read(workspaceProvider).bottomPanel,
      CommandsNotifier.panel,
    );

    container.read(commandsProvider.notifier).run(waiting.id);

    expect(
      (await status as Success<String, GitClientFailure>).value,
      contains('a.md'),
    );
    expect(rows().single.id, waiting.id, reason: 'the same row');
    expect(rows().single.stage, CommandStageEnum.ended);
    expect(rows().single.record.exitCode, 0);
  });

  test('refused, git never starts and the file is not staged', () async {
    mode('manual');

    final Future<Result<void, GitClientFailure>> staging = container
        .read(gitClientForProvider)(repository)
        .stage(<String>['a.md']);
    await listed(1);
    container.read(commandsProvider.notifier).deny(rows().single.id);

    final Result<void, GitClientFailure> refused = await staging;

    expect(
      (refused as Failure<void, GitClientFailure>).failure,
      isA<GitClientCommandDenied>(),
    );
    expect(rows().single.stage, CommandStageEnum.denied);
    expect(
      Process.runSync('git', <String>[
        'status',
        '--porcelain',
      ], workingDirectory: repository).stdout,
      startsWith('?? a.md'),
    );
  });

  test('in Semi-automatic, Always allow writes the key and the next one '
      'runs unasked', () async {
    mode('semi');
    final GitClient client = container.read(gitClientForProvider)(repository);

    final Future<Result<String, GitClientFailure>> first = client.status();
    await listed(1);
    await container
        .read(commandsProvider.notifier)
        .alwaysAllow(rows().single.id);
    await first;

    expect(
      (jsonDecode(list.readAsStringSync())
          as Map<String, Object?>)[GitCommandKeyEnum.status.template],
      isTrue,
    );

    await client.status();

    expect(rows(), hasLength(2));
    expect(rows().last.stage, CommandStageEnum.ended);
    expect(rows().last.isAllowed, isTrue);
  });

  /// Answers whatever waits, the way a person at the panel would: [answer]
  /// is called with each approvable row until [done] is true.
  Future<void> approver(
    bool Function() done,
    void Function(CommandsNotifier commands, CommandRow row) answer,
  ) async {
    for (int tries = 0; !done() && tries < 500; tries++) {
      final CommandsState state = container.read(commandsProvider);
      final Iterable<CommandRow> ready = state.rows.where(state.isApprovable);
      if (ready.isNotEmpty) {
        answer(container.read(commandsProvider.notifier), ready.first);
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('in Manual Home asks git nothing by itself: the account is read, '
      'through the gate, when the popover opens', () async {
    mode('manual');
    container
      ..listen<PreferencesValueObject>(preferencesProvider, (_, _) {})
      ..listen<AccountState>(accountProvider, (_, _) {});
    await container.read(preferencesProvider.notifier).loaded;
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(container.read(accountProvider).isUnread, isTrue);
    expect(rows(), isEmpty);

    unawaited(container.read(accountProvider.notifier).readIfUnread());
    for (int tries = 0; rows().isEmpty && tries < 200; tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    expect(rows(), isNotEmpty);
    expect(rows().first.stage, CommandStageEnum.waiting);
    expect(container.read(accountProvider).isUnread, isFalse);
  });

  test('opening a space in Manual waits at the panel, and opens once every '
      'command it asks was let', () async {
    mode('manual');
    bool finished = false;
    final Future<Result<SpaceEntity, AppFailure>> opening = container
        .read(openSpaceProvider)
        .open(repository)
        .whenComplete(() => finished = true);
    await listed(1);
    expect(container.read(workspaceProvider).showingBottom, isTrue);
    expect(finished, isFalse, reason: 'it ran before anybody said Run');

    await approver(
      () => finished,
      (CommandsNotifier commands, CommandRow row) => commands.run(row.id),
    );

    expect(await opening, isA<Success<SpaceEntity, AppFailure>>());
    expect(rows().length, greaterThan(1));
    expect(
      rows().map((CommandRow it) => it.stage),
      everyElement(CommandStageEnum.ended),
    );
  });

  test('opening a space is one plan: what opens the folder and the first '
      'reading of the git column wait together, approved top down', () async {
    mode('manual');
    final CommandScope plan = CommandScope.start(
      CommandActionEnum.readRepository,
    );
    bool opened = false;
    final Future<Result<SpaceEntity, AppFailure>> opening = plan
        .within(() => container.read(openSpaceProvider).open(repository))
        .whenComplete(() => opened = true);
    await listed(1);
    await approver(
      () => opened,
      (CommandsNotifier commands, CommandRow row) => commands.run(row.id),
    );
    final SpaceEntity space =
        (await opening as Success<SpaceEntity, AppFailure>).value;

    // What Home does once the window changes: hand the plan over, open the
    // session, and let the shell's reader make the first reading.
    container.read(openingPlanProvider.notifier).handed = plan;
    container.read(spaceSessionProvider.notifier).open(space);
    container.listen<GitReadingState>(gitReadingProvider, (_, _) {});
    await approver(
      () => container.read(gitReadingProvider) is GitReadingReady,
      (CommandsNotifier commands, CommandRow row) => commands.run(row.id),
    );

    expect(rows().length, greaterThanOrEqualTo(4));
    expect(rows().map((CommandRow it) => it.plan).toSet(), hasLength(1));
    expect(rows().first.plan, isNotNull);
    expect(
      rows().map((CommandRow it) => it.action).toSet(),
      <CommandActionEnum?>{CommandActionEnum.readRepository},
    );

    // The next reading is an action of its own, not the tail of this one.
    final int before = rows().length;
    unawaited(container.read(gitReadingProvider.notifier).refresh());
    await listed(before + 1);
    expect(rows().last.plan, isNot(rows().first.plan));
  });

  test('in Manual a folder opens from the disk with no command asked, and '
      'its repository is found once the person lets git run', () async {
    mode('manual');

    final Result<SpaceEntity, AppFailure> opened = await container
        .read(openSpaceProvider)
        .openFolder(repository);

    final SpaceEntity folder =
        (opened as Success<SpaceEntity, AppFailure>).value;
    expect(folder.repositoryRoot, isNull, reason: 'git was not asked');
    expect(rows(), isEmpty, reason: 'nothing waited for a yes');

    bool located = false;
    final Future<Result<SpaceEntity, AppFailure>> locating = container
        .read(openSpaceProvider)
        .locate(folder)
        .whenComplete(() => located = true);
    await listed(1);
    expect(located, isFalse, reason: 'it ran before anybody said Run');
    await approver(
      () => located,
      (CommandsNotifier commands, CommandRow row) => commands.run(row.id),
    );

    final SpaceEntity found =
        (await locating as Success<SpaceEntity, AppFailure>).value;
    expect(found.repositoryRoot, repository);
    expect(found.root, folder.root);
  });

  test('a folder opened from the disk, whose repository was denied, keeps '
      'its files and the denial', () async {
    mode('manual');
    final SpaceEntity folder =
        ((await container.read(openSpaceProvider).openFolder(repository))
                as Success<SpaceEntity, AppFailure>)
            .value;
    final Future<Result<SpaceEntity, AppFailure>> locating = container
        .read(openSpaceProvider)
        .locate(folder);
    await listed(1);

    container.read(commandsProvider.notifier).deny(rows().first.id);

    final Result<SpaceEntity, AppFailure> result = await locating.timeout(
      const Duration(seconds: 5),
    );
    expect(
      (result as Failure<SpaceEntity, AppFailure>).failure.isDenial,
      isTrue,
    );
    final Result<List<SpaceEntryValueObject>, SpaceFailure> files =
        await container.read(spaceRepositoryProvider).entries(folder);
    expect(
      (files as Success<List<SpaceEntryValueObject>, SpaceFailure>).value,
      isNotEmpty,
    );
  });

  test('opening a space in Manual and denying a command ends the opening '
      'with the denial, never waiting for ever', () async {
    mode('manual');
    final Future<Result<SpaceEntity, AppFailure>> opening = container
        .read(openSpaceProvider)
        .open(repository);
    await listed(1);
    final int first = rows().first.id;

    container.read(commandsProvider.notifier).deny(first);

    final Result<SpaceEntity, AppFailure> result = await opening.timeout(
      const Duration(seconds: 5),
    );
    expect(result, isA<Failure<SpaceEntity, AppFailure>>());
    expect(
      (result as Failure<SpaceEntity, AppFailure>).failure.isDenial,
      isTrue,
    );
    expect(rows().first.stage, CommandStageEnum.denied);
  });

  test('Always allow in the middle of an opening makes the next command of '
      'it run unasked', () async {
    mode('semi');
    await container.read(approvalsRepositoryProvider).seed();
    bool finished = false;
    final Future<Result<SpaceEntity, AppFailure>> opening = container
        .read(openSpaceProvider)
        .open(repository)
        .whenComplete(() => finished = true);
    await listed(1);

    int allowed = 0;
    await approver(() => finished, (CommandsNotifier commands, CommandRow row) {
      allowed++;
      unawaited(commands.alwaysAllow(row.id));
    });

    expect(await opening, isA<Success<SpaceEntity, AppFailure>>());
    expect(allowed, greaterThan(0));
    // Each command has a key of its own: allowing one writes that one, and
    // the rest of the opening still asks, so every command was answered.
    final Map<String, Object?> held =
        jsonDecode(list.readAsStringSync()) as Map<String, Object?>;
    expect(held['git --version'], isTrue);
    expect(rows().length, 2);
  });

  test('discarding everything waits as one plan of two, approved top '
      'down', () async {
    mode('manual');
    git(<String>['add', 'a.md']);
    git(<String>[
      '-c',
      'user.name=Test',
      '-c',
      'user.email=test@example.com',
      '-c',
      'commit.gpgsign=false',
      'commit',
      '--quiet',
      '--message',
      'Add A',
    ]);
    File('$repository/a.md').writeAsStringSync('# A changed\n');
    final CommandsNotifier commands = container.read(commandsProvider.notifier);

    final Future<Result<void, GitClientFailure>> discarding = container
        .read(gitClientForProvider)(repository)
        .discardAll();
    await listed(2);

    final CommandsState asked = container.read(commandsProvider);
    expect(asked.rows.first.plan, asked.rows.last.plan);
    expect(asked.isApprovable(asked.rows.first), isTrue);
    expect(asked.isApprovable(asked.rows.last), isFalse);

    commands.run(asked.rows.first.id);
    for (
      int tries = 0;
      !container.read(commandsProvider).isApprovable(rows().last) &&
          tries < 200;
      tries++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    commands.run(rows().last.id);

    expect(await discarding, isA<Success<void, GitClientFailure>>());
    expect(File('$repository/a.md').readAsStringSync(), '# A\n');
    expect(
      rows().map((CommandRow it) => it.stage),
      everyElement(CommandStageEnum.ended),
    );
  });
}
