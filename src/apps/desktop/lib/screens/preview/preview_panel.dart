/// The preview: the open document, rendered block by block.
library;

import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/preview/code_highlighter.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// What the design fixes about the preview.
///
/// The reading column is a *measure*, not a pane width: prose is set to a
/// line length, and the pane is whatever is left around it. Type comes from
/// the table in
/// [components.md](../../../../../../docs/technical/design/components.md).
///
/// These are the split-view numbers, which is where the preview sits while
/// it shares the document area. Reading mode's more generous 660 and 16
/// arrive with the mode bar, in source mode's milestone.
abstract final class _Design {
  /// The reading measure, beside the source pane.
  static const double measure = 540;

  /// Caption, then the first block.
  static const double captionTop = 18;
  static const double bodyTop = 42;

  /// Prose, and the headings over it.
  static const double body = 15;
  static const double bodyHeight = 1.7;
  static const double headingLarge = 24;
  static const double heading = 17;
  static const double code = 12.5;
  static const double caption = 10;

  /// The gap between two blocks, and what a block's own padding is.
  static const double blockGap = 18;
  static const double codePad = 14;
  static const double quoteBar = 3;
}

/// The open document, one container per block.
///
/// **Assembled block by block, never as one widget tree**
/// ([flows](../../../../../../docs/technical/flows.md#the-preview-is-assembled-block-by-block)):
/// the container around each block is ours, and it is what will carry the
/// diff decoration in M2. Inline markdown inside a block is delegated, which
/// is where CommonMark's real complexity lives.
class PreviewPanel extends ConsumerWidget {
  /// Creates the panel.
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreviewState state = ref.watch(previewProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: _Design.captionTop),
        const _Caption(),
        const SizedBox(
          height: _Design.bodyTop - _Design.captionTop - _Design.caption * 1.4,
        ),
        Expanded(
          child: switch (state) {
            PreviewEmpty() => const _Note('Choose a document in the explorer.'),
            PreviewLoading() => const _Note('Reading the document…'),
            PreviewFailed(failure: final AppFailure failure) => _Note(
              _explain(failure),
            ),
            PreviewReady(document: final ParsedDocument document) => _Document(
              document: document,
            ),
          },
        ),
      ],
    );
  }

  /// What to say about a document that did not open.
  ///
  /// A catch-all, because this switches over [AppFailure] itself: whatever
  /// went wrong, the panel says something rather than staying blank.
  static String _explain(AppFailure failure) => switch (failure) {
    DocumentNotFound() => 'That document is no longer there.',
    DocumentPermissionDenied() => 'TOM is not allowed to read that document.',
    DocumentNotUtf8() =>
      'That file is not UTF-8 text, so TOM will not open it.',
    _ => 'That document could not be read.',
  };
}

/// What the panel is called, in the design's own words.
class _Caption extends StatelessWidget {
  const _Caption();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      'PREVIEW',
      style: TextStyle(
        fontSize: _Design.caption,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// A line of prose where the document would be.
class _Note extends StatelessWidget {
  const _Note(this.text);

  /// What it says.
  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// The document, scrolling as one column of blocks.
class _Document extends StatelessWidget {
  const _Document({required this.document});

  /// What to render.
  final ParsedDocument document;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ParsedDocument>('document', document));
  }

  @override
  Widget build(BuildContext context) {
    if (document.blocks.isEmpty) {
      return const _Note('This document is empty.');
    }
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        // A measure, not a pane: the column keeps its line length whatever
        // the window does, and the pane grows around it.
        width: _Design.measure + TomMetrics.pad * 2,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TomMetrics.pad,
            0,
            TomMetrics.pad,
            TomMetrics.pad,
          ),
          itemCount: document.blocks.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: _Design.blockGap),
          itemBuilder: (BuildContext context, int index) =>
              _BlockView(block: document.blocks[index], document: document),
        ),
      ),
    );
  }
}

/// One block, in the container the app owns.
///
/// The container is the point: today it is a box with a gap under it, and in
/// M2 it is what carries the diff mark and the navigation anchor. What is
/// *inside* it is delegated.
class _BlockView extends ConsumerWidget {
  const _BlockView({required this.block, required this.document});

  /// The block to draw.
  final Block block;

