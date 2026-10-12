/// Offering documents while a wikilink is being typed.
library;

import 'package:tom_domain/src/editing/markdown_code_service.dart';
import 'package:tom_domain/src/spaces/space_entry_value_object.dart';
import 'package:tom_domain/src/wikilinks/wikilink_completion_value_object.dart';

/// The buffer, the caret and the listing in; what `[[` offers out.
///
/// A domain service beside the resolver, over the same listing, because what
/// it writes has to resolve by the resolver's rule — a name the space holds
/// twice is offered as its path
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
final class WikilinkCompletionService {
  /// Creates the service.
  const WikilinkCompletionService();

  /// What tells code from prose; a `[[` inside code is not a link.
  static const MarkdownCodeService _code = MarkdownCodeService();

  /// What to offer with the caret at [caret] in [buffer], or null when the
  /// caret is not inside a `[[` still being typed, or is inside code.
  ///
  /// Null and empty are different answers: null is "offer nothing", an
  /// empty list is "offer, and say nothing matches".
  WikilinkCompletionValueObject? complete(
    String buffer,
    int caret,
    List<SpaceEntryValueObject> entries,
  ) {
    final int? from = _openAt(buffer, caret);
    // The code check second, because it reads the buffer from the top.
    if (from == null || _code.isInsideCode(buffer, caret)) {
      return null;
    }
    final String query = buffer.substring(from, caret);
    return WikilinkCompletionValueObject(
      from: from,
      query: query,
      candidates: List<WikilinkCandidateValueObject>.unmodifiable(
        _rank(query, entries),
      ),
    );
  }

  /// Where the target being typed starts, or null when there is none.
  ///
  /// Only on the caret's own line, and only while what follows `[[` is still
  /// a target: a `]`, `|` or `#` means the target is finished.
  static int? _openAt(String buffer, int caret) {
    if (caret < 2 || caret > buffer.length) {
      return null;
    }
    final int open = buffer.lastIndexOf('[[', caret - 2);
    if (open < 0 || (open > 0 && buffer[open - 1] == r'\')) {
      return null;
    }
    final String typed = buffer.substring(open + 2, caret);
    if (typed.contains(RegExp(r'[\[\]|#\n]'))) {
      return null;
    }
    return open + 2;
  }

  /// The documents matching [query], best first.
  ///
  /// A name that starts with it, then one with a word that does, then one
  /// that holds it, then one whose folder does; shorter names first inside
  /// each. A query with a `/` is a path and is matched against paths.
  static List<WikilinkCandidateValueObject> _rank(
    String query,
    List<SpaceEntryValueObject> entries,
  ) {
    final List<SpaceEntryValueObject> documents = <SpaceEntryValueObject>[
      for (final SpaceEntryValueObject entry in entries)
        if (entry.isDocument) entry,
    ];
    final Map<String, int> named = <String, int>{};
    for (final SpaceEntryValueObject document in documents) {
      final String stem = _stem(document.name).toLowerCase();
      named[stem] = (named[stem] ?? 0) + 1;
    }

    final String wanted = query.trim().toLowerCase();
    final List<(int, SpaceEntryValueObject)> ranked =
        <(int, SpaceEntryValueObject)>[
          for (final SpaceEntryValueObject document in documents)
            if (_tierOf(wanted, document) case final int tier) (tier, document),
        ]..sort((
          (int, SpaceEntryValueObject) a,
          (int, SpaceEntryValueObject) b,
        ) {
          final int byTier = a.$1.compareTo(b.$1);
          if (byTier != 0) {
            return byTier;
          }
          final int byLength = a.$2.name.length.compareTo(b.$2.name.length);
          return byLength != 0
              ? byLength
              : a.$2.path.value.compareTo(b.$2.path.value);
        });

    return <WikilinkCandidateValueObject>[
      for (final (int, SpaceEntryValueObject) hit in ranked)
        if (_targetOf(
              hit.$2,
              // Somebody typing a path is given the path, even for a name
              // the space holds once.
              byName:
                  !wanted.contains('/') &&
                  named[_stem(hit.$2.name).toLowerCase()] == 1,
            )
            case final String target)
          WikilinkCandidateValueObject(path: hit.$2.path, target: target),
    ];
  }

  /// What is written to link to [document], or null when nothing written
  /// would reach it.
  ///
  /// A path with no folder gets a leading `/`, or it would read as a name
  /// and stay ambiguous. A target holding `#` or `|` is not offered: the
  /// link's own syntax would cut it there
  /// (`docs/product/wikilinks/doc.md`).
  static String? _targetOf(
    SpaceEntryValueObject document, {
    required bool byName,
  }) {
    final String path = _stem(document.path.value);
    final String target = byName
        ? _stem(document.name)
        : (path.contains('/') ? path : '/$path');
    return target.contains(RegExp('[#|]')) ? null : target;
  }

  /// How well [document] matches [wanted], lower is better, or null when it
  /// does not match at all.
  static int? _tierOf(String wanted, SpaceEntryValueObject document) {
    final String path = _stem(document.path.value).toLowerCase();
    if (wanted.startsWith('/')) {
      // From the root, so only what starts there.
      return '/$path'.startsWith(wanted) ? 0 : null;
    }
    if (wanted.contains('/')) {
      return path.startsWith(wanted)
          ? 0
          : path.contains(wanted)
          ? 1
          : null;
    }
    final String name = _stem(document.name).toLowerCase();
    if (name.startsWith(wanted)) {
      return 0;
    }
    if (name
        .split(RegExp(r'[-_ .]'))
        .any((String word) => word.startsWith(wanted))) {
      return 1;
    }
    if (name.contains(wanted)) {
      return 2;
    }
    return path.contains(wanted) ? 3 : null;
  }

  /// [written] without its `.md`, which a link may leave out.
  static String _stem(String written) => written.toLowerCase().endsWith('.md')
      ? written.substring(0, written.length - 3)
      : written;
}
