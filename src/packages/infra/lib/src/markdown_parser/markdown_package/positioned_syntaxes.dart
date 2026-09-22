/// Getting source positions out of a parser that does not report them.
library;

import 'package:markdown/markdown.dart' as md;

/// Parses [markdown], recording where each top-level node came from.
///
/// The parser tracks the line it is on and throws it away: `BlockParser`
/// keeps `_pos` private and the AST has no field for it. What it exposes is
/// `lines` and `current`, which a syntax can read before and after it
/// consumes.
///
/// A node that arrives without a position is left in the map's absence
/// rather than guessed at — the caller drops it.
({
  List<md.Node> nodes,
  Map<md.Node, (int, int)> spans,
  Map<String, md.LinkReference> linkReferences,
})
parseWithPositions(String markdown) {
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
  // collected: the map is the parser's own and knows a definition from a
  // line that merely looks like one inside a code block.
  return (nodes: nodes, spans: spans, linkReferences: document.linkReferences);
}

/// The block syntaxes the parser would have used, each recording where it
/// parsed.
///
/// **Subclasses, not wrappers.** A decorator looks like the obvious
/// mechanism and silently changes the parse: the package's syntaxes
/// recognise each other *by type* — `ParagraphSyntax` asks whether what
/// interrupted it `is SetextHeaderSyntax`, and behind a decorator that
/// answers false, so a setext heading quietly becomes a paragraph.
///
/// The price is one class per syntax. A package upgrade that adds one
/// produces a construct with no position rather than a wrong one.
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
  // Then the standard set, in the parser's own order. Four of it are
  // missing on purpose: the plain header, setext header and two lists are
  // shadowed by the GitHub variants above, which subclass them and match
  // first, so including them would be code nothing can reach.
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
/// A helper rather than an override, because the package's syntaxes do not
/// agree on one signature: about half narrow `parse` to a non-nullable
/// `Node`, and a mixin can only declare one of the two.
mixin _RecordsPosition on md.BlockSyntax {
  /// Where to put what it learns. Set once, right after construction.
  late final Map<md.Node, (int, int)> spans;

  /// Runs [inner], noting the lines it consumed.
  ///
  /// The start is not always the line the parser is on: a setext heading is
  /// a heading because of the line *after* its text, so the paragraph syntax
  /// has already consumed the text and handed it back. `linesToConsume` is
  /// that handed-back run, and its length is how far back the block began.
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
  /// By identity, not by content: `lines` holds one instance per line, and
  /// an `indexOf` would find the first of two identical lines and place
  /// every later block wrong — in a document of repeated table rows, most
  /// of them.
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
