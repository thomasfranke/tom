import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  /// Mounts the panel with [space] open, showing [document].
  Future<void> pumpStatus(
    WidgetTester tester, {
    Space? space,
    String? document,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
      if (document != null) {
        container
            .read(spaceSessionProvider.notifier)
            .show(SpaceRelativePath(document));
      }
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: StatusPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with nothing open it says so, in Home\'s own words', (
    WidgetTester tester,
  ) async {
    // The two bars are one piece of chrome: describing the same situation
    // two ways would read as two products.
    await pumpStatus(tester);

    expect(find.text('no space open'), findsOneWidget);
  });

  testWidgets('with a space open it says where it is', (
    WidgetTester tester,
  ) async {
    await pumpStatus(
      tester,
      space: Space(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
    );

    expect(find.text('/code/app/docs'), findsOneWidget);
    expect(find.text('no space open'), findsNothing);
  });

  testWidgets('a space under the home folder is written with a tilde', (
    WidgetTester tester,
  ) async {
    // The status bar is the one place the whole path is on screen, and an
    // absolute path under a home folder is mostly the home folder.
    final String home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    await pumpStatus(
      tester,
      space: Space(
        root: '$home/dev/tom/docs',
        repositoryRoot: '$home/dev/tom',
        name: 'docs',
      ),
    );

    expect(
      find.text(home.isEmpty ? '/dev/tom/docs' : '~/dev/tom/docs'),
      findsOneWidget,
    );
  });

  testWidgets('no document is named until one is open', (
    WidgetTester tester,
  ) async {
    final Space docs = Space(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    await pumpStatus(tester, space: docs);
    expect(find.text('guides/writing.md'), findsNothing);

    await pumpStatus(tester, space: docs, document: 'guides/writing.md');

    // Its path inside the space, not its name: two `index.md` in two folders
    // are a real thing, and the bar is where the whole answer fits.
    expect(find.text('guides/writing.md'), findsOneWidget);
  });
}
