/// Drawing the wikilink `WikilinkSyntaxImpl` found.
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tom_desktop/screens/preview/widgets/preview_wikilink_widget.dart';
import 'package:tom_domain/tom_domain.dart';

/// Puts a [PreviewWikilinkWidget] inside the sentence, on its baseline.
///
/// Handed back as a `Text` holding one `WidgetSpan`, because the renderer
/// merges a `Text` into the paragraph's own span; any other widget is laid
/// beside the paragraph and breaks the line at the link.
class WikilinkBuilderImpl extends MarkdownElementBuilder {
  /// Creates the builder.
  WikilinkBuilderImpl();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final WikilinkValueObject? link = WikilinkValueObject.tryParse(
      element.textContent,
    );
    if (link == null) {
      return null;
    }
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: PreviewWikilinkWidget(
          link: link,
          style: parentStyle ?? preferredStyle ?? const TextStyle(),
        ),
      ),
    );
  }
}
