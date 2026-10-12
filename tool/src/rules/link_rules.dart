// Whether a link in the written record leads anywhere.
library;

import 'dart:io';

import '../rule.dart';

/// The folders whose markdown is the written record.
const linkedFolders = <String>['docs', '.ai/skills'];

/// The files at the root that belong to it, each read on its own.
const linkedFiles = <String>['AGENTS.md', 'CONTRIBUTING.md', 'README.md'];

/// A relative link names a file that is there, and a heading that file has.
///
/// The corpus is the product's memory and is read by following it, so a link
/// to nothing is a rule nobody can reach. An address on the network is not
/// asked: a gate that needs one fails with the weather.
Iterable<Offence> linksResolve(Directory root) sync* {
  final anchors = <String, Set<String>>{};
  final listings = <String, Set<String>>{};
  Set<String> anchorsOf(File file) =>
      anchors.putIfAbsent(file.path, () => anchorsIn(file.readAsLinesSync()));

  for (final file in markdownUnder(root)) {
    final lines = file.readAsLinesSync();
    for (final link in linksIn(lines)) {
      final target = splitTarget(link.target);
      if (target == null) continue;

      final resolved = target.path.isEmpty
          ? file.path
          : _resolve(root, file, target.path);
      if (!_isThere(root, resolved, listings)) {
        yield (
          rule: 'a link leads to a file that exists',
          where: '${relative(root, file)}:${link.line}',
          detail: '${link.target} — nothing at ${_spelled(root, resolved)}',
        );
        continue;
      }

      final anchor = target.anchor;
      if (anchor == null || !resolved.endsWith('.md')) continue;
      if (anchorsOf(File(resolved)).contains(anchor.toLowerCase())) continue;
      yield (
        rule: 'a link leads to a heading that exists',
        where: '${relative(root, file)}:${link.line}',
        detail:
            '${link.target} — ${_spelled(root, resolved)} has no heading '
            'that reads as #$anchor',
      );
    }
  }
}

/// Every markdown file the record is made of, in a stable order so two runs
/// list the same breaks the same way.
List<File> markdownUnder(Directory root) {
  final found = <File>[
    for (final name in linkedFiles)
      if (File('${root.path}/$name') case final file when file.existsSync())
        file,
    for (final folder in linkedFolders)
      if (Directory('${root.path}/$folder') case final directory
          when directory.existsSync())
        ...directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md')),
  ];
  return found..sort((a, b) => slashed(a.path).compareTo(slashed(b.path)));
}

/// One link as the file spells it, and the line it is on, counting from one.
typedef Link = ({int line, String target});

/// The links in [lines]: `[text](target)`, an image, a `[label]: target`
/// definition, and an `href` or `src` written as HTML.
///
/// A fence and a code span are skipped, since what they hold is an example
/// of a link and not one.
Iterable<Link> linksIn(List<String> lines) sync* {
  for (final (index, line) in _prose(lines)) {
    for (final pattern in <RegExp>[_inline, _definition, _attribute]) {
      for (final match in pattern.allMatches(line)) {
        yield (line: index + 1, target: _unwrapped(match.group(1)!));
      }
    }
  }
}

/// The path and the heading a target names, or null when it is not a place
/// in this repository — an address with a scheme, or nothing at all.
({String path, String? anchor})? splitTarget(String target) {
  if (target.isEmpty || _scheme.hasMatch(target)) return null;
  final hash = target.indexOf('#');
  final path = hash < 0 ? target : target.substring(0, hash);
  final anchor = hash < 0 ? null : target.substring(hash + 1);
  final query = path.indexOf('?');
  return (
    path: _decoded(query < 0 ? path : path.substring(0, query)),
    // `#` alone is the top of the page, which every page has.
    anchor: anchor == null || anchor.isEmpty ? null : _decoded(anchor),
  );
}

/// What a link's `#fragment` can be in a file made of [lines]: each heading
/// as GitHub spells it, and each `id` or `name` written as HTML.
///
/// A heading said twice is numbered from the second on, as GitHub numbers
/// it. A name with an underscore is kept both ways, because whether `_` was
/// emphasis is the one thing a line-by-line reading cannot tell.
Set<String> anchorsIn(List<String> lines) {
  final found = <String>{};
  final seen = <String, int>{};
  void add(String heading) {
    for (final slug in <String>{
      slugOf(heading),
      slugOf(heading.replaceAll('_', '')),
    }) {
      final count = seen[slug] ?? 0;
      seen[slug] = count + 1;
      found.add(count == 0 ? slug : '$slug-$count');
    }
  }

  String? previous;
  for (final (_, line) in _prose(lines, keepCode: true)) {
    final atx = _atxHeading.firstMatch(line);
    if (atx != null) {
      add(atx.group(1)!);
    } else if (_setextRule.hasMatch(line) && (previous ?? '').trim() != '') {
      add(previous!);
    }
    for (final match in _htmlAnchor.allMatches(line)) {
      found.add(match.group(1)!.toLowerCase());
    }
    previous = line;
  }
  return found;
}

