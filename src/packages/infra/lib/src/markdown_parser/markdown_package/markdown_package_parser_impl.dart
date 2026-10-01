/// The `markdown`-package implementation of [MarkdownParser].
library;

import 'package:markdown/markdown.dart' as md;
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// [MarkdownParser] over the official Dart parser ([Decision
/// 19](../../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
///
/// The package reports no source positions, so this recovers them by
/// extending every block syntax — [_positionedSyntaxes] says why extending
/// and not wrapping.
final class MarkdownPackageParserImpl implements MarkdownParser {
  /// Creates the parser.
  const MarkdownPackageParserImpl();

  @override
  Future<Result<MarkdownOutlineDto, MarkdownParserFailure>> outline(
    String markdown,
  ) async {
    try {
      final List<String> lines = markdown.split('\n');
      final _Parsed parsed = _parseWithPositions(markdown);
      return Success<MarkdownOutlineDto, MarkdownParserFailure>(
        MarkdownOutlineDto(
          spans: List<MarkdownSpanDto>.unmodifiable(<MarkdownSpanDto>[
            for (final md.Node node in parsed.nodes)
              // A node the parse could not place — the synthesised footnotes
              // section — is left out, as the contract promises.
              if (parsed.spans[node] case final (int, int) span)
                if (_kindOf(node) case final MarkdownSpanKindEnum kind)
                  MarkdownSpanDto(
                    startLine: span.$1,
                    endLine: _lastLineOf(span, lines),
                    kind: kind,
                  ),
          ]),
          linkDefinitions: _definitionsOf(parsed.linkReferences),
          footnotes: _footnotesOf(parsed, lines),
        ),
      );
    } on Object catch (error) {
      return Failure<MarkdownOutlineDto, MarkdownParserFailure>(
        MarkdownParserFailed(error.toString()),
      );
    }
  }

  /// Where [span] really ends, once trailing blank lines are given back.
  ///
  /// A syntax that runs to the end of its input consumes the blank line
  /// after it, and the contract says a blank line belongs to no construct.
  static int _lastLineOf((int, int) span, List<String> lines) {
    int last = span.$2;
    while (last > span.$1 && lines[last].trim().isEmpty) {
      last--;
    }
    return last;
  }

  /// What [node] is, or null for something with no kind of its own.
  ///
  /// A bare text node at top level is a raw HTML block, which the package
  /// hands through as text rather than as an element.
  static MarkdownSpanKindEnum? _kindOf(md.Node node) {
    if (node is! md.Element) {
      return node is md.Text && node.text.trim().isNotEmpty
          ? MarkdownSpanKindEnum.html
          : null;
    }
    return switch (node.tag) {
      'p' => MarkdownSpanKindEnum.paragraph,
      'h1' ||
      'h2' ||
      'h3' ||
      'h4' ||
      'h5' ||
      'h6' => MarkdownSpanKindEnum.heading,
      'ul' || 'ol' => MarkdownSpanKindEnum.list,
      'table' => MarkdownSpanKindEnum.table,
      'pre' || 'code' => MarkdownSpanKindEnum.code,
      'blockquote' => MarkdownSpanKindEnum.quote,
      'hr' => MarkdownSpanKindEnum.rule,
      _ => MarkdownSpanKindEnum.html,
    };
  }

  /// Every footnote of the document, in citation order.
  ///
  /// The parser moves each definition into a section it synthesises at the
  /// end, so the definitions are no longer top-level nodes — they are found
  /// one level down, and each is read from **the lines its own span points
  /// at** rather than by scanning the text, so a line that looks like a
  /// definition inside a code block is not one.
  static List<MarkdownFootnoteDto> _footnotesOf(
    _Parsed parsed,
    List<String> lines,
  ) {
    final List<MarkdownFootnoteDto> footnotes = <MarkdownFootnoteDto>[];
    for (final md.Node node in parsed.nodes) {
      if (node is! md.Element || node.tag != 'section') {
        continue;
      }
      for (final md.Node item in _definitionsIn(node)) {
        final String? label = item is md.Element ? item.footnoteLabel : null;
        if (label == null) {
          continue;
        }
        if (parsed.spans[item] case final (int, int) span) {
          footnotes.add(
            MarkdownFootnoteDto(
              label: label,
              // The order the notes are first cited in, which is the order
              // the parser collected the labels in.
              number: parsed.footnoteLabels.indexOf(label) + 1,
              text: _noteTextOf(span, lines),
            ),
          );
        }
      }
    }
    footnotes.sort(
      (MarkdownFootnoteDto a, MarkdownFootnoteDto b) =>
          a.number.compareTo(b.number),
    );
    return List<MarkdownFootnoteDto>.unmodifiable(footnotes);
  }

