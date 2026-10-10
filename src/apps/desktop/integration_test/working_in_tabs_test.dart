/// The tabs: documents opened in preview, kept by editing, and an unsaved one
/// that asks before it closes.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Works in tabs',
    group: 'Editor',
    describe:
        'What the strip at the head of the document area does, on a real '
        'folder. A click opens a document in preview — italic, and replaced '
        'by the next click rather than joined by it. Typing keeps the tab, so '
        'the next document opens beside it, and the edit survives going back '
        'and forth. The tab with edits draws a dot where its close would be, '
        'and ⌘W asks before it lets the edit go.',
    steps: <Step>[
      Step('open the docs folder, and a document from the tree', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.seesTheTabs(<String>['index.md']);
        robot.seesTheTabInPreview('index.md');
      }),
      Step('the next click replaces the tab in preview', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('writing.md');
        await robot.seesTheTabs(<String>['writing.md']);
      }),
      Step('typing keeps the tab, and the next one opens beside it', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');
        await robot.typesInTheSource('# Writing, kept\n');
        robot.seesTheTabInPreview('writing.md', inPreview: false);
        await robot.clickInTheTree('index.md');
        await robot.seesTheTabs(<String>['writing.md', 'index.md']);
      }),
      Step('going back finds the edit still there', (TomRobot robot) async {
        await robot.choosesTheTab('writing.md');
        await robot.seesInTheSource('# Writing, kept');
      }),
      Step('⌘W on the unsaved tab asks first', (TomRobot robot) async {
        await robot.closesTheTabFromTheKeyboard();
        await robot.seesOnScreen(<String>['writing.md has unsaved changes.']);
      }),
      Step('keeping the tab open keeps the edit', (TomRobot robot) async {
        await robot.tapInTheDialog('Keep the tab open');
        await robot.seesTheTabs(<String>['writing.md', 'index.md']);
        await robot.seesInTheSource('# Writing, kept');
      }),
      Step('discarding closes it, and the next tab is on screen', (
        TomRobot robot,
      ) async {
        await robot.closesTheTabFromTheKeyboard();
        await robot.tapInTheDialog('Discard and close');
        await robot.seesTheTabs(<String>['index.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
