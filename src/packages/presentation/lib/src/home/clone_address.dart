/// What a pasted address says about where a clone goes, read the way
/// `git clone` reads it.
library;

/// The folder `git clone` would create for [url] — its last segment without
/// `.git` — or null when the address names none.
///
/// Named here rather than by git, because the destination is chosen before
/// git runs and handed to it.
String? cloneFolderNameOf(String url) {
  String rest = url.trim();
  while (rest.endsWith('/') || rest.endsWith(r'\')) {
    rest = rest.substring(0, rest.length - 1);
  }
  if (rest.endsWith('/.git')) {
    rest = rest.substring(0, rest.length - '/.git'.length);
  }
  // `:` too, for the scp form `git@host:acme/handbook.git`.
  String name = rest.substring(rest.lastIndexOf(RegExp(r'[/\\:]')) + 1);
  if (name.endsWith('.git')) {
    name = name.substring(0, name.length - '.git'.length);
  }
  return name.isEmpty || name == '.' || name == '..' ? null : name;
}

/// The host [url] points at, or null for a path on this machine.
String? cloneHostOf(String url) {
  final String address = url.trim();
  final Uri? parsed = Uri.tryParse(address);
  // A scheme of one letter is a Windows drive, not a protocol.
  if (parsed != null && parsed.scheme.length > 1) {
    return parsed.host.isEmpty ? null : parsed.host;
  }
  // The scp form has no scheme; two letters at least, so `C:` is a drive.
  return RegExp(r'^(?:[^@/\\]+@)?([^:/\\]{2,}):').firstMatch(address)?.group(1);
}

/// [name] inside [parent], in the separator [parent] is already written in.
String cloneDestinationIn(String parent, String name) {
  final String separator = parent.contains(r'\') && !parent.contains('/')
      ? r'\'
      : '/';
  return parent.endsWith(separator) ? '$parent$name' : '$parent$separator$name';
}
