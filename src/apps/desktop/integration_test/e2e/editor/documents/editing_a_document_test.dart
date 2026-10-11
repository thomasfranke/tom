/// Source mode: typing into a real file and putting it back on disk.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  late String untrackedOnDisk;

  scenario(
    'Edits a document and saves it',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'The claim the whole product rests on, end to end: **the file on '
        'disk is the truth**. A document is opened, typed into, shown '
        'changed in the preview with no refresh step, marked as unsaved '
        'everywhere that says so, and then written — and the last assertion '
        'is against the bytes on disk, not against anything the app '
        'remembers.',
    steps: <Step>[
      // `untracked.md` on purpose: this scenario rewrites the file, and no
      // other scenario reads its content.
      Step('open a document in the docs folder', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesTheOpenDocument('untracked.md');
      }),
      Step('the source pane holds the file as it is written', (
        TomRobot robot,
      ) async {
        await robot.seesInTheSource('# Untracked');
        untrackedOnDisk = File(
          '${docsInRepo.root}/untracked.md',
        ).readAsStringSync();
      }),
      Step('typing reaches the preview with no refresh step', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSource('# Typed in TOM\n\nAnd rendered.\n');

        await robot.seesInThePreview('Typed in TOM');
      }),
      Step('and the document is marked unsaved, everywhere it is said', (
        TomRobot robot,
      ) async {
        await robot.seesUnsaved('untracked.md');
      }),
      Step('and nothing has reached the disk before the save', (
        TomRobot robot,
      ) async {
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          untrackedOnDisk,
          reason: 'the file changed before anybody saved',
        );
      }),
      Step('saving clears the mark', (TomRobot robot) async {
        await robot.saves();

        await robot.seesNothingUnsaved('untracked.md');
      }),
      Step('and the file on disk is what the editor held', (
        TomRobot robot,
      ) async {
        // Read off the disk: everything above could pass with a buffer that
        // never landed.
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Typed in TOM\n\nAnd rendered.\n',
        );
        robot.seesNothingBroken();
      }),
      Step('in Split, scrolling one pane carries the other to the same place', (
        TomRobot robot,
      ) async {
        // Sections of four lines — heading, blank, body, blank — so the
        // section a line belongs to is the line over four, and the two panes
        // (whose heights differ for the same text) can be compared by it.
        await robot.looksAt('Split');
        await robot.typesInTheSource(
          <String>[
            for (int n = 0; n < 120; n++)
              '## Section $n\n\nBody of Section $n.\n',
          ].join('\n'),
        );
        await robot.seesInThePreview('Section 0');

        // The source scrolled: the preview shows what the source shows.
        await robot.scrollsTheSourceBy(2400);
        final int section = robot.theLineAtTheTopOfTheSource() ~/ 4;
        expect(section, greaterThan(20), reason: 'the source did not scroll');
        await robot.seesInThePreview('Section $section');
        await robot.seesNotInThePreview('Section 0');

        // And the other way: the preview scrolled back to the top takes the
        // source with it.
        await robot.scrollsThePreviewBy(-100000);
        await robot.seesInThePreview('Section 0');
        expect(robot.theLineAtTheTopOfTheSource(), lessThan(8));
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Asks before saving over a file that changed on disk',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'The app has a terminal and a pull, and other editors exist: a file '
        'can change while its buffer holds edits. **The save asks the disk '
        'first**, and a file that is no longer what was read is not written '
        'over — a band names it and offers the two answers. Both are '
        'pressed here, and each is checked against the bytes on disk.',
    steps: <Step>[
      Step('open a document and type into it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesInTheSource('# Untracked');
        await robot.typesInTheSource('# Mine\n');
        await robot.seesUnsaved('untracked.md');
      }),
      Step('another program writes the same file, and the save is not made', (
        TomRobot robot,
      ) async {
        File('${docsInRepo.root}/untracked.md').writeAsStringSync('# Theirs\n');
        await robot.saves();

        await robot.seesTheBandSaying(<String>[
          'untracked.md changed on disk while you were editing it.',
        ]);
        await robot.seesOnScreen(<String>['Keep mine', 'Reload']);
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Theirs\n',
        );
        await robot.seesUnsaved('untracked.md');
      }),
      Step('Reload takes the file, and the edit goes', (TomRobot robot) async {
        await robot.answersTheBand('Reload');

        await robot.seesInTheSource('# Theirs');
        await robot.seesNoBand();
        await robot.seesNothingUnsaved('untracked.md');
      }),
      Step('it changes under a second edit, and the band is back', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSource('# Mine again\n');
        File(
          '${docsInRepo.root}/untracked.md',
        ).writeAsStringSync('# Theirs again\n');
        await robot.saves();

        await robot.seesTheBandSaying(<String>['untracked.md changed on disk']);
      }),
      Step('Keep mine puts the band away and writes nothing yet', (
        TomRobot robot,
      ) async {
        await robot.answersTheBand('Keep mine');

        await robot.seesNoBand();
        await robot.seesInTheSource('# Mine again');
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Theirs again\n',
        );
      }),
      Step('and the next save writes the buffer over what was there', (
        TomRobot robot,
      ) async {
        await robot.saves();

        await robot.seesNothingUnsaved('untracked.md');
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Mine again\n',
        );
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Saves the text and leaves the file what it was',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'A save replaces what a document says, not what its file *is*. '
        'The write is a rename over the path, which used to hand back a '
        'file with the default permissions: a private note became readable '
        'by everyone. Here a document nobody else may read is edited and '
        'saved, and the disk is asked for its mode afterwards. A document '
        'that is a symbolic link is the integration tests\'.',
    steps: <Step>[
      Step('open a document only its owner may read', (TomRobot robot) async {
        // Set before the app starts, the way it would be found.
        Process.runSync('chmod', <String>[
          '600',
          '${docsInRepo.root}/untracked.md',
        ]);
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesInTheSource('# Untracked');
      }),
      Step('type into it and save', (TomRobot robot) async {
        await robot.typesInTheSource('# Still private\n');
        await robot.saves();

        await robot.seesNothingUnsaved('untracked.md');
      }),
      Step('the file holds the new text, and is still only its owner\'s', (
        TomRobot robot,
      ) async {
        final File file = File('${docsInRepo.root}/untracked.md');

        expect(file.readAsStringSync(), '# Still private\n');
        expect((file.statSync().mode & 0x1ff).toRadixString(8), '600');
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Reads a document with the source out of the way',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Reading is not a lesser mode: for anyone who does not write '
        'markdown by hand, the rendered view is the product and the editor '
        'is the part they never open. The mode bar is what gives it the '
        'whole document area — and the shell hides the source without ever '
        'learning which panel that is.',
    steps: <Step>[
      Step('open a document', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');
        await robot.seesInThePreview('Writing');
      }),
      Step('a space opens with both panes', (TomRobot robot) async {
        robot.seesThePanes(source: true, preview: true);
      }),
      Step('preview-only leaves the preview alone on screen', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Preview');

        robot.seesThePanes(source: false, preview: true);
      }),
      Step('and the explorer is still there, because nothing takes over', (
        TomRobot robot,
      ) async {
        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('source-only is the other way round', (TomRobot robot) async {
        await robot.looksAt('Source');

        robot
          ..seesThePanes(source: true, preview: false)
          ..seesNothingBroken();
      }),
    ],
  );
}
