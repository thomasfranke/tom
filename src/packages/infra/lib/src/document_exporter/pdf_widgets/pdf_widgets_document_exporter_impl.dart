/// The `pdf`-package implementation of [DocumentExporter], for PDF.
library;

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/document_exporter/document_exporter.dart';
import 'package:tom_infra/src/document_exporter/document_exporter_failure.dart';

/// A PDF laid out by `pdf`'s own widgets, from the same blocks the preview
/// draws ([Decision
/// 30](../../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)).
///
/// The faces are handed in as font files, since this package cannot see the
/// ones `tom_ui` vendors; a face not handed in falls back to the PDF's own
/// Times, Helvetica or Courier, which draw nothing outside Latin-1.
final class PdfWidgetsDocumentExporterImpl implements DocumentExporter {
  /// Creates the exporter over whichever IBM Plex files the caller has.
  const PdfWidgetsDocumentExporterImpl({
    this.serif,
    this.serifItalic,
    this.serifSemiBold,
    this.sansSemiBold,
    this.mono,
  });

  /// IBM Plex Serif 400, the prose.
  final ByteData? serif;

  /// IBM Plex Serif 400 italic, emphasis.
  final ByteData? serifItalic;

  /// IBM Plex Serif 600, strong emphasis.
  final ByteData? serifSemiBold;

  /// IBM Plex Sans 600, the headings — the interface's voice, as in the
  /// preview.
  final ByteData? sansSemiBold;

  /// IBM Plex Mono 400, code.
  final ByteData? mono;

  @override
  Future<Result<Uint8List, DocumentExporterFailure>> export(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  }) async {
    if (format != ExporterFormatEnum.pdf) {
      return Failure<Uint8List, DocumentExporterFailure>(
        DocumentExporterUnsupported(format),
      );
    }
    try {
      final pw.Document pdf = pw.Document(title: document.title);
      final _Writer writer = await _Writer.read(
        document,
        _Faces.of(this),
        pdf.document,
        readImage,
      );
      pdf.addPage(
        // Paginated A4, the maintainer's answer to Decision 30's open
        // question (`docs/product/export/doc.md`).
        pw.MultiPage(
          pageFormat: _page,
          margin: const pw.EdgeInsets.all(_margin),
          theme: writer.theme,
          build: writer.widgets,
        ),
      );
      return Success<Uint8List, DocumentExporterFailure>(await pdf.save());
    } on PdfTooBigPageException catch (error) {
      return Failure<Uint8List, DocumentExporterFailure>(
        DocumentExporterTooLarge('${error.message}'),
      );
    } on PdfException catch (error) {
      // The package has no type for a block taller than a page, only this
      // sentence; anything else it throws is the engine breaking.
      final String said = '${error.message}';
      return Failure<Uint8List, DocumentExporterFailure>(
        said.startsWith("Widget won't fit")
            ? DocumentExporterTooLarge(said)
            : DocumentExporterWriteFailed(said),
      );
    } on Object catch (error) {
      return Failure<Uint8List, DocumentExporterFailure>(
        DocumentExporterWriteFailed(error.toString()),
      );
    }
  }

  static const PdfPageFormat _page = PdfPageFormat.a4;

  /// The page's margin, about two centimetres.
  static const double _margin = 56;

  /// How wide and how tall the text may run inside the margins.
  static const double _textWidth = 21.0 * PdfPageFormat.cm - 2 * _margin;
  static const double _textHeight = 29.7 * PdfPageFormat.cm - 2 * _margin;
}

/// The three families, each IBM Plex where its file was handed in.
final class _Faces {
  const _Faces({required this.serif, required this.sans, required this.mono});

