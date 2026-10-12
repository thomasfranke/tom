/// The count beside `Git`: the changes git reports, and nothing for none.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/changes/changes_tab_count_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> pumpCount(WidgetTester tester, int changes) async {
    container.read(spaceSessionProvider.notifier)
      ..open(
        SpaceEntity(root: '/code/docs', repositoryRoot: '/code', name: 'docs'),
      )
      ..observe(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: <StatusEntryValueObject>[
            for (int i = 0; i < changes; i++)
              StatusEntryValueObject(
                path: RepoRelativePathValueObject('docs/$i.md'),
                state: FileStateEnum.modified,
                isStaged: false,
              ),
          ],
          isDetached: false,
        ),
      );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(body: Center(child: ChangesTabCountWidget())),
        ),
      ),
    );
  }

  testWidgets('it counts what git reports', (WidgetTester tester) async {
    await pumpCount(tester, 3);

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('with nothing changed it says nothing', (
    WidgetTester tester,
  ) async {
    await pumpCount(tester, 0);

    expect(find.text('0'), findsNothing);
  });
}
