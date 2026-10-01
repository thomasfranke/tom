// How long a comment is allowed to be, and the ratchet that gets us there.
library;

import 'dart:io';

import '../rule.dart';

/// How many comment blocks are still over the ceiling — a ratchet, not a
/// target: it can only go down, every trim lowers it in the diff, and
/// nothing new gets in.
const commentBudget = 0;

/// Past twelve lines, the paragraph belongs in `docs/technical/`: the ceiling
/// is the exception's, not the rule's (`.ai/skills/tom-comments/SKILL.md`).
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
