/// The notes, at the foot of the document that cites them.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// Every footnote of the document, numbered, under a rule.
///
/// **The one container that is not a block.** Every other row of the preview
/// is a construct the author wrote in that place; this one is assembled from
/// notes written all over the document, which is what a footnote is — the
/// marker stays in the prose and the text comes to the foot
/// ([Decision 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
///
/// It carries no link back to the citation: every block is a widget of its
/// own, so there is nowhere for an anchor to jump to, and a link that did
/// nothing would be worse than none.
class PreviewFootnotesWidget extends StatelessWidget {
  /// Creates the foot for [footnotes].
  const PreviewFootnotesWidget({
    required this.footnotes,
    required this.body,
    super.key,
  });

  /// The document's notes, in citation order.
  final List<FootnoteValueObject> footnotes;

  /// The size the prose around it is set in.
  final double body;

  /// The last block to the rule above the notes.
  static const double ruleTop = 24;

  /// That rule to the first note.
  static const double ruleToFirst = 16;

  /// Between one note and the next.
  static const double noteGap = 8;

  /// The number's column, wide enough for two digits and the stop.
  static const double numberWidth = 24;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<FootnoteValueObject>('footnotes', footnotes))
      ..add(DoubleProperty('body', body));
  }

  @override
  Widget build(BuildContext context) {
    if (footnotes.isEmpty) {
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: ruleTop),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: ruleToFirst),
        for (final FootnoteValueObject note in footnotes) ...<Widget>[
          if (note != footnotes.first) const SizedBox(height: noteGap),
          _NoteWidget(note: note, body: body),
        ],
      ],
    );
  }
}

/// One note: its number, and what it says.
class _NoteWidget extends StatelessWidget {
  const _NoteWidget({required this.note, required this.body});

  final FootnoteValueObject note;
  final double body;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FootnoteValueObject>('note', note))
      ..add(DoubleProperty('body', body));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    // Smaller than the prose it was taken out of, which is what a note is:
    // the same words would not be a note if they read as loudly.
    final double size = body - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: PreviewFootnotesWidget.numberWidth,
          child: Text(
            '${note.number}.',
            style: TextStyle(
              fontSize: size,
              height: PreviewDesign.bodyHeight,
              color: colors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: MarkdownBody(
            // The note's own markdown: a note may carry a link or emphasis,
            // and drawing it as plain text would be a second renderer.
            data: note.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: size,
                height: PreviewDesign.bodyHeight,
                fontFamily: TomFonts.serif,
                color: colors.textSecondary,
              ),
              a: TextStyle(fontSize: size, color: colors.accent),
              blockSpacing: PreviewFootnotesWidget.noteGap,
            ),
          ),
        ),
      ],
    );
  }
}
