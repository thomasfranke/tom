/// The folder the user opened, and the repository that encloses it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/repo_relative_path_value_object.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'space_entity.freezed.dart';

/// A local folder open in TOM: the unit everything else is scoped to.
///
/// The git queue, the watcher, the search index and the session all belong to
/// a space ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// [root] and [repositoryRoot] are separate because most teams keep `docs/`
/// inside the repository that holds the code: git runs against the
/// repository and reports paths relative to it, while navigation, search and
/// the watcher stay inside the folder. That makes this class the only place
/// in the application that may convert between a
/// [SpaceRelativePathValueObject] and a [RepoRelativePathValueObject] —
/// everywhere else, the two types keep the mix-up from
/// compiling.
@freezed
abstract class SpaceEntity with _$SpaceEntity {
  /// Creates a space.
  ///
  /// [repositoryRoot] must enclose [root] — equal to it when the repository
  /// itself was opened, an ancestor when a subfolder was. Nothing else is a
  /// space: a folder outside any repository is a `GitNotARepository`, which
  /// Home reports rather than works around.
  /// Not `const`: the assertion below calls a method, which a constant
  /// expression may not do. Keeping the invariant is worth more than keeping
  /// the constructor constant — a space is read off a folder picker at
  /// runtime, never written as a literal outside a test.
  @Assert(
    '_isEnclosedBy(root, repositoryRoot)',
    'repositoryRoot must enclose root',
  )
  factory SpaceEntity({
    /// Absolute path to the folder the user opened; the identity of the
    /// space.
    required String root,

    /// Absolute path to the enclosing Git repository.
    required String repositoryRoot,

    /// What the space is called in the UI.
    ///
    /// Derived from the folder name unless configured otherwise — see
    /// [nameOfFolder], which is what derives it.
    required String name,
  }) = _SpaceEntity;

  const SpaceEntity._();

  /// The default name for the folder at [root] — its last segment.
  ///
  /// Static so that every caller derives the same name: a space created by
  /// Home and one restored from the recent list must not disagree about what
  /// the folder is called. Falls back to [root] itself when it has no
  /// segment to take, which is a filesystem root and still needs a label.
  static String nameOfFolder(String root) {
    final List<String> segments = _normalize(
      root,
    ).split('/').where((String segment) => segment.isNotEmpty).toList();
    return segments.isEmpty ? root : segments.last;
  }

  /// Where [root] sits inside the repository, or null when it *is* the
  /// repository.
  ///
  /// The prefix every conversion below is made of.
  RepoRelativePathValueObject? get rootWithinRepository {
    final String within = _normalize(
      root,
    ).substring(_normalize(repositoryRoot).length);
    final String trimmed = within.startsWith('/')
        ? within.substring(1)
        : within;
    return trimmed.isEmpty ? null : RepoRelativePathValueObject(trimmed);
  }

  /// [path] as git names it.
  ///
  /// What a stage, a diff or a history request needs: `guide.md` in a space
  /// opened at `docs/` is `docs/guide.md` to git.
  RepoRelativePathValueObject toRepoRelative(
    SpaceRelativePathValueObject path,
  ) {
    final RepoRelativePathValueObject? prefix = rootWithinRepository;
    return prefix == null
        ? RepoRelativePathValueObject(path.value)
        : RepoRelativePathValueObject('${prefix.value}/${path.value}');
  }

  /// [path] as the app navigates it, or null when it is outside the space.
  ///
  /// Null is an ordinary answer, not a failure: git reports the whole
  /// repository, so a status on a space opened at `docs/` routinely names
  /// source files the file tree does not show and the editor cannot open.
  SpaceRelativePathValueObject? toSpaceRelative(
    RepoRelativePathValueObject path,
  ) {
    final RepoRelativePathValueObject? prefix = rootWithinRepository;
    if (prefix == null) {
      return SpaceRelativePathValueObject(path.value);
    }
    final String inside = '${prefix.value}/';
    return path.value.startsWith(inside)
        ? SpaceRelativePathValueObject(path.value.substring(inside.length))
        : null;
  }

  /// [absolutePath] as a path inside this space, or null when it is not one.
  ///
  /// The way back from what a directory listing reports: the filesystem
  /// capability answers in absolute paths, because it knows nothing about
  /// spaces. Null for the root itself, which names no entry, and for
  /// anything outside the folder — including a sibling that merely shares a
  /// prefix.
  ///
  /// Both sides are compared normalized, for the reason the constructor's
  /// invariant gives; what comes back is spelled with `/`, like every other
  /// [SpaceRelativePathValueObject].
  SpaceRelativePathValueObject? relativize(String absolutePath) {
    final String normalizedRoot = _normalize(root);
    final String normalized = _normalize(absolutePath);
    if (!normalized.startsWith('$normalizedRoot/')) {
      return null;
    }
    return SpaceRelativePathValueObject.tryParse(
      normalized.substring(normalizedRoot.length + 1),
    );
  }

  /// Where [path] is on disk.
  ///
  /// The only form the filesystem capability accepts, and the reason the
  /// conversion is not spread across the data layer. Built on [root] as it
  /// was given, separators included, so the string handed back is one the
  /// platform recognises.
  String absolutePathOf(SpaceRelativePathValueObject path) {
    final String separator = root.contains(r'\') ? r'\' : '/';
    final String base = root.endsWith('/') || root.endsWith(r'\')
        ? root.substring(0, root.length - 1)
        : root;
    return '$base$separator${path.value.replaceAll('/', separator)}';
  }
}

/// Whether [inner] is [outer] or sits inside it.
///
/// A top-level function rather than a static: the constructor's assertion is
/// generated into `space.freezed.dart`, which is a `part` of this library and
/// therefore sees what is private here — but not what belongs to the class.
///
/// Comparison is on the normalized forms. The folder picker and
/// `git rev-parse` do not spell the same folder the same way — one returns
/// `C:\code\app`, the other `C:/code/app` — and a prefix test on the raw
/// strings would call that pair unrelated. The trailing separator is what
/// makes this containment rather than a prefix match: `/code/app-docs`
/// starts with `/code/app` and is a different folder.
bool _isEnclosedBy(String inner, String outer) {
  final String normalizedInner = _normalize(inner);
  final String normalizedOuter = _normalize(outer);
  return normalizedInner == normalizedOuter ||
      normalizedInner.startsWith('$normalizedOuter/');
}

/// [path] with `/` separators, no trailing separator, and an upper-case drive
/// letter.
///
/// Enough to compare two spellings of the same absolute path. Case elsewhere
/// is left alone deliberately: Windows and macOS are usually case-insensitive
/// and Linux is not, and guessing wrong either loses a distinct folder or
/// fails to match the same one.
String _normalize(String path) {
  String normalized = path.replaceAll(r'\', '/');
  while (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return _drive.hasMatch(normalized)
      ? normalized[0].toUpperCase() + normalized.substring(1)
      : normalized;
}

final RegExp _drive = RegExp(r'^[A-Za-z]:');
