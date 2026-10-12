import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );
  final BranchRefValueObject develop = BranchRefValueObject(
    name: BranchNameValueObject('develop'),
  );

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// Mounts the control at the right of a bar, with [document] open when one
  /// is given and [base] as what the session compares against.
  Future<void> pumpControl(
    WidgetTester tester, {
    SpaceRelativePathValueObject? document,
    BranchRefValueObject? base,
    double labelRoom = double.infinity,
    SpaceEntity? space,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final SpaceSessionNotifier session = container.read(
      spaceSessionProvider.notifier,
    )..open(space ?? docs);
    if (document != null) {
      session.show(document);
    }
    session.compare(
      base == null
          ? null
          : DiffBaseValueObject(
              branch: base,
              forkPoint: CommitShaValueObject(
                'abc1234def5678901234567890abcdef12345678',
              ),
            ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: TomMetrics.modeBar,
                  child: Row(
                    children: <Widget>[
                      const Spacer(),
                      CompareControlWidget(labelRoom: labelRoom),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester) async {
    await tester.tap(find.text('Diff'));
    await tester.pumpAndSettle();
  }

  bool showing() => container.read(spaceSessionProvider)!.showingDiff;

  testWidgets('nothing is drawn with no document open', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);

    expect(find.text('Diff'), findsNothing);
  });

  testWidgets('nor in a folder with no repository, document or not', (
    WidgetTester tester,
  ) async {
    // Nothing committed to compare with
    // (`docs/product/workspace/without-a-repository/doc.md`).
    await pumpControl(
      tester,
      document: index,
      space: SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'),
    );

    expect(find.text('Diff'), findsNothing);
  });

  testWidgets('nor over a file that is not markdown', (
    WidgetTester tester,
  ) async {
    // Its line marks are all the tab has to say
    // (`git-workflow/commit/opening-a-change/doc.md`).
    await pumpControl(
      tester,
      document: SpaceRelativePathValueObject('mkdocs.yml'),
    );

    expect(find.text('Diff'), findsNothing);
  });

  testWidgets('nor over a document git reports deleted', (
    WidgetTester tester,
  ) async {
    // Turning its marks off would leave an empty page.
    await pumpControl(tester, document: index);
    expect(find.text('Diff'), findsOneWidget);

    container
        .read(spaceSessionProvider.notifier)
        .observe(
          GitStatusValueObject(
            branch: BranchNameValueObject('main'),
            upstream: null,
            ahead: 0,
            behind: 0,
            entries: <StatusEntryValueObject>[
              StatusEntryValueObject(
                path: RepoRelativePathValueObject('docs/index.md'),
                state: FileStateEnum.deleted,
                isStaged: false,
              ),
            ],
            isDetached: false,
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Diff'), findsNothing);
  });

  testWidgets('with a document open the chip is there, and on', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);

    expect(find.text('Diff'), findsOneWidget);
    expect(showing(), isTrue);
  });

  testWidgets('a press turns the marks off, and the next turns them on', (
    WidgetTester tester,
  ) async {
    // The maintainer's call, 2026-10-08: the chip only switches the marks;
    // what they are measured against is nobody's choice.
    await pumpControl(tester, document: index);

    await press(tester);
    expect(showing(), isFalse);

    await press(tester);
    expect(showing(), isTrue);
  });

  testWidgets('a press opens nothing', (WidgetTester tester) async {
    await pumpControl(tester, document: index, base: develop);

    await press(tester);

    // What the popover used to hold: a filter, and the branches by name.
    expect(find.byType(TextField), findsNothing);
    expect(find.text('develop'), findsNothing);
    expect(find.text('Stop marking what changed'), findsNothing);
  });

  testWidgets('on, the chip is a chosen control; off, one at rest', (
    WidgetTester tester,
  ) async {
    // `accent` when on, never `added`; off is Rest, not Disabled, because the
    // chip can always be pressed.
    const TomColors colors = TomColors.light;
    Material chip() => tester.widget<Material>(
      find
          .ancestor(of: find.text('Diff'), matching: find.byType(Material))
          .first,
    );
    Color outline() => (chip().shape! as RoundedRectangleBorder).side.color;
    Color? label() => tester.widget<Text>(find.text('Diff')).style?.color;
    await pumpControl(tester, document: index);

    expect(chip().color, colors.accentSoft);
    expect(outline(), colors.accent);
    expect(label(), colors.accent);

    await press(tester);

    expect(chip().color, Colors.transparent);
    expect(outline(), colors.borderStrong);
    expect(label(), colors.textSecondary);
  });

  testWidgets('the branch it came from is named beside the chip', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index, base: develop);

    expect(find.text('Compared to develop'), findsOneWidget);
  });

  testWidgets('a remote\'s copy is named as git resolves it', (
    WidgetTester tester,
  ) async {
    await pumpControl(
      tester,
      document: index,
      base: BranchRefValueObject(
        name: BranchNameValueObject('develop'),
        remote: 'origin',
      ),
    );

    expect(find.text('Compared to origin/develop'), findsOneWidget);
  });

  testWidgets('against the last commit nothing is named, the tooltip says', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);

    expect(find.textContaining('Compared to'), findsNothing);
    expect(
      tester.widget<Tooltip>(find.byType(Tooltip)).message,
      'Compared to the last commit',
    );
  });

  testWidgets('with the marks off the base is not named, and is kept', (
    WidgetTester tester,
  ) async {
    // Off is a reading position, not a comparison
    // (`diff/rendered-diff/turning-it-off/doc.md`).
    await pumpControl(tester, document: index, base: develop);

    await press(tester);

    expect(find.text('Compared to develop'), findsNothing);
    expect(
      container.read(spaceSessionProvider)?.comparingAgainst?.branch,
      develop,
    );

    await press(tester);
    expect(find.text('Compared to develop'), findsOneWidget);
  });

  testWidgets('with no room for a name, only the tooltip carries it', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index, base: develop, labelRoom: 0);

    expect(find.text('Compared to develop'), findsNothing);
    expect(
      tester.widget<Tooltip>(find.byType(Tooltip)).message,
      'Compared to develop',
    );
  });
}
