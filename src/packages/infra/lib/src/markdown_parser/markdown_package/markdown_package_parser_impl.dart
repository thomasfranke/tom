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
      final ({
        List<md.Node> nodes,
        Map<md.Node, (int, int)> spans,
        Map<String, md.LinkReference> linkReferences,
      })
      parsed = _parseWithPositions(markdown);
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
({
  List<md.Node> nodes,
  Map<md.Node, (int, int)> spans,
  Map<String, md.LinkReference> linkReferences,
})
_parseWithPositions(String markdown) {
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
  return (nodes: nodes, spans: spans, linkReferences: document.linkReferences);
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
