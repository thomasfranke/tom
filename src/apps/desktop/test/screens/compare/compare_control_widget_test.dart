import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Git git;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  BranchEntity branch(String name, {bool isCurrent = false}) =>
      BranchEntity(name: BranchNameValueObject(name), isCurrent: isCurrent);

  CommitEntity commit(String sha, String subject) => CommitEntity(
    sha: CommitShaValueObject(sha.padRight(40, '0')),
    author: const AuthorValueObject(name: 'Thomas Franke', email: 'a@b.test'),
    date: CommitDateValueObject(
      utc: DateTime.now().toUtc().subtract(const Duration(days: 3)),
      offset: Duration.zero,
    ),
    subject: subject,
    body: '',
  );

  setUp(() {
    git = _Git()
      ..reportedBranches = <BranchEntity>[
        branch('main', isCurrent: true),
        branch('feat/rendered-diff'),
      ]
      ..reportedCommits = <CommitEntity>[
        commit('aaa1', 'docs: fix a typo in the index'),
      ];
    container = ProviderContainer(
      overrides: <Override>[
        listBranchesProvider.overrideWithValue(
          ListBranchesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        readFileHistoryProvider.overrideWithValue(
          ReadFileHistoryUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the control in a bar, with [document] open when one is given.
  Future<void> pumpControl(
    WidgetTester tester, {
    SpaceRelativePathValueObject? document,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier).open(docs);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          // At the right of the bar, where the real one sits: the popover
          // hangs from the control's right edge, so a control mounted at the
          // left would put it off the window.
          home: const Scaffold(
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: TomMetrics.modeBar,
                  child: Row(
                    children: <Widget>[Spacer(), CompareControlWidget()],
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

  /// Opens the popover.
  Future<void> openIt(WidgetTester tester) async {
    await tester.tap(find.text('Compare against…'));
    await tester.pumpAndSettle();
  }

  RevisionValueObject? base() =>
      container.read(spaceSessionProvider)?.comparingAgainst;

  testWidgets('nothing is drawn with no document open', (
    WidgetTester tester,
  ) async {
    // A base belongs to a document, because the comparison is scoped to one
    // file — there is nothing to compare before one is chosen.
    await pumpControl(tester);

    expect(find.text('Compare against…'), findsNothing);
  });

  testWidgets('with a document open it offers to compare', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);

    expect(find.text('Compare against…'), findsOneWidget);
  });

  testWidgets('it lists the branches and the document\'s commits', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);

    await openIt(tester);

    expect(find.text('main'), findsOneWidget);
    expect(find.text('feat/rendered-diff'), findsOneWidget);
    expect(find.text('docs: fix a typo in the index'), findsOneWidget);
  });

  testWidgets('a commit says which one, whose and how old', (
    WidgetTester tester,
  ) async {
    // The same three facts the history panel shows, so the same commit reads
    // the same way in both places.
    await pumpControl(tester, document: index);

    await openIt(tester);

    expect(find.text('aaa1000 · Thomas Franke · 3 days ago'), findsOneWidget);
  });

  testWidgets('choosing a branch says so on the control', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);

    await tester.tap(find.text('feat/rendered-diff'));
    await tester.pumpAndSettle();

    expect(base(), RevisionValueObject.branch(branch('feat/rendered-diff')));
    expect(find.text('Compared to feat/rendered-diff'), findsOneWidget);
  });

  testWidgets('choosing a commit names it by its sha and its age', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);

    await tester.tap(find.text('docs: fix a typo in the index'));
    await tester.pumpAndSettle();

    expect(base(), isA<RevisionCommit>());
    expect(find.text('Compared to aaa1000 · 3 days ago'), findsOneWidget);
  });

  testWidgets('the surface closes when the base actually changed', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);

    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();

    expect(
      find.text('Filter branches and commits'),
      findsNothing,
      reason: 'the popover is still open after the base changed',
    );
  });

  testWidgets('the filter narrows both lists at once', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);

    await tester.enterText(find.byType(TextField), 'feat');
    await tester.pumpAndSettle();

    expect(find.text('feat/rendered-diff'), findsOneWidget);
    expect(find.text('main'), findsNothing);
    expect(find.text('docs: fix a typo in the index'), findsNothing);
  });

  testWidgets('an empty list with nothing typed is still being read', (
    WidgetTester tester,
  ) async {
    // A repository always has a branch, so nothing at all means the lists
    // have not arrived — which is different news from a filter that matched
    // none of them, and saying the wrong one is what the e2e run caught.
    git
      ..reportedBranches = <BranchEntity>[]
      ..reportedCommits = <CommitEntity>[];
    await pumpControl(tester, document: index);

    await openIt(tester);

    expect(find.text('Asking git…'), findsOneWidget);
    expect(find.text('Nothing by that name.'), findsNothing);
  });

  testWidgets('a filter matching nothing says so', (WidgetTester tester) async {
    await pumpControl(tester, document: index);
    await openIt(tester);

    await tester.enterText(find.byType(TextField), 'nothing by this name');
    await tester.pumpAndSettle();

    expect(find.text('Nothing by that name.'), findsOneWidget);
  });

  testWidgets('the way back is offered only once there is a base', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);
    expect(find.text('Compare against the last commit'), findsNothing);

    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compared to main'));
    await tester.pumpAndSettle();

    expect(find.text('Compare against the last commit'), findsOneWidget);
  });

  testWidgets('taking it back returns to the default comparison', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);
    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compared to main'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compare against the last commit'));
    await tester.pumpAndSettle();

    expect(base(), isNull);
    expect(find.text('Compare against…'), findsOneWidget);
  });

  testWidgets('Escape closes it and keeps nothing', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, document: index);
    await openIt(tester);
    await tester.enterText(find.byType(TextField), 'feat');
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Filter branches and commits'), findsNothing);
    await openIt(tester);
    expect(find.text('main'), findsOneWidget);
  });
}

/// Git, answering with whatever the test said the repository holds.
final class _Git implements GitRepository {
  List<BranchEntity> reportedBranches = <BranchEntity>[];
  List<CommitEntity> reportedCommits = <CommitEntity>[];

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      Success<List<BranchEntity>, GitFailure>(reportedBranches);

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => Success<List<CommitEntity>, GitFailure>(reportedCommits);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
