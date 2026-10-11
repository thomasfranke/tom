/// Telling code apart from prose at a place in the source.
library;

/// Whether an offset in a markdown buffer sits inside code: a fenced block,
/// an indented one, or an inline span on the offset's own line.
///
/// Read from the text alone, because it is asked on every keystroke and the
/// parsed document lags the buffer; what offers prose help asks it first, so
/// a `[[` typed inside code is code (`docs/product/wikilinks/doc.md`).
final class MarkdownCodeService {
  /// Creates the service.
  const MarkdownCodeService();

  /// A line that opens or closes a fence, inside a quote or a list too.
  static final RegExp _fence = RegExp(r'^(?:[ \t]*>)*[ \t]*(`{3,}|~{3,})(.*)$');

  /// Whether [offset] in [buffer] is inside code.
  ///
  /// A fence's own lines count as its inside, and one never closed runs to
  /// the end, as CommonMark has it. A backtick with no partner on the line is
  /// a span still being typed, so what follows it is code.
  bool isInsideCode(String buffer, int offset) {
    if (offset < 0 || offset > buffer.length) {
      return false;
    }
    final int lineStart = offset == 0
        ? 0
        : buffer.lastIndexOf('\n', offset - 1) + 1;
    if (_insideFence(buffer, lineStart) || _isIndented(buffer, lineStart)) {
      return true;
    }
    final int newline = buffer.indexOf('\n', lineStart);
    final String line = buffer.substring(
      lineStart,
      newline < 0 ? buffer.length : newline,
    );
    return _insideSpan(line, offset - lineStart);
  }

  /// Whether the line starting at [target] belongs to a fenced block.
  static bool _insideFence(String buffer, int target) {
    String? open;
    int start = 0;
    while (start <= target) {
      final int newline = buffer.indexOf('\n', start);
      final int end = newline < 0 ? buffer.length : newline;
      final String line = buffer.substring(start, end);
      final RegExpMatch? fence = _fence.firstMatch(line.trimRight());
      if (open == null) {
        // A backtick fence's info string holds no backtick; one that does is
        // inline code, not a fence.
        if (fence != null &&
            !(fence[1]!.startsWith('`') && fence[2]!.contains('`'))) {
          open = fence[1];
        }
        if (start == target) {
          return open != null;
        }
      } else {
        if (start == target) {
          return true;
        }
        if (fence != null &&
            fence[1]![0] == open[0] &&
            fence[1]!.length >= open.length &&
            fence[2]!.trim().isEmpty) {
          open = null;
        }
      }
      if (newline < 0) {
        return false;
      }
      start = newline + 1;
    }
    return false;
  }

  /// A line indented far enough to be code: four spaces, or a tab.
  static final RegExp _indent = RegExp(r'^(?: {4}|\t| {1,3}\t)');

  /// A line that starts a list item.
  static final RegExp _item = RegExp(r'^ {0,3}(?:[-*+]|\d{1,9}[.)])(?: |\t|$)');

  /// Whether the line starting at [target] belongs to an indented code block.
  ///
  /// Walked upwards: indented lines and blank ones may be the block's own,
  /// and the first line that is neither decides — after a paragraph with no
  /// blank line between, the indent is a continuation; under a list item it
  /// is the item's text. Code nested inside an item is not recognised.
  static bool _isIndented(String buffer, int target) {
    String lineAt(int start) {
      final int newline = buffer.indexOf('\n', start);
      return buffer.substring(start, newline < 0 ? buffer.length : newline);
    }

    if (!_indent.hasMatch(lineAt(target)) || lineAt(target).trim().isEmpty) {
      return false;
    }
    bool blankBetween = false;
    int start = target;
    while (start > 0) {
      start = start < 2 ? 0 : buffer.lastIndexOf('\n', start - 2) + 1;
      final String line = lineAt(start);
      if (line.trim().isEmpty) {
        blankBetween = true;
        continue;
      }
      if (_indent.hasMatch(line)) {
        blankBetween = false;
        continue;
      }
      return blankBetween && !_item.hasMatch(line);
    }
    return true;
  }

  /// Whether [at] in [line] falls inside an inline code span.
  ///
  /// A span closes on a run of exactly as many backticks as opened it; a
  /// backslash outside a span keeps the character after it literal.
  static bool _insideSpan(String line, int at) {
    int i = 0;
    while (i < line.length) {
      if (line[i] == r'\') {
        i += 2;
        continue;
      }
      if (line[i] != '`') {
        i++;
        continue;
      }
      final int open = i;
      while (i < line.length && line[i] == '`') {
        i++;
      }
      if (at < i) {
        return false;
      }
      final int? close = _closingRun(line, i, i - open);
      if (close == null || at <= close) {
        return true;
      }
      i = close + (i - open);
    }
    return false;
  }

  /// Where the run of exactly [length] backticks after [from] starts.
  static int? _closingRun(String line, int from, int length) {
    int j = from;
    while (j < line.length) {
      if (line[j] != '`') {
        j++;
        continue;
      }
      final int start = j;
      while (j < line.length && line[j] == '`') {
        j++;
      }
      if (j - start == length) {
        return start;
      }
    }
    return null;
  }
}
