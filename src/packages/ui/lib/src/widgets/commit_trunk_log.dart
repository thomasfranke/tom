/// What the ground writes down its lines.
library;

import 'package:flutter/foundation.dart';

/// One line of a log: the short sha, then what the commit did.
@immutable
class TrunkCommit {
  /// Creates an entry.
  const TrunkCommit({required this.sha, required this.subject});

  /// The short hash, which is what a log leads with.
  final String sha;

  /// The subject line, in the Conventional Commit this repository writes.
  final String subject;

  @override
  bool operator ==(Object other) =>
      other is TrunkCommit && other.sha == sha && other.subject == subject;

  @override
  int get hashCode => Object.hash(sha, subject);
}

/// TOM's own history, which is the one log this screen can show.
///
/// **Real commits of this repository** — `git log`, subjects short enough to
/// read at a glance — the way a landing page tells its own story rather than
/// borrowing somebody's. Fifty of them because the ground shows three at a
/// time and writes them again on every turn of its cycle: a pool this long
/// is a minute of watching before a line comes back.
///
/// It goes stale, and that is fine: it is the ground of a screen, not a
/// reading of the repository. Refresh it from `git log` when it starts to
/// read like an old release.
abstract final class TrunkLog {
  /// The pool, in the order the log made them.
  static const List<TrunkCommit> tomsOwn = <TrunkCommit>[
    TrunkCommit(
      sha: 'e4bccd7',
      subject: 'build(tool): check the naming and shape rules on every verify',
    ),
    TrunkCommit(
      sha: 'a9c4e0b',
      subject: 'refactor(data): read through a data source, never a capability',
    ),
    TrunkCommit(
      sha: '0e35575',
      subject: 'feat(infra): make a capability a folder, failures included',
    ),
    TrunkCommit(
      sha: '781c8a3',
      subject: 'refactor(app): spell use case the way the identifier does',
    ),
    TrunkCommit(
      sha: '6c14c4e',
      subject:
          'refactor(desktop): one widget per file, and a name that says so',
    ),
    TrunkCommit(
      sha: '724155f',
      subject: 'refactor(core): name the port a port and the rule a rule',
    ),
    TrunkCommit(
      sha: 'd5bb7ba',
      subject: 'refactor(core): name every domain type entity or value object',
    ),
    TrunkCommit(
      sha: 'c8642a3',
      subject: 'refactor(core): put both halves of an outcome in the signature',
    ),
    TrunkCommit(
      sha: 'c6ddfc0',
      subject: 'feat(desktop): draw the commit trunk behind Home',
    ),
    TrunkCommit(
      sha: 'aaab796',
      subject:
          'docs: settle DTO/DAO placement, and the naming rules that follow',
    ),
    TrunkCommit(
      sha: '3665988',
      subject: 'feat(editor): render the open document as blocks',
    ),
    TrunkCommit(
      sha: '5b379e4',
      subject: 'style(cli): reformat what the formatter had left behind',
    ),
    TrunkCommit(
      sha: '55cb09d',
      subject:
          'docs(design): the identity, the component set and the visual boards',
    ),
    TrunkCommit(
      sha: '9fe374e',
      subject: 'docs: cap a comment at two or three lines',
    ),
    TrunkCommit(
      sha: 'b2d7ac4',
      subject:
          'feat: give the CLI a doctor, an update check and tests of its own',
    ),
    TrunkCommit(
      sha: '8ca4544',
      subject: 'feat(desktop): build the file tree on a space session',
    ),
    TrunkCommit(
      sha: '25d20ce',
      subject: 'refactor: generate every provider from riverpod_annotation',
    ),
    TrunkCommit(
      sha: '107020b',
      subject: 'refactor(desktop): group the UI into screens and widgets',
    ),
    TrunkCommit(
      sha: '23909f5',
      subject: 'chore(desktop): remove the spike harnesses',
    ),
    TrunkCommit(
      sha: '1bebcf9',
      subject: 'feat(desktop): build the workspace shell on a registry',
    ),
    TrunkCommit(
      sha: '85c887e',
      subject: 'feat(desktop): drive the app end to end from the CLI',
    ),
    TrunkCommit(
      sha: 'a46eef7',
      subject: 'feat(desktop): build Home against its design',
    ),
    TrunkCommit(
      sha: 'fb35623',
      subject: 'feat(core): open a folder into a space, and remember it',
    ),
    TrunkCommit(
      sha: '3f9c15a',
      subject:
          'feat(core): settle Spike B — blocks come from the markdown package',
    ),
    TrunkCommit(
      sha: 'ebb3574',
      subject: 'docs(process): add a code review skill for architecture',
    ),
    TrunkCommit(
      sha: '833e669',
      subject:
          'feat(editor): settle Spike A — source mode is built on re_editor',
    ),
    TrunkCommit(
      sha: '195d187',
      subject: 'fix(desktop): raise the macOS deployment target to 12.0',
    ),
    TrunkCommit(
      sha: '4e0a35a',
      subject: "fix: let the CLI's exit code reach the process",
    ),
    TrunkCommit(
      sha: '5c134a8',
      subject: 'feat: group the root screen into Dev Tools and Tests',
    ),
    TrunkCommit(
      sha: 'dc957b4',
      subject: 'feat(core): fulfil the document and space contracts',
    ),
    TrunkCommit(
      sha: '83e5b25',
      subject: 'feat(core): give the space a tree and a failure vocabulary',
    ),
    TrunkCommit(
      sha: '8de239a',
      subject: 'feat(git): parse status, log and branches into the domain',
    ),
    TrunkCommit(
      sha: '1cfb7d2',
      subject: 'feat(git): fulfil GitRepository over the GitClient capability',
    ),
    TrunkCommit(
      sha: '655d589',
      subject:
          'feat(git): give the domain its space, its paths and its contract',
    ),
    TrunkCommit(
      sha: '46d31ab',
      subject: 'feat(git): give the domain its git vocabulary',
    ),
    TrunkCommit(
      sha: '1b8ac19',
      subject: "fix(git): unstage a path before the repository's first commit",
    ),
    TrunkCommit(
      sha: '6bd7416',
      subject: 'fix(git): close nine findings from a review of domain and data',
    ),
    TrunkCommit(
      sha: 'f4b49ed',
      subject: 'feat(filesystem): refuse what cannot be read back losslessly',
    ),
    TrunkCommit(
      sha: 'e5c2bf4',
      subject: 'feat(git): make every path on the contract repository-relative',
    ),
    TrunkCommit(
      sha: '8e07e29',
      subject: 'docs(decisions): record that tom is the entry point',
    ),
    TrunkCommit(
      sha: '57d5bcd',
      subject: 'feat: add tom, a navigable CLI, and make the Makefile a face',
    ),
    TrunkCommit(
      sha: '1022d70',
      subject: 'docs(git): say what a folder with no repository means',
    ),
    TrunkCommit(
      sha: 'e88d8c2',
      subject: 'test(git): stop the tests assuming POSIX path separators',
    ),
    TrunkCommit(
      sha: 'a82d9fd',
      subject: 'feat(filesystem): list directories and probe them behind it',
    ),
    TrunkCommit(
      sha: 'd15266c',
      subject: 'feat(git): add the GitClient capability over the system binary',
    ),
    TrunkCommit(
      sha: 'febf272',
      subject: 'chore: drop the task and spec process',
    ),
    TrunkCommit(
      sha: '41f43d6',
      subject: 'chore: remove WritRun from the project',
    ),
    TrunkCommit(
      sha: 'aad932f',
      subject: 'chore: derive the MVP queue from the roadmap',
    ),
    TrunkCommit(
      sha: 'd782a5d',
      subject: 'chore: adopt WritRun v0.0.09 as the project flow',
    ),
    TrunkCommit(
      sha: '9c7b6a1',
      subject: 'docs: write the roadmap the milestones are picked from',
    ),
  ];
}
