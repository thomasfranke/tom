/// The rendered diff: what changed, drawn over the formatted document.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  /// `guides/writing.md` as the fixture's one commit left it.
  ///
  /// The working tree has a paragraph more than this — `fixture.json` keeps
  /// it out of the commit — which is what makes the file open already
  /// carrying a diff.
  const String committed = '''
# Writing

Keep it short. A paragraph that runs past a screen is two paragraphs that
have not been separated yet.

## Headings carry the structure

| Rule | Why |
|---|---|
| One idea per section | It can be linked to |
| No heading below four | Nobody navigates that deep |

```dart
// Even a code block, so highlighting has something to do.
final answer = 42;
```
''';

  scenario(
    'Sees what changed, rendered',
    group: 'Diff',
    describe:
        'The product\'s differentiator, end to end: what changed is shown '
        'over the **formatted** document — a mark against the block and the '
        'text still rendered — and never as `+`/`-` lines of raw markdown. '
        'A document that matches the last commit carries no decoration at '
        'all, and a paragraph that was deleted is still on screen to read.',
    steps: <Step>[
      Step('a modified document opens already saying what changed', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');
        await robot.seesTheOpenDocument('guides/writing.md');

        // One paragraph the commit does not have, and nothing else: the
        // rest of the document is untouched and is drawn untouched.
        await robot.seesTheDiffMarks(<String>['A']);
        await robot.seesInThePreview('One line added, uncommitted.');
      }),
      Step('a document matching the last commit carries no decoration', (
        TomRobot robot,
      ) async {
        // The rule that keeps the diff usable: it is on screen for whole
        // documents at a time, so an unchanged one must add nothing to read
        // past (`docs/product/diff/rendered-diff/doc.md`).
        await robot.clickInTheTree('index.md');
        await robot.seesTheOpenDocument('index.md');

        await robot.seesNoDiffMarks();
      }),
      Step('rewriting a paragraph marks that paragraph, not the document', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('writing.md');
        await robot.seesTheOpenDocument('guides/writing.md');

        // The buffer, not the disk: nothing has been saved, and the
        // comparison is against what git holds either way.
        await robot.typesInTheSource(
          committed.replaceFirst('Keep it short.', 'Keep it very short.'),
        );

        await robot.seesTheDiffMarks(<String>['M']);
        await robot.seesInThePreview('Keep it very short.');
      }),
      Step('and a deleted paragraph is still there to read', (
        TomRobot robot,
      ) async {
        // The whole claim: what went is *rendered*, struck through in the
        // place it used to hold — not written out as removed source lines.
        const String deleted =
            'Keep it short. A paragraph that runs past a screen is two '
            'paragraphs that\nhave not been separated yet.\n\n';
        await robot.typesInTheSource(committed.replaceFirst(deleted, ''));

        await robot.seesTheDiffMarks(<String>['R']);
        await robot.seesInThePreview('two paragraphs that');
        robot.seesNothingBroken();
      }),
    ],
  );
}
