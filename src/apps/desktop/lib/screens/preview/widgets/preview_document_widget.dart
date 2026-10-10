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
    super.key,
  });

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

  @override
  void initState() {
    super.initState();
    _awaitAnchor();
  }

  @override
  void didUpdateWidget(PreviewDocumentWidget old) {
    super.didUpdateWidget(old);
    if (widget.anchor != old.anchor || widget.document != old.document) {
      _awaitAnchor();
    }
  }

  @override
  void dispose() {
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
    itemBuilder: (BuildContext context, int index) => index == _sought
        ? KeyedSubtree(
            key: _soughtKey,
            child: _row(index, rows, changes, hasFootnotes: hasFootnotes),
          )
        : _row(index, rows, changes, hasFootnotes: hasFootnotes),
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
