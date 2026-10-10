/// How the source pane colours markdown.
library;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:tom_ui/tom_ui.dart';

/// The scope a `[[…]]` run is given, and the theme's key for it.
const String editorWikilinkScope = 'tom-wikilink';

/// `re_highlight`'s markdown with `[[…]]` asked first, so the link syntax
/// never claims the bracket. An unclosed `[[` runs to the end of its line,
/// because that is the link still being typed
/// (`design/screens/desktop/editor-links-export/linking-a-document-light.svg`).
final Mode editorMarkdown = Mode(
  name: 'Markdown',
  refs: langMarkdown.refs,
  contains: <Mode>[
    Mode(scope: editorWikilinkScope, match: r'\[\[[^\[\]\n]*(?:\]\])?'),
    ...(langMarkdown.contains as List<Mode>),
  ],
);

/// The highlighting the source pane is given in [brightness], the wikilink
/// in `accent` as the boards draw it
/// (`design/screens/desktop/editor-links-export/wikilinks-light.svg`).
CodeHighlightTheme editorHighlightOf(TomColors colors, Brightness brightness) =>
    CodeHighlightTheme(
      languages: <String, CodeHighlightThemeMode>{
        'markdown': CodeHighlightThemeMode(mode: editorMarkdown),
      },
      theme: <String, TextStyle>{
        ...(brightness == Brightness.dark
            ? atomOneDarkTheme
            : atomOneLightTheme),
        editorWikilinkScope: TextStyle(color: colors.accent),
      },
    );
