/// Drawing a footnote's marker in a block that does not hold its note.
library;

import 'package:markdown/markdown.dart' as md;
import 'package:tom_domain/tom_domain.dart';

/// Turns `[^label]` into the number the **document** gave that footnote.
///
/// The package numbers a footnote by the order it is first cited **in the
/// text it was handed**, so a block rendered on its own would call every
/// footnote it cites number one. The document already counted them
/// ([FootnoteValueObject.number]), so this draws that instead and the
/// package's own footnote handling never runs
/// ([Decision 31](../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
///
/// A reference to a note the document does not have is **left as it was
/// written**: `[^a]` with no definition is not a footnote, and rewriting it
/// would invent one.
class FootnoteRefSyntaxImpl extends md.InlineSyntax {
  /// Draws the numbers [footnotes] carry.
  FootnoteRefSyntaxImpl(this.footnotes) : super(r'\[\^([^\]\s]+)\]');

  /// The document's footnotes, by label.
  final Map<String, FootnoteValueObject> footnotes;

  /// What the marker is emitted as, and what draws it.
  static const String tag = 'tomFootnoteRef';

  /// [notes] by the label each is cited under.
  static Map<String, FootnoteValueObject> by(List<FootnoteValueObject> notes) =>
      <String, FootnoteValueObject>{
        for (final FootnoteValueObject note in notes) note.label: note,
      };

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final FootnoteValueObject? note = footnotes[match.group(1)];
    if (note == null) {
      // Written back as it was, and **consumed**: answering false does not
      // mean "not mine" — the parser has already committed to this syntax
      // and only advances when this answers true, so refusing here leaves it
      // on the same character for ever.
      parser.addNode(md.Text(match[0] ?? ''));
      return true;
    }
    // A tag of the app's own, drawn by [FootnoteMarkerBuilderImpl]. Not
    // `sup`: the renderer raises that with the `sups` font feature, which
    // the serif face the prose is set in does not carry — the number came
    // out on the baseline, reading as a typo rather than as a marker.
    parser.addNode(md.Element(tag, <md.Node>[md.Text('${note.number}')]));
    return true;
  }
}
