import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/remote/remote_band_widget.dart';
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

  GitStatusValueObject statusOf({
    int behind = 0,
    List<StatusEntryValueObject> entries = const <StatusEntryValueObject>[],
  }) => GitStatusValueObject(
    branch: BranchNameValueObject('main'),
    upstream: null,
    ahead: 2,
    behind: behind,
    entries: entries,
    isDetached: false,
  );

  /// A path git reports as conflicted.
  StatusEntryValueObject conflicted(String path) => StatusEntryValueObject(
    path: RepoRelativePathValueObject(path),
    state: FileStateEnum.conflicted,
    isStaged: false,
  );

  setUp(() {
    git = _Git()..reported = statusOf();
    container = ProviderContainer(
      overrides: <Override>[
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        readMergeStateProvider.overrideWithValue(
          ReadMergeStateUseCase(
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
        pullRemoteProvider.overrideWithValue(
          PullRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        abortPullProvider.overrideWithValue(
          AbortPullUseCase(
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
        // A pull walks the tree again when it is done, so it needs a folder.
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the band across the document area, with [docs] open.
  Future<void> pumpBand(WidgetTester tester, {Locale? locale}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier).open(docs);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: locale == null
              ? null
              : AppLocalizations.localizationsDelegates,
          supportedLocales: locale == null
              ? const <Locale>[Locale('en', 'US')]
              : AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Column(children: <Widget>[RemoteBandWidget()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it takes no room until the remote has said something', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester);

    expect(find.byType(NoticeBandWidget), findsNothing);
    expect(
      tester.getSize(find.byType(RemoteBandWidget)).height,
      0,
      reason: 'a band nobody needs must not push the document down',
    );
  });

  group('a push the remote refused', () {
    Future<void> pushAndBeRefused(WidgetTester tester) async {
      git.pushFailure = const GitPushRejected();
      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();
    }

    testWidgets('says who got there first, and that nothing was lost', (
      WidgetTester tester,
    ) async {
      // The wording is the product's
      // (docs/product/git-workflow/push-pull/when-it-fails/doc.md).
      git.reported = statusOf(behind: 3);
      await pumpBand(tester);

      await pushAndBeRefused(tester);

      expect(
        find.text(
          'Someone pushed 3 commits first. '
          'Pull them, then push again — nothing you committed has been lost.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('counts nothing it has not been told', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);

      await pushAndBeRefused(tester);

      expect(
        find.text(
          'Someone pushed first. '
          'Pull them, then push again — nothing you committed has been lost.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers Pull as its remedy, and it pulls', (
      WidgetTester tester,
    ) async {
      // Not a fourth button in the chrome: the remedy lives inside the news,
      // beside the way to the command that was refused.
      await pumpBand(tester);
      await pushAndBeRefused(tester);

      expect(find.byType(OutlinedButton), findsNWidgets(2));
      expect(find.text('Show the command'), findsOneWidget);
      await tester.tap(find.text('Pull'));
      await tester.pumpAndSettle();

      expect(git.pulled, 1);
    });

    testWidgets('is at least as tall as the boards draw it, and grows rather '
        'than cut the sentence', (WidgetTester tester) async {
      await pumpBand(tester);

      await pushAndBeRefused(tester);

      expect(
        tester.getSize(find.byType(NoticeBandWidget)).height,
        greaterThanOrEqualTo(TomMetrics.noticeBand),
      );
      final Text sentence = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(NoticeBandWidget),
              matching: find.byType(Text),
            )
            .first,
      );
      expect(sentence.maxLines, isNull);
    });
  });

  group('a remote that would not answer', () {
    testWidgets('says nothing was published, and offers to try again', (
      WidgetTester tester,
    ) async {
      git.pushFailure = const GitAuthenticationFailed();
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'The remote would not accept this machine. '
          'Nothing was published, and nothing you committed has been lost.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(git.pushes, 2, reason: 'Try again runs the action it failed on');
    });

    testWidgets('a fetch that failed says what a fetch costs', (
      WidgetTester tester,
    ) async {
      git.fetchFailure = const GitTimedOut();
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).fetch();
      await tester.pumpAndSettle();

      expect(
        find.text('git could not reach the remote. Nothing arrived.'),
        findsOneWidget,
      );
    });

    testWidgets('offers nothing when trying again would answer the same', (
      WidgetTester tester,
    ) async {
      git.fetchFailure = const GitNotInstalled();
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).fetch();
      await tester.pumpAndSettle();

      expect(
        find.text('TOM could not find git on this machine.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('a failure shows the command behind it', () {
    // `docs/product/workspace/commands/doc.md`: the panel never opens by
    // itself, and a failure's band is the one place that offers it.
    testWidgets('as a second action, before the retry', (
      WidgetTester tester,
    ) async {
      git.fetchFailure = const GitTimedOut();
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).fetch();
      await tester.pumpAndSettle();

      expect(find.text('Show the command'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Show the command')).dx,
        lessThan(tester.getCenter(find.text('Try again')).dx),
      );
      expect(container.read(workspaceProvider).showingBottom, isFalse);
    });

    testWidgets('which opens the panel on the last command that failed', (
      WidgetTester tester,
    ) async {
      git.pushFailure = const GitAuthenticationFailed();
      await pumpBand(tester);
      container.read(commandsProvider.notifier)
        ..record(_ran('push', exitCode: 128))
        ..record(_ran('status'));
      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show the command'));
      await tester.pumpAndSettle();

      expect(container.read(workspaceProvider).showingBottom, isTrue);
      expect(container.read(workspaceProvider).bottomPanel, 'tom.commands');
      expect(container.read(commandsProvider).expanded, <int>{0});
    });

    testWidgets('a refused push offers it beside Pull', (
      WidgetTester tester,
    ) async {
      git.pushFailure = const GitPushRejected();
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(find.text('Show the command'), findsOneWidget);
      expect(find.text('Pull'), findsOneWidget);
    });
  });

  testWidgets('a pull that conflicts is named, and offers no retry', (
    WidgetTester tester,
  ) async {
    git.pullFailure = const GitMergeConflict(<String>[
      'docs/about.md',
      'docs/roadmap.md',
    ]);
    await pumpBand(tester);

    await container.read(remoteProvider.notifier).pull();
    await tester.pumpAndSettle();

    expect(
      find.text('The pull stopped: 2 documents conflict.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
  });

  group('a pull refused over uncommitted work', () {
    /// The band's colour, read off its 3-point bar.
    Color? inkOf(WidgetTester tester) =>
        tester.widget<NoticeBandWidget>(find.byType(NoticeBandWidget)).ink;

    testWidgets('names the one file, says nothing changed, and the remedy', (
      WidgetTester tester,
    ) async {
      git.pullFailure = const GitLocalChangesOverwritten(<String>[
        'docs/roadmap.md',
      ]);
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).pull();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Git refused the pull: it would overwrite the uncommitted changes '
          'to docs/roadmap.md. Nothing changed here — commit them, then try '
          'again.',
        ),
        findsOneWidget,
      );
      // A situation to act on, not a fault: the refusal's colour.
      expect(inkOf(tester), TomColors.light.modified);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Show the command'), findsOneWidget);
    });

    testWidgets('counts several', (WidgetTester tester) async {
      git.pullFailure = const GitLocalChangesOverwritten(<String>[
        'docs/a.md',
        'docs/b.md',
        'notes.md',
      ]);
      await pumpBand(tester);

      await container.read(remoteProvider.notifier).pull();
      await tester.pumpAndSettle();

      expect(
        find.textContaining('the uncommitted changes to 3 files.'),
        findsOneWidget,
      );
    });

    testWidgets('says it in Portuguese', (WidgetTester tester) async {
      git.pullFailure = const GitLocalChangesOverwritten(<String>[
        'docs/a.md',
        'docs/b.md',
      ]);
      await pumpBand(tester, locale: const Locale('pt'));

      await container.read(remoteProvider.notifier).pull();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'O git recusou o pull: ele sobrescreveria as alterações sem commit '
          'em 2 arquivos. Nada mudou aqui — faça o commit delas e tente de '
          'novo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tentar de novo'), findsOneWidget);
    });
  });

  testWidgets('a pull in flight says so on the band that started it', (
    WidgetTester tester,
  ) async {
    // Pull has no button of its own, so the band is the control that was
    // pressed and the one that must say it is working.
    final Completer<void> pulling = Completer<void>();
    git.pullGate = pulling.future;
    await pumpBand(tester);

    final Future<void> done = container.read(remoteProvider.notifier).pull();
    await tester.pump();

    expect(find.text('Pulling what the remote has…'), findsOneWidget);

    pulling.complete();
    await done;
    await tester.pumpAndSettle();

    expect(find.byType(NoticeBandWidget), findsNothing);
  });

  group('a merge the repository is still in the middle of', () {
    /// The session as a stopped pull leaves it, with [count] left to
    /// resolve.
    ///
    /// Put on the session directly: the band reads the session, and who
    /// fills it is the shell's business, not this widget's.
    void stopped({int count = 2}) {
      container.read(spaceSessionProvider.notifier)
        ..observe(
          statusOf(
            entries: <StatusEntryValueObject>[
              for (int i = 0; i < count; i++) conflicted('docs/doc$i.md'),
            ],
          ),
        )
        ..observeMerge(
          const MergeStateValueObject(
            inProgress: true,
            message: "Merge branch 'main'",
          ),
        );
    }

    // The state belongs to the repository, not to the pull: closing the
    // window and opening it again has to find the same sentence, or the `C`
    // marks in the tree stand there with nothing explaining them.
    testWidgets('says so even though nobody pulled in this session', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();

      expect(
        find.textContaining('The pull stopped: 2 documents conflict'),
        findsOneWidget,
      );
    });

    testWidgets('says nothing was lost, which is what people ask first', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped(count: 1);
      await tester.pump();

      expect(
        find.textContaining('Nothing you committed has been lost'),
        findsOneWidget,
      );
      expect(find.textContaining('1 document conflict'), findsOneWidget);
    });

    testWidgets('offers no retry, because a conflict is not a failure', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();

      expect(find.text('Try again'), findsNothing);
      expect(find.text('Pull'), findsNothing);
    });

    testWidgets('offers Abort the pull, and nothing else', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();

      expect(find.text('Abort the pull'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    // A press that cannot be taken back is never the one that needs no
    // thought: the safe answer is the filled button.
    testWidgets('asks before undoing, and says what the undo costs', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();

      await tester.tap(find.text('Abort the pull'));
      await tester.pumpAndSettle();

      expect(find.byType(TomDialogWidget), findsOneWidget);
      expect(find.text('Abort the pull?'), findsOneWidget);
      expect(
        find.text('The space goes back to what it was before the pull.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Keep the conflict'),
        ),
        findsOneWidget,
      );
      expect(git.aborted, 0);
    });

    testWidgets('keeping the conflict closes the question and undoes nothing', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();
      await tester.tap(find.text('Abort the pull'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep the conflict'));
      await tester.pumpAndSettle();

      expect(find.byType(TomDialogWidget), findsNothing);
      expect(git.aborted, 0);
    });

    testWidgets('confirming asks git to abort', (WidgetTester tester) async {
      await pumpBand(tester);
      stopped();
      await tester.pump();
      await tester.tap(find.text('Abort the pull'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TomDialogWidget),
          matching: find.text('Abort the pull'),
        ),
      );
      await tester.pumpAndSettle();

      expect(git.aborted, 1);
    });

    testWidgets('says nothing once no document is conflicted any more', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester);
      container
          .read(spaceSessionProvider.notifier)
          .observeMerge(
            const MergeStateValueObject(
              inProgress: true,
              message: "Merge branch 'main'",
            ),
          );
      await tester.pump();

      expect(find.byType(NoticeBandWidget), findsNothing);
    });
  });
}

/// Git, answering what the test set and counting what it was asked.
final class _Git implements GitRepository {
  GitStatusValueObject? reported;
  GitFailure? fetchFailure;
  GitFailure? pullFailure;
  GitFailure? pushFailure;

  /// Held open to keep an action in flight.
  Future<void>? pullGate;

  int pulled = 0;
  int pushes = 0;

  /// What git is taken to say about a merge; no merge unless a test says so.
  MergeStateValueObject merge = MergeStateValueObject.none;

  /// How many times the merge was asked to be undone.
  int aborted = 0;

  @override
  Future<Result<void, GitFailure>> abortMerge() async {
    aborted += 1;
    merge = MergeStateValueObject.none;
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async =>
      Success<MergeStateValueObject, GitFailure>(merge);

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      Success<GitStatusValueObject, GitFailure>(reported!);

  @override
  Future<Result<void, GitFailure>> fetch() async => fetchFailure == null
      ? const Success<void, GitFailure>(null)
      : Failure<void, GitFailure>(fetchFailure!);

  @override
  Future<Result<void, GitFailure>> pull() async {
    pulled++;
    await pullGate;
    return pullFailure == null
        ? const Success<void, GitFailure>(null)
        : Failure<void, GitFailure>(pullFailure!);
  }

  @override
  Future<Result<void, GitFailure>> push() async {
    pushes++;
    return pushFailure == null
        ? const Success<void, GitFailure>(null)
        : Failure<void, GitFailure>(pushFailure!);
  }

  // A branch with no upstream is published rather than pushed; to this fake
  // the two are one request.
  @override
  Future<Result<void, GitFailure>> publish(BranchNameValueObject branch) =>
      push();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A space that holds nothing, so the tree has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A git command, as the client would write it down.
CommandRecord _ran(String verb, {int exitCode = 0}) => CommandRecord.of(
  executable: 'git',
  arguments: <String>[verb],
  startedAt: DateTime(2026, 10, 8),
  duration: const Duration(milliseconds: 40),
  exitCode: exitCode,
);

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
