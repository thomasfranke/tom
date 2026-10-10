/// Export: asked for on the tab, written where the dialog says, and the band
/// that says where it went.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Exports a document from its tab',
    group: 'Editor',
    describe:
        'A right click on a tab offers the export, the dialog is answered '
        'beside the scenario, and the file is read back off the disk — a '
        'paginated PDF, then HTML. **What is exported is the buffer**, so an '
        'edit nobody saved is in the HTML, which is the preview\'s rendering '
        'rather than the file\'s.',
    steps: <Step>[
      Step('open the docs folder, and a document from the tree', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.seesTheTabs(<String>['index.md']);
      }),
      Step('export it as PDF from the tab\'s menu', (TomRobot robot) async {
        await robot.choosesFromTheTabMenu('index.md', 'Export as PDF…');
      }),
      Step('the band says where the PDF went', (TomRobot robot) async {
        await robot.seesTheBandSaying(<String>['Exported index.pdf to ']);
        await robot.seesTheExportWritten('index.pdf', '%PDF');
      }),
      Step('an edit nobody saved goes into the HTML', (TomRobot robot) async {
        await robot.looksAt('Source');
        await robot.typesInTheSource('# Exported unsaved\n');
        await robot.choosesFromTheTabMenu('index.md', 'Export as HTML…');
        await robot.seesTheBandSaying(<String>['Exported index.html to ']);
        await robot.seesTheExportWritten(
          'index.html',
          '<!DOCTYPE html>',
          holding: 'Exported unsaved',
        );
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
