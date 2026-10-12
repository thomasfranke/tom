import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/commands/commands_count_widget.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/commands/widgets/command_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The waiting row and the column it holds up, at the numbers of
/// `manual-opening-a-space` (`docs/design/screens/desktop/git-approvals/`):
/// the `accent_soft` band, the answers 14 from the panel's edge, the row
/// never cut by the panel's foot, and the git column's sentence.
void main() {
  late ProviderContainer container;

  const CommandRequest first = CommandRequest(
    key: 'git rev-parse --show-toplevel',
    executable: 'git',
    arguments: <String>['rev-parse', '--show-toplevel'],
    isWrite: false,
  );
  const CommandRequest second = CommandRequest(
    key: 'git status --porcelain=v2 --branch',
    executable: 'git',
    arguments: <String>['status', '--porcelain=v2', '--branch'],
    isWrite: false,
  );

  const double panelWidth = 878;
  const double panelHeight = 260;

  setUp(() {
    final _Preferences stored = _Preferences()
      ..held = const PreferencesValueObject(
        gitApprovals: GitApprovalModeEnum.manual,
      );
    final _Approvals list = _Approvals();
    container = ProviderContainer(
      overrides: <Override>[
        changesProvider.overrideWith(_Loading.new),
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

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Asks a plan of reads, as opening a space does.
  Future<void> askReads(WidgetTester tester) async {
    final CommandsNotifier gate = container.read(commandsProvider.notifier);
    late CommandPlan plan;
    await CommandScope.run(CommandActionEnum.readRepository, () async {
      plan = gate.plan(<CommandRequest>[first, second]);
    });
    // Not awaited: the verdict comes when somebody answers.
    plan.next().ignore();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Widget panel() => const SizedBox(
    width: panelWidth,
    height: panelHeight,
    child: Column(
      children: <Widget>[
        CommandsCountWidget(),
        Expanded(child: CommandsPanel()),
      ],
    ),
  );

  testWidgets('the row that can be answered is tinted accent_soft, and only '
      'it', (WidgetTester tester) async {
    await pump(tester, panel());
    await askReads(tester);

    final TomColors colors = TomColors.of(
      tester.element(find.byType(CommandsPanel)),
    );
    Finder tint(Color color) => find.descendant(
      of: find.byType(CommandRowWidget),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == color,
      ),
    );

    expect(colors.accentSoft, const Color(0xFF15302A));
    expect(tint(colors.accentSoft), findsOneWidget);
    // The band is the row's own 24, inset 4 from the panel's sides.
    final Rect band = tester.getRect(tint(colors.accentSoft));
    expect(band.height, 24);
    expect(band.left, 4);
    expect(band.right, panelWidth - 4);
  });

  testWidgets('Run, Always allow and Deny end 14 from the panel, and so does '
      '"waits for the one above"', (WidgetTester tester) async {
    await pump(tester, panel());
    await askReads(tester);

    expect(
      tester.getRect(find.byType(TomRowActionWidget).last).right,
      panelWidth - 14,
    );
    expect(
      tester.getRect(find.text('waits for the one above')).right,
      moreOrLessEquals(panelWidth - 14, epsilon: 1),
    );
  });

  testWidgets('the last row is never cut by the panel foot', (
    WidgetTester tester,
  ) async {
    await pump(tester, panel());
    // Enough rows that the list scrolls, the waiting ones at its end.
    final CommandsNotifier gate = container.read(commandsProvider.notifier);
    for (int i = 0; i < 12; i++) {
      gate.record(
        CommandRecord.of(
          executable: 'git',
          arguments: <String>['config', '--get', 'key$i'],
          startedAt: DateTime(2026, 10, 11),
          duration: const Duration(milliseconds: 5),
          exitCode: 0,
        ),
      );
    }
    await askReads(tester);

    final Rect last = tester.getRect(find.byType(CommandRowWidget).last);
    expect(last.bottom, lessThanOrEqualTo(panelHeight - 6));
  });

  testWidgets('the git column says whose turn it is while a read waits', (
    WidgetTester tester,
  ) async {
    await pump(tester, const SizedBox(width: 280, child: ChangesPanel()));
    expect(find.text('Asking git…'), findsOneWidget);

    await askReads(tester);

    expect(find.text('Asking git…'), findsNothing);
    final Finder note = find.text(
      'Waiting for your approval to read the repository.',
    );
    expect(note, findsOneWidget);
    // 14 in from the column's edge, as the board sets it.
    expect(tester.getTopLeft(note).dx, 14);
  });
}

/// The git column's list, still being asked for.
class _Loading extends ChangesNotifier {
  @override
  ChangesState build() => const ChangesLoading();
}

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