  /// The document it belongs to, for the scope it needs to render alone.
  final ParsedDocument document;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Block>('block', block))
      ..add(DiagnosticsProperty<ParsedDocument>('document', document));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final Space? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    return MarkdownBody(
      // The link reference definitions travel with the block: they are
      // declared at document scope, so a block rendered on its own would
      // otherwise draw `[text][ref]` as literal text. Footnotes do not
      // survive the same way — M2's problem (Decision 19).
      data: document.linkDefinitions.isEmpty
          ? block.source
          : '${block.source}\n\n${document.linkDefinitions}',
      selectable: true,
      styleSheet: _styleSheetOf(context, colors),
      syntaxHighlighter: CodeHighlighter(
        language: _languageOf(block),
        brightness: Theme.of(context).brightness,
      ),
      imageBuilder: (Uri uri, String? title, String? alt) =>
          _image(uri, alt, space, colors),
      onTapLink: (String text, String? href, String? title) =>
          _follow(href, space, ref),
    );
  }

  /// The fence's language, or empty when it has none.
  ///
  /// Read off the block's own first line, because the highlighter is handed
  /// the code and not the fence.
  static String _languageOf(Block block) {
    if (block.kind != BlockKind.code) {
      return '';
    }
    final String first = block.source.split('\n').first.trim();
    return first.startsWith('```') || first.startsWith('~~~')
        ? first.substring(3).trim().toLowerCase()
        : '';
  }

  /// An image from the space, or a line saying it is not there.
  ///
  /// Local files only: a document's images live beside it in the repository,
  /// which is the whole point of keeping documentation in one. A remote
  /// image would be the network, and nothing in TOM reaches it yet.
  static Widget _image(Uri uri, String? alt, Space? space, TomColors colors) {
    if (uri.hasScheme && !uri.isScheme('file')) {
      return _missing(alt ?? uri.toString(), colors);
    }
    final SpaceRelativePath? path = space == null
        ? null
        : SpaceRelativePath.tryParse(Uri.decodeFull(uri.path));
    if (path == null || space == null) {
      return _missing(alt ?? uri.toString(), colors);
    }
    return Image.file(
      File(space.absolutePathOf(path)),
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _missing(alt ?? path.value, colors),
    );
  }

  /// What an image that cannot be shown looks like.
  static Widget _missing(String label, TomColors colors) => Text(
    label,
    style: TextStyle(
      fontSize: _Design.body,
      height: _Design.bodyHeight,
      fontStyle: FontStyle.italic,
      color: colors.textMuted,
    ),
  );

  /// Opens [href] when it names a document in this space.
  ///
  /// A relative link to a `.md` file is navigation the app already has, so
  /// it moves the session. **An external link does nothing yet**: opening a
  /// browser needs a plugin, and taking one is the maintainer's call.
  static void _follow(String? href, Space? space, WidgetRef ref) {
    if (href == null || space == null) {
      return;
    }
    final Uri? uri = Uri.tryParse(href);
    if (uri == null || uri.hasScheme) {
      return;
    }
    final SpaceRelativePath? path = SpaceRelativePath.tryParse(
      Uri.decodeFull(uri.path),
    );
    if (path != null && path.isMarkdown) {
      ref.read(spaceSessionProvider.notifier).show(path);
    }
  }

  /// The document's type, from the table.
  ///
  /// Serif for prose and mono for code, both the system's until the faces
  /// are bundled — the same stand-in Home draws the wordmark's text with.
  static MarkdownStyleSheet _styleSheetOf(
    BuildContext context,
    TomColors colors,
  ) {
    final TextStyle prose = TextStyle(
      fontSize: _Design.body,
      height: _Design.bodyHeight,
      color: colors.textPrimary,
    );
    return MarkdownStyleSheet(
      p: prose,
      h1: _headingStyle(_Design.headingLarge, colors),
      h2: _headingStyle(_Design.headingLarge, colors),
      h3: _headingStyle(_Design.heading, colors),
      h4: _headingStyle(_Design.body, colors),
      h5: _headingStyle(_Design.body, colors),
      h6: _headingStyle(_Design.body, colors),
      a: prose.copyWith(color: colors.accent),
      em: prose.copyWith(fontStyle: FontStyle.italic),
      strong: prose.copyWith(fontWeight: FontWeight.w600),
      listBullet: prose,
      blockquote: prose.copyWith(color: colors.textSecondary),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colors.border, width: _Design.quoteBar),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: TomMetrics.padTight),
      code: TextStyle(
        fontFamily: 'Menlo',
        fontSize: _Design.code,
        height: 1.6,
        color: colors.textPrimary,
        backgroundColor: colors.surfaceSunken,
      ),
      codeblockDecoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(6),
      ),
      codeblockPadding: const EdgeInsets.all(_Design.codePad),
      tableHead: prose.copyWith(fontWeight: FontWeight.w600),
      tableBody: prose,
      tableBorder: TableBorder.all(color: colors.border),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      // The gap between blocks is the container's, not the renderer's: one
      // block is one MarkdownBody, and it must not add a second margin.
      blockSpacing: 0,
    );
  }

  /// A heading at [size].
  static TextStyle _headingStyle(double size, TomColors colors) => TextStyle(
    fontSize: size,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );
}
