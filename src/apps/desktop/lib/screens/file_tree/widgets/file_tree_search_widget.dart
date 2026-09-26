/// The box the space is searched from.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The search field, above the tree and answering into the aside
/// (`docs/product/search/full-text-search/the-surface/doc.md`).
///
/// It types into [SearchNotifier] on every keystroke and never waits: the
/// index is local and already built, so the results follow the typing. The
/// controller is the field's own, cleared only when the notifier says the
/// box is empty — a space that opened after this one.
class FileTreeSearchWidget extends ConsumerStatefulWidget {
  /// Creates the search field.
  const FileTreeSearchWidget({super.key});

  @override
  ConsumerState<FileTreeSearchWidget> createState() =>
      _FileTreeSearchWidgetState();
}

class _FileTreeSearchWidgetState extends ConsumerState<FileTreeSearchWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(searchProvider).terms,
  );

  @override
  void dispose() {
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
    return Padding(
      padding: const EdgeInsets.only(left: TomMetrics.padTight),
      child: SizedBox(
        width: FileTreeDesign.searchWidth,
        height: FileTreeDesign.searchHeight,
        child: TextField(
          controller: _controller,
          onChanged: ref.read(searchProvider.notifier).type,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: FileTreeDesign.placeholder,
            height: 1.4,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search',
            hintStyle: TextStyle(
              fontSize: FileTreeDesign.placeholder,
              height: 1.4,
              color: colors.textMuted,
            ),
            filled: true,
            fillColor: colors.surfaceSunken,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FileTreeDesign.radius),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FileTreeDesign.radius),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FileTreeDesign.radius),
              borderSide: BorderSide(color: colors.accent, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
