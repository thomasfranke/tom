/// The two panes of `Split`, kept at one place of the document.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One pane's two ends: where it is now, and how it is told to go somewhere.
///
/// Positions are *lines* of the source, fractional — `12.4` is two fifths of
/// the way down line 12 — because that is the one coordinate both panes can
/// speak (the preview maps it to a block with `ScrollMapService`).
typedef ScrollPane = ({double? Function() read, void Function(double) follow});

/// Keeps the source and the preview where each other is, whichever one is
/// scrolled.
///
/// A pane **attaches while it is on screen beside the other** and detaches
/// when it is not, so with one pane there is nothing to follow. A pane that
/// is told to follow must not tell the other back: each pane guards its own
/// programmatic scroll, and the link only carries the user's.
final class DocumentScrollLink {
  final List<ScrollPane> _sources = <ScrollPane>[];
  final List<ScrollPane> _previews = <ScrollPane>[];

  ScrollPane? get _source => _sources.isEmpty ? null : _sources.last;
  ScrollPane? get _preview => _previews.isEmpty ? null : _previews.last;

  /// Whether both panes are on screen.
  bool get isLinked => _source != null && _preview != null;

  /// The line the source shows at its top, or null while it is not on screen.
  double? get sourceLine => _source?.read();

  /// The line the preview shows at its top, or null while it is not on
  /// screen.
  double? get previewLine => _preview?.read();

  /// A source pane is now beside the preview.
  void attachSource(ScrollPane pane) {
    _sources.add(pane);
    _align();
  }

  /// The source pane left, or went under another.
  void detachSource(ScrollPane pane) => _sources.remove(pane);

  /// A preview is now beside the source.
  void attachPreview(ScrollPane pane) {
    _previews.add(pane);
    _align();
  }

  /// The preview left.
  void detachPreview(ScrollPane pane) => _previews.remove(pane);

  /// The source was scrolled by somebody: the preview follows to [line].
  void sourceMoved(double line) => _preview?.follow(line);

  /// The preview was scrolled by somebody: the source follows to [line].
  void previewMoved(double line) => _source?.follow(line);

  /// The preview takes the source's place when the second of them arrives.
  void _align() {
    if (!isLinked) {
      return;
    }
    final double? line = _source!.read();
    if (line != null) {
      _preview!.follow(line);
    }
  }
}

/// The one link, which lives as long as the window's space does.
final Provider<DocumentScrollLink> documentScrollLinkProvider =
    Provider<DocumentScrollLink>((Ref ref) => DocumentScrollLink());
