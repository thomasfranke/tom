/// Spike B — what the `markdown` package's AST can and cannot carry.
///
/// Pure Dart, and runnable on its own:
///
/// ```bash
/// cd src/apps/desktop
/// dart run lib/spikes/spike_b/ast_report.dart ../../../docs
/// ```
///
/// The five questions are the ones the [domain
/// model](../../../../../../docs/technical/domain-model.md) formulated, and
/// they are answered against this repository's own documentation rather than
/// a fixture: the project is its own first space, and a spike that only
/// parses what it invented proves nothing. The one fixture that *is* here
/// exists because the corpus turned out not to exercise the question that
/// mattered most — see `document_scoped_fixture.dart`.
///
/// **Answered.** The verdict is [Decision
/// 19](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md).
///
/// It is kept rather than deleted, and states when it goes, the way a
/// feature flag has to (`CONTRIBUTING.md`). The reason is in the decision's
/// own "revisit when": a package upgrade that adds a block syntax produces
/// blocks with no position, and **this report is the check** — section 0
/// catches a parse that changed, section 2 catches a block that lost its
/// place. **It goes when the real parser lands in `tom_infra` with tests
/// that make the same assertions.**
library;

import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:tom_desktop/spikes/spike_b/document_scoped_fixture.dart';
import 'package:tom_desktop/spikes/spike_b/positioned_blocks.dart';

/// How many times each parse is measured, after a warm-up run.
const int _runs = 5;

/// Runs the report over the markdown under the directories given, or `docs`.
void main(List<String> arguments) {
  final List<File> files = _markdownUnder(
    arguments.isEmpty ? <String>['../../../docs'] : arguments,
  );
  if (files.isEmpty) {
    stdout.writeln('No markdown found. Pass a directory.');
    return;
  }
  stdout
    ..writeln('# Spike B — the `markdown` package AST')
    ..writeln()
    ..writeln('${files.length} documents, ${_lineCount(files)} lines')
    ..writeln();

  final _Totals totals = _Totals();
  for (final File file in files) {
    _inspect(file, totals);
  }
  totals.report();
  _reportDocumentScoped();
  _reportFidelity(files);
}

/// Everything the run learned, accumulated across documents.
class _Totals {
  final Map<String, int> tags = <String, int>{};
  final Map<int, int> spanHistogram = <int, int>{};
  final List<String> unpositioned = <String>[];
  final List<String> standsAlone = <String>[];
  final List<String> needsReferences = <String>[];
  final List<String> differsAnyway = <String>[];
  final Map<String, int> headingPaths = <String, int>{};
  final Map<String, int> contentHashes = <String, int>{};
  int blocks = 0;
  int documents = 0;
  Duration positioned = Duration.zero;
  Duration plain = Duration.zero;

  void report() {
    stdout
      ..writeln('## 1 · Granularity — what counts as one block')
      ..writeln()
      ..writeln('$blocks top-level blocks across $documents documents.')
      ..writeln();
    final List<MapEntry<String, int>> byCount = tags.entries.toList()
      ..sort(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            b.value.compareTo(a.value),
      );
    for (final MapEntry<String, int> entry in byCount) {
      stdout.writeln('  ${entry.key.padRight(12)} ${entry.value}');
    }
    stdout
      ..writeln()
      ..writeln('Lines per block:')
      ..writeln('  1 line        ${spanHistogram[1] ?? 0}')
      ..writeln('  2-5 lines     ${_range(2, 5)}')
      ..writeln('  6-20 lines    ${_range(6, 20)}')
      ..writeln('  21+ lines     ${_range(21, 100000)}')
      ..writeln('  longest       ${spanHistogram.keys.fold(0, _max)} lines')
      ..writeln()
      ..writeln('## 2 · Source positions')
      ..writeln()
      ..writeln('Blocks with no recoverable position: ${unpositioned.length}');
    for (final String example in unpositioned.take(5)) {
      stdout.writeln('  $example');
    }
    stdout
      ..writeln()
      ..writeln('## 5 · Rendering a block in isolation')
      ..writeln()
      ..writeln('  identical alone                 ${standsAlone.length}')
      ..writeln(
        '  identical once references are '
        'carried  ${needsReferences.length}',
      )
      ..writeln('  still different                 ${differsAnyway.length}');
    for (final String example in needsReferences.take(3)) {
      stdout.writeln('    needs refs: $example');
    }
    for (final String example in differsAnyway.take(5)) {
      stdout.writeln('    differs:    $example');
    }
    stdout
      ..writeln()
      ..writeln('## 4 · Identity')
      ..writeln()
      ..writeln(
        '  distinct heading paths   ${headingPaths.length} '
        'for $blocks blocks',
      )
      ..writeln(
        '  paths holding >1 block   '
        '${headingPaths.values.where((int n) => n > 1).length}',
      )
      ..writeln(
        '  identical block contents '
        '${contentHashes.values.where((int n) => n > 1).length}',
      )
      ..writeln()
      ..writeln('## 3 · Cost of carrying both text and structure')
      ..writeln()
      ..writeln('  plain parse                ${_ms(plain)}')
      ..writeln('  parse with positions       ${_ms(positioned)}')
      ..writeln('  overhead                   ${_overhead()}');
  }

