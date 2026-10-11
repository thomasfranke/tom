/// What git said a file held at a revision, kept so it is asked once.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The committed text of files, by revision and path.
///
/// In Manual and Semi-automatic every `git show` waits for an answer
/// (Decision 38), so a preview that re-diffs on each keystroke would raise a
/// row per key. Its owner clears it when the base or the git reading moves.
final class BaseContentCache {
  /// Creates an empty cache.
  BaseContentCache();

  final Map<String, String> _held = <String, String>{};

  /// Forgets everything: the base changed, or a commit moved `HEAD`.
  void clear() => _held.clear();

  /// The text a comparison takes [path] to have at [revision], through
  /// [cache] when there is one.
  ///
  /// **Nothing is asked of git when [status] already says `HEAD` holds
  /// nothing there** (untracked, added, renamed): the empty text it would
  /// have answered. Only `HEAD` is short-cut — a path can have been in the
  /// commit a branch forked from, and then it is asked and git's refusal is
  /// the client's declared answer.
  static Future<Result<String, GitFailure>> baseOf({
    required String revision,
    required RepoRelativePathValueObject path,
    required Future<Result<String, GitFailure>> Function() ask,
    BaseContentCache? cache,
    GitStatusValueObject? status,
  }) async {
    if (revision == 'HEAD' && (status?.hasNothingAtHead(path) ?? false)) {
      return const Success<String, GitFailure>('');
    }
    return cache == null
        ? await ask()
        : await cache.read(revision: revision, path: path, ask: ask);
  }

  /// The text of [path] at [revision], asking [ask] only the first time.
  ///
  /// A file the revision does not hold is kept as the empty text it is
  /// compared as; any other failure is passed on and not kept.
  Future<Result<String, GitFailure>> read({
    required String revision,
    required RepoRelativePathValueObject path,
    required Future<Result<String, GitFailure>> Function() ask,
  }) async {
    final String key = '$revision\u0000${path.value}';
    final String? known = _held[key];
    if (known != null) {
      return Success<String, GitFailure>(known);
    }
    final Result<String, GitFailure> asked = await ask();
    switch (asked) {
      case Success<String, GitFailure>(value: final String content):
        _held[key] = content;
      case Failure<String, GitFailure>(failure: GitPathNotInRevision()):
        _held[key] = '';
        return const Success<String, GitFailure>('');
      case Failure<String, GitFailure>():
        break;
    }
    return asked;
  }
}