  /// The definitions inside the synthesised section, which wraps them in a
  /// list of its own.
  static Iterable<md.Node> _definitionsIn(md.Element section) sync* {
    for (final md.Node child in section.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'ol') {
        yield* child.children ?? const <md.Node>[];
      }
    }
  }

  /// What the note says, from the lines [span] points at.
  ///
  /// The `[^label]:` that introduced it is dropped and the continuation lines
  /// are given back their own indentation, so what comes out is the markdown
  /// somebody wrote rather than the syntax that held it.
  static String _noteTextOf((int, int) span, List<String> lines) {
    final List<String> own = <String>[
      for (int at = span.$1; at <= span.$2 && at < lines.length; at++)
        lines[at],
    ];
    if (own.isEmpty) {
      return '';
    }
    own[0] = own.first.replaceFirst(RegExp(r'^\s*\[\^[^\]]*\]:\s?'), '');
    return own.join('\n').trim();
  }

  /// [references] written back as the lines that declared them.
  ///
  /// Rebuilt from the parser's own map rather than read off the text, because
  /// a line that looks like a definition inside a code block is not one.
  static String _definitionsOf(Map<String, md.LinkReference> references) =>
      <String>[
        for (final MapEntry<String, md.LinkReference> entry
            in references.entries)
          '[${entry.key}]: ${entry.value.destination}'
              '${_titleOf(entry.value)}',
      ].join('\n');

  /// The quoted title of [reference], or nothing when it has none.
  static String _titleOf(md.LinkReference reference) {
    final String? title = reference.title;
    return title == null || title.isEmpty ? '' : ' "$title"';
  }
}

/// Parses [markdown], recording where each top-level node came from.
///
/// `BlockParser` keeps its line private and the AST has no field for it, so
/// each syntax reads `current` before and after it consumes. A node that
/// arrives without a position is absent from the map, and the caller drops it.
_Parsed _parseWithPositions(String markdown) {
  final Map<md.Node, (int, int)> spans = <md.Node, (int, int)>{};
  final List<md.BlockSyntax> syntaxes = _positionedSyntaxes();
  for (final md.BlockSyntax syntax in syntaxes) {
    (syntax as _RecordsPosition).spans = spans;
  }
  final md.Document document = md.Document(
    extensionSet: md.ExtensionSet.gitHubWeb,
    blockSyntaxes: syntaxes,
    withDefaultBlockSyntaxes: false,
  );
  final List<md.Node> nodes = document.parseLines(markdown.split('\n'));
  // Read after the parse, because that is when the definitions have been
  // collected.
  return _Parsed(
    nodes: nodes,
    spans: spans,
    linkReferences: document.linkReferences,
    // Collected as the references were met, which is what makes it citation
    // order rather than definition order.
    footnoteLabels: document.footnoteLabels,
  );
}

/// One parse, and everything read off it.
///
/// A type rather than a record because four fields travel together through
/// three functions, and a record repeated three times is a shape nobody can
/// change in one place.
final class _Parsed {
  const _Parsed({
    required this.nodes,
    required this.spans,
    required this.linkReferences,
    required this.footnoteLabels,
  });

  /// The top-level nodes, in document order.
  final List<md.Node> nodes;

  /// Where each node came from; a node that arrives without a position is
  /// absent, and the caller drops it.
  final Map<md.Node, (int, int)> spans;

  /// The link reference definitions the parse collected.
  final Map<String, md.LinkReference> linkReferences;