  /// The cost of positions as a percentage over a plain parse.
  String _overhead() {
    final double ratio = positioned.inMicroseconds / plain.inMicroseconds;
    return '${((ratio - 1) * 100).toStringAsFixed(0)}%';
  }

  int _range(int from, int to) => spanHistogram.entries
      .where((MapEntry<int, int> e) => e.key >= from && e.key <= to)
      .fold(0, (int sum, MapEntry<int, int> e) => sum + e.value);

  static int _max(int a, int b) => a > b ? a : b;

  static String _ms(Duration d) =>
      '${(d.inMicroseconds / 1000).toStringAsFixed(1)}ms';
}

/// Checks that recording positions does not change what is parsed.
///
/// The precondition for everything else in this report. The mechanism
/// replaces every block syntax with a wrapper, and a wrapper that perturbs
/// the parser's state — the lookahead a setext heading needs, the
/// `linesToConsume` buffer a paragraph hands back when it is interrupted —
/// would produce positions for a document nobody wrote.
void _reportFidelity(List<File> files) {
  int same = 0;
  final List<String> different = <String>[];
  // The fixture is checked alongside the corpus, and it is the half that
  // matters: the corpus contains no setext heading, no reference link and
  // no footnote, so a wrapper that broke exactly those would pass on 50
  // documents and fail on the one that was written to catch it.
  final Map<String, String> sources = <String, String>{
    for (final File file in files) file.path: file.readAsStringSync(),
    'the document-scoped fixture': documentScopedFixture,
  };
  for (final MapEntry<String, String> entry in sources.entries) {
    final String text = entry.value;
    final String plain = _render(
      md.Document(
        extensionSet: md.ExtensionSet.gitHubWeb,
      ).parseLines(text.split('\n')),
    );
    final String wrapped = _render(
      parseWithPositions(text).blocks.map(_nodeOf).toList(),
    );
    if (plain == wrapped) {
      same++;
    } else {
      different.add(entry.key.split('/').last);
    }
  }
  stdout
    ..writeln()
    ..writeln('## 0 · Does recording positions change the parse?')
    ..writeln()
    ..writeln('  identical to a plain parse   $same')
    ..writeln('  different                    ${different.length}');
  for (final String name in different.take(10)) {
    stdout.writeln('    $name');
  }
}

/// Answers question 5 against markdown that is actually document-scoped.
///
/// Three outcomes per block, and which one a block falls into is the whole
/// answer: it stands alone, it stands once the document's reference map is
/// handed to the second parse, or it cannot be recovered at all.
void _reportDocumentScoped() {
  final ParsedDocument parsed = parseWithPositions(documentScopedFixture);
  stdout
    ..writeln()
    ..writeln('## 5b · Blocks that depend on the document')
    ..writeln()
    ..writeln(
      'A fixture built to break isolation — '
      '${parsed.blocks.length} blocks.',
    )
    ..writeln();
  for (final SourceBlock block in parsed.blocks) {
    final String inDocument = _render(<md.Node>[block.node]);
    final String alone = _render(
      parseWithPositions(block.source).blocks.map(_nodeOf).toList(),
    );
    final String withContext = _render(
      parseWithPositions(
        block.source,
        inheritedReferences: parsed.document.linkReferences,
      ).blocks.map(_nodeOf).toList(),
    );
    final String verdict = alone == inDocument
        ? 'stands alone'
        : withContext == inDocument
        ? 'NEEDS the reference map'
        : 'LOST';
    stdout.writeln(
      '  line ${block.startLine.toString().padLeft(2)} '
      '${block.tag.padRight(11)} $verdict',
    );
    if (verdict == 'LOST') {
      stdout
        ..writeln('      in document: ${_snippet(inDocument)}')
        ..writeln('      alone:       ${_snippet(alone)}')
        ..writeln('      with refs:   ${_snippet(withContext)}');
    }
  }
}

