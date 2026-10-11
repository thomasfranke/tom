/// The document, scrolling as one column of blocks.
library;

import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_conflict_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_diff_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_footnotes_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The document, scrolling as one column of blocks, one [PreviewBlockWidget]
/// each
/// ([runtime](../../../../../../../docs/technical/runtime/preview.md)).
class PreviewDocumentWidget extends StatefulWidget {
  /// Creates the column for [document].
  const PreviewDocumentWidget({
    required this.document,
    required this.isReading,
    this.diff,
    this.segments,
    this.anchor,
    this.onAnchor,
    this.onChoose,
    this.reveals = 0,
    this.revealLine = 0,
    this.link,
    super.key,
  });

  /// The link to the source pane beside this one, or null when this pane has
  /// the area to itself — scrolling either then moves the other.
  final DocumentScrollLink? link;

  /// How many times a place of the document was asked for — a click on a
  /// search occurrence while only the preview is on screen; a new count is a
  /// new request, even for the same place.
  final int reveals;

  /// The zero-based source line the request is for.
  final int revealLine;

  /// What to render.
  final ParsedDocumentValueObject document;

  /// What changed against `HEAD`, when that is known and anything did.
  ///
  /// The column is then the diff's sequence, not the document's, because a
  /// removed block has to be drawn where it used to be.
  final DocumentDiffValueObject? diff;

  /// Whether the preview has the document area to itself, which is the mode
  /// the wider measure and the larger prose belong to.
  final bool isReading;

  /// The document cut at its conflicts, when it holds any.
  ///
  /// Non-null takes over from [document] and from [diff] both: while a
  /// marker is on screen the preview shows the conflict and nothing else.
  final List<PreviewSegment>? segments;

  /// A followed link's `#anchor` waiting to be drawn, or null.
  final PreviewAnchor? anchor;

  /// Takes the waiting anchor, answering the heading of [document] it names.
  final BlockValueObject? Function()? onAnchor;

  /// What to do when a side is chosen.
  final void Function(ConflictRegionValueObject, ConflictChoiceEnum)? onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ParsedDocumentValueObject>('document', document),
      )
      ..add(DiagnosticsProperty<bool>('isReading', isReading))
      ..add(DiagnosticsProperty<DocumentDiffValueObject?>('diff', diff))
      ..add(IntProperty('segments', segments?.length))
      ..add(DiagnosticsProperty<PreviewAnchor?>('anchor', anchor))
      ..add(IntProperty('reveals', reveals))
      ..add(IntProperty('revealLine', revealLine))
      ..add(DiagnosticsProperty<DocumentScrollLink?>('link', link))
      ..add(
        ObjectFlagProperty<BlockValueObject? Function()?>.has(
          'onAnchor',
          onAnchor,
        ),
      )
      ..add(
        ObjectFlagProperty<
          void Function(ConflictRegionValueObject, ConflictChoiceEnum)?
        >.has('onChoose', onChoose),
      );
  }

  @override
  State<PreviewDocumentWidget> createState() => _PreviewDocumentWidgetState();
}

class _PreviewDocumentWidgetState extends State<PreviewDocumentWidget> {
  final ScrollController _scroll = ScrollController();

  /// The row a heading is being sought at, and the key it wears meanwhile.
  int? _sought;
  final GlobalKey _soughtKey = GlobalKey();

  /// How many jumps a seek may take before it gives up: a page each, so a
  /// document longer than this many screens stays where the last jump left.
  static const int _maxJumps = 200;

  ParsedDocumentValueObject get _document => widget.document;
  DocumentDiffValueObject? get _diff => widget.diff;
  List<PreviewSegment>? get _segments => widget.segments;
  double get _body =>
      widget.isReading ? PreviewDesign.readingBody : PreviewDesign.body;

  // The link to the source pane. The pane is told to go somewhere (`_target`)
  // and settles over a few frames, because a far row is not built until the
  // list has been taken near it; every scroll it makes meanwhile is its own
  // and is not reported (`_following`).

