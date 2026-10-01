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
/// `re_highlight` is what source mode already brings
/// ([Decision 18](../../../../../../docs/technical/decisions/018-source-mode-uses-re-editor.md)).
/// An unknown language is left unstyled rather than guessed at.
class CodeHighlighterImpl implements SyntaxHighlighter {
  /// Creates a highlighter for [language], in [brightness], over [style].
  CodeHighlighterImpl({
    required this.language,
    required this.brightness,
    required this.style,
  });

  /// The fence's language tag, lowercased, or empty for a bare fence.
  final String language;

  /// Which mode the theme must match.
  final Brightness brightness;

  /// How the code is drawn before anything is coloured.
  ///
  /// Handed in because a fence reads it nowhere else: with a highlighter set,
  /// `flutter_markdown_plus` renders the fence from `formatText` alone and
  /// never applies the style sheet's `code`.
  final TextStyle style;

  /// The engine, built once: registering every language is the expensive
  /// part.
  static final Highlight _engine = Highlight()
    ..registerLanguages(builtinAllLanguages);

  @override
  TextSpan format(String source) => TextSpan(
    // The colouring goes inside the style: a theme sets a colour and nothing
    // else, and a span's style merges over the one it sits in.
    style: style,
    children: <InlineSpan>[_coloured(source)],
  );

  /// [source] with each token in the theme's colour, or plain in one span.
  TextSpan _coloured(String source) {
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
