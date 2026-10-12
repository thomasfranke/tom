/// The pull request's three surfaces: the row in the tree, the status row
/// where the tabs were, and the right column's two segments.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_overview_panel.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_panel.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_row_widget.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_status_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');

  CommitEntity commit(String subject) => CommitEntity(
    sha: CommitShaValueObject('a' * 40),
    author: const AuthorValueObject(name: 'Ana', email: 'ana@example.com'),
    date: CommitDateValueObject(
      utc: DateTime.now().toUtc().subtract(const Duration(days: 3)),
      offset: Duration.zero,
    ),
    subject: subject,
    body: '',
  );

  final PullRequestTargetValueObject github = PullRequestTargetValueObject(
    project: const RemoteProjectValueObject(
      host: RemoteHostEnum.github,
      path: 'acme/docs',
    ),
    defaultBranch: main,
    hasRemote: true,
  );

  late _Page page;
  late ProviderContainer container;

  /// A space on [branch], with the page's notifier answering [state] and the
  /// status row answering [status].
  void arrange({
    PullRequestState state = const PullRequestState(),
    BranchNameValueObject? branch,
    PullRequestStatus status = const PullRequestStatus.ready(commits: 2),
    bool proposing = false,
  }) {
    page = _Page(state);
    container = ProviderContainer(
      overrides: <Override>[
        pullRequestProvider.overrideWith(() => page),
        pullRequestStatusProvider.overrideWithValue(status),
        remoteProvider.overrideWith(_Idle.new),
      ],
    );
    addTearDown(container.dispose);
    final SpaceSessionNotifier session =
        container.read(spaceSessionProvider.notifier)
          ..open(
            SpaceEntity(
              root: '/code/docs',
              repositoryRoot: '/code',
              name: 'docs',
            ),
          )
          ..observe(
            GitStatusValueObject(
              branch: branch ?? feature,
              upstream: BranchNameValueObject('origin/feat/x'),
              ahead: 0,
              behind: 0,
              entries: const <StatusEntryValueObject>[],
              isDetached: false,
            ),
          );
    if (proposing) {
      session.proposeBranch(feature, main);
    }
  }

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.dark,
    Size size = const Size(300, 900),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
  }

  group('the row in the tree', () {
    testWidgets('is drawn on a branch there is something to propose from', (
      WidgetTester tester,
    ) async {
      arrange(state: PullRequestState(target: github));
      await mount(tester, const PullRequestRowWidget());

      expect(find.text('Pull request'), findsOneWidget);
      expect(
        tester.getSize(find.byType(PullRequestRowWidget)).height,
        PullRequestRowWidget.extent,
      );
    });

    testWidgets('on the remote’s own branch it is unavailable, and says why', (
      WidgetTester tester,
    ) async {
      arrange(
        state: PullRequestState(target: github),
        branch: main,
      );
      await mount(tester, const PullRequestRowWidget());

      expect(find.text('Pull request'), findsOneWidget);
      expect(find.text('On main — nothing to propose'), findsOneWidget);
      expect(
        tester.getSize(find.byType(PullRequestRowWidget)).height,
        PullRequestRowWidget.unavailableExtent,
      );
      await tester.tap(find.text('Pull request'));
      expect(page.opened, 0);
    });

    testWidgets('a host the app does not know is its own reason', (
      WidgetTester tester,
    ) async {
      arrange(
        state: PullRequestState(
          target: PullRequestTargetValueObject(
            defaultBranch: main,
            hasRemote: true,
          ),
        ),
      );
      await mount(tester, const PullRequestRowWidget());

      expect(find.text('origin is not on a known host'), findsOneWidget);
      expect(
        find.byTooltip(
          'origin is not on GitHub, GitLab or Bitbucket, so there is no page '
          'to open a pull request on.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('so is no remote at all', (WidgetTester tester) async {
      arrange(
        state: PullRequestState(
          target: PullRequestTargetValueObject(defaultBranch: main),
        ),
      );
      await mount(tester, const PullRequestRowWidget());

      expect(find.text('No remote to propose to'), findsOneWidget);
    });

    testWidgets('while git is still answering it is muted and says nothing', (
      WidgetTester tester,
    ) async {
      arrange();
      await mount(tester, const PullRequestRowWidget());

      expect(
        tester.widget<Text>(find.text('Pull request')).style?.color,
        TomColors.dark.textMuted,
      );
      expect(
        tester.getSize(find.byType(PullRequestRowWidget)).height,
        PullRequestRowWidget.extent,
      );
    });

    testWidgets('a folder with no repository draws it muted, with no reason', (
      WidgetTester tester,
    ) async {
      // A shortcut that vanishes is one somebody hunts for
      // (`docs/product/workspace/without-a-repository/doc.md`).
      arrange(
        state: const PullRequestState(
          targetFailure: GitNotARepository('/code/docs'),
        ),
      );
      await mount(tester, const PullRequestRowWidget());

      expect(find.text('Pull request'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Pull request')).style?.color,
        TomColors.dark.textMuted,
      );
      expect(
        tester.getSize(find.byType(PullRequestRowWidget)).height,
        PullRequestRowWidget.extent,
      );
      await tester.tap(find.text('Pull request'));
      expect(page.opened, 0);
    });

    testWidgets('pressing it opens the page', (WidgetTester tester) async {
      arrange(state: PullRequestState(target: github));
      await mount(tester, const PullRequestRowWidget());

      await tester.tap(find.text('Pull request'));

      expect(page.opened, 1);
    });
  });

  group('the status row takes the action over', () {
    testWidgets('when the right column is shut', (WidgetTester tester) async {
      arrange(state: PullRequestState(target: github));
      container.read(workspaceProvider.notifier).toggleAside();
      await mount(tester, const PullRequestStatusRowWidget());

      await tester.tap(find.text('Open on GitHub'));

      expect(page.hosted, 1);
    });

    testWidgets('and not while the column carries it', (
      WidgetTester tester,
    ) async {
      arrange(state: PullRequestState(target: github));
      await mount(tester, const PullRequestStatusRowWidget());

      expect(find.text('Open on GitHub'), findsNothing);
    });
  });

  group('the status row', () {
    for (final (PullRequestStatus status, String says)
        in <(PullRequestStatus, String)>[
          (
            const PullRequestStatus.ready(commits: 3),
            'Ready to open. 3 commits pushed, nothing left to publish.',
          ),
          (
            const PullRequestStatus.uncommitted(documents: 2),
            '2 documents are not committed. They would not be in this pull '
                'request — commit them first.',
          ),
          (
            const PullRequestStatus.untitled(),
            'The draft has no title — its first line is a # heading.',
          ),
        ]) {
      testWidgets('says “$says” and offers nothing', (
        WidgetTester tester,
      ) async {
        arrange(status: status);
        await mount(tester, const PullRequestStatusRowWidget());

        expect(find.text(says), findsOneWidget);
        expect(find.text('Push'), findsNothing);
      });
    }

    testWidgets(
      'commits not on the remote carry Push, which can happen there',
      (WidgetTester tester) async {
        arrange(
          status: const PullRequestStatus.unpublished(
            commits: 1,
            hasUpstream: true,
          ),
        );
        await mount(tester, const PullRequestStatusRowWidget());

        expect(
          find.text('1 commit not on the remote yet. Push before opening.'),
          findsOneWidget,
        );
        expect(find.text('Push'), findsOneWidget);
      },
    );
  });

  group('the Pull request segment', () {
    final PullRequestState read = PullRequestState(
      target: github,
      proposal: BranchProposalValueObject(
        commits: <CommitEntity>[commit('Second'), commit('First')],
        changes: <BranchChangeValueObject>[
          BranchChangeValueObject(
            path: RepoRelativePathValueObject('docs/a.md'),
            state: FileStateEnum.modified,
            added: 40,
            removed: 2,
          ),
          BranchChangeValueObject(
            path: RepoRelativePathValueObject('docs/b.md'),
            state: FileStateEnum.added,
            added: 8,
            removed: 10,
          ),
        ],
      ),
    );

    testWidgets('names the base, counts the branch and lists its commits', (
      WidgetTester tester,
    ) async {
      arrange(state: read, proposing: true);
      await mount(tester, const PullRequestPanel());

      expect(find.text('PROPOSING ONTO'), findsOneWidget);
      expect(find.text('main'), findsOneWidget);
      expect(find.text('2 commits · 2 documents'), findsOneWidget);
      expect(find.text('+48'), findsOneWidget);
      expect(find.text('−12'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('3 days ago'), findsNWidgets(2));
    });

    testWidgets('the base is picked from the branches it can move to', (
      WidgetTester tester,
    ) async {
      arrange(
        state: read.copyWith(
          bases: <BranchNameValueObject>[
            main,
            BranchNameValueObject('release'),
          ],
        ),
        proposing: true,
      );
      await mount(tester, const PullRequestPanel());

      await tester.tap(find.text('main'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('release'));
      await tester.pumpAndSettle();

      expect(page.chosen, <BranchNameValueObject>[
        BranchNameValueObject('release'),
      ]);
    });

    testWidgets('with only one base on offer the control opens nothing', (
      WidgetTester tester,
    ) async {
      arrange(
        state: read.copyWith(bases: <BranchNameValueObject>[main]),
        proposing: true,
      );
      await mount(tester, const PullRequestPanel());

      await tester.tap(find.text('main'));
      await tester.pumpAndSettle();

      expect(find.byType(TomMenuWidget), findsNothing);
    });

    testWidgets('its one action names the host and hands over the draft', (
      WidgetTester tester,
    ) async {
      arrange(state: read, proposing: true);
      await mount(tester, const PullRequestPanel());

      expect(find.text('Create pull request'), findsNothing);
      await tester.tap(find.text('Open on GitHub'));

      expect(page.hosted, 1);
    });

    testWidgets('the action is unavailable while something stands in the way', (
      WidgetTester tester,
    ) async {
      arrange(
        state: read,
        proposing: true,
        status: const PullRequestStatus.uncommitted(documents: 1),
      );
      await mount(tester, const PullRequestPanel());

      await tester.tap(find.text('Open on GitHub'));

      expect(page.hosted, 0);
    });
  });

  group('through gh', () {
    final BranchProposalValueObject twoCommits = BranchProposalValueObject(
      commits: <CommitEntity>[commit('Second'), commit('First')],
      changes: const <BranchChangeValueObject>[],
    );
    final OpenedPullRequestValueObject numbered = OpenedPullRequestValueObject(
      number: 123,
      address: Uri.parse('https://github.com/acme/docs/pull/123'),
      title: 'Release notes',
    );

    /// The status row over the column, as the page draws them.
    Future<void> mountPage(WidgetTester tester, Brightness brightness) => mount(
      tester,
      const Column(
        children: <Widget>[
          PullRequestStatusRowWidget(),
          Expanded(child: PullRequestPanel()),
        ],
      ),
      brightness: brightness,
      size: const Size(600, 900),
    );

    Color rowFill(WidgetTester tester) => tester
        .widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(PullRequestStatusRowWidget),
                matching: find.byType(ColoredBox),
              )
              .first,
        )
        .color;

    ButtonStyle styleOf(WidgetTester tester, String label) => tester
        .widget<ButtonStyleButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byWidgetPredicate(
              (Widget it) => it is ButtonStyleButton,
            ),
          ),
        )
        .style!;

    for (final Brightness brightness in Brightness.values) {
      final TomColors colors = brightness == Brightness.dark
          ? TomColors.dark
          : TomColors.light;

      testWidgets(
        '${brightness.name}: Create pull request over the host page',
        (WidgetTester tester) async {
          arrange(
            state: PullRequestState(
              target: github,
              proposal: twoCommits,
              throughGh: true,
            ),
            proposing: true,
          );
          await mountPage(tester, brightness);

          expect(
            find.text(
              'Ready to open. 2 commits pushed, nothing left to publish.',
            ),
            findsOneWidget,
          );
          final Rect create = tester.getRect(
            find.ancestor(
              of: find.text('Create pull request'),
              matching: find.byType(FilledButton),
            ),
          );
          final Rect instead = tester.getRect(
            find.ancestor(
              of: find.text('Open on GitHub instead'),
              matching: find.byType(OutlinedButton),
            ),
          );
          expect(create.height, 32);
          expect(instead.height, 32);
          expect(instead.top - create.bottom, 6);
          expect(
            styleOf(
              tester,
              'Create pull request',
            ).backgroundColor?.resolve(<WidgetState>{}),
            colors.accent,
          );
          expect(
            styleOf(
              tester,
              'Open on GitHub instead',
            ).side?.resolve(<WidgetState>{})?.color,
            colors.borderStrong,
          );
          expect(
            styleOf(
              tester,
              'Open on GitHub instead',
            ).foregroundColor?.resolve(<WidgetState>{}),
            colors.textSecondary,
          );

          await tester.tap(find.text('Create pull request'));
          await tester.tap(find.text('Open on GitHub instead'));

          expect(page.created, 1);
          expect(page.hosted, 1);
        },
      );

      testWidgets('${brightness.name}: one already open is shown, by number', (
        WidgetTester tester,
      ) async {
        arrange(
          state: PullRequestState(
            target: github,
            proposal: twoCommits,
            throughGh: true,
            opened: numbered,
          ),
          status: const PullRequestStatus.alreadyOpen(number: 123),
          proposing: true,
        );
        await mountPage(tester, brightness);

        expect(
          find.text(
            'Pull request #123 is open on GitHub — this draft is what it was '
            'opened with.',
          ),
          findsOneWidget,
        );
        expect(rowFill(tester), colors.accentSoft);
        expect(find.text('Create pull request'), findsNothing);
        expect(find.text('Open on GitHub instead'), findsNothing);

        await tester.tap(find.text('View #123 on GitHub'));

        expect(page.viewed, 1);
      });

      testWidgets('${brightness.name}: nothing to propose is said quietly', (
        WidgetTester tester,
      ) async {
        arrange(
          state: PullRequestState(
            target: github,
            proposal: const BranchProposalValueObject(
              commits: <CommitEntity>[],
              changes: <BranchChangeValueObject>[],
            ),
            throughGh: true,
          ),
          status: const PullRequestStatus.empty(),
          proposing: true,
        );
        await mountPage(tester, brightness);

        final Finder sentence = find.text(
          'Nothing to propose yet: this branch has no commits over main.',
        );
        expect(sentence, findsOneWidget);
        expect(tester.widget<Text>(sentence).style?.color, colors.textMuted);
        expect(rowFill(tester), colors.surfaceSunken);
        expect(
          find.descendant(
            of: find.byType(PullRequestStatusRowWidget),
            matching: find.byType(TomGlyphWidget),
          ),
          findsNothing,
        );
        expect(find.text('No commits over main'), findsOneWidget);
        expect(find.text('+0'), findsNothing);
        expect(find.text('Open on GitHub instead'), findsNothing);
        expect(
          tester
              .widget<FilledButton>(
                find.ancestor(
                  of: find.text('Create pull request'),
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNull,
        );
      });
    }

    testWidgets(
      'a create gh refused is said, with the command one press away',
      (WidgetTester tester) async {
        arrange(
          state: PullRequestState(
            target: github,
            proposal: twoCommits,
            throughGh: true,
          ),
          status: const PullRequestStatus.notCreated(
            failure: PullRequestHostUnreachable(),
          ),
          proposing: true,
        );
        container.read(commandsProvider.notifier)
          ..record(
            CommandRecord.of(
              executable: 'gh',
              arguments: const <String>['pr', 'create'],
              startedAt: DateTime(2026, 10, 8),
              duration: const Duration(milliseconds: 40),
              exitCode: 1,
            ),
          )
          ..record(
            CommandRecord.of(
              executable: 'git',
              arguments: const <String>['config', '--get', 'x'],
              startedAt: DateTime(2026, 10, 8),
              duration: const Duration(milliseconds: 4),
              exitCode: 1,
            ),
          );
        await mountPage(tester, Brightness.light);

        expect(
          find.text(
            'GitHub could not be reached — the pull request was not opened.',
          ),
          findsOneWidget,
        );
        expect(rowFill(tester), TomColors.light.removedSoft);

        await tester.tap(find.text('Show the command'));
        await tester.pump();

        expect(container.read(workspaceProvider).bottomPanel, 'tom.commands');
        expect(container.read(commandsProvider).expanded, <int>{0});
      },
    );

    testWidgets('with the column shut, the row creates it', (
      WidgetTester tester,
    ) async {
      arrange(
        state: PullRequestState(
          target: github,
          proposal: twoCommits,
          throughGh: true,
        ),
      );
      container.read(workspaceProvider.notifier).toggleAside();
      await mount(
        tester,
        const PullRequestStatusRowWidget(),
        size: const Size(900, 200),
      );

      await tester.tap(find.text('Create pull request'));

      expect(page.created, 1);
    });
  });

  testWidgets('the Overview says what the branch did, and carries no action', (
    WidgetTester tester,
  ) async {
    arrange(
      proposing: true,
      state: PullRequestState(
        target: github,
        overview: BranchOverviewValueObject(
          commits: 3,
          added: 1,
          modified: 2,
          deleted: 0,
          wordsAdded: 820,
          wordsRemoved: 310,
          blocks: const <BlockKindEnum, int>{
            BlockKindEnum.paragraph: 12,
            BlockKindEnum.heading: 3,
            BlockKindEnum.table: 1,
          },
          folders: const <String, int>{'docs/product': 2, 'docs/design': 1},
          readingMinutes: 6,
          mostChanged: BranchChangeValueObject(
            path: RepoRelativePathValueObject('docs/tasks/roadmap.md'),
            state: FileStateEnum.modified,
            added: 410,
            removed: 120,
          ),
        ),
      ),
    );
    await mount(tester, const PullRequestOverviewPanel());
    await tester.pump();

    expect(find.text('6 min'), findsOneWidget);
    expect(find.text('+820'), findsOneWidget);
    expect(find.text('12 paragraphs · 3 headings · 1 table'), findsOneWidget);
    expect(find.text('2 modified · 1 added'), findsOneWidget);
    expect(find.text('docs/product'), findsOneWidget);
    expect(find.text('roadmap.md'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(page.shown, <PullRequestSegmentEnum>[
      PullRequestSegmentEnum.overview,
    ]);
  });
}

/// The page's notifier, answering a fixed state and counting presses.
final class _Page extends PullRequestNotifier {
  _Page(this.initial);

  final PullRequestState initial;
  int opened = 0;
  int hosted = 0;
  int created = 0;
  int viewed = 0;
  final List<PullRequestSegmentEnum> shown = <PullRequestSegmentEnum>[];

  @override
  PullRequestState build() => initial;

  @override
  void open() => opened++;

  /// The bases the page was told to move to.
  final List<BranchNameValueObject> chosen = <BranchNameValueObject>[];

  @override
  void chooseBase(BranchNameValueObject base) => chosen.add(base);

  @override
  Future<void> openOnHost() async => hosted++;

  @override
  Future<void> create() async => created++;

  @override
  Future<void> viewOnHost() async => viewed++;

  @override
  Future<void> show(PullRequestSegmentEnum segment) async => shown.add(segment);
}

/// A remote nobody is talking to.
final class _Idle extends RemoteNotifier {
  @override
  RemoteState build() => const RemoteState.idle();
}
