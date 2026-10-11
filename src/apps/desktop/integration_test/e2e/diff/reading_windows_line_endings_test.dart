/// A document written with Windows line endings, read and compared.
library;

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture withCrlf = fixtures['docs-with-crlf'];

  scenario(
    'Reads a document written with Windows line endings',
    group: 'Diff',
    describe:
        'A file saved on Windows ends every line in a carriage return and a '
        'line feed, in the commit and in the working copy alike. The '
        'preview must read paragraphs, not stray characters, and the diff '
        'must mark the one paragraph added after the commit — a carriage '
        'return taken for content would mark every line as changed.',
    steps: <Step>[
      Step('open the document written with CRLF', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: withCrlf.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('windows.md');

        await robot.seesTheOpenDocument('windows.md');
      }),
      Step('the preview reads its paragraphs', (TomRobot robot) async {
        await robot.seesInThePreview('A note saved by an editor on Windows.');
        await robot.seesInThePreview('Second paragraph.');
      }),
      Step('the diff marks the added paragraph and nothing else', (
        TomRobot robot,
      ) async {
        await robot.seesInThePreview(
          'Third paragraph, added after the commit.',
        );

        await robot.seesTheDiffMarks(<String>['A']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
