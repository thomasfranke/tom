/// Which stretches of an excerpt are the words somebody typed.
library;

/// A stretch of an excerpt, drawn as the match or as the text around it.
typedef ExcerptRun = ({String text, bool marked});

/// Words, the way the index takes them out of what was typed.
final RegExp _word = RegExp(r'[\p{L}\p{N}_]+', unicode: true);

/// [excerpt] cut into runs, marking the words [terms] asked for.
///
/// A word counts as asked for when it *starts* with one of them, because
/// that is what the index matched on — the last word half-typed included
/// (`SearchIndex.find`). The mark is the panel's own reading of the words,
/// not something the index reports back.
List<ExcerptRun> markedRuns(String excerpt, String terms) {
  final List<String> typed = _word
      .allMatches(terms.toLowerCase())
      .map((RegExpMatch match) => match[0]!)
      .toList();
  if (typed.isEmpty || excerpt.isEmpty) {
    return <ExcerptRun>[(text: excerpt, marked: false)];
  }
  final List<ExcerptRun> runs = <ExcerptRun>[];
  int cursor = 0;
  for (final RegExpMatch match in _word.allMatches(excerpt)) {
    final String word = excerpt.substring(match.start, match.end).toLowerCase();
    if (!typed.any(word.startsWith)) {
      continue;
    }
    if (match.start > cursor) {
      runs.add((text: excerpt.substring(cursor, match.start), marked: false));
    }
    runs.add((text: excerpt.substring(match.start, match.end), marked: true));
    cursor = match.end;
  }
  if (cursor < excerpt.length) {
    runs.add((text: excerpt.substring(cursor), marked: false));
  }
  return runs;
}
