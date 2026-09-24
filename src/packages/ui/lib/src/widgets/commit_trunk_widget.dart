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

/// Home's ground: the commit line the wordmark's O sits on.
///
/// The O *is* a commit on a trunk ([TomMark]) and the letterform stops that
/// trunk at its own edge. This carries it to both edges of the screen and
/// runs one cycle over it — a commit rises from below, lands on the node,
/// the node answers with rings that leave the window, and the change carries
/// on upward. History runs the way a trunk grows: older below, newer above.
///
/// The log is *written by that commit on its way up*: a line appears as the
/// ray reaches it and its node answers as it passes, so one climb draws the
/// whole history and the end of the cycle takes it back off ([commits]).
///
/// Lanes come and go beside it — a branch shows up, one commit runs past,
/// and it is gone again somewhere else next time — so the screen reads as a
/// graph. The trunk is the one line that stays and carries the letter's
/// weight.
///
/// **Nothing is assumed about where the mark is.** The wordmark under a
/// trunk carries [anchorOf]'s key, and the geometry is read off what was
/// actually laid out, *in the paint that uses it* — so a different cap
/// height, or a window being resized, moves the ground with it and never a
/// frame later. Without that key it paints nothing, which is how a screen
/// keeps using [TomWordmarkWidget] with no trunk above it.
class CommitTrunkWidget extends StatefulWidget {
  /// Puts the trunk behind [child], carrying [commits] down the line.
  const CommitTrunkWidget({
    required this.child,
    this.commits = TrunkLog.tomsOwn,
    super.key,
  });

  /// The screen this is the ground for.
  final Widget child;

  /// The pool the lines are drawn from, not the three that are up.
  ///
  /// Every turn of the cycle takes the next screenful, so a line is a new
  /// message each time it appears — which is why this is fifty long
  /// ([TrunkLog.tomsOwn]) and not three. The log is the ground's own, not a
  /// reading of anybody's repository: what the user opened is on the card in
  /// front of it, and saying that twice is what makes a screen busy.
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
  static const Duration _cycle = Duration(milliseconds: 13600);

  final GlobalKey _anchor = GlobalKey();

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  /// Which turn of the cycle this is, and where the last one had got to.
  ///
  /// The lanes stand somewhere else on every turn, and a controller that
  /// repeats says nothing about how many times it has: the value going
  /// backwards is the only announcement there is.
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
    super.dispose();
  }

  /// The mark's box in this widget's own coordinates, as laid out.
  ///
  /// Read by the painter during the paint rather than remembered from the
  /// last frame: resizing the window moves the mark without rebuilding
  /// anything here — the only `MediaQuery` this widget depends on is
  /// `disableAnimations` — so a remembered box would leave the line where
  /// the previous width had put it until something else forced a build.
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

/// A slot for a branch beside the trunk: where it may stand, and when.
///
/// A lane writes its own log as its ray goes up, in smaller type and out of
/// focus: near enough to see that work is going on, too far to read.
@immutable
class _Lane {
  const _Lane({
    required this.near,
    required this.far,
    required this.from,
    required this.to,
  });

  /// The stretch it stands in, as a fraction of the trunk's own distance to
  /// that edge — negative to the left, and one slot per side of the mark.
  ///
  /// Proportional rather than a number of pixels: a lane then clears the
  /// wordmark on a wide window and still has room on a narrow one. A slot
  /// keeps its side, so two of them never land on the same line.
  final double near;

  /// The far end of that stretch.
  final double far;

  /// The stretch of the cycle it is alive for, from
  final double from;

  /// to.
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

  /// How far the letterform's own weight reaches past the mark before it
  /// thins into the line — long enough to read as the same stroke.
  static const double _stub = 150;

  /// The pulse, head to tail.
  static const double _pulse = 130;

  /// The stretch under the mark the words take up — the expansion, the
  /// tagline and the two ways in. The line is washed out across it.
  static const double _words = 340;

