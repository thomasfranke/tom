/// How current each search scope is: the buffer is now, the index is the
/// last save.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final String path = '${docsInRepo.root}/guides/writing.md';

  scenario(
    'Keeps search up with what is saved, and only with that',
    group: 'Search',
    describe:
        'The two scopes answer about different moments, and the product '
        'says so: `This file` reads the buffer, so a word typed and not '
        'saved is there at once, while `Whole space` is the index, which '
        'files a document when it is saved and a file written outside when '
        'the explorer is reloaded.',
    steps: <Step>[
      Step('open the docs folder and a document in it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
      }),
      Step('type a word nobody has written, and do not save it', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');
        await robot.typesInTheSource(
          '${File(path).readAsStringSync()}\nA note on zymurgy.\n',
        );

        await robot.seesUnsaved('guides/writing.md');
      }),
      Step('This file finds it, the whole space does not', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('zymurgy');
        await robot.seesNoResults();

        await robot.searchesTheOpenFile();
        await robot.seesInTheOccurrences(<String>[
          '1 occurrence in writing.md',
        ]);
        expect(File(path).readAsStringSync(), isNot(contains('zymurgy')));
      }),
      Step('saved, the whole space finds it', (TomRobot robot) async {
        await robot.saves();
        await robot.searchesTheWholeSpace();

        await robot.seesInTheResults(<String>['writing.md', '1 document']);
        expect(File(path).readAsStringSync(), contains('zymurgy'));
      }),
      Step('a file written from outside is not found yet', (
        TomRobot robot,
      ) async {
        robot.writesFromOutside(
          '${docsInRepo.root}/brewing.md',
          '# Brewing\n\nThe study of fermentology.\n',
        );
        await robot.typesInTheSearch('fermentology');

        await robot.seesNoResults();
      }),
      Step('Reload reads the folder again, and then it is', (
        TomRobot robot,
      ) async {
        await robot.clearsTheSearch();
        await robot.choosesFromTheMenu('Explorer menu', 'Reload');
        await robot.seesInTheTree(<String>['brewing.md']);

        await robot.typesInTheSearch('fermentology');

        await robot.seesInTheResults(<String>['brewing.md']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
