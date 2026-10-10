import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const MarkdownCodeService service = MarkdownCodeService();

  /// Whether the `|` in [marked] sits inside code; the `|` is not in the text.
  bool inside(String marked) =>
      service.isInsideCode(marked.replaceFirst('|', ''), marked.indexOf('|'));

  /// Each case: the source with its caret, the answer, and why.
  void table(List<(String, bool, String)> cases) {
    for (final (String marked, bool expected, String why) in cases) {
      test(why, () => expect(inside(marked), expected, reason: marked));
    }
  }

  group('a fenced block', () {
    table(<(String, bool, String)>[
      ('plain |text', false, 'prose is not code'),
      ('```\n|code\n```', true, 'inside backticks'),
      ('~~~\n|code\n~~~', true, 'inside tildes'),
      ('```dart\nvar a = |1;\n```', true, 'with an info string'),
      ('```\ncode\n```\n|after', false, 'after it closes'),
      ('|before\n```\ncode\n```', false, 'before it opens'),
      ('```\n|never closed', true, 'one never closed runs to the end'),
      ('```\n\n\n|far below', true, 'blank lines do not close it'),
      ('```|', true, 'on its opening line'),
      ('```\ncode\n|```', true, 'on its closing line'),
      ('````\n```\n|still\n````', true, 'a shorter fence does not close it'),
      ('~~~\n```\n|still\n~~~', true, 'the other fence does not close it'),
      ('```\na\n```\ntext\n```\n|b', true, 'inside a second one'),
      ('```\na\n```\n```\nb\n```\n|c', false, 'after a second one'),
      ('> ```\n> |quoted', true, 'inside a quote'),
      ('- item\n  ```\n  |listed\n  ```', true, 'inside a list item'),
      ('``` `x` ```\n|after', false, 'backticks in the info: inline code'),
      ('```\r\n|code\r\n```', true, 'with Windows line ends'),
    ]);
  });

  group('an inline span', () {
    table(<(String, bool, String)>[
      ('a `co|de` b', true, 'between its backticks'),
      ('a `|code` b', true, 'straight after it opens'),
      ('a `code|` b', true, 'straight before it closes'),
      ('a |`code` b', false, 'before it opens'),
      ('a `code`| b', false, 'after it closes'),
      ('`a` and `b` and |c', false, 'after two spans'),
      ('`a` and `b|`', true, 'inside the second span'),
      ('`` a ` |b ``', true, 'two backticks close only on two'),
      ('a `typing |', true, 'one still being typed'),
      (r'a \`not |code', false, 'an escaped backtick opens nothing'),
      ('`a`\n|next', false, 'a span on another line'),
      ('`a\n|b`', false, 'only the caret\'s own line is read'),
      ('|', false, 'an empty buffer'),
    ]);
  });

  test('an offset outside the buffer is not code', () {
    expect(service.isInsideCode('`a`', 9), isFalse);
    expect(service.isInsideCode('`a`', -1), isFalse);
  });
}
