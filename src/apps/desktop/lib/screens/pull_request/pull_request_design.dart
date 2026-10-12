/// The pull request page's numbers, measured off
/// `design/screens/desktop/git-pull-request/writing-a-pull-request-dark.svg`.
library;

/// Where the page's three surfaces sit: the row in the tree, the status
/// row where the tabs were, and the right column.
abstract final class PullRequestDesign {
  /// The tree row's top, inside the tree's body.
  static const double rowTop = 4;

  /// The tree row: two points taller than a file's, because it is not one.
  static const double rowHeight = 28;

  /// What an unavailable row grows by to carry its reason, and what the tree
  /// moves down (`git-pull-request/pull-request-row-states-dark.svg`).
  static const double reasonHeight = 12;

  /// An unavailable row's name line: the name and glyph centred in it.
  static const double nameLine = 22;

  /// An unavailable row's reason, from the row's top.
  static const double reasonTop = 22;

  /// Row to the hairline under it.
  static const double ruleGap = 8;

  /// Hairline to the first row of the tree.
  static const double afterRule = 14;

  /// The hairline's inset from the column's edges.
  static const double ruleInset = 7;

  /// The tree row's glyph, from the column's edge.
  static const double glyphLeft = 16;

  /// The tree row's label, from the column's edge.
  static const double labelLeft = 36;

  /// The branch glyph, in the row and in the base control.
  static const double glyph = 12;

  /// The status row's sentence, from the document's edge.
  static const double statusText = 36;

  /// The right column's first caption, below the switch.
  static const double captionTop = 13;

  /// A caption's line.
  static const double captionHeight = 16;

  /// The base control.
  static const double selectHeight = 32;

  /// The base control to the next caption.
  static const double afterSelect = 19;

  /// Caption to the branch's numbers, and between their two lines.
  static const double lineGap = 2;

  /// The numbers to the first commit.
  static const double commitsTop = 15;

  /// One commit: subject and age.
  static const double commitPitch = 44;

  /// A commit's subject, from the column's inset.
  static const double commitText = 20;

  /// The commit node's box.
  static const double node = 14;

  /// The action's foot, from the bottom of the column.
  static const double footBottom = 31;

  /// The overview's reading time.
  static const double headline = 26;

  /// The column's top to the reading time.
  static const double headlineTop = 16;

  /// Between two of the overview's sections.
  static const double sectionGap = 16;

  /// One folder's row in the overview.
  static const double folderPitch = 22;

  /// A commit's subject.
  static const double subject = 12;

  /// A commit's age, and the line counts.
  static const double small = 11;
}
