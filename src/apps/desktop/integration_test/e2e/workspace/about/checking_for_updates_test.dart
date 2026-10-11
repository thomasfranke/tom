/// About, and the check for a newer TOM.
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
    'Says which TOM this is, and asks for a newer one only when asked',
    group: 'Workspace',
    submenu: 'About',
    describe:
        'The About dialog and the update check, against a release endpoint '
        'on the scenario\'s own machine — a real server on a real socket, so '
        'the real `HttpClient` implementation runs and GitHub is never '
        'reached. Opening asks once, as it does by default; the button asks; '
        'the answers are read in turn: GitHub down (with `Try again`), up to '
        'date, a newer version — announced quietly on the gear and in the '
        'status bar — and finally no release at all, which leaves the button '
        'unavailable. `Update and restart` is not built and is not drawn.',
    steps: <Step>[
      Step('opening the app asks once, by default, and says nothing', (
        TomRobot robot,
      ) async {
        await startReleases();
        releases.publish('v0.1.0');
        await robot.launchWindowed(
          pickFolder: docsInRepo.root,
          releasesAt: releases.address,
        );
        await robot.chooseFolder();
        await robot.seesTheShell();

        await robot.seesNotOnScreen('Update available');
        expect(releases.asked, 1);
      }),
      Step('the popover ends with About TOM and the running version', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferences();

        await robot.seesOnScreen(<String>['About TOM', '0.1.0']);
        expect(releases.asked, 1);
      }),
      Step('the dialog says what this build is, and the button is live', (
        TomRobot robot,
      ) async {
        await robot.opensTheAbout();

        await robot.seesInTheAbout(<String>[
          'Team-Oriented Markdown',
          'Version',
          '0.1.0',
          'Platform',
          'License',
          'MIT',
          'Source on GitHub',
          'Licenses',
          'Release notes',
        ]);
        robot.seesTheAboutButton('Check for updates', live: true);
        expect(releases.asked, 1);
      }),
      Step('GitHub not answering is said, with Try again', (
        TomRobot robot,
      ) async {
        releases.breakDown();
        await robot.pressesInTheAbout('Check for updates');

        await robot.seesInTheAbout(<String>['GitHub did not answer.']);
        robot.seesTheAboutButton('Try again', live: true);
        expect(releases.asked, 2);
      }),
      Step('trying again against the latest release says up to date', (
        TomRobot robot,
      ) async {
        releases.publish('v0.1.0');
        await robot.pressesInTheAbout('Try again');

        await robot.seesInTheAbout(<String>[
          'TOM 0.1.0 is the latest version.',
          'Checked at',
        ]);
        robot
          ..seesNotInTheAbout('GitHub did not answer.')
          ..seesTheAboutButton('Check for updates', live: true);
      }),
      Step('a newer version is named, with what is new', (
        TomRobot robot,
      ) async {
        releases.publish('v9.9.0');
        await robot.pressesInTheAbout('Check for updates');

        await robot.seesInTheAbout(<String>[
          'TOM 9.9.0 is available.',
          "What's new",
        ]);
        robot.seesNotInTheAbout('Update and restart');
        expect(releases.asked, 4);
      }),
      Step('and it is announced on the gear and in the status bar', (
        TomRobot robot,
      ) async {
        await robot.closesTheAbout();

        await robot.seesOnScreen(<String>['Update available: 9.9.0']);
        await robot.seesTheGearDot();
        await robot.opensThePreferences();
        await robot.seesOnScreen(<String>['About TOM', 'Update available']);
        robot.seesNothingBroken();
      }),
      Step('no release at all leaves the button unavailable', (
        TomRobot robot,
      ) async {
        releases.status = 404;
        await robot.opensTheAbout();
        await robot.pressesInTheAbout('Check for updates');

        await robot.seesInTheAbout(<String>['No release yet.']);
        robot.seesTheAboutButton('Check for updates', live: false);
        await robot.closesTheAbout();
      }),
    ],
  );
}
