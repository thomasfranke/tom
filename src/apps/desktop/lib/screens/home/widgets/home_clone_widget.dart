/// `Clone from URL`, and the field that takes its place.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_clone_note_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_secondary_button_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Cloning by URL in place, Home still on screen
/// (`docs/product/home/cloning/doc.md`, boards `clone-from-url`, `cloning`,
/// `clone-failed`).
///
/// Enter or `Clone` asks for the folder and clones into it; Escape puts the
/// button back. The line under the controls sits inside the gap the recent
/// list already keeps, so nothing below it moves.
class HomeCloneWidget extends ConsumerStatefulWidget {
  /// Creates the control for [clone], keeping the gap under it while
  /// [keepsGap] even with the button showing.
  const HomeCloneWidget({
    required this.clone,
    required this.keepsGap,
    super.key,
  });

  /// Where cloning has got to.
  final HomeCloneState clone;

  /// Whether something follows that the gap separates it from.
  final bool keepsGap;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<HomeCloneState>('clone', clone))
      ..add(DiagnosticsProperty<bool>('keepsGap', keepsGap));
  }

  @override
  ConsumerState<HomeCloneWidget> createState() => _HomeCloneState();
}

class _HomeCloneState extends ConsumerState<HomeCloneWidget> {
  final TextEditingController _address = TextEditingController();

  late final FocusNode _focus = FocusNode(onKeyEvent: _escape)
    ..addListener(_refocused);

  /// Whether the folder dialog is up, so a second press does not open
  /// another.
  bool _picking = false;

  KeyEventResult _escape(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _address.clear();
      ref.read(homeProvider.notifier).closeClone();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // The outline follows the keyboard.
  void _refocused() => setState(() {});

  @override
  void didUpdateWidget(HomeCloneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The field takes the keyboard when it appears, even though Home holds
    // focus for its shortcuts: `autofocus` only wins over an empty scope.
    if (oldWidget.clone is HomeCloneClosed && widget.clone is HomeCloneOpen) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          _focus.requestFocus();
        }
      });
    }
  }

  /// Asks for the folder to clone into, then clones; a cancelled dialog
  /// moves nothing.
  Future<void> _clone() async {
    final String url = _address.text.trim();
    if (url.isEmpty || _picking) {
      return;
    }
    _picking = true;
    final String? parent = await ref.read(folderPickerProvider)();
    _picking = false;
    if (parent == null || !mounted) {
      return;
    }
    await ref.read(homeProvider.notifier).clone(url: url, parent: parent);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_refocused)
      ..dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeCloneState clone = widget.clone;
    final bool isOpen = clone is! HomeCloneClosed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isOpen)
          SizedBox(
            width: HomeDesign.column,
            height: HomeDesign.control,
            child: Row(
              children: <Widget>[
                Expanded(child: _field(context, clone)),
                const SizedBox(width: HomeDesign.fieldToClone),
                _button(context, clone),
              ],
            ),
          )
        else
          HomeSecondaryButtonWidget(
            label: context.l10n.homeCloneFromUrl,
            glyph: TomGlyphEnum.link,
            onPressed: ref.read(homeProvider.notifier).showClone,
          ),
        if (isOpen || widget.keepsGap)
          SizedBox(
            width: HomeDesign.column,
            height: HomeDesign.cloneToRecent,
            child: isOpen ? HomeCloneNoteWidget(clone: clone) : null,
          ),
      ],
    );
  }

  Widget _field(BuildContext context, HomeCloneState clone) {
    final TomColors colors = TomColors.of(context);
    final (Color edge, double stroke) = switch (clone) {
      HomeCloneCloning() => (colors.border, 1.0),
      HomeCloneFailed() => (colors.removed, HomeDesign.fieldStroke),
      _ when _focus.hasFocus => (colors.accent, HomeDesign.fieldStroke),
      _ => (colors.border, 1.0),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        // Centred on the edge, as the board strokes it, so the text keeps
        // its 16 whatever the outline's weight.
        border: Border.all(
          color: edge,
          width: stroke,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: switch (clone) {
        // Read-only while git works: the address is what is being cloned.
        HomeCloneCloning(:final String url) => Padding(
          padding: const EdgeInsets.only(left: HomeDesign.fieldInset),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: HomeDesign.fieldText,
                color: colors.textMuted,
              ),
            ),
          ),
        ),
        _ => TomFieldWidget(
          controller: _address,
          focusNode: _focus,
          autofocus: true,
          hint: '',
          fontSize: HomeDesign.fieldText,
          pad: HomeDesign.fieldInset,
          onSubmit: () => unawaited(_clone()),
        ),
      },
    );
  }

  Widget _button(BuildContext context, HomeCloneState clone) {
    final TomColors colors = TomColors.of(context);
    final bool isCloning = clone is HomeCloneCloning;
    return FilledButton(
      onPressed: isCloning ? null : () => unawaited(_clone()),
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.surfaceRaised,
        disabledBackgroundColor: colors.control,
        disabledForegroundColor: colors.textMuted,
        fixedSize: const Size(HomeDesign.cloneButton, HomeDesign.control),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        // Restated for the reason `HomePrimaryButtonWidget` gives.
        textStyle: const TextStyle(
          fontFamily: TomFonts.sans,
          fontSize: HomeDesign.fieldText,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(
        isCloning ? context.l10n.homeCloning : context.l10n.homeClone,
      ),
    );
  }
}
