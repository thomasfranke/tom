/// The box the search is typed into.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_focus.dart';
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

  /// The shell's node when there is one, so ⌘K can reach this field; its own
  /// otherwise, and only then is it this field's to dispose.
  late final FocusNode? _borrowed = SearchFocusScope.maybeOf(context);
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
    final bool replacing = ref.watch(
      searchProvider.select(SearchBoxes.isReplacing),
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
              hint: context.l10n.searchHint,
              fontSize: SearchDesign.boxText,
            ),
          ),
          // The shortcut, said where it leads, while the box is idle: once it
          // has the keyboard or a question, the keycap has nothing to offer.
          if (!hasTerms && !_focus.hasFocus)
            const Padding(
              padding: EdgeInsets.only(right: SearchDesign.keycapRight),
              child: _KeycapWidget(),
            ),
          // Replace, drawn once there is something to replace — the same
          // press as ⌥⌘F, lit while the second box is open
          // (`search/searching-replace-dark.svg`).
          if (hasTerms)
            _ReplaceToggleWidget(
              isOn: replacing,
              onPressed: SearchFocusScope.toggleReplaceOf(context),
            ),
          // The `Field clear` component, present only while there is
          // something to clear (`docs/design/components/controls.md`).
          if (hasTerms)
            IconButton(
              onPressed: ref.read(searchProvider.notifier).clear,
              icon: TomFieldClearWidget(on: colors.surfaceSunken),
              iconSize: SearchDesign.clearGlyph,
              splashRadius: SearchDesign.clearGlyph,
              tooltip: context.l10n.searchClear,
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

/// `⇄` beside the clear: opens the replace box, lit while it is open
/// (`docs/product/search/replacing/doc.md`).
class _ReplaceToggleWidget extends StatelessWidget {
  const _ReplaceToggleWidget({required this.isOn, required this.onPressed});

  final bool isOn;

  /// The shell's own ⌥⌘F; null where nothing provides it, which leaves the
  /// button on screen and unavailable.
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('isOn', value: isOn, ifTrue: 'on'))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final String keys = defaultTargetPlatform == TargetPlatform.macOS
        ? '⌥⌘F'
        : 'Ctrl+H';
    return Tooltip(
      message: isOn
          ? context.l10n.searchHideReplace(keys)
          : context.l10n.searchShowReplace(keys),
      child: SizedBox(
        width: SearchDesign.replaceToggleBox,
        height: SearchDesign.boxHeight,
        child: OverflowBox(
          maxWidth: SearchDesign.replaceToggleFill,
          child: Material(
            color: isOn ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(
              SearchDesign.replaceToggleRadius,
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                SearchDesign.replaceToggleRadius,
              ),
              child: SizedBox.square(
                dimension: SearchDesign.replaceToggleFill,
                child: Center(
                  child: TomGlyphWidget(
                    glyph: TomGlyphEnum.replace,
                    color: isOn ? colors.accent : colors.textMuted,
                    size: SearchDesign.replaceToggleGlyph,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `⌘K` in a keycap — `Ctrl K` off macOS, where the key is called that.
class _KeycapWidget extends StatelessWidget {
  const _KeycapWidget();

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Container(
      width: SearchDesign.keycapWidth,
      height: SearchDesign.keycapHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SearchDesign.keycapRadius),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        defaultTargetPlatform == TargetPlatform.macOS ? '⌘K' : 'Ctrl K',
        maxLines: 1,
        style: TextStyle(
          fontSize: SearchDesign.keycapText,
          height: 1,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
