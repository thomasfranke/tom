/// The mark's trunk, carried past the letterform and given a heartbeat.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/widgets/tom_wordmark_widget.dart';

/// Home's ground: the commit line the wordmark's O sits on.
///
/// The O *is* a commit on a trunk ([TomMark]) and the letterform stops that
/// trunk at its own edge. This carries it to both edges of the screen and
/// runs one cycle over it — a commit rises from below, lands on the node,
/// the node answers, and the change carries on upward. History runs the way
/// a trunk grows: older below, newer above.
///
/// **Nothing is assumed about where the mark is.** The wordmark under a
/// trunk carries [anchorOf]'s key, and the geometry is measured off what was
/// actually laid out — so a different cap height, or a window that moves the
/// block, moves the ground with it. Without that key it paints nothing,
/// which is how a screen keeps using [TomWordmarkWidget] with no trunk above
/// it.
class CommitTrunkWidget extends StatefulWidget {
  /// Puts the trunk behind [child], carrying [commits] down the line.
  const CommitTrunkWidget({
    required this.child,
    this.commits = const <TrunkCommit>[],
    super.key,
  });

  /// The screen this is the ground for.
  final Widget child;

  /// What sits on the line under the mark, newest first.
  ///
  /// **Whatever is here has to be true.** On a landing page the log can be
  /// the site's own story; on a screen someone is using, a plausible hash
  /// that belongs to nobody reads as their data. Empty is a fine answer —
  /// a first run has no history, and the line is then just a line.
  final List<TrunkCommit> commits;

  /// The key the wordmark under a [CommitTrunkWidget] must carry.
  ///
  /// Null when there is no trunk above it — `TomWordmarkWidget(key:
  /// anchorOf(...))`
  /// is then an ordinary wordmark with no key, and nothing else changes.
  static GlobalKey? anchorOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TrunkScope>()?.anchor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TrunkCommit>('commits', commits));
  }

  @override
  State<CommitTrunkWidget> createState() => _CommitTrunkWidgetState();
}