  /// How wide that wash is: the column the words are set to, and then some
  /// on each side for it to fade out over.
  static const double _clearing = 1240;

  /// The branches beside the trunk — `git log --graph` from across the room.
  ///
  /// Four slots, each with a stretch of the screen it may stand in and a
  /// stretch of the cycle it is alive for: it fades in, one commit runs up
  /// it, and it is gone. Their stretches overlap two or three at a time, so
  /// four is the most that can ever be on screen at once.
  static const List<_Lane> _lanes = <_Lane>[
    _Lane(near: -0.92, far: -0.58, from: 0.02, to: 0.44),
    _Lane(near: -0.54, far: -0.30, from: 0.30, to: 0.76),
    _Lane(near: 0.60, far: 0.74, from: 0.14, to: 0.58),
    _Lane(near: 0.78, far: 0.94, from: 0.56, to: 0.98),
  ];

  /// Mark to the first entry over it, and one entry to the next.
  ///
  /// The gap is short because the room over the mark is: the block sits a
  /// third of the way down, so a taller gap would mean no entry up there at
  /// all on the window the design was drawn for.
  static const double _logGap = 52;
  static const double _logStep = 88;

  /// How many lines the trunk writes, and how many are on screen with the
  /// lanes' as well.
  ///
  /// Three, because the trunk's log is the thing being read and a fourth
  /// line turns a ground into a list. The lanes' two apiece are what make it
  /// a graph rather than a list of three.
  static const int _shown = 3;
  static const int _onScreen = _shown + 8;

  /// How long a written line holds before it starts to go, and how far the
  /// ray travels while it does — both in pixels past it.
  static const double _holds = 240;
  static const double _forgets = 460;

  /// How much of a lane's life is its arriving, and the same again leaving.
  static const double _laneFade = 0.16;

  /// The cycle, in three marks: the commit reaches the node, leaves it, and
  /// is off the top of the window.
  ///
  /// Nearly half of it is the climb, because the climb is what writes the
  /// log — everything after it is the answer.
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

    // The line, above and below the letterform's own reach. It fades into the
    // top bar rather than butting against it; below it runs to the edge,
    // because that is where the next commit comes from.
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