  static const ScrollMapService _map = ScrollMapService();

  /// How many frames a far target may take to be built and reached.
  static const int _maxSettles = 10;

  late final ScrollPane _pane = (read: _readLine, follow: _followLine);

  /// The row widgets that exist now, by row, so a row can be measured.
  final Map<int, BuildContext> _probes = <int, BuildContext>{};

  /// The line this pane was asked to show, until it has been reached.
  double? _target;

  /// Whether a scroll in progress is this pane's own, not the reader's.
  bool _following = false;

  bool _publishQueued = false;

  /// For each row, the index of the block of [_document] it draws, or null
  /// for a row that is no block's — a removed block's, the footnotes' — and
  /// null as a whole while a conflict is on screen, which has no lines to
  /// follow.
  List<int?>? get _rowBlocks {
    if (_segments != null) {
      return null;
    }
    final DocumentDiffValueObject? changes = _changes;
    if (changes == null) {
      return <int?>[for (int i = 0; i < _document.blocks.length; i++) i];
    }
    // The drawn blocks come in the document's order, so each is looked for
    // after the last one found: two equal paragraphs are two rows.
    final List<int?> rows = <int?>[];
    int cursor = 0;
    for (final DiffBlockValueObject it in changes.blocks) {
      final int found = it is DiffBlockRemoved
          ? -1
          : _document.blocks.indexOf(it.drawn, cursor);
      if (found >= 0) {
        cursor = found + 1;
      }
      rows.add(found >= 0 ? found : null);
    }
    return rows;
  }

