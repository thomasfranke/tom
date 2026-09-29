/// Finding words in one document's text, and replacing them.
library;

import 'package:tom_domain/src/search/occurrence_value_object.dart';

/// Where the words are in a text, and what the text becomes without them.
///
/// A domain service because the rule belongs to no single type, and it holds
/// nothing: it is handed the text every time, which is what keeps an
/// occurrence from outliving the buffer it was found in
/// (`docs/product/search/in-the-document/doc.md`).
final class DocumentSearchService {
  /// Creates the service.
  const DocumentSearchService();

  /// Every place [terms] appears in [text], in the order they appear.
  ///
  /// Case-insensitive, because somebody looking for a word is not spelling
  /// it. Empty terms find nothing rather than everything.
  List<OccurrenceValueObject> find(String text, String terms) {
    final String wanted = terms.trim();
    if (wanted.isEmpty || text.isEmpty) {
      return const <OccurrenceValueObject>[];
    }
    final String haystack = text.toLowerCase();
    final String needle = wanted.toLowerCase();
    final List<(int, String)> headings = _headings(text);

    final List<OccurrenceValueObject> found = <OccurrenceValueObject>[];
    int line = 0;
    int scanned = 0;
    int heading = -1;
    int at = haystack.indexOf(needle);
    while (at >= 0) {
      // Lines counted forward from the last match rather than by splitting
      // the whole text again per match.
      line += '\n'.allMatches(text.substring(scanned, at)).length;
      scanned = at;
      // The headings are in order and so are the matches, so this pointer
      // only ever moves forward.
      while (heading + 1 < headings.length && headings[heading + 1].$1 <= at) {
        heading++;
      }
      final (String excerpt, int within) = _excerpt(text, at, needle.length);
      found.add(
        OccurrenceValueObject(
          start: at,
          matched: text.substring(at, at + needle.length),
          line: line,
          heading: heading < 0 ? '' : headings[heading].$2,
          excerpt: excerpt,
          excerptStart: within,
        ),
      );
      // Past this match, so overlapping runs of the same word are counted
      // once each rather than once per character.
      at = haystack.indexOf(needle, at + needle.length);
    }
    return List<OccurrenceValueObject>.unmodifiable(found);
  }

  /// [text] with [occurrence] replaced by [replacement], or null when the
  /// text there is no longer what the occurrence said.
  ///
  /// Null is the answer to a stale occurrence, and it is an ordinary one:
  /// the buffer moved under it, so the caller drops it rather than writing
  /// into the middle of something else.
  String? replace(
    String text,
    OccurrenceValueObject occurrence,
    String replacement,
  ) {
    if (occurrence.end > text.length) {
      return null;
    }
    if (text.substring(occurrence.start, occurrence.end) !=
        occurrence.matched) {
      return null;
    }
    return text.replaceRange(occurrence.start, occurrence.end, replacement);
  }

  /// [text] with every occurrence of [terms] replaced by [replacement].
  ///
  /// Found again here rather than taking a list: a caller holding
  /// occurrences from before an edit would have every one of them stale, and
  /// this is the operation with the most text to corrupt.
  String replaceAll(String text, String terms, String replacement) {
    final List<OccurrenceValueObject> found = find(text, terms);
    final StringBuffer written = StringBuffer();
    int taken = 0;
    for (final OccurrenceValueObject each in found) {
      written
        ..write(text.substring(taken, each.start))
        ..write(replacement);
      taken = each.end;
    }
    written.write(text.substring(taken));
    return written.toString();
  }

  /// Where each ATX heading starts, and what it says.
  ///
  /// Read off the text rather than off a parsed document: this service is
  /// handed a buffer mid-edit, where a heading may be half-typed and no AST
  /// exists yet.
  static List<(int, String)> _headings(String text) {
    final List<(int, String)> found = <(int, String)>[];
    for (final Match line in RegExp(
      r'^ {0,3}(#{1,6})[ \t]+(.*)$',
      multiLine: true,
    ).allMatches(text)) {
      found.add((line.start, line.group(2)!.trim()));
    }
    return found;
  }

  /// The match in its line, cut to something a row can hold.
  ///
  /// Returns the text and where the match sits inside it. Built by pieces
  /// around the match rather than by trimming the result, because a trim
  /// after the fact moves the offset and nothing would notice.
  static (String, int) _excerpt(String text, int at, int length) {
    final int from = text.lastIndexOf('\n', at) + 1;
    final int lineEnd = switch (text.indexOf('\n', at)) {
      -1 => text.length,
      final int it => it,
    };
    final bool cutFront = at - from > _before;
    final int start = cutFront ? _wordStart(text, at - _before, from) : from;
    final bool cutBack = lineEnd - start > _window;
    final int end = cutBack ? _atLeast(start + _window, at + length) : lineEnd;
    final String head = text.substring(start, at).trimLeft();
    final String tail = text.substring(at + length, end).trimRight();
    final String matched = text.substring(at, at + length);
    return (
      '${cutFront ? '…' : ''}$head$matched$tail${cutBack ? '…' : ''}',
      (cutFront ? 1 : 0) + head.length,
    );
  }

  /// Never cut the match itself out of its own excerpt.
  static int _atLeast(int end, int match) => end < match ? match : end;

  /// The start of the word [at] falls inside, never before [floor].
  ///
  /// A cut through the middle of a word reads as a misspelling rather than
  /// as an excerpt, and the ellipsis does not save it.
  static int _wordStart(String text, int at, int floor) {
    int start = at;
    while (start > floor && text[start - 1] != ' ' && text[start - 1] != '\t') {
      start--;
    }
    return start;
  }

  /// How much of the line before the match is kept.
  static const int _before = 40;

  /// How much of it is kept in all — two rendered lines at the row's width.
  static const int _window = 120;
}
