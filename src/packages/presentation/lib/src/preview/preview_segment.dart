/// One stretch of a conflicted document, ready to be drawn.
library;

import 'package:tom_domain/tom_domain.dart';

/// Either prose to render, or a conflict to offer the choice on.
///
/// A conflicted document is drawn as a sequence of these rather than as one
/// parse, because git marks whole lines while markdown ends a paragraph at a
/// blank one: cutting at the markers is what keeps every marker off the
/// screen without losing a word of what the document says
/// (`docs/product/editor/conflicted-document/doc.md`).
///
/// `sealed`, so a surface that forgets one of the two does not compile.
sealed class PreviewSegment {
  const PreviewSegment();
}

/// A stretch with no conflict, parsed the way any document is.
final class PreviewProse extends PreviewSegment {
  /// Wraps [document].
  const PreviewProse(this.document);

  /// The blocks to draw.
  final ParsedDocumentValueObject document;
}

/// A conflict, with each side parsed so the preview can render it as
/// markdown rather than as the raw text the source pane shows.
final class PreviewConflict extends PreviewSegment {
  /// Wraps [region], with [current] and [incoming] already parsed.
  const PreviewConflict({
    required this.region,
    required this.current,
    required this.incoming,
  });

  /// Where the conflict is, so a choice knows what span to rewrite.
  final ConflictRegionValueObject region;

  /// The side already on this branch.
  final ParsedDocumentValueObject current;

  /// The side being merged in.
  final ParsedDocumentValueObject incoming;
}