  factory _Faces.of(PdfWidgetsDocumentExporterImpl files) {
    pw.Font face(ByteData? file, pw.Font Function() builtIn) =>
        file == null ? builtIn() : pw.Font.ttf(file);
    final pw.Font sans = face(files.sansSemiBold, pw.Font.helveticaBold);
    final pw.Font mono = face(files.mono, pw.Font.courier);
    // Plex Serif carries no semibold italic, so strong emphasis inside
    // emphasis keeps the italic, which is the cut that says more.
    final pw.Font italic = face(files.serifItalic, pw.Font.timesItalic);
    return _Faces(
      serif: pw.TextStyle(
        fontNormal: face(files.serif, pw.Font.times),
        fontBold: face(files.serifSemiBold, pw.Font.timesBold),
        fontItalic: italic,
        fontBoldItalic: files.serifItalic == null
            ? pw.Font.timesBoldItalic()
            : italic,
      ),
      sans: pw.TextStyle(
        fontNormal: sans,
        fontBold: sans,
        fontItalic: sans,
        fontBoldItalic: sans,
      ),
      mono: pw.TextStyle(
        fontNormal: mono,
        fontBold: mono,
        fontItalic: mono,
        fontBoldItalic: mono,
      ),
    );
  }

  final pw.TextStyle serif;
  final pw.TextStyle sans;
  final pw.TextStyle mono;
}

/// One document turned into widgets, block by block.
///
/// Every block is a top-level child of the page, and every child that can be
/// long is one `pdf` can split, so a long list or fence runs onto the next
/// page instead of failing.
final class _Writer {
  _Writer._(this.faces, this.blocks, this.notes, this.pictures);

  /// [document] parsed once, with every image it names read into [pdf]
  /// before the first page is laid out — a layout cannot wait.
  static Future<_Writer> read(
    ExporterDocumentDto document,
    _Faces faces,
    PdfDocument pdf,
    ExporterImageReader? readImage,
  ) async {
    final Map<String, int> numbers = <String, int>{
      for (final ExporterFootnoteDto note in document.footnotes)
        note.label: note.number,
    };
    List<md.Node> parse(String source) =>
        _parse(source, document.linkDefinitions, numbers);
    final List<List<md.Node>> blocks = <List<md.Node>>[
      for (final ExporterBlockDto block in document.blocks) parse(block.source),
    ];
    final List<(int, List<md.Node>)> notes = <(int, List<md.Node>)>[
      for (final ExporterFootnoteDto note in document.footnotes)
        (note.number, parse(note.text)),
    ];
    final Map<String, _Picture> pictures = <String, _Picture>{};
    if (readImage != null) {
      final Set<String> asked = <String>{};
      for (final List<md.Node> nodes in <List<md.Node>>[
        ...blocks,
        for (final (int, List<md.Node>) note in notes) note.$2,
      ]) {
        for (final String reference in _imagesIn(nodes)) {
          if (!asked.add(reference)) {
            continue;
          }
          if (await readImage(reference) case final Uint8List bytes) {
            if (_Picture.of(pdf, bytes) case final _Picture picture) {
              pictures[reference] = picture;
            }
          }
        }
      }
    }
    return _Writer._(faces, blocks, notes, pictures);
  }

  final _Faces faces;
  final List<List<md.Node>> blocks;
  final List<(int, List<md.Node>)> notes;

  /// The images that could be drawn, by the `src` the document wrote.
  final Map<String, _Picture> pictures;

  // The preview's sizes (15 · 24 · 17 · 12.5) at print scale.
  static const double _body = 11;
  static const double _headingLarge = 17.5;
  static const double _heading = 12.5;
  static const double _code = 9;
  static const double _gap = 8;

  /// The tallest an image inside a line may be: a badge, never a figure.
  static const double _inlineImage = 2 * _body;
  static const PdfColor _ink = PdfColor.fromInt(0xFF1F1F1F);
  static const PdfColor _quiet = PdfColor.fromInt(0xFF555555);
  static const PdfColor _rule = PdfColor.fromInt(0xFFD6D3CC);
  static const PdfColor _well = PdfColor.fromInt(0xFFF2F1ED);

  pw.ThemeData get theme =>
      pw.ThemeData.withFont(
        base: faces.serif.fontNormal,
        bold: faces.serif.fontBold,
        italic: faces.serif.fontItalic,
        boldItalic: faces.serif.fontBoldItalic,
      ).copyWith(
        defaultTextStyle: const pw.TextStyle(
          fontSize: _body,
          lineSpacing: 4,
          color: _ink,
        ),
      );