/// Parses one file and folds what it says into [totals].
void _inspect(File file, _Totals totals) {
  final String text = file.readAsStringSync();
  totals.documents++;

  // Warmed first, and each measured the same number of times: whichever
  // parse runs first otherwise pays the JIT's warm-up for both, which is how
  // the first version of this spike reported positions as *cheaper* than no
  // positions.
  final List<String> lines = text.split('\n');
  md.Document(extensionSet: md.ExtensionSet.gitHubWeb).parseLines(lines);
  parseWithPositions(text);

  final Stopwatch plainWatch = Stopwatch()..start();
  for (int run = 0; run < _runs; run++) {
    md.Document(extensionSet: md.ExtensionSet.gitHubWeb).parseLines(lines);
  }
  totals.plain += plainWatch.elapsed;

  final Stopwatch watch = Stopwatch()..start();
  late ParsedDocument parsed;
  for (int run = 0; run < _runs; run++) {
    parsed = parseWithPositions(text);
  }
  totals.positioned += watch.elapsed;

  final List<String> headings = <String>[];
  for (final SourceBlock block in parsed.blocks) {
    totals.blocks++;
    totals.tags[block.tag] = (totals.tags[block.tag] ?? 0) + 1;

    if (block.startLine < 0) {
      totals.unpositioned.add('${_name(file)} · ${block.tag}');
      continue;
    }
    totals.spanHistogram[block.lineCount] =
        (totals.spanHistogram[block.lineCount] ?? 0) + 1;

    _trackHeading(block, headings);
    final String path = '${_name(file)}#${headings.join('/')}';
    totals.headingPaths[path] = (totals.headingPaths[path] ?? 0) + 1;
    totals.contentHashes[block.source] =
        (totals.contentHashes[block.source] ?? 0) + 1;

    _checkIsolation(file, block, parsed, totals);
  }
}

/// Keeps [headings] as the chain of headings above [block].
void _trackHeading(SourceBlock block, List<String> headings) {
  final md.Node node = block.node;
  if (node is! md.Element || !RegExp(r'^h[1-6]$').hasMatch(node.tag)) {
    return;
  }
  final int level = int.parse(node.tag.substring(1));
  while (headings.length >= level) {
    headings.removeLast();
  }
  headings.add(node.textContent);
}

/// Re-parses [block] on its own and records whether it survives.
void _checkIsolation(
  File file,
  SourceBlock block,
  ParsedDocument parsed,
  _Totals totals,
) {
  // Trimmed on both sides: `HtmlRenderer` writes a newline *between*
  // blocks, so the same node rendered first in a list and rendered after
  // something else differ by one leading character that is not content.
  final String inDocument = _render(<md.Node>[block.node]);
  final String alone = _render(
    parseWithPositions(block.source).blocks.map(_nodeOf).toList(),
  );
  if (alone == inDocument) {
    totals.standsAlone.add('${_name(file)}:${block.startLine}');
    return;
  }
  final String withContext = _render(
    parseWithPositions(
      block.source,
      inheritedReferences: parsed.document.linkReferences,
    ).blocks.map(_nodeOf).toList(),
  );
  if (withContext == inDocument) {
    totals.needsReferences.add(
      '${_name(file)}:${block.startLine} ${block.tag}',
    );
  } else {
    totals.differsAnyway.add(
      '${_name(file)}:${block.startLine} ${block.tag} — '
      '${_snippet(inDocument)} vs ${_snippet(alone)}',
    );
    if (Platform.environment['SPIKE_B_VERBOSE'] != null) {
      stdout
        ..writeln('--- ${_name(file)}:${block.startLine} in document')
        ..writeln(inDocument.replaceAll(' ', '·'))
        ..writeln('--- alone')
        ..writeln(alone.replaceAll(' ', '·'))
        ..writeln('---');
    }
  }
}

/// How many lines [files] hold in total.
int _lineCount(List<File> files) => files.fold(
  0,
  (int sum, File file) => sum + file.readAsStringSync().split('\n').length,
);

/// [nodes] as HTML, trimmed so the renderer's block separator does not
/// count as a difference.
String _render(List<md.Node> nodes) => md.HtmlRenderer().render(nodes).trim();

md.Node _nodeOf(SourceBlock block) => block.node;

String _name(File file) => file.path.split('/').last;

String _snippet(String html) {
  final String flat = html.replaceAll('\n', ' ').trim();
  return flat.length <= 60 ? flat : '${flat.substring(0, 60)}…';
}

/// Every `.md` file under [paths], sorted.
List<File> _markdownUnder(List<String> paths) => <File>[
  for (final String path in paths)
    if (Directory(path).existsSync())
      ...Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.md'))
    else if (File(path).existsSync())
      File(path),
]..sort((File a, File b) => a.path.compareTo(b.path));
