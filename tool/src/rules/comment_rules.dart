// How long a comment is allowed to be, and the ratchet that gets us there.
//
// The rule is two or three lines (`layers.md#inside-a-package`), and it is
// not checkable — an exception that earns itself is a judgement. What is
// checkable is runaway, and how much of it is left.
library;

import 'dart:io';

import '../rule.dart';

/// How many comment blocks are still over the ceiling.
///
/// A ratchet, not a target. The rewrite to "two or three lines" was done for
/// the files each change touched and never for the rest of the repository,
/// so a check that failed on all of them on day one would have been turned
/// off on day one. This can only go down: every trim lowers it in a line
/// that shows up in the diff, and nothing new is allowed in.
const commentBudget = 48;

/// Past twelve lines, the paragraph belongs in `docs/technical/`.
///
/// The ceiling is the exception's ceiling, not the rule's: the two cases
/// that earn extra lines are a rule with no other home and a trap worth an
/// afternoon, and neither of them takes a page
/// (`.ai/skills/tom-comments/SKILL.md`).
Iterable<Offence> commentsHaveACeiling(Directory root) sync* {
  const ceiling = 12;
  final comment = RegExp(r'^\s*//');

  for (final file in sourcesUnder(root)) {
    final lines = file.readAsLinesSync();
    var run = 0;
    for (var index = 0; index <= lines.length; index++) {
      if (index < lines.length && comment.hasMatch(lines[index])) {
        run++;
        continue;
      }
      if (run > ceiling) {
        yield (
          rule: 'a comment is two or three lines',
          where: '${relative(root, file)}:${index - run + 1}',
          detail:
              '$run lines — past $ceiling it belongs in docs/technical/ '
              'with a link from here (.ai/skills/tom-comments/SKILL.md)',
        );
      }
      run = 0;
    }
  }
}
