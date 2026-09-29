/// What the words are in the open document, and what they would become.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/widgets/search_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The occurrences in the buffer, each under the heading it was found below
/// (`docs/design/screens/desktop/search/searching-open-file-dark.svg`).
///
/// The actions are on the current row rather than under the fields: replacing
/// is a decision per occurrence, and one pair of buttons for all of them
/// decides for somebody (`docs/product/search/replacing/doc.md`).
class SearchOccurrencesPanel extends ConsumerWidget {
  /// Creates the list.
  const SearchOccurrencesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SearchReady? ready = switch (ref.watch(searchProvider)) {
      final SearchReady it => it,
      _ => null,
    };
    final String name =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.openDocument?.name,
          ),
        ) ??
        '';
    if (ready == null || name.isEmpty) {
      return const SearchNoteWidget('Open a document to search inside it.');
    }
    if (ready.terms.trim().isEmpty) {
      return const SearchNoteWidget('Type to search this document.');
    }
    final List<OccurrenceValueObject> found = ready.occurrences;
    if (found.isEmpty) {
      return SearchNoteWidget('Nothing in $name says that.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The count and the button share one row of the board's own height,
        // so the list starts in the same place whether or not the button is
        // there.
        SizedBox(
          height: SearchDesign.countRow,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SearchDesign.controlInset,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _counted(found.length, name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: SearchDesign.count,
                      height: 1.2,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                // Beside the count, which is what says how many it is about
                // to change.
                if (ready.isReplacing) const _ReplaceAllWidget(),
              ],
            ),
          ),
        ),
        const SizedBox(height: SearchDesign.countGap),
        Expanded(
          child: ListView.builder(
            itemCount: found.length,
            itemExtent: SearchDesign.rowHeight + SearchDesign.rowGap,
            itemBuilder: (BuildContext context, int index) => _RowWidget(
              occurrence: found[index],
              replacement: ready.replacement,
              isReplacing: ready.isReplacing,
              isCurrent: index == ready.current,
              index: index,
            ),
          ),
        ),
      ],
    );
  }

  /// How many, and in what.
  static String _counted(int found, String name) =>
      found == 1 ? '1 occurrence in $name' : '$found occurrences in $name';
}

/// Replaces all of them, at the right of the count.
class _ReplaceAllWidget extends ConsumerWidget {
  const _ReplaceAllWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: SearchDesign.replaceAllWidth,
      height: SearchDesign.countRow,
      child: TextButton(
        onPressed: ref.read(searchProvider.notifier).replaceEvery,
        style: TextButton.styleFrom(
          backgroundColor: colors.surfaceRaised,
          foregroundColor: colors.textPrimary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SearchDesign.radius),
          ),
          textStyle: const TextStyle(
            fontSize: SearchDesign.replaceAll,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Replace all'),
      ),
    );
  }
}

/// One occurrence: the heading it is under, the text around it, and — while
/// it is the current one — what can be done to it.
class _RowWidget extends ConsumerWidget {
  const _RowWidget({
    required this.occurrence,
    required this.replacement,
    required this.isReplacing,
    required this.isCurrent,
    required this.index,
  });

  final OccurrenceValueObject occurrence;
  final String replacement;
  final bool isReplacing;
  final bool isCurrent;
  final int index;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<OccurrenceValueObject>('at', occurrence))
      ..add(StringProperty('replacement', replacement))
      ..add(DiagnosticsProperty<bool>('isReplacing', isReplacing))
      ..add(DiagnosticsProperty<bool>('isCurrent', isCurrent))
      ..add(IntProperty('index', index));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SearchDesign.controlInset,
        right: SearchDesign.controlInset,
        bottom: SearchDesign.rowGap,
      ),
      // The pointer moving down the list is what makes a row the current one,
      // which is what puts the actions within reach of where it already is.
      child: MouseRegion(
        onEnter: (PointerEnterEvent _) =>
            ref.read(searchProvider.notifier).focusOn(index),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCurrent ? colors.accentSoft : null,
            borderRadius: BorderRadius.circular(SearchDesign.radius),
          ),
          child: SizedBox(
            height: SearchDesign.rowHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SearchDesign.hitPad,
                SearchDesign.rowTop,
                SearchDesign.hitPad,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (occurrence.heading.isNotEmpty) ...<Widget>[
                          Text(
                            occurrence.heading,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SearchDesign.heading,
                              height: 1.2,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: SearchDesign.headingGap),
                        ],
                        _ExcerptWidget(
                          occurrence: occurrence,
                          replacement: replacement,
                          isReplacing: isReplacing,
                        ),
                      ],
                    ),
                  ),
                  if (isReplacing && isCurrent) ...<Widget>[
                    _ActionWidget(
                      icon: Icons.swap_horiz,
                      tooltip: 'Replace this one',
                      onPressed: () => ref
                          .read(searchProvider.notifier)
                          .replaceOne(occurrence),
                    ),
                    _ActionWidget(
                      icon: Icons.close,
                      tooltip: 'Skip this one',
                      onPressed: () =>
                          ref.read(searchProvider.notifier).dismiss(occurrence),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The text around the match, with the match itself in the diff's own roles.
class _ExcerptWidget extends StatelessWidget {
  const _ExcerptWidget({
    required this.occurrence,
    required this.replacement,
    required this.isReplacing,
  });

  final OccurrenceValueObject occurrence;
  final String replacement;
  final bool isReplacing;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<OccurrenceValueObject>('at', occurrence))
      ..add(StringProperty('replacement', replacement))
      ..add(DiagnosticsProperty<bool>('isReplacing', isReplacing));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final int at = occurrence.excerptStart;
    final String excerpt = occurrence.excerpt;
    final int after = at + occurrence.matched.length;
    final TextStyle around = TextStyle(
      fontSize: SearchDesign.excerpt,
      height: 1.2,
      color: colors.textSecondary,
    );
    return Text.rich(
      TextSpan(
        style: around,
        children: <InlineSpan>[
          TextSpan(text: excerpt.substring(0, at)),
          // What is there now, and what would take its place: struck through
          // in the removed role, then the new words in the added one.
          TextSpan(
            text: excerpt.substring(at, after),
            style: TextStyle(
              color: isReplacing ? colors.removed : colors.accent,
              decoration: isReplacing ? TextDecoration.lineThrough : null,
              decorationColor: colors.removed,
            ),
          ),
          if (isReplacing && replacement.isNotEmpty)
            TextSpan(
              text: replacement,
              style: TextStyle(color: colors.added),
            ),
          TextSpan(text: excerpt.substring(after)),
        ],
      ),
      maxLines: SearchDesign.occurrenceLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// One of the two things that can be done to the current occurrence.
class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(StringProperty('tooltip', tooltip))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: SearchDesign.rowAction,
      color: colors.textMuted,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: SearchDesign.rowActionBox,
        height: SearchDesign.rowActionBox,
      ),
    );
  }
}
