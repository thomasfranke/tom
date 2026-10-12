/// What opens and closes a column or the bottom panel.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A region that slides open and shut along [axis], [extent] points long
/// when open.
///
/// Only a change of [isOpen] moves, over [duration] and never on the first
/// layout; a change of [extent] — a drag — follows at once, and the platform's
/// reduce-motion setting turns the motion off. The child is laid out at its
/// full length all along and clipped, so its contents do not reflow.
class ShellSlideWidget extends StatefulWidget {
  /// Creates the region, [child] drawn in [extent] along [axis].
  const ShellSlideWidget({
    required this.isOpen,
    required this.axis,
    required this.extent,
    required this.alignment,
    required this.child,
    super.key,
  });

  /// How long an opening or a closing takes.
  static const Duration duration = Duration(milliseconds: 200);

  /// Whether the region is on screen.
  final bool isOpen;

  /// Along which it opens: width for horizontal, height for vertical.
  final Axis axis;

  /// Its length when open, which a drag changes.
  final double extent;

  /// The edge of the child that leads the motion: the content stays put
  /// behind it. The right edge of a left column, say.
  final Alignment alignment;

  /// What it holds.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(EnumProperty<Axis>('axis', axis))
      ..add(DoubleProperty('extent', extent))
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment));
  }

  @override
  State<ShellSlideWidget> createState() => _ShellSlideWidgetState();
}

class _ShellSlideWidgetState extends State<ShellSlideWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: ShellSlideWidget.duration,
    value: widget.isOpen ? 1 : 0,
  );

  @override
  void didUpdateWidget(ShellSlideWidget old) {
    super.didUpdateWidget(old);
    if (old.isOpen == widget.isOpen) {
      return;
    }
    final double end = widget.isOpen ? 1 : 0;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _progress.value = end;
    } else {
      unawaited(_progress.animateTo(end, curve: Curves.easeOutCubic));
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool horizontal = widget.axis == Axis.horizontal;
    return AnimatedBuilder(
      animation: _progress,
      // Shut and not moving, nothing of it is built: a closed region is no
      // widget, as it was before it slid.
      builder: (BuildContext context, Widget? child) =>
          _progress.value == 0 && !widget.isOpen
          ? const SizedBox.shrink()
          : ClipRect(
              child: Align(
                alignment: widget.alignment,
                widthFactor: horizontal ? _progress.value : null,
                heightFactor: horizontal ? null : _progress.value,
                child: child,
              ),
            ),
      child: SizedBox(
        width: horizontal ? widget.extent : double.infinity,
        height: horizontal ? double.infinity : widget.extent,
        child: widget.child,
      ),
    );
  }
}
