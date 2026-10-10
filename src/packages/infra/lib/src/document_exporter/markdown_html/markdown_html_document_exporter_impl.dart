/// The `markdown`-package implementation of [DocumentExporter], for HTML.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/document_exporter/document_exporter.dart';
import 'package:tom_infra/src/document_exporter/document_exporter_failure.dart';

/// One self-contained HTML page, written block by block the way the preview
/// renders them.
///
/// Each block is rendered alone with the link definitions appended, as the
/// preview does, so the two read a block the same way; the notes are drawn
/// once at the foot ([Decision
/// 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
/// An image is carried inside the page as a `data:` address, since the file
/// lands outside the space where a relative `src` points at nothing.
final class MarkdownHtmlDocumentExporterImpl implements DocumentExporter {
  /// Creates the exporter.
  const MarkdownHtmlDocumentExporterImpl();

  @override
  Future<Result<Uint8List, DocumentExporterFailure>> export(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  }) async {
    if (format != ExporterFormatEnum.html) {
      return Failure<Uint8List, DocumentExporterFailure>(
        DocumentExporterUnsupported(format),
      );
    }
    try {
      final Map<String, int> numbers = <String, int>{
        for (final ExporterFootnoteDto note in document.footnotes)
          note.label: note.number,
      };
      List<md.Node> parse(String source) =>
          _parse(source, document.linkDefinitions, numbers);
      final List<List<md.Node>> blocks = <List<md.Node>>[
        for (final ExporterBlockDto block in document.blocks)
          parse(block.source),
      ];
      final List<(int, List<md.Node>)> notes = <(int, List<md.Node>)>[
        for (final ExporterFootnoteDto note in document.footnotes)
          (note.number, parse(note.text)),
      ];
      await _embed(<List<md.Node>>[
        ...blocks,
        for (final (int, List<md.Node>) note in notes) note.$2,
      ], readImage);
      final StringBuffer body = StringBuffer();
      for (final List<md.Node> block in blocks) {
        body.write('${md.renderToHtml(block)}\n');
      }
      body.write(_notes(notes));
      return Success<Uint8List, DocumentExporterFailure>(
        Uint8List.fromList(utf8.encode(_page(document.title, '$body'))),
      );
    } on Object catch (error) {
      return Failure<Uint8List, DocumentExporterFailure>(
        DocumentExporterWriteFailed(error.toString()),
      );
    }
  }

  /// [source] parsed in the scope of the whole document, as
  /// `markdownToHtml` would before rendering.
  static List<md.Node> _parse(
    String source,
    String linkDefinitions,
    Map<String, int> numbers,
  ) => md.Document(
    extensionSet: md.ExtensionSet.gitHubWeb,
    inlineSyntaxes: <md.InlineSyntax>[_FootnoteMarker(numbers)],
  ).parse(linkDefinitions.isEmpty ? source : '$source\n\n$linkDefinitions');

  /// Points every image [readImage] can answer at its own bytes; one it
  /// cannot keeps its `src`, and a browser shows its alt text.
  static Future<void> _embed(
    List<List<md.Node>> blocks,
    ExporterImageReader? readImage,
  ) async {
    if (readImage == null) {
      return;
    }
    final List<md.Element> images = <md.Element>[
      for (final List<md.Node> nodes in blocks) ..._imagesIn(nodes),
    ];
    final Map<String, String?> addresses = <String, String?>{};
    for (final md.Element image in images) {
      final String? reference = image.attributes['src'];
      if (reference == null) {
        continue;
      }
      if (!addresses.containsKey(reference)) {
        final Uint8List? bytes = await readImage(reference);
        addresses[reference] = bytes == null ? null : _dataAddress(bytes);
      }
      if (addresses[reference] case final String address) {
        image.attributes['src'] = address;
      }
    }
  }

  static Iterable<md.Element> _imagesIn(List<md.Node> nodes) sync* {
    for (final md.Node node in nodes) {
      if (node is md.Element) {
        if (node.tag == 'img') {
          yield node;
        }
        yield* _imagesIn(node.children ?? const <md.Node>[]);
      }
    }
  }

  /// [bytes] as a `data:` address, or null when they are no image a browser
  /// is known to draw — read off the bytes, never the name.
  static String? _dataAddress(Uint8List bytes) {
    final String? type = switch (bytes) {
      [0x89, 0x50, 0x4E, 0x47, ...] => 'image/png',
      [0xFF, 0xD8, 0xFF, ...] => 'image/jpeg',
      [0x47, 0x49, 0x46, 0x38, ...] => 'image/gif',
      [0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x45, 0x42, 0x50, ...] =>
        'image/webp',
      _ when _isSvg(bytes) => 'image/svg+xml',
      _ => null,
    };
    return type == null ? null : 'data:$type;base64,${base64Encode(bytes)}';
  }

  static bool _isSvg(Uint8List bytes) {
    final String head = utf8
        .decode(bytes.take(512).toList(), allowMalformed: true)
        .trimLeft();
    return (head.startsWith('<svg') || head.startsWith('<?xml')) &&
        head.contains('<svg');
  }

  /// The notes under a rule, numbered by the document rather than by the
  /// list, so a gap in the numbering stays a gap.
  static String _notes(List<(int, List<md.Node>)> notes) {
    if (notes.isEmpty) {
      return '';
    }
    final StringBuffer written = StringBuffer(
      '<section class="footnotes">\n<hr>\n<ol>\n',
    );
    for (final (int number, List<md.Node> nodes) in notes) {
      written.write(
        '<li value="$number">${md.renderToHtml(nodes).trim()}</li>\n',
      );
    }
    return '$written</ol>\n</section>\n';
  }

  /// [body] inside a page that carries its own style, so the file reads the
  /// same wherever it is opened. The faces are named, never embedded.
  static String _page(String title, String body) =>
      '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${const HtmlEscape().convert(title)}</title>
<style>
body { max-width: 46em; margin: 3em auto; padding: 0 1.5em; font: 17px/1.7 "IBM Plex Serif", Georgia, serif; color: #1f1f1f; }
h1, h2, h3, h4, h5, h6 { font-family: "IBM Plex Sans", "Helvetica Neue", Arial, sans-serif; font-weight: 600; line-height: 1.3; }
code, pre { font-family: "IBM Plex Mono", Menlo, Consolas, monospace; font-size: 0.85em; }
pre { padding: 0.8em 1em; background: #f2f1ed; border-radius: 6px; overflow-x: auto; }
blockquote, .markdown-alert { margin-left: 0; padding-left: 1em; border-left: 3px solid #d6d3cc; color: #555; }
table { border-collapse: collapse; }
th, td { border: 1px solid #d6d3cc; padding: 6px 10px; }
hr { border: 0; border-top: 1px solid #d6d3cc; }
sup { font-size: 0.7em; }
</style>
</head>
<body>
<article>
$body</article>
</body>
</html>
''';
}

/// Turns `[^label]` into the number the **document** gave that note, and
/// leaves a reference to no note exactly as written — the preview's rule
/// ([Decision 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
final class _FootnoteMarker extends md.InlineSyntax {
  _FootnoteMarker(this.numbers) : super(r'\[\^([^\]\s]+)\]');

  final Map<String, int> numbers;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final int? number = numbers[match.group(1)];
    // Consumed either way: answering false leaves the parser on the same
    // character for ever.
    parser.addNode(
      number == null
          ? md.Text(match[0] ?? '')
          : md.Element('sup', <md.Node>[md.Text('$number')]),
    );
    return true;
  }
}
