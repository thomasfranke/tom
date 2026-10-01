/// The folder the user opened, and the repository that encloses it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/repo_relative_path_value_object.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'space_entity.freezed.dart';

/// A local folder open in TOM: the unit everything else is scoped to
/// ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// [root] and [repositoryRoot] are separate because git runs against the
/// repository while navigation and search stay in the folder, which makes
/// this class the only place allowed to convert between a
/// [SpaceRelativePathValueObject] and a [RepoRelativePathValueObject].
@freezed
abstract class SpaceEntity with _$SpaceEntity {
  /// A space; [repositoryRoot] must enclose [root].
  ///
  /// Not `const`, because the assertion calls a method; a space is read off a
  /// folder picker at runtime, never written as a literal outside a test.
  @Assert(
    '_isEnclosedBy(root, repositoryRoot)',
    'repositoryRoot must enclose root',
  )
  factory SpaceEntity({
    /// Absolute path to the folder the user opened; the space's identity.
    required String root,

    /// Absolute path to the enclosing Git repository.
    required String repositoryRoot,

    /// What the space is called in the UI, by default [nameOfFolder].
    required String name,
  }) = _SpaceEntity;

  const SpaceEntity._();

  /// The default name for the folder at [root]: its last segment, or [root]
  /// itself for a filesystem root.
  ///
  /// Static so a space created by Home and one restored from the recent list
  /// cannot disagree about the name.
  static String nameOfFolder(String root) {
    final List<String> segments = _normalize(
      root,
    ).split('/').where((String segment) => segment.isNotEmpty).toList();
    return segments.isEmpty ? root : segments.last;
  }

  /// Whether [repositoryRoot] is [root] or a folder above it, the
  /// constructor's invariant asked before constructing.
  ///
  /// The assertion is stripped from a release build, so a pair that does not
  /// enclose has to be refused as a failure rather than trusted to throw.
  static bool isEnclosedBy(String root, String repositoryRoot) =>
      _isEnclosedBy(root, repositoryRoot);

  /// Where [root] sits inside the repository, or null when it *is* the
  /// repository; the prefix every conversion below is made of.
  RepoRelativePathValueObject? get rootWithinRepository {
    final String within = _normalize(
      root,
    ).substring(_normalize(repositoryRoot).length);
    final String trimmed = within.startsWith('/')
        ? within.substring(1)
        : within;
    return trimmed.isEmpty ? null : RepoRelativePathValueObject(trimmed);
  }

  /// [path] as git names it: `guide.md` in a space opened at `docs/` is
  /// `docs/guide.md` to git.
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
  /// Null is ordinary: git reports the whole repository, so a status on a
  /// space opened at `docs/` routinely names files the tree does not show.
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
  /// The way back from a directory listing, which answers in absolute paths.
  /// Null for the root itself and for anything outside the folder, a sibling
  /// that merely shares a prefix included; both sides are compared normalized.
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

  /// Where [path] is on disk, the only form the filesystem capability takes.
  ///
  /// Built on [root] as it was given, separators included, so the string is
  /// one the platform recognises.
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
/// Top level rather than static, because the assertion is generated into
/// `space_entity.freezed.dart`, a `part` that sees what is private here but
/// not what belongs to the class. Compared normalized, since the picker and
/// `git rev-parse` spell the same folder differently, and with the trailing
/// separator so `/code/app-docs` is not inside `/code/app`.
bool _isEnclosedBy(String inner, String outer) {
  final String normalizedInner = _normalize(inner);
  final String normalizedOuter = _normalize(outer);
  return normalizedInner == normalizedOuter ||
      normalizedInner.startsWith('$normalizedOuter/');
}

/// [path] with `/` separators, no trailing separator, and an upper-case drive
/// letter: enough to compare two spellings of the same absolute path.
///
/// Case elsewhere is left alone, since only some platforms are
/// case-insensitive and guessing wrong loses a folder either way.
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
