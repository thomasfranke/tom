/// The box the search is typed into.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The search field, at the top of the left column and answering into it
/// (`docs/product/search/full-text-search/the-surface/doc.md`).
///
/// It types into [SearchNotifier] on every keystroke and never waits: the
/// index is local and already built, so the results follow the typing. The
/// controller is the field's own, cleared only when the notifier says the
/// box is empty — a space that opened after this one.
class SearchFieldWidget extends ConsumerStatefulWidget {
  /// Creates the search field.
  const SearchFieldWidget({super.key});

  @override
  ConsumerState<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends ConsumerState<SearchFieldWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(searchProvider).terms,
  );
  late final FocusNode _focus = FocusNode()..addListener(_focusChanged);

  void _focusChanged() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_focusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SearchState>(searchProvider, (
      SearchState? previous,
      SearchState next,
    ) {
      if (next.terms.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });
    final TomColors colors = TomColors.of(context);
    final bool hasTerms = ref.watch(
      searchProvider.select((SearchState state) => state.terms.isNotEmpty),
    );
    return TomFieldBoxWidget(
      height: SearchDesign.boxHeight,
      fill: colors.surfaceSunken,
      isFocused: _focus.hasFocus,
      radius: SearchDesign.radius,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TomFieldWidget(
              controller: _controller,
              focusNode: _focus,
              onChanged: ref.read(searchProvider.notifier).type,
              hint: 'Search',
              fontSize: SearchDesign.boxText,
            ),
          ),
          // The `Field clear` component, present only while there is
          // something to clear (`docs/design/components/controls.md`).
          if (hasTerms)
            IconButton(
              onPressed: ref.read(searchProvider.notifier).clear,
              icon: TomFieldClearWidget(on: colors.surfaceSunken),
              iconSize: SearchDesign.chevronBox,
              splashRadius: SearchDesign.chevronBox,
              tooltip: 'Clear the search',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: SearchDesign.boxHeight,
                height: SearchDesign.boxHeight,
              ),
            ),
        ],
      ),
    );
  }
}
