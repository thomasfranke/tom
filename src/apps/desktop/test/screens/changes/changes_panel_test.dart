import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_commit_button_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_message_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The commit button, not the Push beside it: the column now holds two
/// filled buttons, and `byType` would find both.
final Finder commitButton = find.ancestor(
  of: find.textContaining('Commit'),
  matching: find.byType(FilledButton),
);

void main() {
  late _Git git;

  /// What the documents hold, by path inside the space; empty unless a test
  /// about the marker check says otherwise.
  final Map<String, String> onDisk = <String, String>{};
  late ProviderContainer container;

  /// What the pull request already read of the repository's remote, which
  /// is where the column learns there is none before anything is pressed.
  PullRequestState pullRequest = const PullRequestState();

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  StatusEntryValueObject entry(
    String path,
    FileStateEnum state, {
    required bool isStaged,
  }) => StatusEntryValueObject(
    path: RepoRelativePathValueObject(path),
    state: state,
    isStaged: isStaged,
  );

  GitStatusValueObject statusOf(
    List<StatusEntryValueObject> entries, {
    int ahead = 0,
    int behind = 0,
    String? upstream,
  }) => GitStatusValueObject(
    branch: BranchNameValueObject('main'),
    upstream: upstream == null ? null : BranchNameValueObject(upstream),
    ahead: ahead,
    behind: behind,
    entries: entries,
    isDetached: false,
  );

  setUp(() {
    git = _Git()..reported = statusOf(const <StatusEntryValueObject>[]);
    onDisk.clear();
    pullRequest = const PullRequestState();
    container = ProviderContainer(
      overrides: <Override>[
        pullRequestProvider.overrideWith(() => _Remembers(() => pullRequest)),
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
        stageChangesProvider.overrideWithValue(
          StageChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            documentsFor: (SpaceEntity space) => _Documents(onDisk),
            observability: const _Silent(),
          ),
        ),
        commitChangesProvider.overrideWithValue(
          CommitChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A refused push puts its remedy on this column, so the remote
        // actions are wired though the panel offers none of them.
        pushRemoteProvider.overrideWithValue(
          PushRemoteUseCase(
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
        // A pull rewrites the working tree and walks it again, so a test
        // that pulls needs a folder to walk.
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

  /// Mounts the panel at the shell's width with [space] open, at [height]
  /// when it shares the aside with another.
  Future<void> pumpPanel(
    WidgetTester tester, {
    SpaceEntity? space,
    double? height,
    Locale? locale,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
    }
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
          home: Scaffold(
            body: Row(
              children: <Widget>[
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: TomMetrics.git,
                  height: height,
                  child: const ChangesPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with nothing open it says so, and names itself no more', (
    WidgetTester tester,
  ) async {
    // The column's switch names the panel now, so a caption here would
    // repeat the raised segment (`docs/product/workspace/columns/doc.md`).
    await pumpPanel(tester);

    expect(find.text('No space is open.'), findsOneWidget);
    expect(find.text('CHANGES'), findsNothing);
  });

  testWidgets('a clean tree says so rather than looking broken', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, space: docs);

    expect(
      find.text('Nothing has changed since the last commit.'),
      findsOneWidget,
    );
  });

  testWidgets('every change git reports is a row', (WidgetTester tester) async {
    // The repository's changes, not the space's: a commit records the index.
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: true),
      entry('lib/main.dart', FileStateEnum.added, isStaged: false),
      entry('notes.md', FileStateEnum.untracked, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('index.md'), findsOneWidget);
    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('notes.md'), findsOneWidget);
  });

  testWidgets('pressing a name opens its document with the diff on', (
    WidgetTester tester,
  ) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: true),
      entry('docs/guides/writing.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);

    for (final String name in <String>['index.md', 'writing.md']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();

      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.openDocument?.value, endsWith(name));
      expect(session.showingDiff, isTrue);
    }
  });

  testWidgets('a space inside the repository opens a change outside it too, '
      'as a tab the tree does not draw', (WidgetTester tester) async {
    // The maintainer's case: the space is a folder of the repository and
    // every change is beside it, so a row that opened only the space's
    // documents opened nothing at all.
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('README.md', FileStateEnum.modified, isStaged: true),
      entry('notes/plan.md', FileStateEnum.added, isStaged: false),
    ]);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..decorate(showing: false);
    await pumpPanel(tester);

    await tester.tap(find.text('README.md'));
    await tester.pumpAndSettle();
    SpaceSessionState session = container.read(spaceSessionProvider)!;
    expect(session.openDocument, isNull);
    expect(session.outsideDocument?.value, 'README.md');
    expect(session.showingDiff, isTrue);

    await tester.tap(find.text('plan.md'));
    await tester.pumpAndSettle();
    session = container.read(spaceSessionProvider)!;
    expect(session.outsideDocument?.value, 'notes/plan.md');
    expect(session.tabs, <DocumentTab>[
      DocumentTab.outside(RepoRelativePathValueObject('notes/plan.md')),
    ]);
  });

  testWidgets('a change that is not markdown opens too, source only', (
    WidgetTester tester,
  ) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('pubspec.yaml', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);

    await tester.tap(find.text('pubspec.yaml'));
    await tester.pumpAndSettle();

    final SpaceSessionState session = container.read(spaceSessionProvider)!;
    expect(
      session.onScreen,
      DocumentTab.outside(RepoRelativePathValueObject('pubspec.yaml')),
    );
    expect(session.isSourceOnly, isTrue);
  });

  testWidgets('a row names the folder under the file, two doc.md apart', (
    WidgetTester tester,
  ) async {
    // The board draws the row as two lines, and this repository is full of
    // files that share a name
    // (`design/screens/desktop/git-commit/committing-dark.svg`).
    git.reported = statusOf(<StatusEntryValueObject>[
      entry(
        'docs/product/commit/doc.md',
        FileStateEnum.modified,
        isStaged: false,
      ),
      entry('notes.md', FileStateEnum.untracked, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('docs/product/commit'), findsOneWidget);
    // Nothing under a file at the repository's own root: there is no folder
    // to name, and an empty line still takes one. Two texts in that row is
    // the mark's letter and the name, and no third.
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('notes.md'),
          matching: find.byType(ChangesRowWidget),
        ),
        matching: find.byType(Text),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('and the count under the button says what is going in', (
    WidgetTester tester,
  ) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('a.md', FileStateEnum.modified, isStaged: true),
      entry('b.md', FileStateEnum.modified, isStaged: true),
      entry('c.md', FileStateEnum.modified, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('2 of 3 staged'), findsOneWidget);
  });

  testWidgets('the button names the branch the commit is going onto', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, space: docs);

    expect(find.text('Commit to main'), findsOneWidget);
  });

  testWidgets('each row says what happened with a letter, not a colour only', (
    WidgetTester tester,
  ) async {
    // Colour is never the only signal
    // (docs/design/visual-language/README.md).
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('a.md', FileStateEnum.modified, isStaged: false),
      entry('b.md', FileStateEnum.added, isStaged: false),
      entry('c.md', FileStateEnum.deleted, isStaged: false),
      entry('d.md', FileStateEnum.untracked, isStaged: false),
    ]);

    await pumpPanel(tester, space: docs);

    expect(find.text('M'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
  });

  testWidgets('ticking a row stages it, one file at a time', (
    WidgetTester tester,
  ) async {
    // Whole files, no hunks
    // (docs/product/git-workflow/commit/the-changes-list/doc.md).
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);

    await tester.tap(find.byType(TomCheckWidget).last);
    await tester.pumpAndSettle();

    expect(git.staged.single.value, 'docs/index.md');
  });

  group('the commit button', () {
    setUp(
      () => git.reported = statusOf(<StatusEntryValueObject>[
        entry('docs/index.md', FileStateEnum.modified, isStaged: true),
      ]),
    );

    /// Whether *Commit* can be pressed.
    bool isEnabled(WidgetTester tester) =>
        tester.widget<FilledButton>(commitButton).onPressed != null;

    testWidgets('is disabled until there is a message', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      expect(isEnabled(tester), isFalse);
    });

    testWidgets('is disabled with nothing staged, however good the message', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(<StatusEntryValueObject>[
        entry('docs/index.md', FileStateEnum.modified, isStaged: false),
      ]);
      await pumpPanel(tester, space: docs);

      await tester.enterText(find.byType(TextField).first, 'docs: say it');
      await tester.pumpAndSettle();

      expect(isEnabled(tester), isFalse);
    });

    group('with the repository on no branch', () {
      setUp(
        () => git.reported = GitStatusValueObject(
          branch: null,
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: <StatusEntryValueObject>[
            entry('docs/index.md', FileStateEnum.modified, isStaged: true),
          ],
          isDetached: true,
        ),
      );

      testWidgets('is unavailable, names no branch, and the column says why', (
        WidgetTester tester,
      ) async {
        // Refused before anything is asked of git: the commit would be
        // reachable from nothing
        // (`docs/product/git-workflow/commit/the-message/doc.md`).
        await pumpPanel(tester, space: docs);
        await tester.enterText(find.byType(TextField).first, 'docs: say it');
        await tester.pumpAndSettle();

        expect(isEnabled(tester), isFalse);
        expect(find.text('Commit'), findsOneWidget);
        expect(
          find.text('Not on a branch — switch to one to commit.'),
          findsOneWidget,
        );
        // Above the message box, where the commit is asked for.
        expect(
          tester
              .getBottomLeft(
                find.text('Not on a branch — switch to one to commit.'),
              )
              .dy,
          lessThan(tester.getTopLeft(find.byType(ChangesMessageWidget)).dy),
        );
        expect(git.messages, isEmpty);
      });

      testWidgets('and says it in Portuguese', (WidgetTester tester) async {
        await pumpPanel(tester, space: docs, locale: const Locale('pt'));

        expect(
          find.text('Fora de uma branch — mude para uma para fazer commit.'),
          findsOneWidget,
        );
      });
    });

    testWidgets('commits what is staged, and empties the box', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);
      await tester.enterText(find.byType(TextField).first, 'docs: say it');
      await tester.pumpAndSettle();
      expect(isEnabled(tester), isTrue);
      git.reported = statusOf(const <StatusEntryValueObject>[]);

      await tester.tap(commitButton);
      await tester.pumpAndSettle();

      expect(git.messages, <String>['docs: say it']);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
      expect(
        find.text('Nothing has changed since the last commit.'),
        findsOneWidget,
      );
    });

    group('the key that commits', () {
      // `docs/product/git-workflow/commit/the-message/doc.md`.
      final TargetPlatformVariant platform = TargetPlatformVariant.only(
        TargetPlatform.macOS,
      );

      Future<void> pressCommandEnter(WidgetTester tester) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();
      }

      testWidgets('⌘Enter commits when the button would', (
        WidgetTester tester,
      ) async {
        await pumpPanel(tester, space: docs);
        await tester.enterText(find.byType(TextField).first, 'docs: say it');
        await tester.pumpAndSettle();
        git.reported = statusOf(const <StatusEntryValueObject>[]);

        await pressCommandEnter(tester);

        expect(git.messages, <String>['docs: say it']);
      }, variant: platform);

      testWidgets('⌘Enter does nothing while the button is unavailable', (
        WidgetTester tester,
      ) async {
        await pumpPanel(tester, space: docs);
        await tester.tap(find.byType(TextField).first);
        await tester.pumpAndSettle();

        await pressCommandEnter(tester);

        expect(git.messages, isEmpty);
      }, variant: platform);
    });

    testWidgets('a description goes under the summary, after a blank line', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);
      await tester.enterText(find.byType(TextField).first, 'docs: say it');
      await tester.enterText(
        find.byType(TextField).last,
        'Because it was not.',
      );
      await tester.pumpAndSettle();
      git.reported = statusOf(const <StatusEntryValueObject>[]);

      await tester.tap(commitButton);
      await tester.pumpAndSettle();

      expect(git.messages, <String>['docs: say it\n\nBecause it was not.']);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        isEmpty,
      );
    });

    testWidgets('the box offers a summary and an optional description', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester, space: docs);

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
    });
  });

  // The refusals the git menu and a row's ↶ can meet, each in its own words
  // above the message box, muted (`git-menu/doc.md`, `the-changes-list/doc.md`).
  for (final (GitFailure failure, String sentence) in <(GitFailure, String)>[
    (
      const GitMergeConflict(<String>[]),
      'A merge is in progress — resolve it first.',
    ),
    (const GitNoCommitsYet(), 'There is no commit to go back to yet.'),
    (
      const GitPathCommitted(<String>['docs/index.md']),
      'index.md is in the last commit, so it was not deleted. The list '
          'has been read again.',
    ),
  ]) {
    testWidgets('a refusal says "$sentence" and keeps the list', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(<StatusEntryValueObject>[
        entry('docs/index.md', FileStateEnum.modified, isStaged: false),
      ]);
      await pumpPanel(tester, space: docs);
      git.writeFailure = failure;

      await tester.tap(find.byType(TomCheckWidget).last);
      await tester.pumpAndSettle();

      final Finder line = find.text(sentence);
      expect(line, findsOneWidget);
      expect(
        tester.widget<Text>(line).style!.color,
        TomColors.of(tester.element(line)).textMuted,
      );
      expect(find.text('index.md'), findsOneWidget);
    });
  }

  testWidgets('a refused operation says so without losing the list', (
    WidgetTester tester,
  ) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);
    git.writeFailure = const GitOperationFailed();

    await tester.tap(find.byType(TomCheckWidget).last);
    await tester.pumpAndSettle();

    expect(find.text('Git could not do that.'), findsOneWidget);
    expect(find.text('index.md'), findsOneWidget);
  });

  testWidgets('a folder outside a repository is named as that', (
    WidgetTester tester,
  ) async {
    git.statusFailure = const GitNotARepository('/code/app');

    await pumpPanel(tester, space: docs);

    expect(
      find.text('That folder is not inside a Git repository.'),
      findsOneWidget,
    );
  });

  testWidgets('a push standing refused does not take this column away', (
    WidgetTester tester,
  ) async {
    // The refusal is a band above the document
    // (docs/product/git-workflow/push-pull/when-it-fails/doc.md); the box and
    // the button stay, because another commit is still a thing to do.
    git.reported = statusOf(const <StatusEntryValueObject>[], behind: 3);
    await pumpPanel(tester, space: docs);
    git.writeFailure = const GitPushRejected();

    await container.read(remoteProvider.notifier).push();
    await tester.pumpAndSettle();

    expect(find.byType(ChangesMessageWidget), findsOneWidget);
    expect(find.byType(ChangesCommitButtonWidget), findsOneWidget);
    expect(find.textContaining('pushed'), findsNothing);
  });

  group('the link to the remote', () {
    /// The three at the foot of the column, by their verb.
    bool isEnabled(WidgetTester tester, String verb) =>
        tester
            .widget<ButtonStyleButton>(
              find.ancestor(
                of: find.text(verb),
                matching: find.byWidgetPredicate(
                  (Widget widget) => widget is ButtonStyleButton,
                ),
              ),
            )
            .onPressed !=
        null;

    testWidgets('a healthy link draws no broken line', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(const <StatusEntryValueObject>[], ahead: 2);
      await pumpPanel(tester, space: docs);

      for (final String sentence in const <String>[
        'No network',
        'Git refused the credentials',
        'No remote configured',
        'The remote did not answer',
      ]) {
        expect(find.text(sentence), findsNothing);
      }
    });

    // A healthy link says where the branch stands, in the broken line's slot
    // (`push-pull/when-the-link-is-broken/doc.md`).
    for (final (int ahead, int behind, String sentence)
        in const <(int, int, String)>[
          (0, 0, 'Up to date with origin/main'),
          (0, 2, '2 behind origin/main'),
          (1, 0, '1 ahead of origin/main'),
          (1, 2, '1 ahead, 2 behind origin/main'),
        ]) {
      testWidgets('ahead $ahead and behind $behind says "$sentence"', (
        WidgetTester tester,
      ) async {
        git.reported = statusOf(
          const <StatusEntryValueObject>[],
          ahead: ahead,
          behind: behind,
          upstream: 'origin/main',
        );
        await pumpPanel(tester, space: docs);

        final Text line = tester.widget<Text>(find.text(sentence));
        final TomColors colors = TomColors.of(
          tester.element(find.text(sentence)),
        );
        expect(line.style!.color, colors.textMuted);
        expect(line.style!.fontSize, 11);
      });
    }

    testWidgets('a branch with no upstream says nothing', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(const <StatusEntryValueObject>[], ahead: 2);
      await pumpPanel(tester, space: docs);

      expect(find.textContaining('Up to date'), findsNothing);
      expect(find.textContaining('ahead'), findsNothing);
    });

    testWidgets('a repository with no remote says so before any press', (
      WidgetTester tester,
    ) async {
      pullRequest = const PullRequestState(
        target: PullRequestTargetValueObject(),
      );
      git.reported = statusOf(const <StatusEntryValueObject>[], ahead: 2);
      await pumpPanel(tester, space: docs);
      await tester.pumpAndSettle();

      expect(find.text('No remote configured'), findsOneWidget);
      expect(isEnabled(tester, 'Push'), isFalse);
      expect(isEnabled(tester, 'Fetch'), isFalse);
      expect(isEnabled(tester, 'Pull'), isFalse);
    });

    testWidgets('a repository with a remote says nothing of the kind', (
      WidgetTester tester,
    ) async {
      pullRequest = const PullRequestState(
        target: PullRequestTargetValueObject(hasRemote: true),
      );
      await pumpPanel(tester, space: docs);

      expect(find.text('No remote configured'), findsNothing);
    });

    testWidgets('a broken link replaces where the branch stands', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(
        const <StatusEntryValueObject>[],
        ahead: 1,
        upstream: 'origin/main',
      );
      await pumpPanel(tester, space: docs);
      expect(find.text('1 ahead of origin/main'), findsOneWidget);
      git.writeFailure = const GitNetworkUnavailable();

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(find.text('No network'), findsOneWidget);
      expect(find.textContaining('origin/main'), findsNothing);
    });

    testWidgets('no network is said, and the three go unavailable', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(const <StatusEntryValueObject>[], ahead: 2);
      await pumpPanel(tester, space: docs);
      git.writeFailure = const GitNetworkUnavailable();

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(find.text('No network'), findsOneWidget);
      expect(isEnabled(tester, 'Fetch'), isFalse);
      expect(isEnabled(tester, 'Pull'), isFalse);
    });

    testWidgets('a timeout is said, and the three stay live', (
      WidgetTester tester,
    ) async {
      git.reported = statusOf(const <StatusEntryValueObject>[], ahead: 2);
      await pumpPanel(tester, space: docs);
      git.writeFailure = const GitTimedOut();

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(find.text('The remote did not answer'), findsOneWidget);
      expect(isEnabled(tester, 'Fetch'), isTrue);
    });

    testWidgets('committing is never taken away', (WidgetTester tester) async {
      await pumpPanel(tester, space: docs);
      git.writeFailure = const GitNetworkUnavailable();

      await container.read(remoteProvider.notifier).push();
      await tester.pumpAndSettle();

      expect(find.byType(ChangesMessageWidget), findsOneWidget);
      expect(find.byType(ChangesCommitButtonWidget), findsOneWidget);
    });
  });

  testWidgets('both modes render, and differ', (WidgetTester tester) async {
    git.reported = statusOf(<StatusEntryValueObject>[
      entry('docs/index.md', FileStateEnum.modified, isStaged: false),
    ]);
    await pumpPanel(tester, space: docs);
    final TomColors light = TomColors.of(
      tester.element(find.byType(ChangesPanel)),
    );

    expect(light.modified, isNot(light.added));
  });

  testWidgets('a merge still holding conflicts counts what is left, not what '
      'is staged', (WidgetTester tester) async {
    git
      ..reported = statusOf(<StatusEntryValueObject>[
        entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
        entry('docs/guide.md', FileStateEnum.conflicted, isStaged: false),
      ])
      ..merge = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );

    await pumpPanel(tester, space: docs);

    expect(find.text('2 documents to resolve'), findsOneWidget);
    expect(find.text('0 of 2 staged'), findsNothing);
  });

  testWidgets('one left to resolve is said in the singular', (
    WidgetTester tester,
  ) async {
    git
      ..reported = statusOf(<StatusEntryValueObject>[
        entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
      ])
      ..merge = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );

    await pumpPanel(tester, space: docs);

    expect(find.text('1 document to resolve'), findsOneWidget);
  });

  group('staging a conflicted document that still holds a marker', () {
    const MergeStateValueObject merging = MergeStateValueObject(
      inProgress: true,
      message: "Merge branch 'main'",
    );

    testWidgets('is refused by name, and the row stays where it was', (
      WidgetTester tester,
    ) async {
      git
        ..reported = statusOf(<StatusEntryValueObject>[
          entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
        ])
        ..merge = merging;
      // One line left of a region somebody resolved by hand.
      onDisk['roadmap.md'] = '# Roadmap\n\nours\n=======\ntheirs\n';
      await pumpPanel(tester, space: docs);

      await tester.tap(find.byType(TomCheckWidget).last);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'roadmap.md still holds a conflict marker — resolve it, then stage.',
        ),
        findsOneWidget,
      );
      expect(git.staged, isEmpty);
      expect(find.text('roadmap.md'), findsOneWidget);
    });

    testWidgets('says it in removed, where the other refusals stay muted', (
      WidgetTester tester,
    ) async {
      git
        ..reported = statusOf(<StatusEntryValueObject>[
          entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
        ])
        ..merge = merging;
      onDisk['roadmap.md'] = '# Roadmap\n\nours\n=======\ntheirs\n';
      await pumpPanel(tester, space: docs);

      await tester.tap(find.byType(TomCheckWidget).last);
      await tester.pumpAndSettle();

      final Finder sentence = find.text(
        'roadmap.md still holds a conflict marker — resolve it, then stage.',
      );
      expect(
        tester.widget<Text>(sentence).style!.color,
        TomColors.of(tester.element(sentence)).removed,
      );
    });

    testWidgets('several are counted, never listed', (
      WidgetTester tester,
    ) async {
      git
        ..reported = statusOf(<StatusEntryValueObject>[
          entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
          entry('docs/guide.md', FileStateEnum.conflicted, isStaged: false),
        ])
        ..merge = merging;
      onDisk['roadmap.md'] = '<<<<<<< HEAD\nours\n';
      onDisk['guide.md'] = 'theirs\n>>>>>>> main\n';
      await pumpPanel(tester, space: docs);

      await tester.tap(find.text('Stage all'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '2 documents still hold a conflict marker — resolve them, then '
          'stage.',
        ),
        findsOneWidget,
      );
      expect(git.staged, isEmpty);
    });

    testWidgets('once it reads clean it stages, though git still calls it '
        'conflicted', (WidgetTester tester) async {
      git
        ..reported = statusOf(<StatusEntryValueObject>[
          entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: false),
        ])
        ..merge = merging;
      onDisk['roadmap.md'] = '# Roadmap\n\nours\ntheirs\n';
      await pumpPanel(tester, space: docs);

      await tester.tap(find.byType(TomCheckWidget).last);
      await tester.pumpAndSettle();

      expect(git.staged, <RepoRelativePathValueObject>[
        RepoRelativePathValueObject('docs/roadmap.md'),
      ]);
      expect(find.textContaining('conflict marker'), findsNothing);
    });
  });

  // Concluding the merge is a commit, and it cannot be made while a document
  // still holds a marker — so the button is dim rather than refusing after
  // the press (`design/screens/desktop/git-conflict/conflict-in-source-light.svg`).
  testWidgets('the commit is unavailable while anything is unresolved', (
    WidgetTester tester,
  ) async {
    git
      ..reported = statusOf(<StatusEntryValueObject>[
        entry('docs/roadmap.md', FileStateEnum.conflicted, isStaged: true),
      ])
      ..merge = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );

    await pumpPanel(tester, space: docs);
    await tester.enterText(find.byType(TextField).first, 'merge it');
    await tester.pump();

    expect(tester.widget<FilledButton>(commitButton).onPressed, isNull);
  });

  testWidgets('the staged count comes back once nothing is conflicted', (
    WidgetTester tester,
  ) async {
    git
      ..reported = statusOf(<StatusEntryValueObject>[
        entry('docs/roadmap.md', FileStateEnum.modified, isStaged: true),
      ])
      ..merge = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );

    await pumpPanel(tester, space: docs);

    expect(find.text('1 of 1 staged'), findsOneWidget);
    expect(find.textContaining('to resolve'), findsNothing);
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  /// What git is taken to say about a merge; no merge unless a test says so.
  MergeStateValueObject merge = MergeStateValueObject.none;

  GitStatusValueObject? reported;
  GitFailure? statusFailure;
  GitFailure? writeFailure;

  final List<RepoRelativePathValueObject> staged =
      <RepoRelativePathValueObject>[];
  final List<String> messages = <String>[];

  /// How many times the rejection's remedy was taken.
  int pulled = 0;

  Result<void, GitFailure> _done() => writeFailure == null
      ? const Success<void, GitFailure>(null)
      : Failure<void, GitFailure>(writeFailure!);

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      statusFailure == null
      ? Success<GitStatusValueObject, GitFailure>(reported!)
      : Failure<GitStatusValueObject, GitFailure>(statusFailure!);

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    staged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async => _done();

  @override
  Future<Result<void, GitFailure>> commit(String message) async {
    messages.add(message);
    return _done();
  }

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      throw UnimplementedError();

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> fetch() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> pull() async {
    pulled++;
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<void, GitFailure>> push() async => _done();

  // A branch with no upstream is published rather than pushed.
  @override
  Future<Result<void, GitFailure>> publish(BranchNameValueObject branch) =>
      push();

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async =>
      Success<MergeStateValueObject, GitFailure>(merge);

  @override
  Future<Result<void, GitFailure>> discardAll() async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> abortMerge() async =>
      throw UnimplementedError();

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

/// A pull request that has already read what the test says, and reads
/// nothing of its own.
final class _Remembers extends PullRequestNotifier {
  _Remembers(this.read);

  final PullRequestState Function() read;

  @override
  PullRequestState build() => read();
}

/// Documents read from a map; with nothing in it nothing can be read, so
/// the marker check finds nothing to refuse.
final class _Documents implements DocumentRepository {
  const _Documents(this.contents);

  final Map<String, String> contents;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => switch (contents[path.value]) {
    final String text => Success<DocumentEntity, DocumentFailure>(
      DocumentEntity(path: path, content: text),
    ),
    null => Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(path.value),
    ),
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}
