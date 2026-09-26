import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/search/search_marks.dart';

void main() {
  /// The stretches [terms] marks in [excerpt].
  List<String> marked(String excerpt, String terms) => <String>[
    for (final ExcerptRun run in markedRuns(excerpt, terms))
      if (run.marked) run.text,
  ];

  /// The excerpt put back together, which no marking may change.
  String whole(String excerpt, String terms) =>
      markedRuns(excerpt, terms).map((ExcerptRun run) => run.text).join();

  test('with nothing typed nothing is marked', () {
    expect(markedRuns('a rendered diff', ''), <ExcerptRun>[
      (text: 'a rendered diff', marked: false),
    ]);
  });

  test('a word that was typed is marked wherever it appears', () {
    expect(
      marked('the rendered diff of a rendered document', 'rendered'),
      <String>['rendered', 'rendered'],
    );
  });

  test('case is not what a match is about', () {
    expect(marked('Rendered diffs', 'rendered'), <String>['Rendered']);
  });

  test('a half-typed word marks the word it is the start of', () {
    // The index matches a prefix on the last word, and the marking follows
    // the typing rather than waiting for it to finish.
    expect(marked('the rendered diff', 'rend'), <String>['rendered']);
  });

  test('a word only ending the same way is not a match', () {
    expect(marked('surrendered', 'rendered'), isEmpty);
  });

  test('every word has to be marked, in any order', () {
    expect(marked('a diff, rendered', 'rendered diff'), <String>[
      'diff',
      'rendered',
    ]);
  });

  test('punctuation is a separator, never something typed', () {
    expect(marked('a rendered "diff"', '"diff"'), <String>['diff']);
  });

  test('the excerpt itself survives the marking, character for character', () {
    const String excerpt = '…the rendered diff — "one container per block"…';

    expect(whole(excerpt, 'rendered block'), excerpt);
  });
}
