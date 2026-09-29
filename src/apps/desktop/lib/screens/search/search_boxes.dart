/// The search box, the chevron that reveals the second one, and that one.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What is being looked for, and — once revealed — what it becomes.
///
/// The chevron sits left of the first box and opens the second, because
/// replacing is the rarer half and a box nobody uses is a box in the way of
/// the results (`docs/product/search/replacing/doc.md`).
class SearchBoxes extends ConsumerWidget {
  /// Creates the boxes.
  const SearchBoxes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The second box belongs to the open file, which is why it shows only
    // there — the chevron is drawn either way, and opening it is what makes
    // the file the question (`docs/product/search/replacing/doc.md`).
    final bool replacing = ref.watch(
      searchProvider.select(
        (SearchState state) => switch (state) {
          SearchReady(
            isReplacing: final bool showing,
            scope: SearchScopeEnum.thisFile,
          ) =>
            showing,
          _ => false,
        },
      ),
    );
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _ChevronWidget(isOpen: replacing),
            const SizedBox(width: SearchDesign.chevronGap),
            const Expanded(child: SearchFieldWidget()),
            const SizedBox(width: SearchDesign.controlInset),
          ],
        ),
        if (replacing) ...<Widget>[
          const SizedBox(height: SearchDesign.boxGap),
          // Indented to the first box's left edge: the chevron belongs to the
          // pair, not to either one of them.
          const Padding(
            padding: EdgeInsets.only(
              left:
                  SearchDesign.controlInset +
                  SearchDesign.chevronBox +
                  SearchDesign.chevronGap,
              right: SearchDesign.controlInset,
            ),
            child: _ReplacementWidget(),
          ),
        ],
      ],
    );
  }
}

/// The control that reveals the second box.
class _ChevronWidget extends ConsumerWidget {
  const _ChevronWidget({required this.isOpen});

  final bool isOpen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isOpen', isOpen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: SearchDesign.controlInset + SearchDesign.chevronBox,
      height: SearchDesign.boxHeight,
      child: IconButton(
        onPressed: () =>
            ref.read(searchProvider.notifier).showReplacing(showing: !isOpen),
        padding: EdgeInsets.zero,
        tooltip: isOpen ? 'Hide replace' : 'Replace',
        icon: TomChevronWidget(isOpen: isOpen, color: colors.textMuted),
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
        hint: 'Replace with',
        fontSize: SearchDesign.boxText,
      ),
    );
  }
}