  /// The page's children, each heading behind a break that keeps it with
  /// what follows it (`docs/product/export/doc.md`).
  List<pw.Widget> widgets(pw.Context context) {
    final List<(pw.Widget, bool)> flow = <(pw.Widget, bool)>[
      for (final List<md.Node> block in blocks)
        for (final md.Node node in block)
          for (final pw.Widget widget in _spaced(_block(node)))
            (widget, _isHeading(node)),
    ];
    return <pw.Widget>[
      for (int at = 0; at < flow.length; at++) ...<pw.Widget>[
        if (flow[at].$2 && at + 1 < flow.length)
          _KeepWithNext(context, _runFrom(flow, at)),
        flow[at].$1,
      ],
      ..._notes(),
    ];
  }

  /// The headings from [at] on, and the first child that is not one.
  static List<(pw.Widget, bool)> _runFrom(
    List<(pw.Widget, bool)> flow,
    int at,
  ) {
    final List<(pw.Widget, bool)> run = <(pw.Widget, bool)>[];
    for (final (pw.Widget, bool) child in flow.skip(at)) {
      run.add(child);
      if (!child.$2) {
        break;
      }
    }
    return run;
  }

  static bool _isHeading(md.Node node) =>
      node is md.Element && RegExp(r'^h[1-6]$').hasMatch(node.tag);

