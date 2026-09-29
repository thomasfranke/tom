import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const DocumentSearchService service = DocumentSearchService();

  List<int> startsIn(String text, String terms) => service
      .find(text, terms)
      .map((OccurrenceValueObject each) => each.start)
      .toList();

  group('finding', () {
    test('every place the words appear, in order', () {
      expect(startsIn('a palette, a palette', 'palette'), <int>[2, 13]);
    });

    test('however the text capitalised it', () {
      final List<OccurrenceValueObject> found = service.find(
        'Palette and palette',
        'PALETTE',
      );

      expect(found.length, 2);
      expect(
        found.map((OccurrenceValueObject each) => each.matched),
        <String>['Palette', 'palette'],
        reason: 'it carries the text as written, not as searched',
      );
    });

    test('an occurrence knows which line it is on', () {
      final List<OccurrenceValueObject> found = service.find(
        'one\ntwo\nthree palette\n',
        'palette',
      );

      expect(found.single.line, 2);
    });

    test('a run of the same word is counted once each, not per character', () {
      expect(startsIn('aaaa', 'aa'), <int>[0, 2]);
    });

    test('nothing to look for finds nothing, rather than everything', () {
      expect(service.find('a palette', ''), isEmpty);
      expect(service.find('a palette', '   '), isEmpty);
    });

    test('an empty document has nothing in it', () {
      expect(service.find('', 'palette'), isEmpty);
    });
  });

  group('what an occurrence shows', () {
    const String document = '''
# Visual language

Values live in tools/palette.py.

## Roles, never shades

A role survives a palette change.
''';

    test('it carries the heading it sits under', () {
      final List<OccurrenceValueObject> found = service.find(
        document,
        'palette',
      );

      expect(found.map((OccurrenceValueObject each) => each.heading), <String>[
        'Visual language',
        'Roles, never shades',
      ]);
    });

    test('one above the first heading carries none', () {
      const String above = 'a palette\n\n# Later';

      expect(service.find(above, 'palette').single.heading, '');
    });

    test('a match inside a heading is under that one, not the one before', () {
      expect(
        service.find('# One\n\n## Two palette\n', 'palette').single.heading,
        'Two palette',
      );
    });

    test('the excerpt is the line, holding the match where it says', () {
      final OccurrenceValueObject found = service
          .find(document, 'palette')
          .first;

      expect(found.excerpt, 'Values live in tools/palette.py.');
      expect(
        found.excerpt.substring(
          found.excerptStart,
          found.excerptStart + found.matched.length,
        ),
        'palette',
      );
    });

    test('a long line is cut with an ellipsis at each cut end', () {
      final OccurrenceValueObject found = service
          .find('${'word ' * 30}palette${' more' * 30}', 'palette')
          .single;

      expect(found.excerpt, startsWith('…'));
      expect(found.excerpt, endsWith('…'));
      expect(
        found.excerpt.substring(
          found.excerptStart,
          found.excerptStart + found.matched.length,
        ),
        'palette',
        reason: 'the offset must survive both cuts',
      );
    });

    test('and it is cut between words, never through one', () {
      final OccurrenceValueObject found = service
          .find('${'lengthy ' * 12}palette here', 'palette')
          .single;

      expect(
        found.excerpt.substring(1).startsWith('lengthy'),
        isTrue,
        reason: 'a word cut in half reads as a misspelling: ${found.excerpt}',
      );
    });

    test('the line is trimmed of what indents it', () {
      expect(
        service.find('    a palette\n', 'palette').single.excerpt,
        'a palette',
      );
    });
  });

  group('replacing one', () {
    test('the occurrence becomes the replacement', () {
      const String text = 'tools/palette.py';
      final OccurrenceValueObject only = service.find(text, 'palette').single;

      expect(service.replace(text, only, 'swatch'), 'tools/swatch.py');
    });

    test('an empty replacement deletes what matched, and only that', () {
      // The space either side is the document's, not the match's.
      const String text = 'a palette here';
      final OccurrenceValueObject only = service.find(text, 'palette').single;

      expect(service.replace(text, only, ''), 'a  here');
    });

    test('a term typed with space around it is the word, not the space', () {
      const String text = 'a palette here';

      expect(service.find(text, '  palette  ').single.matched, 'palette');
    });

    test('an occurrence the buffer moved is refused, not written', () {
      // The rule the whole design rests on: a stale position does not miss,
      // it writes into the middle of something else
      // (`docs/product/search/replacing/doc.md`).
      const String before = 'aaa palette bbb';
      final OccurrenceValueObject stale = service
          .find(before, 'palette')
          .single;

      // Somebody typed at the start, so everything after moved along.
      const String after = 'XXXXXXXXXX aaa palette bbb';

      expect(service.replace(after, stale, 'swatch'), isNull);
    });

    test('an occurrence past the end of the text is refused', () {
      const String text = 'a palette';
      final OccurrenceValueObject only = service.find(text, 'palette').single;

      expect(service.replace('short', only, 'swatch'), isNull);
    });
  });

  group('replacing all', () {
    test('every occurrence goes, and the rest of the text is untouched', () {
      expect(
        service.replaceAll('a palette and a palette here', 'palette', 'swatch'),
        'a swatch and a swatch here',
      );
    });

    test('a replacement containing the search term does not cascade', () {
      // Replacing `a` with `aa` must not then replace what it just wrote.
      expect(service.replaceAll('a a', 'a', 'aa'), 'aa aa');
    });

    test('the case the text used is what is replaced', () {
      expect(
        service.replaceAll('Palette and palette', 'palette', 'swatch'),
        'swatch and swatch',
      );
    });

    test('nothing to look for changes nothing', () {
      expect(service.replaceAll('a palette', '', 'swatch'), 'a palette');
    });
  });
}
