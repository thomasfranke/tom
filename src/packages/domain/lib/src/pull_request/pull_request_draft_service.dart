/// What a pull request draft starts as, and what is read back out of it.
library;

import 'package:tom_domain/src/git/commit_entity.dart';

/// The draft's two rules: it starts filled from git, and its title is its
/// first heading (`docs/product/git-workflow/pull-request/writing-it/doc.md`).
///
/// A domain service with no port: both directions are string work over
/// what git already said.
final class PullRequestDraftService {
  /// Creates the service.
  const PullRequestDraftService();

  /// The draft for a branch whose commits since its base are [commits],
  /// newest first as `log` gives them.
  ///
  /// The first commit's subject is the heading and the rest are a list
  /// under it, oldest first, so the description reads in the order the
  /// work was done. No commit is a heading with nothing to say yet.
  String seed(List<CommitEntity> commits) {
    if (commits.isEmpty) {
      return '# \n';
    }
    final List<CommitEntity> oldestFirst = commits.reversed.toList();
    final StringBuffer draft = StringBuffer('# ${oldestFirst.first.subject}\n');
    if (oldestFirst.length > 1) {
      draft.writeln();
      for (final CommitEntity commit in oldestFirst.skip(1)) {
        draft.writeln('- ${commit.subject}');
      }
    }
    return draft.toString();
  }

  /// The title [draft] proposes: its first line when that line is a level-one
  /// heading with words in it, and null otherwise.
  ///
  /// Null is the one thing that stops the button, so a draft whose heading
  /// was deleted says so rather than opening with no title.
  String? title(String draft) {
    final String first = _lines(
      draft,
    ).firstWhere((String line) => line.trim().isNotEmpty, orElse: () => '');
    final RegExpMatch? heading = _heading.firstMatch(first);
    final String? words = heading?.namedGroup('title')?.trim();
    return words == null || words.isEmpty ? null : words;
  }

  /// Everything in [draft] after its title line, trimmed — the description
  /// the host is handed. The whole draft when it has no title.
  String body(String draft) {
    if (title(draft) == null) {
      return draft.trim();
    }
    final List<String> lines = _lines(draft);
    final int at = lines.indexWhere((String line) => line.trim().isNotEmpty);
    return lines.skip(at + 1).join('\n').trim();
  }

  static List<String> _lines(String text) => text.split(RegExp(r'\r?\n'));

  /// `# Title`, with the closing hashes ATX allows left out of the title.
  static final RegExp _heading = RegExp(
    r'^ {0,3}#[ \t]+(?<title>.*?)(?:[ \t]+#+)?[ \t]*$',
  );
}
