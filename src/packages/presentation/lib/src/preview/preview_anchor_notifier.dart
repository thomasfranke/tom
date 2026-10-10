/// The heading a followed wikilink asked the preview to show.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preview/preview_anchor.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'preview_anchor_notifier.g.dart';

/// Holds an `#anchor` until its document is drawn, then hands over the
/// heading it names (`docs/product/wikilinks/doc.md`).
///
/// Apart from `PreviewLinksNotifier`'s state, which is worked out again
/// whenever the preview changes — and opening the next document is exactly
/// such a change.
@riverpod
class PreviewAnchorNotifier extends _$PreviewAnchorNotifier {
  /// Turns an anchor and a document's blocks into a heading.
  static const HeadingAnchorService headings = HeadingAnchorService();

  @override
  PreviewAnchor? build() {
    // Another space is another set of documents; nothing waits across it.
    ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    return null;
  }

  /// Asks for the heading [anchor] names once [document] is drawn.
  void request(SpaceRelativePathValueObject document, String anchor) =>
      state = PreviewAnchor(document: document, anchor: anchor);

  /// The heading [shown] holds for the anchor waiting on it, or null when it
  /// names none; the anchor is used up either way, so a later edit that adds
  /// the heading never scrolls anybody.
  ///
  /// An anchor for another document is kept while that one is still on its
  /// way, and dropped once the open document is drawn instead of it.
  BlockValueObject? take(ParsedDocumentValueObject shown) {
    final PreviewAnchor? pending = state;
    if (pending == null) {
      return null;
    }
    final SpaceRelativePathValueObject path = shown.document.path;
    if (pending.document != path) {
      if (ref.read(spaceSessionProvider)?.openDocument == path) {
        state = null;
      }
      return null;
    }
    state = null;
    return headings.headingOf(pending.anchor, shown.blocks);
  }
}
