import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_count_widget.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel as somebody has to answer it: a plan waiting, the three
/// answers, and what each leaves behind
/// (`docs/product/git-workflow/approvals/doc.md`).
void main() {
  late _Preferences stored;
  late _Approvals list;
  late ProviderContainer container;

  const CommandRequest reset = CommandRequest(
    key: 'git reset --quiet',
    executable: 'git',
    arguments: <String>['reset', '--quiet'],
    isWrite: true,
  );
  const CommandRequest restore = CommandRequest(
    key: 'git restore --worktree -- :/',
    executable: 'git',
    arguments: <String>['restore', '--worktree', '--', ':/'],
    isWrite: true,
  );

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

  CommandsNotifier gate() => container.read(commandsProvider.notifier);

  /// The plan one discard asks for: two commands, the first to answer.
  Future<CommandPlan> discardPlan() async {
    late CommandPlan plan;
    await CommandScope.run(CommandActionEnum.discardAll, () async {
      plan = gate().plan(<CommandRequest>[reset, restore]);
    });
    return plan;
  }

  Future<void> pumpPanel(
    WidgetTester tester, {
    Brightness brightness = Brightness.dark,
    Locale? locale,
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 1166,
                height: 260,
                child: Column(
                  children: <Widget>[
                    CommandsCountWidget(),
                    Expanded(child: CommandsPanel()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Asks the plan's commands and lets the rows reach the screen.
  ///
  /// The verdicts are asked here, as a capability does: a row is only
  /// started once its capability stands at the gate.
  Future<List<Future<CommandVerdict>>> ask(
    WidgetTester tester,
    CommandPlan plan,
  ) async {
    final List<Future<CommandVerdict>> verdicts = <Future<CommandVerdict>>[
      plan.next(),
    ];
    // Pumped, not settled: a row that runs draws a spinner that never rests.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return verdicts;
  }

  Finder text(String value) => find.text(value);

  testWidgets('a plan waiting shows its head, the three answers on the first '
      'command and a word on the second', (WidgetTester tester) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester);

    final CommandPlan plan = await discardPlan();
    await ask(tester, plan);

    expect(text('Discard all changes · 2 commands'), findsOneWidget);
    expect(text('Manual · 2 waiting'), findsOneWidget);
    expect(text('Run'), findsOneWidget);
    expect(text('Always allow'), findsOneWidget);
    expect(text('Deny'), findsOneWidget);
    expect(text('waits for the one above'), findsOneWidget);
    expect(text('git reset --quiet'), findsOneWidget);
    expect(find.byType(TomRowActionWidget), findsNWidgets(3));
    // Hollow dots, no check and no spinner yet.
    expect(find.byType(TomSpinnerWidget), findsNothing);
  });

  testWidgets('Run starts the command: a spinner where its check will be, '
      'then the check, and the next row asks', (WidgetTester tester) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester);
    final CommandPlan plan = await discardPlan();
    final Future<CommandVerdict> first = (await ask(tester, plan)).single;

    await tester.tap(text('Run'));
    await tester.pump();

    expect(await first, isA<CommandRun>());
    expect(find.byType(TomSpinnerWidget), findsOneWidget);
    expect(find.byType(TomRowActionWidget), findsNothing);

    final int id = container.read(commandsProvider).rows.first.id;
    gate().record(
      CommandRecord.of(
        executable: 'git',
        arguments: reset.arguments,
        startedAt: DateTime(2026, 10, 11),
        duration: const Duration(milliseconds: 12),
        exitCode: 0,
        ticket: id,
      ),
    );
    await tester.pump();

    expect(find.byType(TomSpinnerWidget), findsNothing);
    expect(text('12 ms'), findsOneWidget);
    // The one under it is the row that waits now.
    expect(find.byType(TomRowActionWidget), findsNWidgets(3));
    expect(text('waits for the one above'), findsNothing);
  });

  testWidgets('Deny stops the plan: denied, cancelled, and what ran said in '
      'the head', (WidgetTester tester) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester);
    final CommandPlan plan = await discardPlan();
    final Future<CommandVerdict> first = (await ask(tester, plan)).single;

    await tester.tap(text('Deny'));
    await tester.pump();

    expect(await first, isA<CommandDenied>());
    expect(text('denied'), findsOneWidget);
    expect(text('cancelled'), findsOneWidget);
    expect(text('Discard all changes · stopped · 0 of 2 ran'), findsOneWidget);
    expect(find.byType(TomRowActionWidget), findsNothing);
    // Nothing waits any more: the head is the session's count again.
    expect(text('2 this session'), findsOneWidget);
    expect(find.textContaining('waiting'), findsNothing);
  });

  testWidgets('Always allow in Manual asks first, with Stay in Manual '
      'before the switch, and staying changes nothing', (
    WidgetTester tester,
  ) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester);
    final CommandPlan plan = await discardPlan();
    await ask(tester, plan);

    await tester.tap(text('Always allow'));
    await tester.pumpAndSettle();

    expect(text('Switch to Semi-automatic?'), findsOneWidget);
    final Finder stay = text('Stay in Manual');
    final Finder switching = text('Switch to Semi-automatic');
    expect(
      tester.getTopLeft(stay).dy,
      lessThan(tester.getTopLeft(switching).dy),
      reason: 'the safe answer comes first',
    );

    await tester.tap(stay);
    await tester.pumpAndSettle();

    expect(
      container.read(preferencesProvider).gitApprovals,
      GitApprovalModeEnum.manual,
    );
    expect(list.held, isEmpty);
    // The command keeps waiting, its three answers still offered.
    expect(find.byType(TomRowActionWidget), findsNWidgets(3));
  });

  testWidgets('switching from the question allows that one command and runs '
      'it', (WidgetTester tester) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester);
    final CommandPlan plan = await discardPlan();
    final Future<CommandVerdict> first = (await ask(tester, plan)).single;

    await tester.tap(text('Always allow'));
    await tester.pumpAndSettle();
    await tester.tap(text('Switch to Semi-automatic'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(await first, isA<CommandRun>());
    expect(
      container.read(preferencesProvider).gitApprovals,
      GitApprovalModeEnum.semi,
    );
    expect(list.held, <String, bool>{reset.key: true});
  });

  testWidgets('a command the list allows says so before its time', (
    WidgetTester tester,
  ) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.semi,
    );
    list.held[reset.key] = true;
    await pumpPanel(tester);
    final CommandPlan plan = await discardPlan();
    final Future<CommandVerdict> first = (await ask(tester, plan)).single;
    expect(await first, isA<CommandRun>());
    gate().record(
      CommandRecord.of(
        executable: 'git',
        arguments: reset.arguments,
        startedAt: DateTime(2026, 10, 11),
        duration: const Duration(milliseconds: 9),
        exitCode: 0,
        ticket: container.read(commandsProvider).rows.first.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(text('allowed · 9 ms'), findsOneWidget);
  });

  testWidgets('in Portuguese the answers and the head are translated', (
    WidgetTester tester,
  ) async {
    stored.held = const PreferencesValueObject(
      gitApprovals: GitApprovalModeEnum.manual,
    );
    await pumpPanel(tester, locale: const Locale('pt'));
    final CommandPlan plan = await discardPlan();
    await ask(tester, plan);

    expect(text('Descartar todas as alterações · 2 comandos'), findsOneWidget);
    expect(text('Executar'), findsOneWidget);
    expect(text('Permitir sempre'), findsOneWidget);
    expect(text('Negar'), findsOneWidget);
    expect(text('espera o de cima'), findsOneWidget);
    expect(text('Manual · 2 aguardando'), findsOneWidget);
  });
}

/// Preferences in memory.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

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

  @override
  Future<ApprovalsValueObject> read() async =>
      ApprovalsValueObject(Map<String, bool>.of(held));

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