/// [heading] as the fragment GitHub gives it: the text without its markup,
/// lower case, punctuation dropped and each space a hyphen.
String slugOf(String heading) => heading
    .replaceAllMapped(_linkText, (match) => match.group(1)!)
    .replaceAll('`', '')
    .trim()
    .toLowerCase()
    .replaceAll(_notInASlug, '')
    .replaceAll(' ', '-');

/// The lines outside a fence, numbered from zero, with each code span
/// blanked unless [keepCode] — a heading keeps the words inside its span.
Iterable<(int, String)> _prose(
  List<String> lines, {
  bool keepCode = false,
}) sync* {
  String? fence;
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final opened = _fence.firstMatch(line)?.group(1);
    if (fence != null) {
      // Closed by the same mark, at least as long as the one that opened it.
      if (opened != null &&
          opened[0] == fence[0] &&
          opened.length >= fence.length &&
          line.trim() == opened) {
        fence = null;
      }
      continue;
    }
    if (opened != null) {
      fence = opened;
      continue;
    }
    yield (index, keepCode ? line : line.replaceAll(_codeSpan, ''));
  }
}

/// [target] as a path on this machine: from the repository root when it
/// starts with `/`, which is how GitHub reads one, else from [from]'s folder.
String _resolve(Directory root, File from, String target) {
  final base = target.startsWith('/')
      ? Uri.directory(root.path)
      : Uri.file(from.path);
  final relativeTarget = target.startsWith('/') ? target.substring(1) : target;
  final resolved = base
      .resolveUri(Uri(path: relativeTarget.replaceAll(r'\', '/')))
      .toFilePath();
  // A folder may be linked with or without its last separator.
  return resolved.length > 1 && resolved.endsWith(Platform.pathSeparator)
      ? resolved.substring(0, resolved.length - 1)
      : resolved;
}

/// Whether [path] exists spelled exactly so, one folder at a time.
///
/// Asked of each folder's listing rather than of the file system: macOS and
/// Windows answer yes to `Readme.md` for `README.md`, and the link then
/// breaks on GitHub and on the Linux runner only.
bool _isThere(Directory root, String path, Map<String, Set<String>> listings) {
  final prefix = '${slashed(root.path)}/';
  final spelled = slashed(path);
  if (!spelled.startsWith(prefix)) {
    return spelled == slashed(root.path) ||
        FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }
  var folder = root.path;
  for (final name in spelled.substring(prefix.length).split('/')) {
    final names = listings.putIfAbsent(folder, () {
      final directory = Directory(folder);
      return directory.existsSync()
          ? <String>{for (final entry in directory.listSync()) nameOf(entry)}
          : const <String>{};
    });
    if (!names.contains(name)) return false;
    folder = '$folder/$name';
  }
  return true;
}

/// [path] as the repository spells it, for a message somebody will search.
String _spelled(Directory root, String path) {
  final prefix = '${slashed(root.path)}/';
  final spelled = slashed(path);
  return spelled.startsWith(prefix)
      ? spelled.substring(prefix.length)
      : spelled;
}

/// [target] without the angle brackets markdown allows around a path that
/// holds a space.
String _unwrapped(String target) =>
    target.startsWith('<') && target.endsWith('>')
    ? target.substring(1, target.length - 1)
    : target;

/// [text] with `%20` read as the space it stands for; left alone when it is
/// not an encoding at all.
String _decoded(String text) {
  try {
    return Uri.decodeComponent(text);
  } on ArgumentError {
    return text;
  }
}

final _inline = RegExp(
  r'''\]\(\s*(<[^>]*>|[^()\s]+)(?:\s+(?:"[^"]*"|'[^']*'))?\s*\)''',
);

/// `[label]: target` — and not `[^1]: text`, which is a footnote.
final _definition = RegExp(r'^ {0,3}\[[^\]^][^\]]*\]:\s+(<[^>]*>|\S+)');
final _attribute = RegExp(r'''\b(?:href|src)=["']([^"']+)["']''');

/// `https:`, `mailto:` and every other address that is not a path here.
final _scheme = RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:');
final _fence = RegExp(r'^\s{0,3}(`{3,}|~{3,})');
final _codeSpan = RegExp(r'(`+)(?:(?!\1).)+\1');
final _atxHeading = RegExp(r'^ {0,3}#{1,6}\s+(.*?)(?:\s+#+)?\s*$');
final _setextRule = RegExp(r'^ {0,3}(?:=+|-+)\s*$');
final _htmlAnchor = RegExp(r'''\b(?:id|name)=["']([^"']+)["']''');
final _linkText = RegExp(r'!?\[([^\]]*)\]\([^)]*\)');
final _notInASlug = RegExp(r'[^\p{L}\p{M}\p{N}_\- ]', unicode: true);
