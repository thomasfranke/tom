import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
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
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  CommitEntity commit(
    String sha,
    String subject, {
    String who = 'Thomas Franke',
    Duration ago = const Duration(days: 3),
  }) => CommitEntity(
    sha: CommitShaValueObject(sha.padRight(40, '0')),
    author: AuthorValueObject(name: who, email: 'who@example.invalid'),
    date: CommitDateValueObject(
      utc: DateTime.now().toUtc().subtract(ago),
      offset: Duration.zero,
    ),
    subject: subject,
    body: '',
  );

  setUp(() {
    git = _Git();
    container = ProviderContainer(
      overrides: <Override>[
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

  /// Mounts the panel at the width the shell gives it.
  Future<void> pumpPanel(
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
          home: const Scaffold(
            body: Row(
              children: <Widget>[
                Expanded(child: SizedBox.shrink()),
                SizedBox(width: TomMetrics.git, child: HistoryPanel()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it names itself, and says so with no document open', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester);

    expect(find.text('HISTORY'), findsOneWidget);
    expect(
      find.text('Open a document to see what changed it.'),
      findsOneWidget,
    );
  });

  testWidgets('every commit git reports is an entry, in its order', (
    WidgetTester tester,
  ) async {
    // The order is git's; sorting here would be a second opinion.
    git.reported = <CommitEntity>[
      commit('aaa1111', 'docs: the second pass'),
      commit('bbb2222', 'docs: the first pass'),
    ];

    await pumpPanel(tester, document: writing);

    expect(find.text('docs: the second pass'), findsOneWidget);
    expect(find.text('docs: the first pass'), findsOneWidget);
  });

  testWidgets('an entry says who wrote it, when, and which commit it is', (
    WidgetTester tester,
  ) async {
    // The product's three (`docs/product/git-workflow/file-history/doc.md`).
    git.reported = <CommitEntity>[
      commit('aaa1111', 'docs: a change', who: 'Ada Lovelace'),
    ];

    await pumpPanel(tester, document: writing);

    expect(find.text('aaa1111 · Ada Lovelace · 3 days ago'), findsOneWidget);
  });

  testWidgets('a file git has never seen says so, and draws no note', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, document: writing);

    expect(find.text('Git has no record of this file yet.'), findsOneWidget);
    expect(
      find.text('scoped to this file, not the repo'),
      findsNothing,
      reason: 'a caveat about a list there is no list to qualify',
    );
  });

  testWidgets('a list says what it is scoped to', (WidgetTester tester) async {
    // Said where somebody would wonder why a busy repository has one entry.
    git.reported = <CommitEntity>[commit('aaa1111', 'docs: a change')];

    await pumpPanel(tester, document: writing);

    expect(find.text('scoped to this file, not the repo'), findsOneWidget);
  });

  testWidgets('clicking an entry opens that version', (
    WidgetTester tester,
  ) async {
    git.reported = <CommitEntity>[commit('aaa1111', 'docs: a change')];
    await pumpPanel(tester, document: writing);

    await tester.tap(find.text('docs: a change'));
    await tester.pumpAndSettle();

    expect(
      container.read(spaceSessionProvider)?.readingVersion?.sha.short,
      'aaa1111',
    );
  });

  testWidgets('a repository that would not answer says so', (
    WidgetTester tester,
  ) async {
    git.answer = const Failure<List<CommitEntity>, GitFailure>(
      GitNotInstalled(),
    );

    await pumpPanel(tester, document: writing);

    expect(
      find.text('TOM could not find git on this machine.'),
      findsOneWidget,
    );
  });
}

/// Git, answering what the test set.
final class _Git implements GitRepository {
  List<CommitEntity> reported = <CommitEntity>[];
  Result<List<CommitEntity>, GitFailure>? answer;

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => answer ?? Success<List<CommitEntity>, GitFailure>(reported);

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
