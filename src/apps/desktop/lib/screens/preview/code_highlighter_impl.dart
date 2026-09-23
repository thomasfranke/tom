/// Colouring the code blocks the preview renders.
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

/// Highlights a code block in [language], or leaves it plain.
///
/// The same package source mode already brings ([Decision
/// 18](../../../../../../docs/technical/decisions/018-source-mode-uses-re-editor.md)),
/// so highlighting the preview costs no new dependency.
///
/// A language the highlighter does not know is rendered unstyled rather than
/// guessed at: a wrong colouring reads as a bug in the document.
class CodeHighlighterImpl implements SyntaxHighlighter {
  /// Creates a highlighter for [language], in [brightness].
  CodeHighlighterImpl({required this.language, required this.brightness});

  /// The fence's language tag, lowercased, or empty for a bare fence.
  final String language;

  /// Which mode the theme must match.
  final Brightness brightness;

  /// The engine, built once: registering every language is the expensive
  /// part and it does not depend on the block.
  static final Highlight _engine = Highlight()
    ..registerLanguages(builtinAllLanguages);

  @override
  TextSpan format(String source) {
    if (!_engine.listLanguages().contains(language)) {
      return TextSpan(text: source);
    }
    final TextSpanRenderer renderer = TextSpanRenderer(
      null,
      brightness == Brightness.dark ? atomOneDarkTheme : atomOneLightTheme,
    );
    _engine.highlight(code: source, language: language).render(renderer);
    return renderer.span ?? TextSpan(text: source);
  }
}
