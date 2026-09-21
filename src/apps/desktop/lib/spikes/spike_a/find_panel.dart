/// The find and replace panel — which `re_editor` does not ship.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

/// A minimal find/replace bar over [CodeFindController].
///
/// **This file is itself a finding.** `re_editor` implements find and
/// replace — the matching, the navigation, the replace-all — but ships no
/// widget for it: `CodeEditor.findBuilder` hands you a controller and
/// expects a panel back, and the package's own example carries roughly 250
/// lines of UI to fill the gap. What is here is the smallest thing that
/// proves the controller works; a shipping panel is ours to write, own and
/// keep in the product's visual language.
///
/// The same is true of the selection toolbar (`toolbarController`) and the
/// line-number gutter, which is at least provided as
/// `DefaultCodeLineNumber`.
class SpikeFindPanel extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the panel.
  const SpikeFindPanel({
    required this.controller,
    required this.readOnly,
    super.key,
  });

  /// What drives the search: matches, navigation, replacement.
  final CodeFindController controller;

  /// Whether the editor refuses edits, which hides replacement.
  final bool readOnly;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CodeFindController>('controller', controller))
      ..add(DiagnosticsProperty<bool>('readOnly', readOnly));
  }

  @override
  Size get preferredSize =>
      Size(double.infinity, controller.value == null ? 0 : 88);

  @override
  Widget build(BuildContext context) {
    final CodeFindValue? value = controller.value;
    if (value == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.topRight,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _field(
                        controller.findInputController,
                        controller.findInputFocusNode,
                        'Find',
                      ),
                    ),
                    Text(_matches(value)),
                    IconButton(
                      onPressed: controller.previousMatch,
                      icon: const Icon(Icons.arrow_upward, size: 16),
                    ),
                    IconButton(
                      onPressed: controller.nextMatch,
                      icon: const Icon(Icons.arrow_downward, size: 16),
                    ),
                    IconButton(
                      onPressed: controller.close,
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
                if (value.replaceMode && !readOnly)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _field(
                          controller.replaceInputController,
                          controller.replaceInputFocusNode,
                          'Replace',
                        ),
                      ),
                      TextButton(
                        onPressed: controller.replaceMatch,
                        child: const Text('One'),
                      ),
                      TextButton(
                        onPressed: controller.replaceAllMatches,
                        child: const Text('All'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One of the two text inputs, which differ only in their hint.
  static Widget _field(
    TextEditingController controller,
    FocusNode focusNode,
    String hint,
  ) => TextField(
    controller: controller,
    focusNode: focusNode,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      isDense: true,
      border: const OutlineInputBorder(),
    ),
  );

  /// `3/117`, or `none` before anything matches.
  static String _matches(CodeFindValue value) {
    final CodeFindResult? result = value.result;
    return result == null
        ? 'none'
        : '${result.index + 1}/${result.matches.length}';
  }
}
