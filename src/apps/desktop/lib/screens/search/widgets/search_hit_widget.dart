/// One document the search found.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_marks.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A hit: the file's name, the folder it is in, and the stretch of it that
/// matched (`docs/product/search/full-text-search/the-surface/doc.md`).
///
/// The excerpt is the index's, cut where it cuts; what is marked in it is
/// this widget's reading of the words in the box ([markedRuns]). Clicking
/// opens the document the way the tree does, through the session.
class SearchHitWidget extends ConsumerWidget {
  /// Creates the row for [hit], marking [terms] in its excerpt.
  const SearchHitWidget({
    required this.hit,
    required this.terms,
    required this.spaceName,
    super.key,
  });

  /// The document that matched.
  final SearchHitValueObject hit;

  /// What is in the search box.
  final String terms;

  /// The space's own folder, which is what a document at its root is in.
  final String spaceName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<SearchHitValueObject>('hit', hit))
      ..add(StringProperty('terms', terms))
      ..add(StringProperty('spaceName', spaceName));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SearchDesign.hitInset),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SearchDesign.radius),
        child: InkWell(
          onTap: () => ref.read(searchProvider.notifier).open(hit),
          borderRadius: BorderRadius.circular(SearchDesign.radius),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SearchDesign.hitPad,
              SearchDesign.hitTop,
              SearchDesign.hitPad,
              SearchDesign.hitBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SearchDesign.name,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  _folder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SearchDesign.path,
                    height: 1.4,
                    fontFamily: 'Menlo',
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: SearchDesign.excerptGap),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      for (final ExcerptRun run in markedRuns(
                        hit.excerpt,
                        terms,
                      ))
                        TextSpan(
                          text: run.text,
                          style: run.marked
                              ? TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colors.accent,
                                )
                              : null,
                        ),
                    ],
                  ),
                  maxLines: SearchDesign.excerptLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SearchDesign.excerpt,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Where the document is, which is the space itself when it is at its root.
  String get _folder {
    final List<String> segments = hit.path.value.split('/')..removeLast();
    return segments.isEmpty ? '$spaceName/' : '${segments.join('/')}/';
  }
}
