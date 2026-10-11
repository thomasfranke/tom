/// Wikilinks: a document named by name, in the three states a name can be.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture linked = fixtures['docs-with-wikilinks'];

  scenario(
    'Follows a link by name, and creates the one that is missing',
    group: 'Editor',
    submenu: 'Links',
    describe:
        'A handbook that links three ways. [[setup]] names one document and '
        'opens it; [[release-notes]] names none, so it is drawn apart and its '
        'tip offers to create it; [[guide]] names two, so it carries the '
        'count and, pressed, asks which one instead of guessing. Every state '
        'is told by more than colour. [[setup#Troubleshooting]] opens setup '
        'at the heading, a window below its top, and [[#Troubleshooting]] '
        'inside setup reaches it without leaving.',
    steps: <Step>[
      Step('open the docs and the handbook', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: linked.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
      }),
      Step('the three links wear their three states', (TomRobot robot) async {
        await robot.seesALinkThatResolves('setup');
        await robot.seesALinkThatIsMissing('release-notes');
        await robot.seesALinkThatIsAmbiguous('guide', 2);
      }),
      Step('a link that names one document opens it', (TomRobot robot) async {
        await robot.followsTheLink('setup');
        await robot.seesTheOpenDocument('setup.md');
        await robot.seesInThePreview('Install it');
      }),
      Step('a link to a heading opens its document at that heading', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        await robot.followsTheLink('what to do when it fails');
        await robot.seesTheOpenDocument('setup.md');
        await robot.seesTheHeadingAtTheTopOfThePreview('Troubleshooting');
      }),
      Step('a link two documents share asks which one, and opens it', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        await robot.followsTheLink('guide²');
        await robot.seesTheLinkCandidates('guide.md', <String>[
          'guides',
          'reference',
        ]);
        await robot.choosesTheLinkCandidate('reference');
        await robot.seesTheOpenDocument('reference/guide.md');
        await robot.seesInThePreview('What every command does');
      }),
      Step('a link to a heading of its own document scrolls there', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('setup.md');
        await robot.followsTheLink('the fixes further down');
        await robot.seesTheOpenDocument('setup.md');
        await robot.seesTheHeadingAtTheTopOfThePreview('Troubleshooting');
      }),
      Step('a link to nothing says so, and offers to create it', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        await robot.pointsAtTheLink('release-notes');
        await robot.seesTheLinkOffersToCreate('release-notes');
      }),
      Step('creating it opens the new document', (TomRobot robot) async {
        await robot.createsTheLinkedDocument();
        await robot.seesTheOpenDocument('release-notes.md');
      }),
      Step('the new document is a file in the space, and the link resolves', (
        TomRobot robot,
      ) async {
        // Created at the space's root, beside the document that linked it.
        expect(File('${linked.root}/release-notes.md').existsSync(), isTrue);
        await robot.seesTheTreeMark(
          'release-notes.md',
          FileStateEnum.untracked,
        );
        await robot.clickInTheTree('index.md');
        // Creating a document leaves the window in source.
        await robot.looksAt('Preview');
        await robot.seesALinkThatResolves('release-notes');
      }),
      Step('[[ offers the documents of the space', (TomRobot robot) async {
        await robot.looksAt('Source');
        await robot.typesAtTheEndOfTheSource('\n[[set');
        await robot.seesTheLinkSuggestions(<String>['setup.md']);
        await robot.acceptsTheLinkSuggestion();
        await robot.seesInTheSource('[[setup]]');
      }),
      Step('a name holding # or | is never offered, it would not resolve', (
        TomRobot robot,
      ) async {
        // Names nothing else in the space resembles, so an offer could only
        // be one of these.
        File('${linked.root}/zqx #1.md').writeAsStringSync('# Zqx\n');
        File('${linked.root}/zqy|name.md').writeAsStringSync('# Zqy\n');
        await robot.choosesFromTheMenu('Explorer menu', 'Reload');
        await robot.seesInTheTree(<String>['zqx #1.md']);

        await robot.looksAt('Source');
        await robot.typesAtTheEndOfTheSource('\n\n[[zqx');
        await robot.seesNoLinkSuggestion();
        await robot.typesAtTheEndOfTheSource('\n[[zqy');
        await robot.seesNoLinkSuggestion();
      }),
      Step('and nothing is offered inside a block indented by four spaces', (
        TomRobot robot,
      ) async {
        await robot.typesAtTheEndOfTheSource('\n\n\n    [[set');
        await robot.seesNoLinkSuggestion();
        // The same letters in prose do offer, so the silence is the code's.
        await robot.typesAtTheEndOfTheSource('\n\nprose [[set');
        await robot.seesTheLinkSuggestions(<String>['setup.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
