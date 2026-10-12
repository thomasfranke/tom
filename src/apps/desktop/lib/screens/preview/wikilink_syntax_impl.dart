/// Finding a wikilink in a block the preview renders.
library;

import 'package:markdown/markdown.dart' as md;
import 'package:tom_domain/tom_domain.dart';

/// Turns `[[…]]` into an element `WikilinkBuilderImpl` draws.
///
/// The parser's own pattern, because what the preview draws has to be what
/// the model resolved (`docs/product/wikilinks/doc.md`). Ahead of the
/// package's syntaxes, so the link syntax never claims the bracket.
class WikilinkSyntaxImpl extends md.InlineSyntax {
  /// Creates the syntax.
  WikilinkSyntaxImpl() : super(r'\[\[([^\[\]\n]+)\]\]', startCharacter: 0x5B);

  /// What the link is emitted as, and what draws it; the element's text is
  /// what was written between the brackets.
  static const String tag = 'tomWikilink';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String inner = match[1]!;
    if (WikilinkValueObject.tryParse(inner) == null) {
      // Written back and consumed: the parser only advances on true
      // (`FootnoteRefSyntaxImpl.onMatch` says why).
      parser.addNode(md.Text(match[0]!));
      return true;
    }
    parser.addNode(md.Element.text(tag, inner));
    return true;
  }
}