  /// The footnote labels, in the order they were first cited.
  final List<String> footnoteLabels;
}

/// The block syntaxes the parser would have used, each recording where it
/// parsed.
///
/// **Subclasses, not wrappers.** The package's syntaxes recognise each other
/// *by type* — `ParagraphSyntax` asks whether what interrupted it `is
/// SetextHeaderSyntax` — so behind a decorator a setext heading quietly
/// becomes a paragraph. One class per syntax is the price; a package upgrade
/// that adds one produces a construct with no position rather than a wrong
/// one.
List<md.BlockSyntax> _positionedSyntaxes() => <md.BlockSyntax>[
  // gitHubWeb's additions first, exactly as the parser orders them.
  _FencedCodeBlock(),
  _HeaderWithId(),
  _SetextHeaderWithId(),
  _Table(),
  _UnorderedListWithCheckbox(),
  _OrderedListWithCheckbox(),
  _FootnoteDef(),
  _AlertBlock(),
  // Then the standard set in the parser's order, minus the four the GitHub
  // variants above subclass and shadow.
  _EmptyBlock(),
  _HtmlBlock(),
  _CodeBlock(),
  _Blockquote(),
  _HorizontalRule(),
  _LinkReferenceDefinition(),
  _Paragraph(),
];

/// Records where the syntax it is mixed into parsed.
///
/// A helper rather than an override, because about half the package's
/// syntaxes narrow `parse` to a non-nullable `Node` and a mixin can declare
/// only one signature.
mixin _RecordsPosition on md.BlockSyntax {
  /// Where to put what it learns. Set once, right after construction.
  late final Map<md.Node, (int, int)> spans;

  /// Runs [inner], noting the lines it consumed.
  ///
  /// The start is not always the line the parser is on: a setext heading's
  /// text was consumed by the paragraph syntax and handed back, and
  /// `linesToConsume` is that run, so its length is how far back the block
  /// began.
  T record<T extends md.Node?>(md.BlockParser parser, T Function() inner) {
    final int start =
        _lineOf(parser) - (parser.linesToConsume.length - 1).clamp(0, 1 << 30);
    final T node = inner();
    // The parser now sits on the first line it did not consume, except at
    // the end of the document, where it sits past the last one.
    final int end = (parser.isDone ? parser.lines.length : _lineOf(parser)) - 1;
    if (node != null && end >= start) {
      spans[node] = (start, end);
    }
    return node;
  }

  /// Which line the parser is on; only ever asked while it is on one.
  ///
  /// By identity, not by content: an `indexOf` would find the first of two
  /// identical lines and place every later block wrong.
  static int _lineOf(md.BlockParser parser) {
    final md.Line current = parser.current;
    for (int index = 0; index < parser.lines.length; index++) {
      if (identical(parser.lines[index], current)) {
        return index;
      }
    }
    return -1;
  }
}

class _AlertBlock extends md.AlertBlockSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _Blockquote extends md.BlockquoteSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _CodeBlock extends md.CodeBlockSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _EmptyBlock extends md.EmptyBlockSyntax with _RecordsPosition {
  @override
  md.Node? parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _FencedCodeBlock extends md.FencedCodeBlockSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _FootnoteDef extends md.FootnoteDefSyntax with _RecordsPosition {
  @override
  md.Node? parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _HeaderWithId extends md.HeaderWithIdSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _HorizontalRule extends md.HorizontalRuleSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _HtmlBlock extends md.HtmlBlockSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _LinkReferenceDefinition extends md.LinkReferenceDefinitionSyntax
    with _RecordsPosition {
  @override
  md.Node? parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _OrderedListWithCheckbox extends md.OrderedListWithCheckboxSyntax
    with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _Paragraph extends md.ParagraphSyntax with _RecordsPosition {
  @override
  md.Node? parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _SetextHeaderWithId extends md.SetextHeaderWithIdSyntax
    with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _Table extends md.TableSyntax with _RecordsPosition {
  @override
  md.Node? parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _UnorderedListWithCheckbox extends md.UnorderedListWithCheckboxSyntax
    with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}