class _CommitTrunkWidgetState extends State<CommitTrunkWidget>
    with SingleTickerProviderStateMixin {
  /// One cycle: rise, land, answer, carry on.
  ///
  /// Slower than the same figure on the website. A visitor watches a landing
  /// page for twenty seconds; this is the screen someone opens the app into,
  /// and a fast loop behind a decision is a distraction.
  static const Duration _cycle = Duration(milliseconds: 7600);

  final GlobalKey _anchor = GlobalKey();

  /// Where the mark landed, in this widget's own coordinates.
  ///
  /// A notifier rather than state: the mark moving repaints the ground and
  /// never rebuilds the screen it is behind.
  final ValueNotifier<Rect?> _mark = ValueNotifier<Rect?>(null);

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The platform's own answer to "no animations, please" — the still frame
    // is the design, not a fallback, so it keeps the line and the commits.
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock
        ..stop()
        ..value = 0;
    } else if (!_clock.isAnimating) {
      // The ticker's future completes only when something stops it, which is
      // dispose — there is nothing here to await.
      unawaited(_clock.repeat());
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    _mark.dispose();
    super.dispose();
  }

  /// Reads the mark's box after the frame that laid it out.
  void _measure() {
    final RenderObject? mark = _anchor.currentContext?.findRenderObject();
    final RenderObject? self = context.findRenderObject();
    if (mark is! RenderBox ||
        self is! RenderBox ||
        !mark.hasSize ||
        !self.hasSize) {
      return;
    }
    final Rect box =
        mark.localToGlobal(Offset.zero, ancestor: self) & mark.size;
    if (_mark.value != box) {
      _mark.value = box;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final ThemeData theme = Theme.of(context);
    return _TrunkScope(
      anchor: _anchor,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TrunkPainter(
                  clock: _clock,
                  mark: _mark,
                  colors: TomColors.of(context),
                  // Sage over cream reads stronger than sage over ink, so the
                  // ground is quieter in light mode to weigh the same.
                  ink: theme.brightness == Brightness.dark ? 0.34 : 0.24,
                  commits: widget.commits,
                  moving: !MediaQuery.disableAnimationsOf(context),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// One entry on the line: what it is, and when.
@immutable
class TrunkCommit {
  /// Creates an entry.
  const TrunkCommit({required this.subject, required this.meta});

  /// The name of the thing — a space, on Home.
  final String subject;

  /// When it happened, already in words.
  final String meta;

  @override
  bool operator ==(Object other) =>
      other is TrunkCommit && other.subject == subject && other.meta == meta;

  @override
  int get hashCode => Object.hash(subject, meta);
}

/// Carries the anchor down to whoever draws the mark.
class _TrunkScope extends InheritedWidget {
  const _TrunkScope({required this.anchor, required super.child});

  final GlobalKey anchor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey>('anchor', anchor));
  }

  @override
  bool updateShouldNotify(_TrunkScope old) => old.anchor != anchor;
}

/// Paints the trunk, its commits, and one cycle over them.
class _TrunkPainter extends CustomPainter {
  _TrunkPainter({
    required this.clock,
    required this.mark,
    required this.colors,
    required this.ink,
    required this.commits,
    required this.moving,
  }) : super(repaint: Listenable.merge(<Listenable>[clock, mark]));

  final Animation<double> clock;
  final ValueListenable<Rect?> mark;
  final TomColors colors;
  final double ink;
  final List<TrunkCommit> commits;
  final bool moving;

  /// How far the letterform's own weight reaches past the mark before it
  /// thins into the line — long enough to read as the same stroke.
  static const double _stub = 150;

  /// The pulse, head to tail.
  static const double _pulse = 90;

  /// The stretch under the mark the words take up — the expansion, the
  /// tagline and the two ways in. The line is washed out across it.
  static const double _words = 340;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect? box = mark.value;
    if (box == null || box.isEmpty) {
      return;
    }

    final double scale = box.width / TomMark.boxWidth;
    final double ox =
        box.left + (TomMark.commitCentre.dx - TomMark.left) * scale;
    final double oy = box.top + (TomMark.commitCentre.dy - TomMark.top) * scale;
    final double gap = TomMark.commitReach * scale;
    final double weight = TomMark.trunkStroke * scale;
    final Color accent = colors.accent;

    // The line, above and below the letterform's own reach. It fades into the
    // top bar rather than butting against it; below it runs to the edge,
    // because that is where the next commit comes from.
    canvas
      ..drawLine(
        Offset(ox, 0),
        Offset(ox, box.top),
        Paint()
          ..strokeWidth = 1.5
          ..shader = ui.Gradient.linear(
            Offset(ox, 0),
            Offset(ox, box.top),
            <Color>[accent.withValues(alpha: 0), accent.withValues(alpha: ink)],
          ),
      )
      ..drawLine(
        Offset(ox, box.bottom),
        Offset(ox, size.height),
        Paint()
          ..color = accent.withValues(alpha: ink)
          ..strokeWidth = 1.5,
      );

    // The stub: the letter's stroke leaving the word, fading into the line.
    void stub(double from, double to) {
      canvas.drawLine(
        Offset(ox, from),
        Offset(ox, to),
        Paint()
          ..strokeWidth = weight
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(ox, from),
            Offset(ox, to),
            <Color>[accent.withValues(alpha: ink), accent.withValues(alpha: 0)],
          ),
      );
    }

    stub(box.top, box.top - _stub);
    stub(box.bottom, box.bottom + _stub);

    // What came before, down the branch and clear of the words above it.
    // Newest first, so the list reads upward the way a trunk grows.
    final double first = math.max(size.height * 0.74, box.bottom + _words + 60);
    for (final (int i, TrunkCommit entry) in commits.indexed) {
      final double y = first + i * 74;
      if (y > size.height - 24) {
        continue;
      }
      _commit(canvas, Offset(ox, y), 6, accent, 0.85);
      _label(canvas, Offset(ox + 20, y), entry);
    }

    final double t = clock.value;

    // A commit rises from below and lands on the node. Drawn before the wash
    // so it dims behind the words and comes back out at the mark.
    final double rising = _span(t, 0, 0.34);
    if (moving && rising > 0 && rising < 1) {
      _bolt(canvas, ox, _lerp(size.height + _pulse, oy + gap, rising), accent);
    }

    // A wash of the page colour over the stretch the words occupy, so the
    // line passes behind the block instead of through it. A band rather than
    // a glow around the mark: the letterform's own stroke has to stay at full
    // weight where it leaves the word, or the continuation is lost.
    final double washTop = box.bottom + 24;
    canvas.drawRect(
      Rect.fromLTRB(0, washTop, size.width, washTop + _words),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(ox, washTop),
          Offset(ox, washTop + _words),
          <Color>[
            colors.surface.withValues(alpha: 0),
            colors.surface.withValues(alpha: 0.96),
            colors.surface.withValues(alpha: 0.96),
            colors.surface.withValues(alpha: 0),
          ],
          <double>[0, 0.18, 0.8, 1],
        ),
    );

    if (!moving) {
      return;
    }

    // The node answers: a flare, then rings leaving it.
    final double lands = _span(t, 0.32, 0.58);
    if (lands > 0 && lands < 1) {
      canvas.drawCircle(
        Offset(ox, oy),
        gap * 2.4,
        Paint()
          ..color = accent.withValues(alpha: 0.45 * (1 - lands))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, gap * 1.3),
      );
    }
    // Four rings, reaching most of the way across the screen. The commit
    // landing is the loudest thing this screen does, and a ring that dies
    // inside the wordmark is a detail nobody sees.
    for (int i = 0; i < 4; i++) {
      final double ring = _span(t, 0.34 + i * 0.06, 0.94 + i * 0.06);
      if (ring <= 0 || ring >= 1) {
        continue;
      }
      // Leaving from just outside the ring the letterform draws, so the first
      // one does not sit on top of it.
      canvas.drawCircle(
        Offset(ox, oy),
        gap * 1.12 + ring * gap * 15,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = accent.withValues(alpha: 0.5 * (1 - ring) * (1 - ring)),
      );
    }

    // And the change carries on upward.
    final double leaving = _span(t, 0.36, 0.72);
    if (leaving > 0 && leaving < 1) {
      _bolt(canvas, ox, _lerp(oy - gap, -_pulse, leaving), accent);
    }
  }

  /// One commit on the line: a ring with the page showing through it.
  void _commit(Canvas canvas, Offset at, double r, Color accent, double alpha) {
    canvas
      ..drawCircle(at, r, Paint()..color = colors.surface)
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = accent.withValues(alpha: alpha),
      )
      ..drawCircle(
        at,
        r + 3,
        Paint()
          ..color = accent.withValues(alpha: alpha * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
  }

  /// What the commit is, beside it: the subject, then when it happened.
  ///
  /// Laid out as one line and centred on the node, the way a log reads.
  void _label(Canvas canvas, Offset at, TrunkCommit entry) {
    final TextPainter text = TextPainter(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: entry.subject,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          TextSpan(
            text: '   ${entry.meta}',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(at.dx, at.dy - text.height / 2));
  }

  /// The travelling commit: a bright head with its tail trailing below, so a
  /// single frame still says which way it is going.
  void _bolt(Canvas canvas, double x, double head, Color accent) {
    canvas
      ..drawLine(
        Offset(x, head),
        Offset(x, head + _pulse),
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(x, head),
            Offset(x, head + _pulse),
            <Color>[accent, accent.withValues(alpha: 0)],
          ),
      )
      ..drawCircle(Offset(x, head), 4.5, Paint()..color = accent)
      ..drawCircle(
        Offset(x, head),
        9,
        Paint()
          ..color = accent.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
  }

  /// Where [t] sits inside one stretch of the cycle, 0 before and 1 after.
  double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0, 1);

  double _lerp(double a, double b, double f) => a + (b - a) * f;

  @override
  bool shouldRepaint(_TrunkPainter old) =>
      old.colors != colors ||
      old.ink != ink ||
      old.moving != moving ||
      !listEquals(old.commits, commits);
}
