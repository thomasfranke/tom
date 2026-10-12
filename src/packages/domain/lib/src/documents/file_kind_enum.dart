/// What kind of file a path names, read off its extension.
library;

/// The kinds the status bar names, and the one the editor renders.
///
/// Read from the extension alone, never from the content: the name is what
/// the person sees in the tree and the list, and what they expect it to be
/// called (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
enum FileKindEnum {
  /// Markdown, the one kind the preview renders.
  markdown,

  /// JSON.
  json,

  /// YAML.
  yaml,

  /// TOML.
  toml,

  /// XML.
  xml,

  /// HTML.
  html,

  /// CSS.
  css,

  /// JavaScript.
  javascript,

  /// TypeScript.
  typescript,

  /// Dart.
  dart,

  /// Python.
  python,

  /// A shell script.
  shell,

  /// Anything else that is text.
  plainText;

  /// The kind [path] names, by its last extension; plain text when there is
  /// none or nobody named it.
  static FileKindEnum of(String path) {
    final String name = path.split('/').last.toLowerCase();
    final int dot = name.lastIndexOf('.');
    return dot <= 0
        ? plainText
        : _byExtension[name.substring(dot + 1)] ?? plainText;
  }

  /// Whether this is the kind the preview renders.
  bool get isMarkdown => this == markdown;

  static const Map<String, FileKindEnum> _byExtension = <String, FileKindEnum>{
    'md': markdown,
    'json': json,
    'yaml': yaml,
    'yml': yaml,
    'toml': toml,
    'xml': xml,
    'html': html,
    'htm': html,
    'css': css,
    'js': javascript,
    'mjs': javascript,
    'ts': typescript,
    'dart': dart,
    'py': python,
    'sh': shell,
    'bash': shell,
    'zsh': shell,
  };
}
