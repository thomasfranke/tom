/// What the design fixes about the history panel.
library;

/// The numbers the history panel is drawn against.
///
/// The `file-history` wireframe
/// (`docs/product/git-workflow/file-history/mocks/file-history.excalidraw`),
/// measured from the top of the panel — the shell is what puts it in the
/// column.
///
/// **One size is not the wireframe's.** It draws the line under a subject at
/// 13 carrying a sha and a relative time; the product also asks for *who*
/// (`docs/product/git-workflow/file-history/doc.md`), and three facts at 13
/// do not fit 248 points. So the meta line is [meta], the size the status
/// bar already uses for exactly this kind of sentence.
abstract final class HistoryDesign {
  /// Panel top to the caption's baseline box.
  static const double captionTop = 18;

  /// Panel top to the first entry.
  static const double entriesTop = 50;

  /// The pitch between entries, which is also the list's item extent.
  static const double entryPitch = 56;

  /// An entry's own box, shorter than the pitch.
  static const double entryHeight = 44;

  /// Corner radius of the row a pointer is over, and of the one being read.
  static const double radius = 6;

  /// The panel's own caption.
  static const double caption = 10;

  /// A commit's subject.
  static const double subject = 13;

  /// The line under it: the sha, who wrote it, and when.
  static const double meta = 11;

  /// Subject to that line.
  static const double metaGap = 4;
}
