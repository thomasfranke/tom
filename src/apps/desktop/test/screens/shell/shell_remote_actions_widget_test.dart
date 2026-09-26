import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_remote_actions_widget.dart';
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

  GitStatusValueObject statusOf({int ahead = 0, int behind = 0}) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: BranchNameValueObject('origin/main'),
        ahead: ahead,
        behind: behind,
        entries: const <StatusEntryValueObject>[],
        isDetached: false,
      );

  setUp(() {
    git = _Git();
    container = ProviderContainer(
      overrides: <Override>[
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        fetchRemoteProvider.overrideWithValue(
          FetchRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        pushRemoteProvider.overrideWithValue(
          PushRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the actions with [git] as the whole window's reading.
  Future<void> pumpActions(
    WidgetTester tester, {
    GitStatusValueObject? reading,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier).open(docs);
    if (reading != null) {
      container.read(spaceSessionProvider.notifier).observe(reading);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: ShellRemoteActionsWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Whether the button saying [label] can be pressed.
  bool isEnabled(WidgetTester tester, String label) =>
      tester
          .widget<OutlinedButton>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(OutlinedButton),
            ),
          )
          .onPressed !=
      null;

  testWidgets('nothing is offered before git has been asked', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    expect(find.text('Fetch'), findsNothing);
    expect(find.text('Push'), findsNothing);
  });

  testWidgets('it offers Fetch and Push, and never a combined Sync', (
    WidgetTester tester,
  ) async {
    // Three risks, three names
    // (docs/product/git-workflow/push-pull/the-controls/doc.md).
    await pumpActions(tester, reading: statusOf(ahead: 1));

    expect(find.text('Fetch'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Sync'), findsNothing);
    // Pull is the remedy inside the rejection, not a button in the chrome.
    expect(find.text('Pull'), findsNothing);
  });

  group('the drift', () {
    testWidgets('says nothing when there is nothing to count', (
      WidgetTester tester,
    ) async {
      await pumpActions(tester, reading: statusOf());

      expect(find.textContaining('↑'), findsNothing);
      expect(find.textContaining('↓'), findsNothing);
    });

    testWidgets('counts each direction only when it has something', (
      WidgetTester tester,
    ) async {
      await pumpActions(tester, reading: statusOf(ahead: 2));

      expect(find.text('↑ 2'), findsOneWidget);
    });

    testWidgets('shows both when the branch has drifted each way', (
      WidgetTester tester,
    ) async {
      await pumpActions(tester, reading: statusOf(ahead: 2, behind: 3));

      expect(find.text('↑ 2  ↓ 3'), findsOneWidget);
    });
  });

  group('push', () {
    testWidgets('is unavailable with nothing to publish', (
      WidgetTester tester,
    ) async {
      await pumpActions(tester, reading: statusOf(behind: 3));

      expect(isEnabled(tester, 'Push'), isFalse);
      expect(isEnabled(tester, 'Fetch'), isTrue);
    });

    testWidgets('publishes when there is something', (
      WidgetTester tester,
    ) async {
      await pumpActions(tester, reading: statusOf(ahead: 2));

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(git.pushed, 1);
    });
  });

  testWidgets('the one that is working says so, and the other waits', (
    WidgetTester tester,
  ) async {
    // Git serializes per space, so a second press would only queue; the
    // others wait with a reason on screen.
    await pumpActions(tester, reading: statusOf(ahead: 2));
    git.holdUp = true;

    await tester.tap(find.text('Fetch'));
    await tester.pump();

    expect(find.text('Fetch…'), findsOneWidget);
    expect(isEnabled(tester, 'Push'), isFalse);

    git.release();
    await tester.pumpAndSettle();
    expect(find.text('Fetch'), findsOneWidget);
  });
}

/// Git, answering the remote actions and nothing else.
final class _Git implements GitRepository {
  int pushed = 0;
  bool holdUp = false;
  Completer<void>? _held;

  void release() {
    _held?.complete();
    _held = null;
    holdUp = false;
  }

  Future<Result<void, GitFailure>> _done() async {
    if (holdUp) {
      _held = Completer<void>();
      await _held!.future;
    }
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      Success<GitStatusValueObject, GitFailure>(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: BranchNameValueObject('origin/main'),
          ahead: 0,
          behind: 0,
          entries: const <StatusEntryValueObject>[],
          isDetached: false,
        ),
      );

  @override
  Future<Result<void, GitFailure>> fetch() => _done();

  @override
  Future<Result<void, GitFailure>> push() {
    pushed++;
    return _done();
  }

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
