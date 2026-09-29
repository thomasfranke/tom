/// What somebody wrote between double brackets.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
// For the dartdoc below: what a link resolves to is that type's answer.
import 'package:tom_domain/src/wikilinks/wikilink_target_value_object.dart';

part 'wikilink_value_object.freezed.dart';

/// A `[[target#anchor]]` as written, before anything is looked up.
///
/// What it *means* is [WikilinkTargetValueObject]'s, decided against the
/// space's listing ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
@freezed
abstract class WikilinkValueObject with _$WikilinkValueObject {
  /// A link to [target], optionally at [anchor].
  const factory WikilinkValueObject({
    /// What was written before the `#`, trimmed, never empty.
    required String target,

    /// What was written after the first `#`, or null when there was none.
    String? anchor,
  }) = _WikilinkValueObject;

  const WikilinkValueObject._();

  /// [inner] parsed, or null when there is no target to look up.
  ///
  /// [inner] is what sits between the brackets — the brackets themselves are
  /// the parser's business, not this type's.
  static WikilinkValueObject? tryParse(String inner) {
    final int hash = inner.indexOf('#');
    final String target = (hash < 0 ? inner : inner.substring(0, hash)).trim();
    if (target.isEmpty) {
      return null;
    }

    final String anchor = hash < 0 ? '' : inner.substring(hash + 1).trim();
    return WikilinkValueObject(
      target: target,
      anchor: anchor.isEmpty ? null : anchor,
    );
  }

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