  /// [source] parsed in the scope of the whole document, as the preview
  /// parses one block.
  static List<md.Node> _parse(
    String source,
    String linkDefinitions,
    Map<String, int> numbers,
  ) {
    final String scoped = linkDefinitions.isEmpty
        ? source
        : '$source\n\n$linkDefinitions';
    return md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
      inlineSyntaxes: <md.InlineSyntax>[_FootnoteMarker(numbers)],
      encodeHtml: false,
    ).parseLines(scoped.split('\n'));
  }

  /// Every image `src` in [nodes], in document order.
  static Iterable<String> _imagesIn(List<md.Node> nodes) sync* {
    for (final md.Node node in nodes) {
      if (node is! md.Element) {
        continue;
      }
      if (node.attributes['src'] case final String reference
          when node.tag == 'img') {
        yield reference;
      }
      yield* _imagesIn(node.children ?? const <md.Node>[]);
    }
  }

  List<pw.Widget> _spaced(List<pw.Widget> widgets) => <pw.Widget>[
    for (final pw.Widget widget in widgets)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: _gap),
        child: widget,
      ),
  ];

  List<pw.Widget> _notes() {
    if (notes.isEmpty) {
      return const <pw.Widget>[];
    }
    return <pw.Widget>[
      pw.Divider(color: _rule, thickness: 0.5, height: 2 * _gap),
      for (final (int number, List<md.Node> nodes) in notes)
        ..._item(pw.Text('$number.'), _blocksOf(nodes), 0),
    ];
  }

  /// The block-level widgets [nodes] stand for.
  List<pw.Widget> _blocksOf(List<md.Node> nodes) => <pw.Widget>[
    for (final md.Node node in nodes) ..._block(node),
  ];

  List<pw.Widget> _block(md.Node node) {
    if (node is! md.Element) {
      // Raw HTML arrives as text at block level, and is shown as written.
      final String text = node.textContent.trim();
      return text.isEmpty ? const <pw.Widget>[] : <pw.Widget>[_text(text)];
    }
    return switch (node.tag) {
      'h1' || 'h2' => <pw.Widget>[_headingOf(node, _headingLarge)],
      'h3' => <pw.Widget>[_headingOf(node, _heading)],
      'h4' || 'h5' || 'h6' => <pw.Widget>[_headingOf(node, _body)],
      'ul' || 'ol' => _list(node, 0),
      'pre' => <pw.Widget>[_fence(node.textContent)],
      'blockquote' || 'div' => <pw.Widget>[_quote(node)],
      'table' => <pw.Widget>[_table(node)],
      'hr' => <pw.Widget>[pw.Divider(color: _rule, thickness: 0.5)],
      'section' => const <pw.Widget>[],
      _ => _runs(node.children ?? const <md.Node>[]),
    };
  }

  /// [inline] as one widget, a column when an image cut it.
  pw.Widget _paragraph(List<md.Node> inline, [pw.TextStyle? style]) =>
      switch (_runs(inline, style)) {
        [final pw.Widget only] => only,
        final List<pw.Widget> runs => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: runs,
        ),
      };

  /// [inline] as text, cut wherever an image stands in it directly: a
  /// figure is drawn at its own size on a line of its own, as the preview
  /// draws it. An image inside a link or an emphasis stays in the line.
  List<pw.Widget> _runs(List<md.Node> inline, [pw.TextStyle? style]) {
    final List<pw.Widget> runs = <pw.Widget>[];
    List<md.Node> text = <md.Node>[];
    void close() {
      final List<md.Node> trimmed = _trimmed(text);
      if (trimmed.isNotEmpty) {
        runs.add(
          pw.RichText(
            text: pw.TextSpan(style: style, children: _inline(trimmed)),
          ),
        );
      }
      text = <md.Node>[];
    }

    for (final md.Node node in inline) {
      if (_pictureOf(node) case final _Picture picture) {
        close();
        runs.add(_figure(picture));
      } else {
        text.add(node);
      }
    }
    close();
    return runs.isEmpty
        ? <pw.Widget>[
            pw.RichText(
              text: pw.TextSpan(style: style, children: _inline(inline)),
            ),
          ]
        : runs;
  }

  /// [nodes] without the blank and the line breaks an image left either
  /// side of it.
  static List<md.Node> _trimmed(List<md.Node> nodes) {
    bool blank(md.Node node) =>
        (node is md.Element && node.tag == 'br') ||
        (node is md.Text && node.text.trim().isEmpty);
    final List<md.Node> kept = nodes.skipWhile(blank).toList();
    while (kept.isNotEmpty && blank(kept.last)) {
      kept.removeLast();
    }
    if (kept.isEmpty) {
      return kept;
    }
    if (kept.first case final md.Text first) {
      kept.first = md.Text(first.text.trimLeft());
    }
    if (kept.last case final md.Text last) {
      kept.last = md.Text(last.text.trimRight());
    }
    return kept;
  }

  _Picture? _pictureOf(md.Node node) => node is md.Element && node.tag == 'img'
      ? pictures[node.attributes['src']]
      : null;

  /// An image on a line of its own: its own size, scaled down to the text's
  /// width and to a page, never up.
  static pw.Widget _figure(_Picture picture) => pw.ConstrainedBox(
    constraints: const pw.BoxConstraints(
      maxWidth: PdfWidgetsDocumentExporterImpl._textWidth,
      maxHeight: PdfWidgetsDocumentExporterImpl._textHeight - 2 * _gap,
    ),
    child: picture.draw(),
  );

  pw.Widget _text(String text) => pw.Text(text);

  pw.Widget _headingOf(md.Element node, double size) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: _gap),
    child: _paragraph(
      node.children ?? const <md.Node>[],
      faces.sans.copyWith(fontSize: size, lineSpacing: size * 0.3),
    ),
  );

  /// A list as one row per item, each nested list indented under its item.
  List<pw.Widget> _list(md.Element list, int depth) {
    final int start = int.tryParse(list.attributes['start'] ?? '') ?? 1;
    final List<pw.Widget> rows = <pw.Widget>[];
    int index = 0;
    for (final md.Node item in list.children ?? const <md.Node>[]) {
      if (item is! md.Element) {
        continue;
      }
      final pw.Widget marker = list.tag == 'ol'
          ? pw.Text('${start + index}.')
          : _dot;
      index++;
      final List<md.Node> inline = <md.Node>[];
      final List<pw.Widget> nested = <pw.Widget>[];
      for (final md.Node child in item.children ?? const <md.Node>[]) {
        if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
          nested.addAll(_list(child, depth + 1));
        } else if (child is md.Element && child.tag == 'p') {
          inline.addAll(child.children ?? const <md.Node>[]);
        } else {
          inline.add(child);
        }
      }
      rows
        ..addAll(_item(marker, <pw.Widget>[_paragraph(inline)], depth))
        ..addAll(nested);
    }
    return rows;
  }

  /// A bullet drawn rather than typed: `•` is outside Latin-1, so the PDF's
  /// own faces would draw nothing for it. A getter, because a `pdf` widget
  /// keeps its layout and cannot sit in two places.
  static pw.Widget get _dot => pw.Padding(
    padding: const pw.EdgeInsets.only(top: _body * 0.45, left: 2),
    child: pw.Container(
      width: 3.5,
      height: 3.5,
      decoration: const pw.BoxDecoration(
        color: _ink,
        shape: pw.BoxShape.circle,
      ),
    ),
  );

  /// [content] hung from [marker], indented [depth] levels.
  List<pw.Widget> _item(pw.Widget marker, List<pw.Widget> content, int depth) =>
      <pw.Widget>[
        pw.Padding(
          padding: pw.EdgeInsets.only(left: 16.0 * depth, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.SizedBox(width: 16, child: marker),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: content,
                ),
              ),
            ],
          ),
        ),
      ];

  /// A fence, one line per widget so a long one can break across pages.
  pw.Widget _fence(String code) {
    final List<String> lines = code.endsWith('\n')
        ? code.substring(0, code.length - 1).split('\n')
        : code.split('\n');
    final pw.TextStyle style = faces.mono.copyWith(
      fontSize: _code,
      lineSpacing: 2,
    );
    return pw.Container(
      color: _well,
      padding: const pw.EdgeInsets.all(_gap),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          // Indentation is meaning in code, and the layout collapses
          // ordinary spaces; a no-break space keeps every one.
          for (final String line in lines)
            pw.Text(line.replaceAll(' ', ' '), style: style),
        ],
      ),
    );
  }

  pw.Widget _quote(md.Element node) => pw.Container(
    padding: const pw.EdgeInsets.only(left: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(left: pw.BorderSide(color: _rule, width: 3)),
    ),
    child: pw.DefaultTextStyle.merge(
      style: const pw.TextStyle(color: _quiet),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: _spaced(_blocksOf(node.children ?? const <md.Node>[])),
      ),
    ),
  );

  pw.Widget _table(md.Element table) => pw.Table(
    border: pw.TableBorder.all(color: _rule, width: 0.5),
    children: <pw.TableRow>[
      for (final md.Node section in table.children ?? const <md.Node>[])
        if (section is md.Element)
          for (final md.Node row in section.children ?? const <md.Node>[])
            if (row is md.Element)
              pw.TableRow(
                children: <pw.Widget>[
                  for (final md.Node cell in row.children ?? const <md.Node>[])
                    if (cell is md.Element)
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: _paragraph(
                          cell.children ?? const <md.Node>[],
                          cell.tag == 'th'
                              ? const pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                )
                              : null,
                        ),
                      ),
                ],
              ),
    ],
  );

  /// The spans [nodes] stand for, inside a block.
  List<pw.InlineSpan> _inline(List<md.Node> nodes) => <pw.InlineSpan>[
    for (final md.Node node in nodes) _span(node),
  ];

  pw.InlineSpan _span(md.Node node) {
    if (node is! md.Element) {
      return pw.TextSpan(text: node.textContent);
    }
    final List<md.Node> children = node.children ?? const <md.Node>[];
    return switch (node.tag) {
      'em' => pw.TextSpan(
        style: const pw.TextStyle(fontStyle: pw.FontStyle.italic),
        children: _inline(children),
      ),
      'strong' => pw.TextSpan(
        style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
        children: _inline(children),
      ),
      'del' => pw.TextSpan(
        style: const pw.TextStyle(decoration: pw.TextDecoration.lineThrough),
        children: _inline(children),
      ),
      'code' => pw.TextSpan(
        text: node.textContent,
        style: faces.mono.copyWith(
          fontSize: _code,
          background: const pw.BoxDecoration(color: _well),
        ),
      ),
      'a' => pw.TextSpan(
        style: const pw.TextStyle(decoration: pw.TextDecoration.underline),
        annotation: switch (node.attributes['href']) {
          final String href => pw.AnnotationUrl(href),
          null => null,
        },
        children: _inline(children),
      ),
      'br' => const pw.TextSpan(text: '\n'),
      'img' => switch (_pictureOf(node)) {
        final _Picture picture => pw.WidgetSpan(
          child: pw.ConstrainedBox(
            constraints: const pw.BoxConstraints(
              maxWidth: PdfWidgetsDocumentExporterImpl._textWidth,
              maxHeight: _inlineImage,
            ),
            child: picture.draw(),
          ),
        ),
        // Missing, unreadable or not an image: the words it stood for.
        null => pw.TextSpan(text: node.attributes['alt'] ?? ''),
      },
      'input' => _checkbox(node.attributes.containsKey('checked')),
      _FootnoteMarker.tag => pw.TextSpan(
        text: node.textContent,
        // Raised and shrunk by hand, as the preview does: the serif carries
        // no superior figures.
        style: const pw.TextStyle(fontSize: _body * 0.7),
        baseline: _body * 0.35,
      ),
      _ => pw.TextSpan(children: _inline(children)),
    };
  }

  /// A task's box, drawn rather than typed, since no face here has a glyph
  /// for one.
  pw.InlineSpan _checkbox(bool checked) => pw.WidgetSpan(
    child: pw.Container(
      width: 8,
      height: 8,
      margin: const pw.EdgeInsets.only(right: 4),
      padding: const pw.EdgeInsets.all(1.5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _quiet, width: 0.75),
      ),
      child: checked ? pw.Container(color: _quiet) : null,
    ),
  );
}

