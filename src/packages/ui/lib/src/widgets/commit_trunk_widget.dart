/// The mark's trunk, carried past the letterform and given a heartbeat.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/widgets/commit_trunk_log.dart';
import 'package:tom_ui/src/widgets/tom_wordmark_widget.dart';

/// Home's ground: the wordmark's trunk carried to both edges of the screen,
/// with one cycle over it — a commit climbs writing the log ([commits]),
/// lands on the O, and rings leave the window; lanes come and go beside it
/// ([brand](../../../../../../docs/design/brand/README.md), [TomMark]).
///
/// The geometry is read at paint time off the [TomWordmarkWidget] carrying
/// [anchorOf]'s key, so a resize moves the ground in the same frame; with no
/// key nothing is painted, which is how a screen draws the mark alone.
class CommitTrunkWidget extends StatefulWidget {
  /// Puts the trunk behind [child], carrying [commits] down the line.
  const CommitTrunkWidget({
    required this.child,
    this.commits = TrunkLog.tomsOwn,
    super.key,
  });

  /// The screen this is the ground for.
  final Widget child;

  /// The pool the lines are drawn from — fifty ([TrunkLog.tomsOwn]), not the
  /// three on screen, because every turn of the cycle takes the next
  /// screenful. It is the ground's own, never a reading of the user's
  /// repository, which is already on the card in front of it.
  final List<TrunkCommit> commits;

  /// The key the wordmark under a [CommitTrunkWidget] must carry; null with
  /// no trunk above, when the wordmark is an ordinary one.
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
  /// One cycle: rise, land, answer, carry on. Slower than the website's,
  /// because a fast loop behind a decision is a distraction.
  static const Duration _cycle = Duration(milliseconds: 13600);

  final GlobalKey _anchor = GlobalKey();

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  /// Which turn of the cycle this is, which moves the lanes.
  ///
  /// A repeating controller announces a new turn only by its value going
  /// backwards, so the last value is kept to notice it.
  int _turn = 0;
  double _wasAt = 0;

  @override
  void initState() {
    super.initState();
    _clock.addListener(_count);
  }

