/// Getting source positions out of a parser that does not report them.
library;

import 'package:markdown/markdown.dart' as md;

/// One top-level block, with where it came from.
///
/// `Block`'s candidate shape, and the thing Spike B exists to find out
/// whether we can build ([domain model](../../../../../../docs/technical/domain-model.md)).
class SourceBlock {
  /// Creates a block.
  const SourceBlock({
    required this.node,
    required this.startLine,
    required this.endLine,
    required this.source,
  });

  /// What the parser produced.
  final md.Node node;

  /// The first line of the block, zero-based and inclusive.
  final int startLine;

  /// The last line of the block, zero-based and inclusive.
  final int endLine;

  /// The document's own text for those lines, newline-joined.
  ///
  /// The answer to the domain model's third question — raw text *and*
  /// structure without duplicating state, because the text is a slice of
  /// the document rather than a second copy of it.
  final String source;

  /// The element's tag, or `text` for a bare text node.
  String get tag => node is md.Element ? (node as md.Element).tag : 'text';

  /// How many lines the block spans.
  int get lineCount => endLine - startLine + 1;
}

/// A parsed document: its blocks, and the context they were parsed in.
///
/// The context is the point. Reference link definitions and footnotes are
/// declared at document scope, so a block that uses one cannot be understood
/// from its own lines alone — and `Document.linkReferences` is a public,
/// mutable map, which means the context *can* be handed to a second parse.
class ParsedDocument {
  /// Creates a parsed document.
  const ParsedDocument({required this.blocks, required this.document});

  /// The top-level blocks, in document order.
  final List<SourceBlock> blocks;

  /// The parser context, carrying the link references it collected.
  final md.Document document;
}

/// Parses [markdown] into top-level blocks that know where they are.
///
/// The parser tracks the line it is on and throws it away: `BlockParser`
/// keeps `_pos` private and the AST has no field for it. What it does expose
/// is `lines` and `current`, so a [md.BlockSyntax] that wraps another can
/// read the position before and after the inner syntax consumes its lines.
///
/// Every standard syntax is wrapped, and `withDefaultBlockSyntaxes: false`
/// stops the parser adding a second, unwrapped copy of each. Anything that
/// still arrives without a position is reported rather than guessed at.
ParsedDocument parseWithPositions(
  String markdown, {
  md.ExtensionSet? extensionSet,
  Map<String, md.LinkReference>? inheritedReferences,
}) {
  final List<String> lines = markdown.split('\n');
  final Map<md.Node, (int, int)> spans = <md.Node, (int, int)>{};
  final List<md.BlockSyntax> syntaxes = _positionedSyntaxes();
  for (final md.BlockSyntax syntax in syntaxes) {
    (syntax as _RecordsPosition).spans = spans;
  }
  final md.Document document = md.Document(
    extensionSet: extensionSet ?? md.ExtensionSet.gitHubWeb,
    blockSyntaxes: syntaxes,
    withDefaultBlockSyntaxes: false,
  );
  if (inheritedReferences != null) {
    document.linkReferences.addAll(inheritedReferences);
  }
  final List<md.Node> nodes = document.parseLines(lines);
  final List<SourceBlock> blocks = <SourceBlock>[
    for (final md.Node node in nodes)
      if (spans[node] case final (int, int) span)
        SourceBlock(
          node: node,
          startLine: span.$1,
          endLine: span.$2,
          source: lines.sublist(span.$1, span.$2 + 1).join('\n'),
        )
      else
        SourceBlock(node: node, startLine: -1, endLine: -1, source: ''),
  ];
  return ParsedDocument(blocks: blocks, document: document);
}

