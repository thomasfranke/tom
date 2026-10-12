/// The git column's `⋮`: four rows, the last one alone and asking first.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/changes_menu_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Changes changes;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  StatusEntryValueObject at(String path, FileStateEnum state) =>
      StatusEntryValueObject(
        path: RepoRelativePathValueObject(path),
        state: state,
        isStaged: false,
      );

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        changesProvider.overrideWith(() => changes = _Changes()),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the menu at the right of a 300-wide column, with git saying
  /// [entries].
  Future<void> pumpMenu(
    WidgetTester tester, {
    List<StatusEntryValueObject> entries = const <StatusEntryValueObject>[],
    bool merging = false,
  }) async {
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..observe(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: entries,
          isDetached: false,
        ),
      )
      ..observeMerge(
        merging
            ? const MergeStateValueObject(inProgress: true, message: '')
            : null,
      );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 300,
                height: 37,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ChangesMenuWidget(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Git menu'));
    await tester.pumpAndSettle();
  }

  List<String> rows(WidgetTester tester) => <String>[
    for (final Text text in tester.widgetList<Text>(
      find.descendant(
        of: find.byType(TomMenuWidget),
        matching: find.byType(Text),
      ),
    ))
      text.data ?? '',
  ];

  testWidgets('three rows, then the discard apart', (
    WidgetTester tester,
  ) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[at('a.md', FileStateEnum.modified)],
    );

    expect(rows(tester), <Object>[
      'Reload',
      'Open in terminal',
      startsWith('Open repository in'),
      'Discard all changes',
    ]);
    expect(
      tester.getSize(find.byType(TomMenuWidget)).width,
      ChangesDesign.menuWidth,
    );
  });

  testWidgets('with nothing to put back, the discard is not offered', (
    WidgetTester tester,
  ) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[at('new.md', FileStateEnum.untracked)],
    );

    expect(rows(tester), isNot(contains('Discard all changes')));
  });

  testWidgets('mid-merge, aborting the pull is the way back instead', (
    WidgetTester tester,
  ) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[at('a.md', FileStateEnum.modified)],
      merging: true,
    );

    expect(rows(tester), isNot(contains('Discard all changes')));
  });

  testWidgets('the discard asks first, naming how many go back', (
    WidgetTester tester,
  ) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[
        at('a.md', FileStateEnum.modified),
        at('b.md', FileStateEnum.deleted),
      ],
    );

    await tester.tap(find.text('Discard all changes'));
    await tester.pumpAndSettle();

    expect(find.text('Discard all changes?'), findsOneWidget);
    expect(
      find.text('2 documents go back to the last commit.'),
      findsOneWidget,
    );
    expect(changes.discards, 0);
  });

  testWidgets('keeping the changes discards nothing', (
    WidgetTester tester,
  ) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[at('a.md', FileStateEnum.modified)],
    );
    await tester.tap(find.text('Discard all changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep the changes'));
    await tester.pumpAndSettle();

    expect(changes.discards, 0);
  });

  testWidgets('answering it discards', (WidgetTester tester) async {
    await pumpMenu(
      tester,
      entries: <StatusEntryValueObject>[at('a.md', FileStateEnum.modified)],
    );
    await tester.tap(find.text('Discard all changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discard all changes').last);
    await tester.pumpAndSettle();

    expect(changes.discards, 1);
  });
}

/// The git column's notifier, counting what the menu asked of it.
final class _Changes extends ChangesNotifier {
  int discards = 0;

  @override
  ChangesState build() => const ChangesState.initial();

  @override
  Future<void> discardAll() async => discards++;
}
