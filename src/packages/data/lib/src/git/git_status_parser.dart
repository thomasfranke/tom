/// Turning `status --porcelain=v2 -z` into a [GitStatus].
library;

import 'package:tom_domain/tom_domain.dart';

/// Reads what `GitClient.status` returned.
///
/// Where infrastructure and the domain meet ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)):
/// `GitClient` knows how to run git and hands back text; this knows what the
/// text means. Neither knows the other's half.
///
/// **Total, and deliberately so.** A record it cannot read is skipped rather
/// than thrown over — one unrecognised line must not cost the user the other
/// four hundred, and porcelain v2 is a versioned grammar precisely so that a
/// reader can ignore what it does not know.
///
/// The format is the one `GitClient.status` promises: NUL-terminated
/// entries, `# branch.*` headers first.
final class GitStatusParser {
  /// Creates a parser.
  ///
  /// Stateless, so one instance serves the whole app
  /// (`docs/technical/flows.md#wiring-three-lifetimes`).
  const GitStatusParser();

  /// The NUL that terminates every entry of the `-z` form.
  static final String _nul = String.fromCharCode(0);

  /// What git says about a detached `HEAD` in `# branch.head`.
  static const String _detached = '(detached)';

  /// Reads [porcelain] into a status.
  GitStatus parse(String porcelain) {
    final List<String> fields = porcelain.split(_nul);
    BranchName? branch;
    BranchName? upstream;
    int ahead = 0;
    int behind = 0;
    final List<StatusEntry> entries = <StatusEntry>[];

    for (int i = 0; i < fields.length; i++) {
      final String field = fields[i];
      if (field.isEmpty) {
        continue;
      }
      if (field.startsWith('# branch.head ')) {
        final String name = field.substring('# branch.head '.length);
        branch = name == _detached ? null : BranchName.tryParse(name);
      } else if (field.startsWith('# branch.upstream ')) {
        upstream = BranchName.tryParse(
          field.substring('# branch.upstream '.length),
        );
      } else if (field.startsWith('# branch.ab ')) {
        final (int, int)? counts = _parseAheadBehind(
          field.substring('# branch.ab '.length),
        );
        if (counts != null) {
          (ahead, behind) = counts;
        }
      } else if (field.startsWith('# ')) {
        continue;
      } else if (field.startsWith('2 ')) {
        // A rename or copy spends two fields: the record, then where the
        // file came from. Reading one without the other is what makes a
        // rename look like an unrelated add.
        final String? previous = i + 1 < fields.length ? fields[++i] : null;
        _add(entries, _parseTracked(field, previousPath: previous));
      } else if (field.startsWith('1 ')) {
        _add(entries, _parseTracked(field));
      } else if (field.startsWith('u ')) {
        _add(entries, _parseUnmerged(field));
      } else if (field.startsWith('? ')) {
        _add(entries, _parseUntracked(field));
      }
      // `! ` is an ignored file. `GitClient.status` does not ask for those,
      // and one arriving anyway is not something to report.
    }

    return GitStatus(
      branch: branch,
      upstream: upstream,
      ahead: ahead,
      behind: behind,
      entries: entries,
    );
  }

  /// Appends [entry] when there was one to make.
  void _add(List<StatusEntry> entries, StatusEntry? entry) {
    if (entry != null) {
      entries.add(entry);
    }
  }

  /// `+1 -2` into its two numbers.
  (int, int)? _parseAheadBehind(String value) {
    final List<String> parts = value.split(' ');
    if (parts.length != 2) {
      return null;
    }
    final int? ahead = int.tryParse(parts[0].replaceFirst('+', ''));
    final int? behind = int.tryParse(parts[1].replaceFirst('-', ''));
    return ahead == null || behind == null ? null : (ahead, behind);
  }

  /// A `1` or `2` record: a tracked file that changed.
  ///
  /// `1 XY sub mH mI mW hH hI path`, with a rename score before the path on
  /// a `2`. The path is everything after the fixed fields, so it is taken by
  /// splitting a bounded number of times rather than on every space — a
  /// document called `release notes.md` is ordinary.
  StatusEntry? _parseTracked(String record, {String? previousPath}) {
    final bool isRename = record.startsWith('2 ');
    final int fixedFields = isRename ? 9 : 8;
    final List<String> parts = record.split(' ');
    if (parts.length <= fixedFields) {
      return null;
    }
    final String xy = parts[1];
    if (xy.length != 2) {
      return null;
    }
    final RepoRelativePath? path = RepoRelativePath.tryParse(
      parts.skip(fixedFields).join(' '),
    );
    if (path == null) {
      return null;
    }

    // X is the index against HEAD, Y the working tree against the index. A
    // file staged and then edited again has both; the staged side is the one
    // the product shows, and `isStaged` carries the rest of the answer.
    final String staged = xy[0];
    final String unstaged = xy[1];
    final FileState? state = _stateOf(staged == '.' ? unstaged : staged);
    if (state == null) {
      return null;
    }

    return StatusEntry(
      path: path,
      state: state,
      isStaged: staged != '.',
      previousPath: isRename && previousPath != null
          ? RepoRelativePath.tryParse(previousPath)
          : null,
    );
  }

  /// A `u` record: a path a merge left conflicted.
  ///
  /// `u XY sub m1 m2 m3 mW h1 h2 h3 path` — ten fixed fields, and the XY
  /// says *how* both sides claim it, which the product does not distinguish.
  StatusEntry? _parseUnmerged(String record) {
    const int fixedFields = 10;
    final List<String> parts = record.split(' ');
    if (parts.length <= fixedFields) {
      return null;
    }
    final RepoRelativePath? path = RepoRelativePath.tryParse(
      parts.skip(fixedFields).join(' '),
    );
    return path == null
        ? null
        : StatusEntry(path: path, state: FileState.conflicted, isStaged: false);
  }

  /// A `? ` record: a file git was never told about.
  StatusEntry? _parseUntracked(String record) {
    final RepoRelativePath? path = RepoRelativePath.tryParse(
      record.substring(2),
    );
    return path == null
        ? null
        : StatusEntry(path: path, state: FileState.untracked, isStaged: false);
  }

  /// One half of git's XY on a tracked record, in the product's words.
  ///
  /// Git distinguishes a copy from an add and a type change from an edit;
  /// the domain names six states and neither of those is among them
  /// (`docs/technical/domain-model.md`), so they land on the closest one the
  /// product can show.
  ///
  /// [FileState.conflicted] is absent on purpose: git reports an unmerged
  /// path as its own `u` record, never as a `U` here, so a branch for it
  /// would be one no input can reach.
  FileState? _stateOf(String code) => switch (code) {
    'M' || 'T' => FileState.modified,
    'A' || 'C' => FileState.added,
    'D' => FileState.deleted,
    'R' => FileState.renamed,
    _ => null,
  };
}