    // The lanes. Drawn before the trunk's log, so its subjects stay readable
    // where one passes behind them — and each only while it is alive.
    for (final (int slot, _Lane lane) in _lanes.indexed) {
      // Still is a design, not a fallback: with nothing moving, every lane
      // stands there at full weight rather than the screen losing its graph.
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
          // Thinner than the trunk, and its nodes and type are smaller too:
          // the only thing saying these branches are further off is how
          // little of them there is to see.
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
      // A lane writes its own log the same way the trunk does, only too far
      // away to read: the text is out of focus, and it is meant to be.
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
          // Far quieter than the trunk's own: a lane is what you see out of
          // the corner of your eye, and only one commit on this screen lands.
          width: 1.4,
          reach: 58,
          dot: 2.2,
          alpha: 0.24,
        );
      }
    }

    // Where the trunk's commit is right now: climbing to the node, held there
    // while it lands, then carrying on off the top. The log is read against
    // it — **a line is written when the ray reaches it**, and fades once the
    // ray is well past, so one climb draws the whole history.
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

    // The log, newest first: the top of it over the mark where the window is
    // tall enough, the rest down the line under the words, so it reads as one
    // history through the whole screen the way a trunk grows.
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
      // The node answers as the ray goes by, the way the O does when it
      // lands: brightest at the moment of passing, then back to the others.
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

    // The commit itself, rising. Drawn before the wash so it dims behind the
    // words and comes back out at the mark, and drawn *at* the head the log
    // is read against, so the two can never disagree.
    if (moving && t < _lands) {
      _bolt(canvas, ox, head, accent);
    }

    // A clearing of the page colour over the stretch the words occupy, so the
    // line passes behind the block instead of through it. An oval and not a
    // band across the window: a band clears the words and cuts every lane in
    // half on its way out. It is not a glow around the mark either — the
    // letterform's own stroke has to stay at full weight where it leaves the
    // word, or the continuation is lost.
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
    // Four rings, each leaving the screen rather than dying inside it: the
    // landing is the loudest thing this screen does, and where it ends is
    // the window's far corner, not a number of pixels. They take the rest of
    // the cycle to get there — a ring that crosses the window in a second is
    // a flash, and this one is meant to be watched.
    final double start = gap * 1.12;
    final double reach = _corner(Offset(ox, oy), size);
    for (int i = 0; i < 4; i++) {
      // Every ring is out of the window before the cycle turns over, and each
      // holds its weight until it nearly is: fading it by the square of the
      // distance put it out at half the reach, which is the wordmark and
      // nothing else — the ring was gone long before the screen had seen it.
      final double ring = _span(t, _lands + i * 0.05, 0.88 + i * 0.04);
      if (ring <= 0 || ring >= 1) {
        continue;
      }
      // Leaving from just outside the ring the letterform draws, so the first
      // one does not sit on top of it.
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

  /// How far along a line is in being written, [px] past the ray's head: how
  /// strongly it shows, and how brightly its node is answering.
  ///
  /// Distance rather than time, so a line appears exactly as the ray reaches
  /// it and dims as the ray leaves it behind — which is what makes one climb
  /// read as the log being written rather than revealed.
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

  /// The line this slot shows on turn [round].
  ///
  /// The pool is walked a screenful at a time, so every appearance is a new
  /// message and no two lines on screen are the same one.
  TrunkCommit _from(int i, int round) =>
      commits[(round * _onScreen + i) % commits.length];

  /// One line of the log beside its node: the sha, then the subject.
  ///
  /// Laid out as one line and centred on the node, the way a log reads, and
  /// cut at [room] rather than run off the window. The figures are tabular
  /// so the hashes line up under each other, which is the only thing a log
  /// asks of its type.
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
    // A lane's log is blurred rather than only faint: out of focus is the
    // one cue that says *further away* instead of *less important*, and a
    // mask filter does it on the glyphs without a layer to composite.
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

  /// How many entries the space over the mark has room for.
  ///
  /// Two at most, and none at all on a window too short to keep them clear
  /// of the top bar — a short screen is then the line it always was.
  int _roomOver(double top) =>
      (((top - _logGap - 26) / _logStep).floor() + 1).clamp(0, 2);

  /// A repeatable number in [0, 1) for [a] on turn [b].
  ///
  /// The same place for as long as a lane is standing there, a new one the
  /// next time that slot comes round; and it is arithmetic, so a repaint
  /// mid-life never moves what is already on screen.
  double _noise(int a, int b) {
    final double s = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
    return s - s.floorToDouble();
  }

  /// The travelling commit: a bright head with its tail trailing below, so a
  /// single frame still says which way it is going.
  ///
  /// The defaults are the trunk's own; a lane passes smaller and dimmer ones.
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

  /// How far the farthest corner of [size] is from [at] — how far a ring has
  /// to grow before the whole window has seen it.
  double _corner(Offset at, Size size) => Offset(
    math.max(at.dx, size.width - at.dx),
    math.max(at.dy, size.height - at.dy),
  ).distance;

  /// Where [t] sits inside one stretch of the cycle, 0 before and 1 after.
  double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0, 1);

  /// The shape of the climb: slow out of the bottom, gathering speed.
  ///
  /// The log is written in the lowest fifth of the window, so an even climb
  /// crosses all three lines in under a second and they light up together.
  /// This spends half the climb down there, a line at a time, and arrives at
  /// the node with the speed the landing wants.
  double _climb(double r) => r * r;

  double _lerp(double a, double b, double f) => a + (b - a) * f;

  @override
  bool shouldRepaint(_TrunkPainter old) =>
      old.colors != colors ||
      old.ink != ink ||
      old.moving != moving ||
      !listEquals(old.commits, commits);
}
