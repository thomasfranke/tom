/// One commit the pull request carries.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// A node, the commit's subject, and how long ago it was written.
class PullRequestCommitWidget extends StatelessWidget {
  /// Creates the row for [commit].
  const PullRequestCommitWidget({required this.commit, super.key});

  /// The commit.
  final CommitEntity commit;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CommitEntity>('commit', commit));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: PullRequestDesign.commitPitch,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            width: PullRequestDesign.node,
            height: PullRequestDesign.node,
            child: CustomPaint(painter: _NodePainter(colors.textMuted)),
          ),
          Positioned(
            left: PullRequestDesign.commitText,
            right: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  commit.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: PullRequestDesign.subject,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  whenInWords(context.l10n, commit.date),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: PullRequestDesign.small,
                    height: 1.4,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A commit as the boards draw it: a ring on a line.
class _NodePainter extends CustomPainter {
  const _NodePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Offset centre = size.center(Offset.zero);
    const double ring = 3;
    canvas
      ..drawLine(
        Offset(0, centre.dy),
        Offset(centre.dx - ring, centre.dy),
        stroke,
      )
      ..drawCircle(centre, ring, stroke)
      ..drawLine(
        Offset(centre.dx + ring, centre.dy),
        Offset(size.width, centre.dy),
        stroke,
      );
  }

  @override
  bool shouldRepaint(_NodePainter old) => old.color != color;
}
