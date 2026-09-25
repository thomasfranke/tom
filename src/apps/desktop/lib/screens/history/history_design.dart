/// What the design fixes about the history panel.
library;

/// The numbers of the `file-history` wireframe
/// (`docs/product/git-workflow/file-history/mocks/file-history.excalidraw`),
/// measured from the top of the panel.
///
/// [meta] is the one size that is not the wireframe's: it draws that line
/// at 13, and the sha, the author and the age do not fit 248 points at 13.
abstract final class HistoryDesign {
  /// Panel top to the caption's box.
  static const double captionTop = 18;

  /// Panel top to the first entry.
  static const double entriesTop = 50;

  /// The pitch between entries, also the list's item extent.
  static const double entryPitch = 56;

  /// An entry's box, shorter than the pitch.
  static const double entryHeight = 44;

  /// Corner radius of a hovered row and of the one being read.
  static const double radius = 6;

  /// The panel's caption.
  static const double caption = 10;

  /// A commit's subject.
  static const double subject = 13;

  /// The line under it: the sha, who wrote it, and when.
  static const double meta = 11;

  /// Subject to that line.
  static const double metaGap = 4;
}