  /// The pixels at which [probe]'s row begins, and its height.
  ({double top, double height})? _measure(BuildContext probe) {
    if (!probe.mounted) {
      return null;
    }
    final RenderObject? box = probe.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return null;
    }
    return (
      top: RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset,
      height: box.size.height,
    );
  }

  /// The source line at the top of the pane, fractional; null while nothing
  /// is laid out, or a conflict is on screen.
  double? _readLine() {
    final List<int?>? blocks = _rowBlocks;
    if (blocks == null || !_scroll.hasClients) {
      return null;
    }
    final double pixels = _scroll.offset;
    int? at;
    double atTop = double.negativeInfinity;
    double atHeight = 1;
    int? first;
    double firstTop = double.infinity;
    for (final MapEntry<int, BuildContext> probe in _probes.entries) {
      if (probe.key >= blocks.length || blocks[probe.key] == null) {
        continue;
      }
      final ({double height, double top})? row = _measure(probe.value);
      if (row == null) {
        continue;
      }
      if (row.top <= pixels + 0.5 && row.top > atTop) {
        at = probe.key;
        atTop = row.top;
        atHeight = row.height;
      }
      if (row.top < firstTop) {
        first = probe.key;
        firstTop = row.top;
      }
    }
    // Above the first row built (the top padding): that row's top.
    final int? row = at ?? first;
    if (row == null) {
      return null;
    }
    final double fraction = at == null
        ? 0
        : ((pixels - atTop) / (atHeight <= 0 ? 1 : atHeight)).clamp(0.0, 1.0);
    return _map.lineAt(_document.blocks, blocks[row]!, fraction);
  }

  /// Takes the pane to [line], over as many frames as the list needs.
  void _followLine(double line) {
    if (_segments != null) {
      return;
    }
    _target = line;
    _following = true;
    _settle(0);
  }

  void _settle(int attempt) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double? line = _target;
      if (!mounted || line == null) {
        _following = false;
        return;
      }
      if (!_scroll.hasClients) {
        // Not attached yet: the first frame of a pane that has just opened.
        if (attempt < _maxSettles) {
          _settle(attempt + 1);
        } else {
          _following = false;
        }
        return;
      }
      final ScrollPosition position = _scroll.position;
      final double? exact = _pixelsOf(line);
      if (exact != null) {
        final double clamped = exact.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        // Where it is already, or as near as the document's ends allow.
        if ((clamped - position.pixels).abs() < 0.5 || attempt >= _maxSettles) {
          _target = null;
          _following = false;
          return;
        }
        // Rows that were not built are estimated until they are, so what was
        // at that offset a frame ago may not be now: jump, then look again.
        position.jumpTo(clamped);
        _settle(attempt + 1);
        return;
      }
      if (attempt >= _maxSettles) {
        _target = null;
        _following = false;
        return;
      }
      // Not built: a step towards it, by the rows still to go at the height
      // of the ones built, which builds more of the way; the next frame
      // measures again, and each step is nearer than the last.
      final List<int?>? blocks = _rowBlocks;
      final ({int block, double fraction})? place = _map.blockAt(
        _document.blocks,
        line,
      );
      if (blocks != null && place != null && blocks.isNotEmpty) {
        final int row = blocks.indexOf(place.block);
        int near = blocks.length;
        double heights = 0;
        int counted = 0;
        for (final MapEntry<int, BuildContext> it in _probes.entries) {
          if (_measure(it.value) case final ({double height, double top}) m) {
            near = math.min(near, it.key);
            heights += m.height;
            counted++;
          }
        }
        final double next;
        if (row < 0) {
          next = 0;
        } else if (counted == 0) {
          next = row / blocks.length * position.maxScrollExtent;
        } else {
          next = position.pixels + (row - near) * heights / counted;
        }
        position.jumpTo(
          next.clamp(position.minScrollExtent, position.maxScrollExtent),
        );
      }
      _settle(attempt + 1);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Where [line] is, in pixels, when its row is built.
  double? _pixelsOf(double line) {
    final List<int?>? blocks = _rowBlocks;
    final ({int block, double fraction})? place = _map.blockAt(
      _document.blocks,
      line,
    );
    if (blocks == null || place == null) {
      return null;
    }
    final int row = blocks.indexOf(place.block);
    final BuildContext? probe = row < 0 ? null : _probes[row];
    final ({double height, double top})? measured = probe == null
        ? null
        : _measure(probe);
    return measured == null
        ? null
        : measured.top + place.fraction * measured.height;
  }

  /// The reader scrolled: tell the source once the frame has laid out the
  /// rows they scrolled to.
  void _scrolled() {
    if (_following || _publishQueued) {
      return;
    }
    _publishQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _publishQueued = false;
      if (!mounted || _following) {
        return;
      }
      if (_readLine() case final double line) {
        widget.link?.previewMoved(line);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scrolled);
    widget.link?.attachPreview(_pane);
    _awaitAnchor();
  }

  @override
  void didUpdateWidget(PreviewDocumentWidget old) {
    super.didUpdateWidget(old);
    if (widget.link != old.link) {
      old.link?.detachPreview(_pane);
      widget.link?.attachPreview(_pane);
    }
    if (widget.anchor != old.anchor || widget.document != old.document) {
      _awaitAnchor();
    }
    if (widget.reveals != old.reveals && widget.reveals > 0) {
      _reveal();
    }
  }

  /// The row marked as the one a click on an occurrence asked for.
  int? _marked;

  /// Scrolls to the block that holds the requested line and marks it.
  void _reveal() {
    // Only when the preview is what is on screen: beside the source it is the
    // source that goes there.
    if (!widget.isReading) {
      return;
    }
    final int index = _document.blocks.indexWhere(
      (BlockValueObject it) =>
          it.startLine <= widget.revealLine && widget.revealLine <= it.endLine,
    );
    final int? row = index < 0 ? null : _rowOf(_document.blocks[index]);
    if (row == null) {
      return;
    }
    setState(() {
      _sought = row;
      _marked = row;
    });
    _seek(0);
  }

  @override
  void dispose() {
    widget.link?.detachPreview(_pane);
    _scroll.dispose();
    super.dispose();
  }

  /// Hands a waiting anchor its heading once this frame is laid out, since
  /// taking it writes a provider and a build may not.
  void _awaitAnchor() {
    if (widget.anchor == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final BlockValueObject? heading = widget.onAnchor?.call();
      final int? row = heading == null ? null : _rowOf(heading);
      if (row != null) {
        setState(() => _sought = row);
        _seek(0);
      }
    });
  }

  /// Where [heading] is drawn among the rows; null while a conflict is on
  /// screen, which is the conflict's to show and not a heading's.
  int? _rowOf(BlockValueObject heading) {
    if (_segments != null) {
      return null;
    }
    final DocumentDiffValueObject? changes = _changes;
    final int row = changes == null
        ? _document.blocks.indexOf(heading)
        : changes.blocks.indexWhere(
            (DiffBlockValueObject it) =>
                it is! DiffBlockRemoved && it.drawn == heading,
          );
    return row < 0 ? null : row;
  }

  /// Brings the sought row to the top of the pane.
  ///
  /// The list builds only what is near the screen, so a far row has no
  /// context to scroll to: the pane walks down from the top a page and its
  /// cache at a time — never past a row — until the row is built.
  void _seek(int jumps) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sought == null || !_scroll.hasClients) {
        return;
      }
      if (_soughtKey.currentContext case final BuildContext row) {
        unawaited(Scrollable.ensureVisible(row));
        return;
      }
      final ScrollPosition position = _scroll.position;
      if (jumps == 0) {
        position.jumpTo(0);
      } else if (position.pixels >= position.maxScrollExtent ||
          jumps > _maxJumps) {
        return;
      } else {
        position.jumpTo(
          math.min(
            position.pixels +
                position.viewportDimension +
                RenderAbstractViewport.defaultCacheExtent * 2,
            position.maxScrollExtent,
          ),
        );
      }
      _seek(jumps + 1);
    });
    // A jump to where the pane already is lays nothing out, and a callback
    // after a frame nobody asked for would wait for ever.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// What changed, or null when nothing did: a document that matches `HEAD`
  /// is drawn undecorated
  /// (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
  DocumentDiffValueObject? get _changes =>
      (_diff?.isUnchanged ?? true) ? null : _diff;

  /// One row per block outside a conflict, and one per conflict.
  ///
  /// Flattened here rather than nested, so the whole document stays a single
  /// scrolling column however many conflicts it holds.
  List<Widget> _rows(double body) {
    final List<Widget> rows = <Widget>[];
    for (final PreviewSegment part in _segments!) {
      switch (part) {
        case PreviewProse(document: final ParsedDocumentValueObject prose):
          for (final BlockValueObject block in prose.blocks) {
            rows.add(
              PreviewBlockWidget(block: block, document: prose, body: body),
            );
          }
        case PreviewConflict(region: final ConflictRegionValueObject region):
          rows.add(
            PreviewConflictWidget(
              region: region,
              body: body,
              onChoose: (ConflictChoiceEnum choice) =>
                  widget.onChoose?.call(region, choice),
            ),
          );
      }
    }
    return rows;
  }

  /// How many rows the blocks themselves take.
  int _rowCount(List<Widget>? rows, DocumentDiffValueObject? changes) =>
      rows?.length ?? changes?.blocks.length ?? _document.blocks.length;

  @override
  Widget build(BuildContext context) {
    if (_document.blocks.isEmpty &&
        (_diff?.blocks.isEmpty ?? true) &&
        (_segments?.isEmpty ?? true)) {
      return PreviewNoteWidget(context.l10n.previewDocumentEmpty);
    }
    final DocumentDiffValueObject? changes = _changes;
    final double measure = widget.isReading
        ? PreviewDesign.readingMeasure
        : PreviewDesign.measure;
    final List<Widget>? rows = _segments == null ? null : _rows(_body);
    // Not while a marker is on screen: the conflict is what the preview is
    // showing, and a foot assembled from a half-merged document would be
    // assembled from two.
    final bool hasFootnotes =
        _segments == null && _document.footnotes.isNotEmpty;
    // A measure, not a pane: the column keeps its line length and the pane
    // grows around it, the diff's gutter included.
    final double width =
        measure +
        (changes == null && _segments == null ? 0 : PreviewDesign.diffInset);
    // The list spans the pane and the column is placed by its padding, so
    // the scrollbar runs down the pane's own edge rather than the column's.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double room = math.max(
          0,
          constraints.maxWidth - TomMetrics.pad * 2 - width,
        );
        // Centred when the pane is the document's, left when it is shared: a
        // column hugging the divider reads as a leftover.
        final double left = widget.isReading ? room / 2 : 0;
        return _list(
          EdgeInsets.fromLTRB(
            TomMetrics.pad + left,
            0,
            TomMetrics.pad + room - left,
            TomMetrics.pad,
          ),
          rows,
          changes,
          hasFootnotes: hasFootnotes,
        );
      },
    );
  }

  /// The blocks, one row each, inside [padding].
  Widget _list(
    EdgeInsets padding,
    List<Widget>? rows,
    DocumentDiffValueObject? changes, {
    required bool hasFootnotes,
  }) => ListView.separated(
    // Another document is read from its top, never from where the last one
    // was left.
    key: ValueKey<SpaceRelativePathValueObject>(_document.document.path),
    controller: _scroll,
    padding: padding,
    // One more row than there are blocks when the document has notes:
    // the foot is assembled from what was written all over it, so it
    // belongs to the document rather than to any block.
    itemCount: _rowCount(rows, changes) + (hasFootnotes ? 1 : 0),
    separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: PreviewDesign.blockGap),
    itemBuilder: (BuildContext context, int index) {
      final Widget row = _RowProbeWidget(
        index: index,
        probes: _probes,
        child: _row(index, rows, changes, hasFootnotes: hasFootnotes),
      );
      // The block a click on an occurrence went to wears the accent's soft
      // fill, so the eye finds it after the jump.
      final Widget marked = index == _marked
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: TomColors.of(context).accentSoft,
                borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
              ),
              child: row,
            )
          : row;
      return index == _sought
          ? KeyedSubtree(key: _soughtKey, child: marked)
          : marked;
    },
  );

  /// The row at [index]: a block, a conflict, or the foot.
  Widget _row(
    int index,
    List<Widget>? rows,
    DocumentDiffValueObject? changes, {
    required bool hasFootnotes,
  }) => hasFootnotes && index == _rowCount(rows, changes)
      ? PreviewFootnotesWidget(footnotes: _document.footnotes, body: _body)
      : rows != null
      ? rows[index]
      : changes == null
      ? PreviewBlockWidget(
          block: _document.blocks[index],
          document: _document,
          body: _body,
        )
      : PreviewDiffWidget(
          block: changes.blocks[index],
          diff: changes,
          body: _body,
        );
}

/// Lets the list measure one of its rows: registers itself while it is built.
class _RowProbeWidget extends StatefulWidget {
  const _RowProbeWidget({
    required this.index,
    required this.probes,
    required this.child,
  });

  final int index;
  final Map<int, BuildContext> probes;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('index', index))
      ..add(IntProperty('probes', probes.length));
  }

  @override
  State<_RowProbeWidget> createState() => _RowProbeWidgetState();
}

class _RowProbeWidgetState extends State<_RowProbeWidget> {
  @override
  void initState() {
    super.initState();
    widget.probes[widget.index] = context;
  }

  @override
  void didUpdateWidget(_RowProbeWidget old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      old.probes.remove(old.index);
    }
    widget.probes[widget.index] = context;
  }

  @override
  void dispose() {
    if (widget.probes[widget.index] == context) {
      widget.probes.remove(widget.index);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
