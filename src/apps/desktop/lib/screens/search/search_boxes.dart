/// The search box and, once revealed, the replace box under it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_desktop/screens/search/search_focus.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What is being looked for, and — once revealed — what it becomes.
///
/// No control opens the second box: ⌥⌘F does (Ctrl+H off macOS), from the
/// shell, because replacing is the rarer half and the field is the
/// `Explorer` master's shape (`docs/product/search/replacing/doc.md`).
class SearchBoxes extends ConsumerWidget {
  /// Creates the boxes.
  const SearchBoxes({super.key});

  /// Whether [state] shows the replace box: only for `This file`, the one
  /// scope with a buffer to write into.
  static bool isReplacing(SearchState state) => switch (state) {
    SearchReady(
      isReplacing: final bool showing,
      scope: SearchScopeEnum.thisFile,
    ) =>
      showing,
    _ => false,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool replacing = ref.watch(searchProvider.select(isReplacing));
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SearchDesign.controlInset,
      ),
      child: Column(
        children: <Widget>[
          const SearchFieldWidget(),
          if (replacing) ...<Widget>[
            const SizedBox(height: SearchDesign.boxGap),
            const _ReplacementWidget(),
          ],
        ],
      ),
    );
  }
}

/// What the words found become.
class _ReplacementWidget extends ConsumerStatefulWidget {
  const _ReplacementWidget();

  @override
  ConsumerState<_ReplacementWidget> createState() => _ReplacementState();
}

class _ReplacementState extends ConsumerState<_ReplacementWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (ref.read(searchProvider)) {
      SearchReady(replacement: final String it) => it,
      _ => '',
    },
  );

  /// The shell's node when there is one, so ⌥⌘F can put the keyboard here;
  /// its own otherwise, and only then is it this box's to dispose.
  late final FocusNode? _borrowed = SearchFocusScope.replaceOf(context);
  late final FocusNode _focus = (_borrowed ?? FocusNode())
    ..addListener(_focusChanged);

  void _focusChanged() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    if (_borrowed == null) {
      _focus.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return TomFieldBoxWidget(
      height: SearchDesign.boxHeight,
      // A step above the search box, which is sunken: the two are not the
      // same kind of field, and the board says so in the fill
      // (`searching-replace-dark.svg`).
      fill: colors.surface,
      isFocused: _focus.hasFocus,
      radius: SearchDesign.radius,
      // An empty box deletes what matched, which is a replacement like any
      // other and needs no second control.
      child: TomFieldWidget(
        controller: _controller,
        focusNode: _focus,
        onChanged: ref.read(searchProvider.notifier).replaceWith,
        hint: context.l10n.searchReplaceWith,
        fontSize: SearchDesign.boxText,
      ),
    );
  }
}
