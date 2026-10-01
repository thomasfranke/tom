import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const MarkdownFormatterService formatter = MarkdownFormatterService();

  /// [command] applied to [text] over the selection between the two `|`.
  ///
  /// Written as a marked-up string because a test that counted offsets by
  /// hand would be a test of the counting.
  FormattedSourceValueObject apply(String text, FormatCommandEnum command) {
    final int start = text.indexOf('|');
    final String once = text.replaceFirst('|', '');
    final int end = once.contains('|') ? once.indexOf('|') : start;
    return formatter.apply(
      once.replaceFirst('|', ''),
      command,
      start: start,
      end: end,
    );
  }

  group('wrapping the selection', () {
    test('bold puts the marks around it and keeps the words selected', () {
      final FormattedSourceValueObject result = apply(
        'a |word| here',
        FormatCommandEnum.bold,
      );

      expect(result.text, 'a **word** here');
      // The words, not the asterisks: the next keystroke replaces what was
      // bolded.
      expect(result.text.substring(result.start, result.end), 'word');
    });

    test('italic and strikethrough are the same shape, other marks', () {
      expect(
        apply('a |word| here', FormatCommandEnum.italic).text,
        'a *word* here',
      );
      expect(
        apply('a |word| here', FormatCommandEnum.strikethrough).text,
        'a ~~word~~ here',
      );
    });

    test('pressed again on its own marks, it takes them off', () {
      // The only way a button can be pressed twice without lying.
      final FormattedSourceValueObject result = apply(
        'a **|word|** here',
        FormatCommandEnum.bold,
      );

      expect(result.text, 'a word here');
      expect(result.text.substring(result.start, result.end), 'word');
    });

    test('with nothing selected it leaves a caret between the marks', () {
      final FormattedSourceValueObject result = apply(
        'a | here',
        FormatCommandEnum.bold,
      );

      expect(result.text, 'a **** here');
      expect(result.isCaret, isTrue);
      expect(result.start, 4);
    });

    test('a few words are inline code, and lines are a fence', () {
      expect(
        apply('a |word| here', FormatCommandEnum.code).text,
        'a `word` here',
      );

      final FormattedSourceValueObject fenced = apply(
        '|one\ntwo|',
        FormatCommandEnum.code,
      );
      expect(fenced.text, '```\none\ntwo\n```');
      expect(fenced.text.substring(fenced.start, fenced.end), 'one\ntwo');
    });
  });

  group('prefixing the lines', () {
    test('a list marks every line the selection touches', () {
      final FormattedSourceValueObject result = apply(
        'o|ne\ntw|o\nthree',
        FormatCommandEnum.list,
      );

      expect(result.text, '- one\n- two\nthree');
    });

    test(
      'the run stays selected, because it is what the next press acts on',
      () {
        final FormattedSourceValueObject result = apply(
          'o|ne\ntw|o',
          FormatCommandEnum.quote,
        );

        expect(result.text.substring(result.start, result.end), '> one\n> two');
      },
    );

    test('pressed again on lines that all have it, it takes it off', () {
      expect(apply('- o|ne\n- tw|o', FormatCommandEnum.list).text, 'one\ntwo');
    });

    test('a run where one line has it is a run being made into a list', () {
      // Not unmade: the press that would toggle it off is the next one.
      expect(
        apply('- o|ne\ntw|o', FormatCommandEnum.list).text,
        '- - one\n- two',
      );
    });

    test(
      'an ordered list counts, which is why its prefix is not a constant',
      () {
        expect(
          apply('o|ne\ntwo\nthre|e', FormatCommandEnum.orderedList).text,
          '1. one\n2. two\n3. three',
        );
      },
    );

    test('a heading, a task and an alert are the same shape', () {
      expect(apply('|a|', FormatCommandEnum.heading).text, '# a');
      expect(apply('|a|', FormatCommandEnum.taskList).text, '- [ ] a');
      expect(apply('|a|', FormatCommandEnum.alert).text, '> [!NOTE] a');
    });
  });

  group('inserting a block', () {
    test('a rule goes on a line of its own, after the caret line', () {
      final FormattedSourceValueObject result = apply(
        'a paragraph|\n\nanother',
        FormatCommandEnum.rule,
      );

      expect(result.text, 'a paragraph\n\n---\n\n\nanother');
      expect(result.isCaret, isTrue);
    });

    test(
      'a table arrives with a header, because an empty one renders as text',
      () {
        expect(
          apply('a|', FormatCommandEnum.table).text,
          'a\n\n| Column | Column |\n|---|---|\n|  |  |\n',
        );
      },
    );

    test('a link wraps the selection and leaves the url to be typed', () {
      final FormattedSourceValueObject result = apply(
        'see |the guide| for more',
        FormatCommandEnum.link,
      );

      expect(result.text, 'see [the guide](url) for more');
      expect(result.text.substring(result.start, result.end), 'the guide');
    });

    test('an image is a link with a bang, and the alt is the selection', () {
      expect(
        apply('|a palette|', FormatCommandEnum.image).text,
        '![a palette](url)',
      );
    });

    test('a footnote is a reference here and a definition at the foot', () {
      // At the foot rather than beside it: that is where a reader of the
      // source expects them and where the parser wants them regardless.
      final FormattedSourceValueObject result = apply(
        'a claim|\n',
        FormatCommandEnum.footnote,
      );

      expect(result.text, 'a claim[^1]\n\n[^1]: \n');
      expect(result.isCaret, isTrue);
    });
  });

  group('offsets it was handed', () {
    test('a selection past the end is clamped, not asserted', () {
      // The selection is the editor's and arrives a frame after the text it
      // was measured against.
      final FormattedSourceValueObject result = formatter.apply(
        'short',
        FormatCommandEnum.bold,
        start: 40,
        end: 90,
      );

      expect(result.text, 'short****');
    });

    test('a backwards selection is read forwards', () {
      final FormattedSourceValueObject result = formatter.apply(
        'a word here',
        FormatCommandEnum.bold,
        start: 6,
        end: 2,
      );

      expect(result.text, 'a **word** here');
    });
  });
}
