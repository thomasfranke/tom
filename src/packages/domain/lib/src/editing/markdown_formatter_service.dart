/// Turning a button press into markdown, in the source itself.
library;

import 'package:tom_domain/src/editing/format_command_enum.dart';
import 'package:tom_domain/src/editing/formatted_source_value_object.dart';

/// A command, a document and a selection in, the document back out.
///
/// A domain service because the rule belongs to no document in particular,
/// and it carries no port: rewriting a string is logic, not a capability.
/// **What it writes is the literal syntax** — there is no intermediate
/// format and the source stays the truth
/// (`docs/product/editor/formatting-shortcuts/doc.md`).
///
/// Fifteen commands, three shapes. A **wrap** puts marks on both sides of
/// the selection, a **prefix** puts them at the head of every line it
/// touches, and an **insert** drops a template at the caret. The first two
/// toggle: pressing bold on bold text takes the marks off, which is the only
/// way a button can be pressed twice without lying.
final class MarkdownFormatterService {
  /// Creates the formatter.
  const MarkdownFormatterService();

  /// What each wrapping command puts on both sides.
  static const Map<FormatCommandEnum, String> _wraps =
      <FormatCommandEnum, String>{
        FormatCommandEnum.bold: '**',
        FormatCommandEnum.italic: '*',
        FormatCommandEnum.strikethrough: '~~',
      };

  /// What each prefixing command puts at the head of a line.
  ///
  /// The ordered list is not here: its prefix counts, so it is the one that
  /// cannot be a constant.
  static const Map<FormatCommandEnum, String> _prefixes =
      <FormatCommandEnum, String>{
        FormatCommandEnum.heading: '# ',
        FormatCommandEnum.list: '- ',
        FormatCommandEnum.taskList: '- [ ] ',
        FormatCommandEnum.quote: '> ',
        FormatCommandEnum.alert: '> [!NOTE] ',
      };

  /// [command] applied to [text] over the selection from [start] to [end].
  ///
  /// Offsets are read forwards and clamped rather than asserted: a selection
  /// is the editor's, it is backwards whenever somebody dragged right to
  /// left, and it arrives a frame after the text it was measured against.
  FormattedSourceValueObject apply(
    String text,
    FormatCommandEnum command, {
    required int start,
    required int end,
  }) {
    final int from = (start < end ? start : end).clamp(0, text.length);
    final int to = (start < end ? end : start).clamp(from, text.length);
    if (_wraps[command] case final String marks) {
      return _wrap(text, marks, from, to);
    }
    if (_prefixes[command] case final String prefix) {
      return _prefix(text, (int line) => prefix, from, to);
    }
    return switch (command) {
      FormatCommandEnum.orderedList => _prefix(
        text,
        (int line) => '${line + 1}. ',
        from,
        to,
      ),
      // A selection spanning lines is a block, and a block of code is a
      // fence; a few words inside a sentence are not.
      FormatCommandEnum.code =>
        text.substring(from, to).contains('\n')
            ? _fence(text, from, to)
            : _wrap(text, '`', from, to),
      FormatCommandEnum.table => _insert(text, _table, from, to),
      FormatCommandEnum.rule => _insert(text, '---\n', from, to),
      FormatCommandEnum.link => _around(text, '[', '](url)', from, to),
      FormatCommandEnum.image => _around(text, '![', '](url)', from, to),
      FormatCommandEnum.footnote => _footnote(text, from, to),
      _ => FormattedSourceValueObject(text: text, start: from, end: to),
    };
  }

  /// The skeleton a table button drops in.
  static const String _table =
      '| Column | Column |\n'
      '|---|---|\n'
      '|  |  |\n';

