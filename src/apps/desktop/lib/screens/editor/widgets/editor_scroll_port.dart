/// A source pane's end of the link between the two panes of `Split`.
library;

import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show ScrollPosition;
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';

/// Reads the line a source pane shows at its top, and takes it to another.
///
/// Lines are fractional (`12.4`), and the pane wraps words, so a line is not
/// a fixed number of pixels: where a line is comes from the editor's own
/// layout, which `takeLines` hands over, and a line that is not laid out yet
/// — far from the screen — is reached by steps that each frame corrects.
///
/// What this pane was told to follow it never reports back: every scroll it
/// makes meanwhile is its own (`_following`).
final class EditorScrollPort {
  /// Listens to [scroll]; [lineCount] is how many lines the text has.
  EditorScrollPort({required this.scroll, required this.lineCount}) {
    scroll.verticalScroller.addListener(_scrolled);
  }

  /// How many frames a far line may take to be built and reached.
  static const int maxSettles = 10;

  /// The editor's scroll position.
  final CodeScrollController scroll;

  /// How many lines the text has now.
  final int Function() lineCount;

  late final ScrollPane _pane = (read: readLine, follow: _follow);

  DocumentScrollLink? _link;
  CodeIndicatorValueNotifier? _lines;
  double? _target;
  bool _following = false;
  bool _publishQueued = false;
  bool _isDisposed = false;

  /// The preview beside this pane, or null while it has the area to itself.
  DocumentScrollLink? get link => _link;

  set link(DocumentScrollLink? next) {
    if (identical(next, _link)) {
      return;
    }
    _link?.detachSource(_pane);
    _link = next;
    next?.attachSource(_pane);
  }

  /// The editor's layout, which says where each line is drawn.
  ///
  /// Handed over once, inside the editor's own build; the first time, the
  /// pane tells the preview where it is, since nothing has scrolled yet.
  void takeLines(CodeIndicatorValueNotifier next) {
    final bool isFirst = _lines == null;
    _lines = next;
    if (isFirst) {
      _scrolled();
    }
  }

  /// The line at the top of the pane; null before the first layout.
  double? readLine() {
    final List<CodeLineRenderParagraph>? shown = _lines?.value?.paragraphs;
    if (shown == null) {
      return null;
    }
    for (final CodeLineRenderParagraph line in shown) {
      if (line.bottom > 0.5) {
        final double height = line.height <= 0 ? 1 : line.height;
        return line.index + (-line.top / height).clamp(0.0, 1.0);
      }
    }
    return null;
  }

  void _follow(double line) {
    _target = line;
    _following = true;
    _settle(0);
  }

  void _settle(int attempt) {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        final double? line = _target;
        if (_isDisposed ||
            line == null ||
            !scroll.verticalScroller.hasClients) {
          if (_isDisposed || line == null || attempt >= maxSettles) {
            _following = false;
            return;
          }
          _settle(attempt + 1);
          return;
        }
        final ScrollPosition position = scroll.verticalScroller.position;
        final double? exact = _pixelsOf(line, position);
        if (exact != null) {
          final double clamped = exact.clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          // Where it is already, or as near as the document's ends allow.
          if ((clamped - position.pixels).abs() < 0.5 ||
              attempt >= maxSettles) {
            _target = null;
            _following = false;
            return;
          }
          // The editor measures the lines it has not laid out as it goes, so
          // what was at that offset a frame ago may not be now: jump, then
          // look again until the line stays put.
          position.jumpTo(clamped);
          _settle(attempt + 1);
          return;
        }
        if (attempt >= maxSettles) {
          _target = null;
          _following = false;
          return;
        }
        // Not laid out: a step towards it, by the lines still to go at the
        // height of the ones on screen, which lays more of the way out; the
        // next frame measures again, and each step is nearer than the last.
        final List<CodeLineRenderParagraph> shown =
            _lines?.value?.paragraphs ?? const <CodeLineRenderParagraph>[];
        final double? now = readLine();
        final double next;
        if (now == null || shown.isEmpty) {
          final int total = math.max(1, lineCount());
          next =
              line /
              total *
              (position.maxScrollExtent + position.viewportDimension);
        } else {
          final double average =
              shown.fold<double>(
                0,
                (double sum, CodeLineRenderParagraph it) => sum + it.height,
              ) /
              shown.length;
          next = position.pixels + (line - now) * average;
        }
        position.jumpTo(
          next.clamp(position.minScrollExtent, position.maxScrollExtent),
        );
        _settle(attempt + 1);
      })
      ..ensureVisualUpdate();
  }

  /// Where [line] is in pixels, when the editor has laid it out.
  double? _pixelsOf(double line, ScrollPosition position) {
    final int index = line.floor();
    for (final CodeLineRenderParagraph shown
        in _lines?.value?.paragraphs ?? const <CodeLineRenderParagraph>[]) {
      if (shown.index == index) {
        return position.pixels + shown.top + (line - index) * shown.height;
      }
    }
    return null;
  }

  void _scrolled() {
    if (_following || _publishQueued || _isDisposed) {
      return;
    }
    _publishQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _publishQueued = false;
      if (_isDisposed || _following) {
        return;
      }
      if (readLine() case final double line) {
        _link?.sourceMoved(line);
      }
    });
  }

  /// Leaves the link and stops listening.
  void dispose() {
    _isDisposed = true;
    _link?.detachSource(_pane);
    _link = null;
    scroll.verticalScroller.removeListener(_scrolled);
  }
}
