/// The rendered diff: what changed, drawn over the formatted document.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  /// `guides/writing.md` as the fixture's one commit left it; the working
  /// tree has one paragraph more, so the file opens already carrying a diff.
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

        await robot.seesTheDiffMarks(<String>['A']);
        await robot.seesInThePreview('One line added, uncommitted.');
      }),
      Step('a document matching the last commit carries no decoration', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        await robot.seesTheOpenDocument('index.md');

        await robot.seesNoDiffMarks();
      }),
      Step('rewriting a paragraph marks that paragraph, not the document', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('writing.md');
        await robot.seesTheOpenDocument('guides/writing.md');

        // Typed, never saved: the comparison is the buffer against git.
        await robot.typesInTheSource(
          committed.replaceFirst('Keep it short.', 'Keep it very short.'),
        );

        await robot.seesTheDiffMarks(<String>['M']);
        await robot.seesInThePreview('Keep it very short.');
      }),
      Step('and a deleted paragraph is still there to read', (
        TomRobot robot,
      ) async {
        const String deleted =
            'Keep it short. A paragraph that runs past a screen is two '
            'paragraphs that\nhave not been separated yet.\n\n';
        await robot.typesInTheSource(committed.replaceFirst(deleted, ''));

        await robot.seesTheDiffMarks(<String>['R']);
        await robot.seesInThePreview('two paragraphs that');
      }),
      Step('a deleted code block is read the same way', (TomRobot robot) async {
        // A fence is rendered by the highlighter alone, outside the preview's
        // style sheet, so struck-through code is a separate claim from prose.
        await robot.typesInTheSource(
          committed.substring(0, committed.indexOf('```dart')),
        );

        await robot.seesTheDiffMarks(<String>['R']);
        await robot.seesInThePreview('final answer = 42;');
        robot.seesNothingBroken();
      }),
    ],
  );
}
