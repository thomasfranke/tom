/// What the design fixes about the account button and its popover.
library;

/// The numbers of the `21 · Screens: Account` boards — `account-signed-out`,
/// `account-signed-in`, `choosing-an-account` — at 1440 × 900.
abstract final class AccountDesign {
  /// The button, a circle at the bar's far right.
  static const double button = 24;

  /// The person drawn when nobody is named.
  static const double person = 14;

  /// The button's bottom edge to the popover's top.
  static const double gap = 6;

  /// The popover.
  static const double width = 280;

  /// How far the popover's right edge runs past the button's: the board
  /// draws the card at 1148 + 280 under a button ending at 1426.
  static const double overhang = 2;

  /// Its corner.
  static const double radius = 10;

  /// What it keeps around its contents.
  static const double inset = 16;

  /// The content's width.
  static const double content = width - inset * 2;

  /// Above and below each rule between two sections.
  static const double ruleGap = 14;

  /// A section's caption.
  static const double caption = 10.5;

  /// Its tracking.
  static const double captionSpacing = 0.6;

  /// A caption to what it heads: 7 under `GITHUB` and `THIS REPOSITORY`,
  /// where the boards read 22 between the inks.
  static const double captionToContent = 7;

  /// The same under `COMMITS AS`, where the boards read 23.
  static const double captionToIdentity = 8;

  /// The card's last line to its foot: the board's 13 between the ink and
  /// the stroke.
  static const double bottomInset = 10;

  /// Every line of plain text.
  static const double text = 12.5;

  /// The smaller, muted lines.
  static const double small = 11.5;

  /// The pitch of the two identity lines.
  static const double line = 18;

  /// The account select, and a row of its menu.
  static const double selectHeight = 32;

  /// The select's corner.
  static const double selectRadius = 6;

  /// The avatar inside the select and the menu.
  static const double avatar = 20;

  /// The select's edge to the avatar.
  static const double avatarInset = 6;

  /// The select's edge to the login.
  static const double loginInset = 34;

  /// The login to `via gh`.
  static const double viaGap = 6;

  /// The chevron.
  static const double chevron = 10;

  /// The chevron's left edge from the select's right edge.
  static const double chevronInset = 16;

  /// The select's bottom to the menu's top.
  static const double menuGap = 4;

  /// The menu's corner.
  static const double menuRadius = 8;

  /// Above the menu's first row and below its last.
  static const double menuPad = 4;

  /// The chosen row's tick.
  static const double tick = 12;

  /// The select to the caption under it.
  static const double selectToNote = 6;

  /// The caption under the select to the rule.
  static const double noteToRule = 16;

  /// The repository's link glyph, and its gap after the name.
  static const double external = 10;

  /// The name to its glyph.
  static const double externalGap = 6;

  /// The repository's name to the grid's labels, top to top: the boards
  /// read 28 between the two inks, which this spacing lands on.
  static const double linkToGrid = 30;

  /// A column label to its mark, top to top: 21 here puts a dash 24 under
  /// its label's ink, as `account-no-credentials` does.
  static const double labelToMark = 21;

  /// A wrapped hint's line, in `Account` all three hints.
  static const double hintLine = 14;

  /// Above the card's first caption, one less than the sides: the boards'
  /// first caption sits a point higher than the stroke-less inset gives.
  static const double topInset = inset - 2;

  /// The `No GitHub credentials` line to the hint under it.
  static const double noteGap = 4;

  /// A granted column's tick.
  static const double check = 12;

  /// An unknown or refused column's dash.
  static const double dash = 10;

  /// The grid to the note under it.
  static const double gridToNote = 11;
}