  void _count() {
    if (_clock.value < _wasAt) {
      _turn++;
    }
    _wasAt = _clock.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The platform's no-animations setting: the still frame is the design,
    // not a fallback, so it keeps the line and the commits.
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock
        ..stop()
        ..value = 0;
    } else if (!_clock.isAnimating) {
      // The ticker's future completes only on dispose; nothing to await.
      unawaited(_clock.repeat());
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// The mark's box in this widget's own coordinates, read at paint time.
  ///
  /// A resize moves the mark without rebuilding this widget — its only media
  /// query is `disableAnimations` — so a box remembered from the last frame
  /// would leave the line where the previous width put it.
  Rect? _markBox() {
    final RenderObject? mark = _anchor.currentContext?.findRenderObject();
    final RenderObject? self = context.findRenderObject();
    if (mark is! RenderBox ||
        self is! RenderBox ||
        !mark.hasSize ||
        !self.hasSize) {
      return null;
    }
    return mark.localToGlobal(Offset.zero, ancestor: self) & mark.size;
  }

  @override
  Widget build(BuildContext context) {
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
                  markBox: _markBox,
                  turn: () => _turn,
                  colors: TomColors.of(context),
                  // Sage over cream reads stronger than over ink, so light
                  // mode is quieter to weigh the same.
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

/// A slot for a branch beside the trunk: where it may stand, and when.
@immutable
class _Lane {
  const _Lane({
    required this.near,
    required this.far,
    required this.from,
    required this.to,
  });

  /// The near end of the stretch it stands in, as a fraction of the trunk's
  /// distance to that edge, negative to the left.
  ///
  /// Proportional rather than pixels, so a lane clears the wordmark on a
  /// wide window and still fits a narrow one; a slot keeps its side, so two
  /// never share a line.
  final double near;

  /// The far end of that stretch.
  final double far;

  /// Where in the cycle it appears.
  final double from;

  /// Where in the cycle it is gone.
  final double to;
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
    required this.markBox,
    required this.turn,
    required this.colors,
    required this.ink,
    required this.commits,
    required this.moving,
  }) : super(repaint: clock);

  final Animation<double> clock;

  /// Where the mark is *now* — see `_CommitTrunkWidgetState._markBox`.
  final ValueGetter<Rect?> markBox;

  /// Which turn of the cycle this is, which is what moves the lanes.
  final ValueGetter<int> turn;
  final TomColors colors;
  final double ink;
  final List<TrunkCommit> commits;
  final bool moving;

  /// How far the letterform's weight reaches past the mark before it thins
  /// into the line — long enough to read as the same stroke.
  static const double _stub = 150;

  /// The pulse, head to tail.
  static const double _pulse = 130;

  /// The stretch under the mark the words take up; the line is washed out
  /// across it.
  static const double _words = 340;

  /// How wide that wash is: the words' column plus room to fade on each side.
  static const double _clearing = 1240;

  /// The branches beside the trunk: four slots, each with where it may stand
  /// and when it is alive, overlapping two or three at a time.
  static const List<_Lane> _lanes = <_Lane>[
    _Lane(near: -0.92, far: -0.58, from: 0.02, to: 0.44),
    _Lane(near: -0.54, far: -0.30, from: 0.30, to: 0.76),
    _Lane(near: 0.60, far: 0.74, from: 0.14, to: 0.58),
    _Lane(near: 0.78, far: 0.94, from: 0.56, to: 0.98),
  ];

  /// Mark to the first entry over it, and entry to entry — short, because
  /// the room over the mark is.
  static const double _logGap = 52;
  static const double _logStep = 88;

  /// Lines on the trunk, and on screen with the lanes' two apiece. Three,
  /// because a fourth turns a ground into a list.
  static const int _shown = 3;
  static const int _onScreen = _shown + 8;

  /// How far past a written line the ray goes before it starts to fade, and
  /// how far again until it is gone.
  static const double _holds = 240;
  static const double _forgets = 460;

  /// How much of a lane's life is its arriving, and the same again leaving.
  static const double _laneFade = 0.16;

  /// The cycle's three marks: the commit reaches the node, leaves it, is off
  /// the top. Nearly half is the climb, because the climb writes the log.
  static const double _lands = 0.46;
  static const double _leaves = 0.48;
  static const double _gone = 0.80;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect? box = markBox();
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

    // Above the mark the line fades into the top bar; below, it runs to the
    // edge the next commit comes from.
    canvas
      ..drawLine(
        Offset(ox, 0),
        Offset(ox, box.top),
        Paint()
          ..strokeWidth = 2.2
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
          ..strokeWidth = 2.2,
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

    final double t = clock.value;
    final int round = turn();

    // Lanes go before the trunk's log, so its subjects stay readable where
    // one passes behind them.
    for (final (int slot, _Lane lane) in _lanes.indexed) {
      // Still is a design, not a fallback: every lane stands at full weight.
      final double life = moving ? _span(t, lane.from, lane.to) : 0.5;
      if (life <= 0 || life >= 1) {
        continue;
      }
      final double fade = math
          .min(life / _laneFade, (1 - life) / _laneFade)
          .clamp(0.0, 1.0);
      final double at = _lerp(lane.near, lane.far, _noise(slot, round));
      final double lx = ox + at * (at < 0 ? ox : size.width - ox);
      canvas.drawLine(
        Offset(lx, 0),
        Offset(lx, size.height),
        Paint()
          // Thinner, with smaller nodes and type: distance is said only by
          // how little there is to see.
          ..strokeWidth = 1
          ..shader = ui.Gradient.linear(
            Offset(lx, 0),
            Offset(lx, size.height),
            <Color>[
              accent.withValues(alpha: 0),
              accent.withValues(alpha: ink * 0.46 * fade),
              accent.withValues(alpha: ink * 0.46 * fade),
            ],
            <double>[0, 0.16, 1],
          ),
      );

      final double ray = _span(life, _laneFade, 1 - _laneFade);
      final double laneHead = moving
          ? _lerp(size.height + _pulse, -_pulse, ray)
          : -_pulse;
      // A lane's log is written the trunk's way, out of focus on purpose.
      final bool behind = lx > ox;
      final double room = math.min(
        170,
        behind ? lx - 30 : size.width - lx - 30,
      );
      for (int n = 0; n < 2; n++) {
        final double where = _noise(slot * 9 + n + 1, round);
        final double y = size.height * (0.14 + where * 0.72);
        final (double told, double lit) = _written(y - laneHead);
        if (told <= 0) {
          continue;
        }
        _commit(canvas, Offset(lx, y), 3.2, accent, (0.5 * told + lit) * fade);
        _label(
          canvas,
          Offset(behind ? lx - 12 : lx + 12, y),
          _from(slot * 2 + n + _shown, round),
          0.5 * told * fade,
          room: room,
          type: 9.5,
          blur: 0.9,
          toLeft: behind,
        );
      }

      if (moving && ray > 0 && ray < 1) {
        _bolt(
          canvas,
          lx,
          laneHead,
          accent,
          // Quieter than the trunk's: only one commit on this screen lands.
          width: 1.4,
          reach: 58,
          dot: 2.2,
          alpha: 0.24,
        );
      }
    }

    // Where the trunk's commit is now. The log is read against it: a line is
    // written when the ray reaches it, so one climb draws the whole history.
    final double head = !moving
        ? -_pulse
        : switch (t) {
            < _lands => _lerp(
              size.height + _pulse,
              oy + gap,
              _climb(_span(t, 0, _lands)),
            ),
            < _leaves => oy,
            _ => _lerp(oy - gap, -_pulse, _span(t, _leaves, _gone)),
          };

    // The log, newest first: over the mark where the window is tall enough,
    // the rest under the words, so it reads as one history down the screen.
    final double under = math.max(
      size.height * 0.715,
      box.bottom + _words + 60,
    );
    final int shown = math.min(_shown, commits.length);
    final int over = math.min(shown, _roomOver(box.top));
    final double clears = 1 - _span(t, 0.88, 0.99);

    for (int i = 0; i < shown; i++) {
      final double y = i < over
          ? box.top - _logGap - (over - 1 - i) * _logStep
          : under + (i - over) * _logStep;
      if (y > size.height - 24) {
        continue;
      }
      final (double written, double lit) = _written(y - head);
      final double told = written * clears;
      if (told <= 0) {
        continue;
      }
      // The node answers as the ray goes by, brightest at the passing.
      if (lit > 0) {
        canvas.drawCircle(
          Offset(ox, y),
          10 + lit * 8,
          Paint()
            ..color = accent.withValues(alpha: 0.55 * lit * clears)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 9 + lit * 9),
        );
      }
      _commit(
        canvas,
        Offset(ox, y),
        7 + lit * 1.5,
        accent,
        (0.85 * told + lit * clears).clamp(0.0, 1.0),
      );
      _label(
        canvas,
        Offset(ox + 22, y),
        _from(i, round),
        told,
        room: size.width - ox - 46,
      );
    }

    // The commit rising: before the wash, so it dims behind the words, and at
    // the head the log is read against, so the two never disagree.
    if (moving && t < _lands) {
      _bolt(canvas, ox, head, accent);
    }

    // A clearing of the page colour behind the words. An oval, because a
    // band would cut every lane in half; not a glow around the mark, because
    // the letterform's stroke must stay at full weight where it leaves the
    // word or the continuation is lost.
    final Offset heart = Offset(ox, box.bottom + 24 + _words / 2);
    const double squash = _words / _clearing;
    canvas
      ..save()
      ..translate(heart.dx, heart.dy)
      ..scale(1, squash)
      ..translate(-heart.dx, -heart.dy)
      ..drawCircle(
        heart,
        _clearing / 2,
        Paint()
          ..shader = ui.Gradient.radial(
            heart,
            _clearing / 2,
            <Color>[
              colors.surface.withValues(alpha: 0.96),
              colors.surface.withValues(alpha: 0.96),
              colors.surface.withValues(alpha: 0),
            ],
            <double>[0, 0.55, 1],
          ),
      )
      ..restore();

    if (!moving) {
      return;
    }

    // The node answers: a flare, then rings leaving it.
    final double lands = _span(t, _lands - 0.02, _lands + 0.24);
    if (lands > 0 && lands < 1) {
      canvas.drawCircle(
        Offset(ox, oy),
        gap * 2.4,
        Paint()
          ..color = accent.withValues(alpha: 0.45 * (1 - lands))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, gap * 1.3),
      );
    }
    // Four rings, each leaving by the window's far corner over the rest of
    // the cycle: a ring that crosses the window in a second is a flash.
    final double start = gap * 1.12;
    final double reach = _corner(Offset(ox, oy), size);
    for (int i = 0; i < 4; i++) {
      // Weight held until the ring is nearly out: fading by the square of
      // the distance put it out at the wordmark, before the screen saw it.
      final double ring = _span(t, _lands + i * 0.05, 0.88 + i * 0.04);
      if (ring <= 0 || ring >= 1) {
        continue;
      }
      // From just outside the letterform's own ring, not on top of it.
      canvas.drawCircle(
        Offset(ox, oy),
        start + ring * (reach - start),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8
          ..color = accent.withValues(alpha: 0.26 * (1 - _span(ring, 0.74, 1))),
      );
    }

