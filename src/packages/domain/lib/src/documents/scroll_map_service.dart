/// Where a place in the source is in the rendering, and back.
library;

import 'package:tom_domain/src/documents/block_value_object.dart';

/// A source line and a block of the preview, mapped to each other.
///
/// The two panes of `Split` have different heights for the same text, so they
/// are kept in step by *place*: a block, and how far into it. A block is a
/// span of lines, which is what makes the map exact at its ends and
/// proportional between them. A line is fractional — `12.4` is two fifths of
/// the way down line 12.
final class ScrollMapService {
  /// Creates the service.
  const ScrollMapService();

  /// The block that holds [line], and how far down it [line] is (0 to 1).
  ///
  /// A blank line between blocks is the top of the next one, so a pane
  /// scrolled through a gap does not hold the rendering back; before the
  /// first block is its top and after the last its foot. Null when the
  /// document has no blocks.
  ({int block, double fraction})? blockAt(
    List<BlockValueObject> blocks,
    double line,
  ) {
    if (blocks.isEmpty) {
      return null;
    }
    if (line < blocks.first.startLine) {
      return (block: 0, fraction: 0);
    }
    for (final (int index, BlockValueObject block) in blocks.indexed) {
      final int after = block.endLine + 1;
      if (line < block.startLine) {
        return (block: index, fraction: 0);
      }
      if (line < after) {
        return (
          block: index,
          fraction: (line - block.startLine) / (after - block.startLine),
        );
      }
    }
    return (block: blocks.length - 1, fraction: 1);
  }

  /// The line [fraction] of the way down block [block] — the inverse of
  /// [blockAt]. A block past either end is the nearest one.
  double lineAt(List<BlockValueObject> blocks, int block, double fraction) {
    if (blocks.isEmpty) {
      return 0;
    }
    final BlockValueObject at = blocks[block.clamp(0, blocks.length - 1)];
    return at.startLine + fraction.clamp(0.0, 1.0) * at.lineCount;
  }
}
