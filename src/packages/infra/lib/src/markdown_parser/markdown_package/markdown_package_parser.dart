/// The markdown capability, over the `markdown` package.
library;

import 'package:markdown/markdown.dart' as md;
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/markdown_parser/markdown_package/positioned_syntaxes.dart';

/// [MarkdownParser] over the official Dart parser ([Decision
/// 19](../../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
///
/// The package reports no source positions, so this recovers them by
/// extending every block syntax — `positioned_syntaxes.dart` says why
/// extending and not wrapping.
final class MarkdownPackageParser implements MarkdownParser {
  /// Creates the parser.
  const MarkdownPackageParser();

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
      parsed = parseWithPositions(markdown);
      return Success<MarkdownOutlineDto, MarkdownParserFailure>(
        MarkdownOutlineDto(
          spans: List<MarkdownSpanDto>.unmodifiable(<MarkdownSpanDto>[
            for (final md.Node node in parsed.nodes)
              // A node the parse could not place — the synthesised footnotes
              // section is the known one — is left out rather than guessed
              // at, which is what the contract promises.
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
  /// A bare text node at top level is a raw HTML block: the package hands
  /// those through as text rather than as an element, and everything else
  /// that would be text — a blank run, a link definition — produces no node
  /// at all.
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
  /// Rebuilt from the parser's own map rather than read off the text: a
  /// line that looks like a definition inside a code block is not one, and
  /// only the parse knows the difference. What comes out parses the same.
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
