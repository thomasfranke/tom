/// Finding the heading an `#anchor` names.
library;

import 'package:tom_domain/src/documents/block_kind_enum.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';

/// An anchor and a document's blocks in, the heading it names out.
///
/// GitHub's rule, because that is where these documents are also read: the
/// heading's words lowercased, punctuation dropped, each space a `-`, and a
/// repeat suffixed `-1`, `-2`. The anchor is put through the same rule, so
/// `#Enforcement` and `#enforcement` name one heading.
final class HeadingAnchorService {
  /// Creates the service.
  const HeadingAnchorService();

  static final RegExp _atx = RegExp(r'^ {0,3}#{1,6}(?:[ \t]+(.*?))?[ \t]*$');
  static final RegExp _closing = RegExp(r'(?:^|[ \t]+)#+$');
  static final RegExp _link = RegExp(r'!?\[([^\]]*)\](?:\([^)]*\)|\[[^\]]*\])');
  static final RegExp _dropped = RegExp(
    r'[^\p{L}\p{M}\p{N}\p{Pc} -]',
    unicode: true,
  );

  /// [text] as GitHub writes it after the `#`.
  String slugOf(String text) =>
      text.trim().toLowerCase().replaceAll(_dropped, '').replaceAll(' ', '-');

  /// The words of [block] when it is a heading, `#` or underlined; null
  /// otherwise. A link keeps its words and loses its address.
  String? textOf(BlockValueObject block) {
    if (block.kind != BlockKindEnum.heading) {
      return null;
    }
    final List<String> lines = block.source.split('\n');
    final String words;
    if (_atx.firstMatch(lines.first) case final RegExpMatch atx) {
      words = (atx.group(1) ?? '').replaceFirst(_closing, '');
    } else {
      // Underlined: every line but the `===` or `---` under it.
      words = lines
          .sublist(0, lines.length - 1)
          .map((String line) => line.trim())
          .join(' ');
    }
    return words
        .replaceAllMapped(_link, (Match link) => link.group(1) ?? '')
        .trim();
  }

  /// The first heading of [blocks] that [anchor] names, or null when none
  /// does — an anchor is a convenience, and missing is not a failure.
  BlockValueObject? headingOf(String anchor, List<BlockValueObject> blocks) {
    final String wanted = slugOf(anchor);
    if (wanted.isEmpty) {
      return null;
    }
    final Map<String, int> seen = <String, int>{};
    for (final BlockValueObject block in blocks) {
      final String? text = textOf(block);
      if (text == null) {
        continue;
      }
      final String slug = slugOf(text);
      final int repeats = seen[slug] ?? 0;
      seen[slug] = repeats + 1;
      if ((repeats == 0 ? slug : '$slug-$repeats') == wanted) {
        return block;
      }
    }
    return null;
  }
}