    // And the change carries on upward.
    if (t > _leaves && t < _gone) {
      _bolt(canvas, ox, head, accent);
    }
  }

  /// One commit on the line: a ring with the page showing through it.
  void _commit(Canvas canvas, Offset at, double r, Color accent, double alpha) {
    final double a = alpha.clamp(0.0, 1.0);
    canvas
      ..drawCircle(at, r, Paint()..color = colors.surface)
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r < 5 ? 1.6 : 2.2
          ..color = accent.withValues(alpha: a),
      )
      ..drawCircle(
        at,
        r + 3,
        Paint()
          ..color = accent.withValues(alpha: a * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
  }

  /// How far a line [px] past the ray's head is written, and how brightly
  /// its node is answering.
  ///
  /// Distance rather than time, so a line appears exactly as the ray reaches
  /// it — written, not revealed.
  (double, double) _written(double px) {
    if (!moving) {
      return (1, 0);
    }
    final double reached = (px / 46).clamp(0.0, 1.0);
    return (
      reached * (1 - ((px - _holds) / _forgets).clamp(0.0, 1.0)),
      reached * (1 - (px / 170).clamp(0.0, 1.0)),
    );
  }

  /// The line slot [i] shows on turn [round], walking the pool a screenful
  /// at a time so no two lines on screen are the same one.
  TrunkCommit _from(int i, int round) =>
      commits[(round * _onScreen + i) % commits.length];

  /// One line of the log beside its node — the sha, then the subject — cut
  /// at [room]. Tabular figures, so the hashes line up under each other.
  void _label(
    Canvas canvas,
    Offset at,
    TrunkCommit entry,
    double alpha, {
    required double room,
    double type = 12.5,
    double blur = 0,
    bool toLeft = false,
  }) {
    if (room < 30 || alpha <= 0) {
      return;
    }
    // Blurred rather than only faint: out of focus says *further away*
    // where faint alone says *less important*.
    final MaskFilter? haze = blur > 0
        ? MaskFilter.blur(BlurStyle.normal, blur)
        : null;
    Paint pen(Color of, double a) => Paint()
      ..color = of.withValues(alpha: (a * alpha).clamp(0.0, 1.0))
      ..maskFilter = haze;

    final TextPainter text = TextPainter(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: entry.sha,
            style: TextStyle(
              fontSize: type,
              height: 1.4,
              letterSpacing: 0.4,
              fontFeatures: const <ui.FontFeature>[
                ui.FontFeature.tabularFigures(),
              ],
              foreground: pen(colors.accent, 0.75),
            ),
          ),
          TextSpan(
            text: '  ${entry.subject}',
            style: TextStyle(
              fontSize: type,
              height: 1.4,
              foreground: pen(colors.textMuted, 1),
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: room);
    text.paint(
      canvas,
      Offset(toLeft ? at.dx - text.width : at.dx, at.dy - text.height / 2),
    );
  }

  /// How many entries fit over the mark: two at most, none on a window too
  /// short to keep them clear of the top bar.
  int _roomOver(double top) =>
      (((top - _logGap - 26) / _logStep).floor() + 1).clamp(0, 2);

  /// A repeatable number in [0, 1) for [a] on turn [b] — arithmetic, so a
  /// repaint mid-life never moves what is already on screen.
  double _noise(int a, int b) {
    final double s = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
    return s - s.floorToDouble();
  }

  /// The travelling commit: a bright head with its tail below, so a single
  /// frame says which way it is going. The defaults are the trunk's own.
  void _bolt(
    Canvas canvas,
    double x,
    double head,
    Color accent, {
    double width = 6,
    double reach = _pulse,
    double dot = 6.5,
    double alpha = 0.52,
  }) {
    canvas
      ..drawLine(
        Offset(x, head),
        Offset(x, head + reach),
        Paint()
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(x, head),
            Offset(x, head + reach),
            <Color>[
              accent.withValues(alpha: alpha),
              accent.withValues(alpha: 0),
            ],
          ),
      )
      ..drawCircle(
        Offset(x, head),
        dot,
        Paint()..color = accent.withValues(alpha: alpha),
      )
      ..drawCircle(
        Offset(x, head),
        dot * 2,
        Paint()
          ..color = accent.withValues(alpha: 0.45 * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dot * 2.2),
      );
  }

  /// The distance from [at] to the farthest corner of [size].
  double _corner(Offset at, Size size) => Offset(
    math.max(at.dx, size.width - at.dx),
    math.max(at.dy, size.height - at.dy),
  ).distance;

  /// Where [t] sits inside one stretch of the cycle, 0 before and 1 after.
  double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0, 1);

  /// The shape of the climb: slow out of the bottom, where the log is
  /// written, so the lines light one at a time rather than together.
  double _climb(double r) => r * r;

  double _lerp(double a, double b, double f) => a + (b - a) * f;

  @override
  bool shouldRepaint(_TrunkPainter old) =>
      old.colors != colors ||
      old.ink != ink ||
      old.moving != moving ||
      !listEquals(old.commits, commits);
}