/// An image a document names, decoded into the PDF once and drawn wherever
/// it is named.
final class _Picture {
  const _Picture(this.draw);

  /// A fresh widget each time, since a `pdf` widget cannot sit in two places.
  final pw.Widget Function() draw;

  /// [bytes] inside [pdf] — PNG, JPEG, the rest `image` decodes, or SVG —
  /// or null when `pdf` cannot draw them.
  ///
  /// Decoded here rather than while the page paints, so a broken file costs
  /// its own picture and never the export.
  static _Picture? of(PdfDocument pdf, Uint8List bytes) {
    try {
      if (_isSvg(bytes)) {
        final String svg = utf8.decode(bytes);
        pw.SvgImage(svg: svg);
        return _Picture(() => pw.SvgImage(svg: svg, fit: pw.BoxFit.scaleDown));
      }
      final pw.ImageProvider image = pw.ImageProxy(
        PdfImage.file(pdf, bytes: bytes),
      );
      return _Picture(() => pw.Image(image, fit: pw.BoxFit.scaleDown));
    } on Object {
      return null;
    }
  }

  static bool _isSvg(Uint8List bytes) {
    final String head = utf8
        .decode(bytes.take(512).toList(), allowMalformed: true)
        .trimLeft();
    return (head.startsWith('<svg') || head.startsWith('<?xml')) &&
        head.contains('<svg');
  }
}

