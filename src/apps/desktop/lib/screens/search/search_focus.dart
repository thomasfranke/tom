/// The search boxes' keyboard focus, reachable from the shell's shortcuts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Hands the two search boxes' [FocusNode]s to whatever is above them.
///
/// ⌘K and ⌥⌘F live in the shell, which owns the window's shortcuts, and the
/// boxes live in the explorer — the nearest thing that holds both is the
/// shell, so it owns the nodes and the boxes borrow them.
class SearchFocusScope extends InheritedWidget {
  /// Puts [node], [replace] and [toggleReplace] over [child].
  const SearchFocusScope({
    required this.node,
    required super.child,
    this.replace,
    this.toggleReplace,
    super.key,
  });

  /// The search field's focus.
  final FocusNode node;

  /// The replace box's focus, when something above it reaches for it.
  final FocusNode? replace;

  /// What ⌥⌘F does, so the field's ⇄ is the same press and not a second
  /// route that could disagree with it about where the keyboard goes.
  final VoidCallback? toggleReplace;

  /// The node above [context], or null when nothing provides one — a field
  /// mounted on its own, in a test, keeps a node of its own.
  static FocusNode? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SearchFocusScope>()?.node;

  /// The replace box's node above [context], null the same way.
  static FocusNode? replaceOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SearchFocusScope>()?.replace;

  /// The replace toggle above [context], null the same way.
  static VoidCallback? toggleReplaceOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SearchFocusScope>()?.toggleReplace;

  @override
  bool updateShouldNotify(SearchFocusScope oldWidget) =>
      node != oldWidget.node ||
      replace != oldWidget.replace ||
      toggleReplace != oldWidget.toggleReplace;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FocusNode>('node', node))
      ..add(DiagnosticsProperty<FocusNode?>('replace', replace))
      ..add(
        ObjectFlagProperty<VoidCallback?>.has('toggleReplace', toggleReplace),
      );
  }
}
