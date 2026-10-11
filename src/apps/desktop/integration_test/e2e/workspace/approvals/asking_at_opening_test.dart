/// The one way the app asks on its own: the check for a newer TOM when it
/// opens, and the box that turns it off.
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_releases.dart';
import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  late FakeReleases releases;

  /// Starts the scenario's own release endpoint, which answers 404 until a
  /// step says otherwise.
  Future<void> startReleases() async {
    releases = await FakeReleases.start();
    addTearDown(releases.stop);
  }

  scenario(
    'Asks at opening by default',
    group: 'Workspace',
    submenu: 'Approvals',
    describe:
        'The one way the app asks on its own: `Check for updates when TOM '
        'opens`, ticked by default. A fresh preferences file shows the box '
        'ticked, and opening asks once, saying what it found as a dot on '
        'the gear and a line in the status bar — no band, no dialog.',
    steps: <Step>[
      Step('a fresh opening asks once, and says so quietly', (
        TomRobot robot,
      ) async {
        await startReleases();
        releases.publish('v9.9.0');
        await robot.launchWindowed(
          pickFolder: docsInRepo.root,
          releasesAt: releases.address,
        );
        await robot.chooseFolder();
        await robot.seesTheShell();

        await robot.seesOnScreen(<String>['Update available: 9.9.0']);
        await robot.seesTheGearDot();
        expect(releases.asked, 1);
        robot
          ..seesNoDialog()
          ..seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Asks nothing at opening when the box was unticked',
    group: 'Workspace',
    submenu: 'Approvals',
    describe:
        'A person who unticked `Check for updates when TOM opens` keeps the '
        'choice: unticking asks nothing by itself, and the next opening '
        'asks nothing and says nothing.',
    steps: <Step>[
      Step('unticking the box asks nothing by itself', (TomRobot robot) async {
        await startReleases();
        releases.publish('v9.9.0');
        await robot.launchWindowed(
          pickFolder: docsInRepo.root,
          releasesAt: releases.address,
        );
        await robot.chooseFolder();
        await robot.seesTheShell();
        // The default opening asked once.
        await robot.seesOnScreen(<String>['Update available: 9.9.0']);
        expect(releases.asked, 1);
        await robot.opensThePreferences();

        await robot.ticksCheckingForUpdates();

        expect(releases.asked, 1);
      }),
      Step('the next opening asks nothing, and says nothing', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(
          pickFolder: docsInRepo.root,
          releasesAt: releases.address,
        );
        await robot.chooseFolder();
        await robot.seesTheShell();

        await robot.seesNotOnScreen('Update available');
        expect(releases.asked, 1);
        robot
          ..seesNoDialog()
          ..seesNothingBroken();
      }),
    ],
  );
}
