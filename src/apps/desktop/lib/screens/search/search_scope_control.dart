/// `This file · Whole space`, under the box.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Which of the two the box is asking about.
///
/// A `Segmented · 2` from the library, and **always visible**: which scope
/// is answering is said by the control rather than guessed from where the
/// cursor is (`docs/product/search/README.md`). Measured off
/// `design/screens/desktop/search/searching-every-document-dark.svg`.
class SearchScopeControl extends ConsumerWidget {
  /// Creates the control.
  const SearchScopeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SearchScopeEnum scope = ref.watch(
      searchProvider.select(
        (SearchState state) => switch (state) {
          SearchReady(scope: final SearchScopeEnum scope) => scope,
          _ => SearchScopeEnum.wholeSpace,
        },
      ),
    );
    return SizedBox(
      height: SearchDesign.scopeHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(SearchDesign.scopeRadius),
        ),
        child: Row(
          children: <Widget>[
            for (final SearchScopeEnum each in SearchScopeEnum.values)
              Expanded(
                child: _SegmentWidget(scope: each, isChosen: each == scope),
              ),
          ],
        ),
      ),
    );
  }
}

/// One of the two, raised when it is the one answering.
class _SegmentWidget extends ConsumerWidget {
  const _SegmentWidget({required this.scope, required this.isChosen});

  final SearchScopeEnum scope;
  final bool isChosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<SearchScopeEnum>('scope', scope))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(
        SearchDesign.scopeInset - SearchDesign.scopeStroke,
      ),
      child: Material(
        color: isChosen ? colors.surfaceRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(SearchDesign.scopeTileRadius),
        child: InkWell(
          onTap: () => ref.read(searchProvider.notifier).scopeTo(scope),
          borderRadius: BorderRadius.circular(SearchDesign.scopeTileRadius),
          child: Center(
            child: Text(
              _labels[scope]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SearchDesign.scopeLabel,
                height: 1.4,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w400,
                color: isChosen ? colors.textPrimary : colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What each scope is called on screen.
const Map<SearchScopeEnum, String> _labels = <SearchScopeEnum, String>{
  SearchScopeEnum.thisFile: 'This file',
  SearchScopeEnum.wholeSpace: 'Whole space',
};