/// The block syntaxes the parser would have used, each recording where it
/// parsed.
///
/// **Subclasses, not wrappers.** A decorator around a `BlockSyntax` looks
/// like the obvious mechanism and silently changes what is parsed: the
/// package's syntaxes recognise each other *by type*.
/// `ParagraphSyntax` asks whether what interrupted it `is
/// SetextHeaderSyntax` before handing its lines over; `BlockquoteSyntax` and
/// `AlertBlockSyntax` ask whether the other match `is ParagraphSyntax` or
/// `is CodeBlockSyntax`; `BlockParser` itself special-cases
/// `EmptyBlockSyntax` and `LinkReferenceDefinitionSyntax`. Wrapped, every
/// one of those tests answers false, and a setext heading quietly becomes a
/// paragraph.
///
/// Extending each syntax keeps the `is` checks true. The price is one class
/// per syntax, and a package upgrade that adds a syntax produces blocks with
/// no position rather than wrong ones — which [parseWithPositions] reports
/// instead of hiding.
List<md.BlockSyntax> _positionedSyntaxes() => <md.BlockSyntax>[
  // gitHubWeb's additions come first, exactly as the parser orders them.
  _FencedCodeBlock(),
  _HeaderWithId(),
  _SetextHeaderWithId(),
  _Table(),
  _UnorderedListWithCheckbox(),
  _OrderedListWithCheckbox(),
  _FootnoteDef(),
  _AlertBlock(),
  // Then the standard set, in the parser's own order.
  _EmptyBlock(),
  _HtmlBlock(),
  _SetextHeader(),
  _Header(),
  _CodeBlock(),
  _Blockquote(),
  _HorizontalRule(),
  _UnorderedList(),
  _OrderedList(),
  _LinkReferenceDefinition(),
  _Paragraph(),
];

/// Records where the syntax it is mixed into parsed.
///
/// The recording is a helper rather than an override, because the package's
/// syntaxes do not agree on one signature: about half narrow `parse` to a
/// non-nullable `Node`, and a mixin can only declare one of the two. So each
/// subclass overrides `parse` with its own parent's signature and routes the
/// call through [record].
mixin _RecordsPosition on md.BlockSyntax {
  /// Where to put what it learns. Set once, right after construction.
  late final Map<md.Node, (int, int)> spans;

  /// Runs [inner], noting the lines it consumed.
  ///
  /// The start is not always the line the parser is on. A setext heading is
  /// only a heading because of the line *after* its text, so `ParagraphSyntax`
  /// has already consumed the text and handed it back before
  /// `SetextHeaderSyntax` claims it — recording the current line would place
  /// the heading on its own underline and lose the words. `linesToConsume`
  /// is the buffer holding exactly that handed-back run, and its length is
  /// how far back the block really began.
  T record<T extends md.Node?>(md.BlockParser parser, T Function() inner) {
    final int start =
        _lineOf(parser) - (parser.linesToConsume.length - 1).clamp(0, 1 << 30);
    final T node = inner();
    // The parser now sits on the first line it did *not* consume, except at
    // the end of the document, where it sits past the last one.
    final int end = (parser.isDone ? parser.lines.length : _lineOf(parser)) - 1;
    if (node != null && end >= start) {
      spans[node] = (start, end);
    }
    return node;
  }

  /// Which line the parser is on.
  ///
  /// By identity, not by content: `lines` holds one [md.Line] instance per
  /// line of the document, and two identical lines are two instances. An
  /// `indexOf` would find the first of them and quietly place every later
  /// block wrong — in a document made of repeated table rows, most of them.
  static int _lineOf(md.BlockParser parser) {
    if (parser.isDone) {
      return parser.lines.length;
    }
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

class _Header extends md.HeaderSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
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

class _OrderedList extends md.OrderedListSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
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

class _SetextHeader extends md.SetextHeaderSyntax with _RecordsPosition {
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

class _UnorderedList extends md.UnorderedListSyntax with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}

class _UnorderedListWithCheckbox extends md.UnorderedListWithCheckboxSyntax
    with _RecordsPosition {
  @override
  md.Node parse(md.BlockParser parser) =>
      record(parser, () => super.parse(parser));
}
