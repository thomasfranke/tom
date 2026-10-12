/// What somebody wrote between double brackets.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
// For the dartdoc below: what a link resolves to is that type's answer.
import 'package:tom_domain/src/wikilinks/wikilink_target_value_object.dart';

part 'wikilink_value_object.freezed.dart';

/// A `[[target#anchor|label]]` as written, before anything is looked up.
///
/// What it *means* is [WikilinkTargetValueObject]'s, decided against the
/// space's listing ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
@freezed
abstract class WikilinkValueObject with _$WikilinkValueObject {
  /// A link to [target], optionally at [anchor], optionally shown as [label].
  const factory WikilinkValueObject({
    /// What was written before the `#`, trimmed; empty only when the link
    /// is to a heading of the document it is written in, `[[#heading]]`.
    required String target,

    /// What was written after the first `#`, or null when there was none.
    String? anchor,

    /// What was written after the first `|`, or null when there was none —
    /// the words the preview shows instead of the target.
    String? label,
  }) = _WikilinkValueObject;

  const WikilinkValueObject._();

  /// [inner] parsed, or null when it names neither a document nor a heading.
  ///
  /// [inner] is what sits between the brackets — the brackets themselves are
  /// the parser's business, not this type's. The `|` is split first, so a
  /// `#` inside the label is the label's.
  static WikilinkValueObject? tryParse(String inner) {
    final int bar = inner.indexOf('|');
    final String link = bar < 0 ? inner : inner.substring(0, bar);
    final String label = bar < 0 ? '' : inner.substring(bar + 1).trim();

    final int hash = link.indexOf('#');
    final String target = (hash < 0 ? link : link.substring(0, hash)).trim();
    final String anchor = hash < 0 ? '' : link.substring(hash + 1).trim();
    if (target.isEmpty && anchor.isEmpty) {
      return null;
    }
    return WikilinkValueObject(
      target: target,
      anchor: anchor.isEmpty ? null : anchor,
      label: label.isEmpty ? null : label,
    );
  }

  /// Whether the link is to a heading of the document it is written in,
  /// naming no document of its own.
  bool get isWithinDocument => target.isEmpty;

  /// The words a reader is shown: the label, else the document's name, else
  /// the heading's.
  String get shownAs => label ?? (isWithinDocument ? anchor ?? '' : target);

  /// Whether the target names a path rather than a document.
  ///
  /// A `/` is the author saying they mean one exact file, which is the only
  /// way to reach a name the space holds more than once.
  bool get isPath => target.contains('/');

  /// The target with a trailing `.md` removed, which is what a name is
  /// matched by — writing the extension is allowed and means the same thing.
  String get targetWithoutExtension => target.toLowerCase().endsWith('.md')
      ? target.substring(0, target.length - 3)
      : target;
}
