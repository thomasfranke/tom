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

/// One block, in the container the app owns; what is inside it is
/// delegated.
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

  /// The prose size, the reading mode's or the split's.
  final double body;

  /// Whether the text is struck through, as a removed block is: still
  /// rendered, because reading what was deleted is the point.
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
    // A link or an image is relative to the document it is in, not the space.
    final SpaceRelativePathValueObject? origin = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    return MarkdownBody(
      // The link reference definitions are document scope, so a block
      // rendered alone would otherwise draw `[text][ref]` literally.
      // Footnotes do not survive the same way (Decision 19).
      data: document.linkDefinitions.isEmpty
          ? block.source
          : '${block.source}\n\n${document.linkDefinitions}',
      selectable: true,
      styleSheet: _styleSheetOf(context, colors, body, struckThrough),
      syntaxHighlighter: CodeHighlighterImpl(
        language: _languageOf(block),
        brightness: Theme.of(context).brightness,
        style: _codeStyle(colors, struckThrough),
      ),
      imageBuilder: (Uri uri, String? title, String? alt) =>
          _image(uri, alt, space, origin, colors),
      onTapLink: (String text, String? href, String? title) =>
          _follow(href, origin, ref),
    );
  }

  /// The fence's language, or empty when it has none; read off the block's
  /// first line because the highlighter is handed the code, not the fence.
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
  /// Local files only, resolved from [origin]'s folder; nothing in TOM
  /// reaches the network yet.
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
  /// Resolved from [origin]'s folder, and a link that climbs out of the
  /// space is refused. An external link does nothing yet: opening a browser
  /// needs a plugin.
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

  /// The document's type, the system's faces until the real ones are
  /// bundled.
  static MarkdownStyleSheet _styleSheetOf(
    BuildContext context,
    TomColors colors,
    double body,
    bool struckThrough,
  ) {
    final TextDecoration? gone = _gone(struckThrough);
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
      // Inline code only: a fence never reads this (see [_codeStyle]).
      code: _codeStyle(colors, struckThrough),
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
      // The gap between blocks is the container's, not the renderer's.
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

  /// The line through a removed block's text, or nothing; the one thing a
  /// removed block changes about its own rendering.
  static TextDecoration? _gone(bool struckThrough) =>
      struckThrough ? TextDecoration.lineThrough : null;

  /// How code is drawn, fenced or inline.
  ///
  /// Handed to both the style sheet and [CodeHighlighterImpl], because a
  /// fence reads the sheet's `code` nowhere.
  static TextStyle _codeStyle(TomColors colors, bool struckThrough) =>
      TextStyle(
        fontFamily: 'Menlo',
        fontSize: PreviewDesign.code,
        height: 1.6,
        color: colors.textPrimary,
        backgroundColor: colors.surfaceSunken,
        decoration: _gone(struckThrough),
      );
}
