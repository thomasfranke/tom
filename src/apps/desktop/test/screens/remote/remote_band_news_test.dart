/// The band after a commit that worked and after a push that landed
/// (`docs/product/git-workflow/commit/confirming/doc.md`,
/// `docs/product/git-workflow/push-pull/when-it-works/doc.md`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/remote/remote_band_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _News remote;

  Future<void> pumpBand(
    WidgetTester tester, {
    required RemoteState news,
    int ahead = 0,
    bool tracksARemoteBranch = true,
    LinkStateEnum? link,
  }) async {
    remote = _News(news);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        remoteProvider.overrideWith(() => remote),
        remoteLinkProvider.overrideWithValue(link),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier)
      ..open(
        SpaceEntity(root: '/code/docs', repositoryRoot: '/code', name: 'docs'),
      )
      ..observe(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: tracksARemoteBranch
              ? BranchNameValueObject('origin/main')
              : null,
          ahead: ahead,
          behind: 0,
          entries: const <StatusEntryValueObject>[],
          isDetached: false,
        ),
      );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(
            body: Column(children: <Widget>[RemoteBandWidget()]),
          ),
        ),
      ),
    );
  }

  group('a commit that worked', () {
    testWidgets('quotes its message, counts what waits, and offers Push', (
      WidgetTester tester,
    ) async {
      await pumpBand(
        tester,
        news: const RemoteState.idle(committed: 'Mark the MVP as shipped'),
        ahead: 3,
      );

      expect(
        find.text(
          'Committed “Mark the MVP as shipped”. 3 commits waiting to push.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Push'));
      expect(remote.pushes, 1);
    });

    testWidgets('with nothing waiting it only quotes the message', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester, news: const RemoteState.idle(committed: 'Fix'));

      expect(find.text('Committed “Fix”.'), findsOneWidget);
      expect(find.text('Push'), findsNothing);
    });

    testWidgets(
      'on a branch with no upstream it offers Push, which publishes',
      (WidgetTester tester) async {
        await pumpBand(
          tester,
          news: const RemoteState.idle(committed: 'Fix'),
          tracksARemoteBranch: false,
        );

        expect(find.text('Committed “Fix”.'), findsOneWidget);
        await tester.tap(find.text('Push'));
        expect(remote.pushes, 1);
      },
    );

    testWidgets('offers no Push when the repository has no remote at all', (
      WidgetTester tester,
    ) async {
      await pumpBand(
        tester,
        news: const RemoteState.idle(committed: 'Fix'),
        tracksARemoteBranch: false,
        link: LinkStateEnum.noRemote,
      );

      expect(find.text('Committed “Fix”.'), findsOneWidget);
      expect(find.text('Push'), findsNothing);
    });
  });

  group('a push that landed', () {
    testWidgets('says how many went and offers nothing', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester, news: const RemoteState.idle(published: 2));

      expect(find.text('Published 2 commits to origin/main.'), findsOneWidget);
      expect(find.text('Push'), findsNothing);
    });

    testWidgets('says it all the same when no count could be read', (
      WidgetTester tester,
    ) async {
      await pumpBand(tester, news: const RemoteState.idle(published: 0));

      expect(find.text('Published to origin/main.'), findsOneWidget);
    });
  });
}

/// The remote holding [news] from the start.
final class _News extends RemoteNotifier {
  _News(this.news);

  final RemoteState news;
  int pushes = 0;

  @override
  RemoteState build() => news;

  @override
  Future<void> push() async => pushes++;
}