  /// [marks] on both sides, or off them when they are already there.
  FormattedSourceValueObject _wrap(
    String text,
    String marks,
    int from,
    int to,
  ) {
    final int width = marks.length;
    final bool wrapped =
        from >= width &&
        to + width <= text.length &&
        text.substring(from - width, from) == marks &&
        text.substring(to, to + width) == marks;
    if (wrapped) {
      return FormattedSourceValueObject(
        text: text
            .replaceRange(to, to + width, '')
            .replaceRange(from - width, from, ''),
        start: from - width,
        end: to - width,
      );
    }
    final String inside = text.substring(from, to);
    return FormattedSourceValueObject(
      text: text.replaceRange(from, to, '$marks$inside$marks'),
      // The words stay selected, not the marks: the next keystroke replaces
      // what was bolded rather than the asterisks around it.
      start: from + width,
      end: to + width,
    );
  }

  /// What [head] says at the head of every line the selection touches.
  ///
  /// Off again when **every** one of them already has it: a run where one
  /// line is a list item and the others are not is a run somebody is making
  /// into a list, not one they are unmaking.
  FormattedSourceValueObject _prefix(
    String text,
    String Function(int line) head,
    int from,
    int to,
  ) {
    final int first = _lineStart(text, from);
    final int last = _lineEnd(text, to);
    final List<String> lines = text.substring(first, last).split('\n');
    final bool on = lines.indexed.every(
      ((int, String) line) => line.$2.startsWith(head(line.$1)),
    );
    final List<String> written = lines.indexed
        .map(
          ((int, String) line) => on
              ? line.$2.substring(head(line.$1).length)
              : '${head(line.$1)}${line.$2}',
        )
        .toList();
    final String body = written.join('\n');
    final int moved = body.length - (last - first);
    return FormattedSourceValueObject(
      text: text.replaceRange(first, last, body),
      // The whole run stays selected: it is what the next press acts on.
      start: first,
      end: last + moved,
    );
  }

  /// The selected lines between two fences of their own.
  FormattedSourceValueObject _fence(String text, int from, int to) {
    final int first = _lineStart(text, from);
    final int last = _lineEnd(text, to);
    final String body = text.substring(first, last);
    return FormattedSourceValueObject(
      text: text.replaceRange(first, last, '```\n$body\n```'),
      start: first + 4,
      end: first + 4 + body.length,
    );
  }

  /// [before] and [after] around the selection, with it left selected.
  FormattedSourceValueObject _around(
    String text,
    String before,
    String after,
    int from,
    int to,
  ) => FormattedSourceValueObject(
    text: text.replaceRange(
      from,
      to,
      '$before${text.substring(from, to)}$after',
    ),
    start: from + before.length,
    end: to + before.length,
  );

  /// A whole [block] on lines of its own, at the caret's line.
  FormattedSourceValueObject _insert(
    String text,
    String block,
    int from,
    int to,
  ) {
    final int at = _lineEnd(text, to);
    // A blank line before it unless the document starts there: a block that
    // touches the paragraph above is part of that paragraph to a parser.
    final String written = at == 0 ? block : '\n\n$block';
    return FormattedSourceValueObject(
      text: text.replaceRange(at, at, written),
      start: at + written.length,
      end: at + written.length,
    );
  }

  /// A reference where the caret is, and its definition at the foot.
  ///
  /// The definition goes to the end rather than beside the reference,
  /// because that is where a reader of the source expects footnotes and
  /// where the parser wants them regardless.
  FormattedSourceValueObject _footnote(String text, int from, int to) {
    const String mark = '[^1]';
    final String withMark = text.replaceRange(from, to, mark);
    final String tail = withMark.endsWith('\n') ? '' : '\n';
    return FormattedSourceValueObject(
      text: '$withMark$tail\n$mark: \n',
      start: from + mark.length,
      end: from + mark.length,
    );
  }

  /// Where the line holding [at] begins.
  int _lineStart(String text, int at) {
    final int newline = text.lastIndexOf('\n', at == 0 ? 0 : at - 1);
    return newline < 0 ? 0 : newline + 1;
  }

  /// Where the line holding [at] ends, before its newline.
  int _lineEnd(String text, int at) {
    final int newline = text.indexOf('\n', at);
    return newline < 0 ? text.length : newline;
  }
}