/// A page break taken only when the headings in [run] would otherwise sit
/// alone at a page's foot, apart from the start of the block after them.
///
/// `MultiPage` asks a `NewPage` whether it is needed before laying it out,
/// so the run is measured here, as the page will lay it. A block that
/// splits across pages needs only its first lines kept; one that cannot is
/// kept whole, unless the run is taller than a page and no break would help.
final class _KeepWithNext extends pw.NewPage {
  _KeepWithNext(this.context, this.run);

  final pw.Context context;
  final List<(pw.Widget, bool)> run;

  /// How much of a block that splits has to come along: three lines.
  static const double _start = 3 * (_Writer._body + 4);

  @override
  bool newPageNeeded(double availableSpace) {
    double needed = 0;
    for (final (pw.Widget widget, bool heading) in run) {
      widget.layout(
        context,
        const pw.BoxConstraints(
          maxWidth: PdfWidgetsDocumentExporterImpl._textWidth,
        ),
      );
      final double height = widget.box?.height ?? 0;
      final bool splits = widget is pw.SpanningWidget && widget.canSpan;
      needed += heading || !splits ? height : math.min(height, _start);
    }
    return needed > availableSpace &&
        needed <= PdfWidgetsDocumentExporterImpl._textHeight;
  }
}

/// Turns `[^label]` into the number the **document** gave that note, and
/// leaves a reference to no note exactly as written — the preview's rule
/// ([Decision 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
final class _FootnoteMarker extends md.InlineSyntax {
  _FootnoteMarker(this.numbers) : super(r'\[\^([^\]\s]+)\]');

  final Map<String, int> numbers;

  static const String tag = 'tomFootnoteRef';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final int? number = numbers[match.group(1)];
    // Consumed either way: answering false leaves the parser on the same
    // character for ever.
    parser.addNode(
      number == null
          ? md.Text(match[0] ?? '')
          : md.Element(tag, <md.Node>[md.Text('$number')]),
    );
    return true;
  }
}
