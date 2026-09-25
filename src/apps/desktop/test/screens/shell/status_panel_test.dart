import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// The container the last mount used, for the tests that write to it.
  late ProviderContainer container;

  /// Mounts the panel with [space] open, showing [document].
  Future<void> pumpStatus(
    WidgetTester tester, {
    SpaceEntity? space,
    String? document,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          const ReadDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
      if (document != null) {
        container
            .read(spaceSessionProvider.notifier)
            .show(SpaceRelativePathValueObject(document));
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
    // The two bars are one piece of chrome, so one wording.
    await pumpStatus(tester);

    expect(find.text('no space open'), findsOneWidget);
  });

  testWidgets('with a space open it says where it is', (
    WidgetTester tester,
  ) async {
    await pumpStatus(
      tester,
      space: SpaceEntity(
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
    // An absolute path under a home folder is mostly the home folder.
    final String home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    await pumpStatus(
      tester,
      space: SpaceEntity(
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
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
    );

    expect(find.text('guides/writing.md'), findsNothing);
  });

  testWidgets('the open document is named by its path in the space', (
    WidgetTester tester,
  ) async {
    // The path, not the name: two `index.md` in two folders are a real thing.
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
      document: 'guides/writing.md',
    );

    expect(find.text('guides/writing.md'), findsOneWidget);
  });

  testWidgets('an unsaved document says so, and how to fix it', (
    WidgetTester tester,
  ) async {
    // Said in words here, with a dot on the mode bar: work is never lost
    // quietly.
    await pumpStatus(
      tester,
      space: SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
      document: 'guides/writing.md',
    );

    container.read(editorProvider.notifier).edit('# changed\n');
    await tester.pumpAndSettle();

    expect(find.text('guides/writing.md — unsaved'), findsOneWidget);
    expect(
      find.text(
        defaultTargetPlatform == TargetPlatform.macOS
            ? '⌘S to save'
            : 'Ctrl+S to save',
      ),
      findsOneWidget,
    );
  });

  group('what git says', () {
    final SpaceEntity docs = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: '/code/app',
      name: 'docs',
    );

    /// Mounts the bar with [git] as the whole window's reading.
    Future<void> pumpWith(WidgetTester tester, GitStatusValueObject git) async {
      await pumpStatus(tester, space: docs);
      container.read(spaceSessionProvider.notifier).observe(git);
      await tester.pumpAndSettle();
    }

    testWidgets('the branch is named as soon as git has been asked', (
      WidgetTester tester,
    ) async {
      await pumpWith(tester, _status(branch: 'feat/rendered-diff'));

      expect(find.text('feat/rendered-diff'), findsOneWidget);
    });

    testWidgets('a clean tree counts nothing, and says nothing', (
      WidgetTester tester,
    ) async {
      // A counter with nothing to count is chrome read twice to be ignored.
      await pumpWith(tester, _status(branch: 'main'));

      expect(find.textContaining('change'), findsNothing);
      expect(find.textContaining('ahead'), findsNothing);
      expect(find.textContaining('behind'), findsNothing);
    });

    testWidgets('one change is singular and three are not', (
      WidgetTester tester,
    ) async {
      await pumpWith(tester, _status(branch: 'main', changes: 1));
      expect(find.text('1 change'), findsOneWidget);

      await pumpWith(tester, _status(branch: 'main', changes: 3));
      expect(find.text('3 changes'), findsOneWidget);
    });

    testWidgets('ahead and behind are each said only when there is one', (
      WidgetTester tester,
    ) async {
      await pumpWith(tester, _status(branch: 'main', ahead: 2));

      expect(find.text('2 ahead'), findsOneWidget);
      expect(find.textContaining('behind'), findsNothing);
    });

    testWidgets('a detached HEAD is named, not left blank', (
      WidgetTester tester,
    ) async {
      // A state to get out of, not a missing value.
      await pumpWith(tester, _status(isDetached: true));

      expect(find.text('detached HEAD'), findsOneWidget);
    });
  });
}

/// What git would say, with everything the bar could show set.
GitStatusValueObject _status({
  String? branch,
  int changes = 0,
  int ahead = 0,
  int behind = 0,
  bool isDetached = false,
}) => GitStatusValueObject(
  branch: branch == null ? null : BranchNameValueObject(branch),
  upstream: null,
  ahead: ahead,
  behind: behind,
  entries: <StatusEntryValueObject>[
    for (int i = 0; i < changes; i++)
      StatusEntryValueObject(
        path: RepoRelativePathValueObject('docs/$i.md'),
        state: FileStateEnum.modified,
        isStaged: false,
      ),
  ],
  isDetached: isDetached,
);

/// A repository for any space, answering with a document that holds nothing.
DocumentRepository _documentsFor(SpaceEntity space) => const _Documents();

/// A repository that reads an empty document and writes nowhere.
final class _Documents implements DocumentRepository {
  const _Documents();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: ''),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
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
