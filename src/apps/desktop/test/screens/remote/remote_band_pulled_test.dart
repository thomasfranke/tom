/// The band after a pull that worked: how many arrived, and `Push` while
/// something of this branch is still to publish.
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
  late ProviderContainer container;
  late _Pulled remote;

  Future<void> pumpBand(
    WidgetTester tester, {
    required int? arrived,
    int ahead = 0,
  }) async {
    remote = _Pulled(arrived);
    container = ProviderContainer(
      overrides: <Override>[remoteProvider.overrideWith(() => remote)],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier)
      ..open(
        SpaceEntity(root: '/code/docs', repositoryRoot: '/code', name: 'docs'),
      )
      ..observe(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: BranchNameValueObject('origin/main'),
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

  testWidgets('it says how many arrived, and offers Push for what is left', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester, arrived: 3, ahead: 2);

    expect(
      find.text(
        'Pulled 3 commits from origin/main. 2 of yours are still to publish.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Push'));
    expect(remote.pushes, 1);
  });

  testWidgets('with nothing of yours to publish there is no action', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester, arrived: 1);

    expect(find.text('Pulled 1 commit from origin/main.'), findsOneWidget);
    expect(find.text('Push'), findsNothing);
  });

  testWidgets('a pull that found nothing still answers, and offers nothing', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester, arrived: 0, ahead: 2);

    expect(
      find.text('Already level with origin/main — nothing arrived.'),
      findsOneWidget,
    );
    expect(find.text('Push'), findsNothing);
  });

  testWidgets('with no pull to report the band takes no room', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester, arrived: null);

    expect(find.byType(NoticeBandWidget), findsNothing);
  });
}

/// The remote just after a pull that brought [arrived] commits.
final class _Pulled extends RemoteNotifier {
  _Pulled(this.arrived);

  final int? arrived;
  int pushes = 0;

  @override
  RemoteState build() => RemoteState.idle(arrived: arrived);

  @override
  Future<void> push() async => pushes++;
}
