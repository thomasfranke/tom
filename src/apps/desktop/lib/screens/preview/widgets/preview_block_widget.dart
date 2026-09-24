/// One block, in the container the app owns.
library;

import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/preview/code_highlighter_impl.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One block, in the container the app owns.
///
/// The container is the point: today it is a box with a gap under it, and in
/// M2 it is what carries the diff mark and the navigation anchor. What is
/// *inside* it is delegated.
class PreviewBlockWidget extends ConsumerWidget {
  /// Creates the view of [block], scoped by [document].
  const PreviewBlockWidget({
    required this.block,
    required this.document,
    required this.body,
    this.struckThrough = false,
    super.key,
  });

  /// The block to draw.
  final BlockValueObject block;

  /// The document it belongs to, for the scope it needs to render alone.
  final ParsedDocumentValueObject document;

  /// The prose size, which is the reading mode's answer or the split's.
  final double body;

  /// Whether the text is drawn as gone.
  ///
  /// What a removed block looks like in the rendered diff: still rendered,
  /// because reading what was deleted is the point, and struck through
  /// because it is not in the document any more.
  final bool struckThrough;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<BlockValueObject>('block', block))
      ..add(
        DiagnosticsProperty<ParsedDocumentValueObject>('document', document),
      )
      ..add(DoubleProperty('body', body))
      ..add(DiagnosticsProperty<bool>('struckThrough', struckThrough));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    // A link or an image is written relative to the document it is in, so
    // the block needs to know which document that is — not just the space.
    final SpaceRelativePathValueObject? origin = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
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
      styleSheet: _styleSheetOf(context, colors, body, struckThrough),
      syntaxHighlighter: CodeHighlighterImpl(
        language: _languageOf(block),
        brightness: Theme.of(context).brightness,
      ),
      imageBuilder: (Uri uri, String? title, String? alt) =>
          _image(uri, alt, space, origin, colors),
      onTapLink: (String text, String? href, String? title) =>
          _follow(href, origin, ref),
    );
  }

  /// The fence's language, or empty when it has none.
  ///
  /// Read off the block's own first line, because the highlighter is handed
  /// the code and not the fence.
  static String _languageOf(BlockValueObject block) {
    if (block.kind != BlockKindEnum.code) {
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
  /// image would be the network, and nothing in TOM reaches it yet. The
  /// path is read from [origin]'s folder, the way the document's author
  /// wrote it.
  static Widget _image(
    Uri uri,
    String? alt,
    SpaceEntity? space,
    SpaceRelativePathValueObject? origin,
    TomColors colors,
  ) {
    if (uri.hasScheme && !uri.isScheme('file')) {
      return _missing(alt ?? uri.toString(), colors);
    }
    final SpaceRelativePathValueObject? path = origin?.resolve(
      Uri.decodeFull(uri.path),
    );
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
      fontSize: PreviewDesign.body,
      height: PreviewDesign.bodyHeight,
      fontStyle: FontStyle.italic,
      color: colors.textMuted,
    ),
  );

  /// Opens [href] when it names a document in this space.
  ///
  /// A relative link to a `.md` file is navigation the app already has, so
  /// it moves the session — read from [origin]'s folder, so `../about.md`
  /// in `guides/writing.md` is `about.md`, and a link that climbs out of
  /// the space is refused. **An external link does nothing yet**: opening a
  /// browser needs a plugin, and taking one is the maintainer's call.
  static void _follow(
    String? href,
    SpaceRelativePathValueObject? origin,
    WidgetRef ref,
  ) {
    if (href == null || origin == null) {
      return;
    }
    final Uri? uri = Uri.tryParse(href);
    if (uri == null || uri.hasScheme || uri.path.isEmpty) {
      return;
    }
    final SpaceRelativePathValueObject? path = origin.resolve(
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
    double body,
    bool struckThrough,
  ) {
    // The one thing a removed block changes about its own rendering: it is
    // still the document's type at the document's size, because it is being
    // read, and the line through it is what says it is gone.
    final TextDecoration? gone = struckThrough
        ? TextDecoration.lineThrough
        : null;
    final TextStyle prose = TextStyle(
      fontSize: body,
      height: PreviewDesign.bodyHeight,
      color: colors.textPrimary,
      decoration: gone,
    );
    return MarkdownStyleSheet(
      p: prose,
      h1: _headingStyle(PreviewDesign.headingLarge, colors, gone),
      h2: _headingStyle(PreviewDesign.headingLarge, colors, gone),
      h3: _headingStyle(PreviewDesign.heading, colors, gone),
      h4: _headingStyle(body, colors, gone),
      h5: _headingStyle(body, colors, gone),
      h6: _headingStyle(body, colors, gone),
      a: prose.copyWith(color: colors.accent),
      em: prose.copyWith(fontStyle: FontStyle.italic),
      strong: prose.copyWith(fontWeight: FontWeight.w600),
      listBullet: prose,
      blockquote: prose.copyWith(color: colors.textSecondary),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colors.border, width: PreviewDesign.quoteBar),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: TomMetrics.padTight),
      code: TextStyle(
        fontFamily: 'Menlo',
        fontSize: PreviewDesign.code,
        height: 1.6,
        color: colors.textPrimary,
        backgroundColor: colors.surfaceSunken,
      ),
      codeblockDecoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(6),
      ),
      codeblockPadding: const EdgeInsets.all(PreviewDesign.codePad),
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
  static TextStyle _headingStyle(
    double size,
    TomColors colors,
    TextDecoration? decoration,
  ) => TextStyle(
    fontSize: size,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
    decoration: decoration,
  );
}
