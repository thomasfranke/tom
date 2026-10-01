/// Turning what was written into what it points at.
library;

import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';
import 'package:tom_domain/src/spaces/space_entry_value_object.dart';
import 'package:tom_domain/src/wikilinks/wikilink_target_value_object.dart';
import 'package:tom_domain/src/wikilinks/wikilink_value_object.dart';

/// A link and a listing in, a target out.
///
/// A domain service because the rule belongs to no single document, and it
/// carries no port: matching a name against a list is logic, not a capability
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
final class WikilinkResolverService {
  /// Creates the resolver.
  const WikilinkResolverService();

  /// What [link] points at among [entries].
  ///
  /// Total: every link gets an answer, and one that matches nothing is
  /// [WikilinkMissing] rather than a failure.
  WikilinkTargetValueObject resolve(
    WikilinkValueObject link,
    List<SpaceEntryValueObject> entries,
  ) {
    final Iterable<SpaceEntryValueObject> documents = entries.where(
      (SpaceEntryValueObject entry) => entry.isDocument,
    );

    final List<SpaceRelativePathValueObject> matches = link.isPath
        ? _byPath(link, documents)
        : _byName(link, documents);

    return switch (matches.length) {
      0 => const WikilinkTargetValueObject.missing(),
      1 => WikilinkTargetValueObject.resolved(matches.single),
      _ => WikilinkTargetValueObject.ambiguous(matches),
    };
  }

  /// Entries whose path is the one written, the `.md` optional.
  ///
  /// Case-sensitive, because a path is what the filesystem said rather than
  /// what somebody remembered.
  List<SpaceRelativePathValueObject> _byPath(
    WikilinkValueObject link,
    Iterable<SpaceEntryValueObject> documents,
  ) {
    final String wanted = '${link.targetWithoutExtension}.md';
    return documents
        .where((SpaceEntryValueObject entry) => entry.path.value == wanted)
        .map((SpaceEntryValueObject entry) => entry.path)
        .toList();
  }

  /// Entries whose file name is the one written, wherever they sit.
  ///
  /// Case-insensitive, because a name is what somebody remembered.
  List<SpaceRelativePathValueObject> _byName(
    WikilinkValueObject link,
    Iterable<SpaceEntryValueObject> documents,
  ) {
    final String wanted = '${link.targetWithoutExtension}.md'.toLowerCase();
    return documents
        .where(
          (SpaceEntryValueObject entry) => entry.name.toLowerCase() == wanted,
        )
        .map((SpaceEntryValueObject entry) => entry.path)
        .toList();
  }
}
