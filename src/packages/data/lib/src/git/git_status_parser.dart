/// Turning `status --porcelain=v2 -z` into a [GitStatusValueObject].
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The reader of what [GitClient.status] returned, in that format and with
/// [GitClient.nulSeparator].
///
/// Total: a record it cannot read is skipped, because porcelain v2 is a
/// versioned grammar so a reader can ignore what it does not know.
final class GitStatusParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitStatusParser();

  /// What git says about a detached `HEAD` in `# branch.head`.
  static const String _detached = '(detached)';

  /// [porcelain] as a status.
  GitStatusValueObject parse(String porcelain) {
    final List<String> fields = porcelain.split(GitClient.nulSeparator);
    bool isDetached = false;
    BranchNameValueObject? branch;
    BranchNameValueObject? upstream;
    int ahead = 0;
    int behind = 0;
    final List<StatusEntryValueObject> entries = <StatusEntryValueObject>[];

    for (int i = 0; i < fields.length; i++) {
      final String field = fields[i];
      if (field.isEmpty) {
        continue;
      }
      if (field.startsWith('# branch.head ')) {
        // Only the sentinel makes a status detached: a name that does not
        // parse also leaves `branch` null, and that is a different answer.
        final String name = field.substring('# branch.head '.length);
        isDetached = name == _detached;
        branch = isDetached ? null : BranchNameValueObject.tryParse(name);
      } else if (field.startsWith('# branch.upstream ')) {
        upstream = BranchNameValueObject.tryParse(
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
        // A rename or copy spends two fields, and the origin is consumed even
        // when the record is unreadable, or it would look like an entry.
        final String? previous = i + 1 < fields.length ? fields[++i] : null;
        _add(entries, _parseTracked(field, previousPath: previous));
      } else if (field.startsWith('1 ')) {
        _add(entries, _parseTracked(field));
      } else if (field.startsWith('u ')) {
        _add(entries, _parseUnmerged(field));
      } else if (field.startsWith('? ')) {
        _add(entries, _parseUntracked(field));
      }
      // `! ` is an ignored file, which `GitClient.status` does not ask for.
    }

    return GitStatusValueObject(
      branch: branch,
      upstream: upstream,
      ahead: ahead,
      behind: behind,
      // Unmodifiable because the status outlives this method.
      entries: List<StatusEntryValueObject>.unmodifiable(entries),
      isDetached: isDetached,
    );
  }

  /// Appends [entry] when there was one to make.
  void _add(
    List<StatusEntryValueObject> entries,
    StatusEntryValueObject? entry,
  ) {
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

  /// A `1` or `2` record, `1 XY sub mH mI mW hH hI path`, with a score before
  /// the path on a `2`.
  ///
  /// The path is everything after the fixed fields, because it may hold
  /// spaces.
  StatusEntryValueObject? _parseTracked(String record, {String? previousPath}) {
    final bool isRenameOrCopy = record.startsWith('2 ');
    final int fixedFields = isRenameOrCopy ? 9 : 8;
    final List<String> parts = record.split(' ');
    if (parts.length <= fixedFields) {
      return null;
    }
    final String xy = parts[1];
    if (xy.length != 2) {
      return null;
    }
    final RepoRelativePathValueObject? path =
        RepoRelativePathValueObject.tryParse(parts.skip(fixedFields).join(' '));
    if (path == null) {
      return null;
    }

    // X is the index against HEAD, Y the working tree against the index; a
    // file with both shows its staged side.
    final String staged = xy[0];
    final String unstaged = xy[1];
    final FileStateEnum? state = _stateOf(staged == '.' ? unstaged : staged);
    if (state == null) {
      return null;
    }

    // A `2` record is a rename or a copy, and the origin is attached only to
    // a rename: for a copy the file is still there.
    return StatusEntryValueObject(
      path: path,
      state: state,
      isStaged: staged != '.',
      previousPath: state == FileStateEnum.renamed && previousPath != null
          ? RepoRelativePathValueObject.tryParse(previousPath)
          : null,
    );
  }

  /// A `u` record, `u XY sub m1 m2 m3 mW h1 h2 h3 path`: a conflicted path,
  /// however both sides claim it.
  StatusEntryValueObject? _parseUnmerged(String record) {
    const int fixedFields = 10;
    final List<String> parts = record.split(' ');
    if (parts.length <= fixedFields) {
      return null;
    }
    final RepoRelativePathValueObject? path =
        RepoRelativePathValueObject.tryParse(parts.skip(fixedFields).join(' '));
    return path == null
        ? null
        : StatusEntryValueObject(
            path: path,
            state: FileStateEnum.conflicted,
            isStaged: false,
          );
  }

  /// A `? ` record: a file git was never told about.
  StatusEntryValueObject? _parseUntracked(String record) {
    final RepoRelativePathValueObject? path =
        RepoRelativePathValueObject.tryParse(record.substring(2));
    return path == null
        ? null
        : StatusEntryValueObject(
            path: path,
            state: FileStateEnum.untracked,
            isStaged: false,
          );
  }

  /// One half of git's XY on a tracked record, in the product's words.
  ///
  /// A copy and a type change land on the closest state the domain names
  /// (`docs/technical/domain/git.md`); [FileStateEnum.conflicted] is absent
  /// because an unmerged path is a `u` record, never a `U` here.
  FileStateEnum? _stateOf(String code) => switch (code) {
    'M' || 'T' => FileStateEnum.modified,
    'A' || 'C' => FileStateEnum.added,
    'D' => FileStateEnum.deleted,
    'R' => FileStateEnum.renamed,
    _ => null,
  };
}
