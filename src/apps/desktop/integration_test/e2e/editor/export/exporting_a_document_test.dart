/// Export: asked for on the tab, written where the dialog says, and the band
/// that says where it went.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  const String cancelled =
      'Writes nothing when the dialog is cancelled, and says so when it cannot';
  // Where an export lands unless the dialog is told otherwise, and a folder
  // beside it that will not take a file.
  final String beside = File(scenarioSettingsPath(cancelled)).parent.path;
  final String shut = '$beside/shut';

  scenario(
    'Exports a document from its tab',
    group: 'Editor',
    submenu: 'Export',
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
      Step('nothing was written beside the source', (TomRobot robot) async {
        // The files went where the dialog said; the space and the
        // repository hold no export, and git sees none.
        for (final String folder in <String>{
          docsInRepo.root,
          docsInRepo.repositoryRoot,
        }) {
          final List<String> exported = Directory(folder)
              .listSync()
              .map((FileSystemEntity it) => it.path.split('/').last)
              .where((String it) => it.endsWith('.pdf') || it.endsWith('.html'))
              .toList();
          expect(exported, isEmpty, reason: '$folder holds $exported');
        }
        // The list is up and listing — an absence is read off a list that
        // would show an export.
        await robot.seesInTheChanges(<String>['untracked.md']);
        await robot.seesNotInTheChanges('index.pdf');
        await robot.seesNotInTheChanges('index.html');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Writes nothing when the dialog is cancelled, and says so when it cannot',
    group: 'Editor',
    submenu: 'Export',
    describe:
        'An export has two ways to end with no file. A dialog the person '
        'dismisses is no error — no band, no file, nothing to apologise for. '
        'A folder that will not take the file is: the band says what could '
        'not be exported and that **nothing was written**, and the disk '
        'agrees.',
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
      Step('a cancelled dialog writes nothing and says nothing', (
        TomRobot robot,
      ) async {
        robot.answersTheSaveDialogWith('cancel');

        await robot.choosesFromTheTabMenu('index.md', 'Export as PDF…');

        await robot.seesNoBand();
        expect(File('$beside/index.pdf').existsSync(), isFalse);
      }),
      Step('a folder that will not take the file is named in the band', (
        TomRobot robot,
      ) async {
        Directory(shut).createSync(recursive: true);
        Process.runSync('chmod', <String>['555', shut]);
        addTearDown(() => Process.runSync('chmod', <String>['755', shut]));
        robot.answersTheSaveDialogWith('$shut/index.pdf');

        await robot.choosesFromTheTabMenu('index.md', 'Export as PDF…');

        await robot.seesTheBandSaying(<String>[
          'Could not export index.pdf',
          'Nothing was written.',
        ]);
      }),
      Step('and the disk agrees: no file, and nothing beside it', (
        TomRobot robot,
      ) async {
        expect(File('$shut/index.pdf').existsSync(), isFalse);
        expect(Directory(shut).listSync(), isEmpty);
        robot.seesNothingBroken();
      }),
    ],
  );
}
