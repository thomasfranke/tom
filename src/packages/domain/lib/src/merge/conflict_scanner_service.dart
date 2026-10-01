/// Reading the conflicts git left in a document, and rewriting one away.
library;

import 'package:tom_domain/src/merge/conflict_region_value_object.dart';

/// Which side of a conflict is kept when it is resolved.
enum ConflictChoiceEnum {
  /// The side already on this branch.
  current,

  /// The side being merged in.
  incoming,

  /// Both, current first.
  both,
}

/// Finds the regions git marked in a document, and applies a choice to one.
///
/// A domain service because the rule belongs to no single type, and it holds
/// nothing: it is handed the text every time, so a region never outlives the
/// buffer it was found in. Reading asks git nothing, which is what lets a
/// conflict somebody resolved in another editor simply stop having any
/// (`docs/product/editor/conflicted-document/doc.md`).
final class ConflictScannerService {
  /// Creates the service.
  const ConflictScannerService();

  static const String _start = '<<<<<<<';
  static const String _middle = '=======';
  static const String _end = '>>>>>>>';

  /// Every conflict in [text], in the order they appear.
  ///
  /// A region needs all three markers, each at the start of its own line and
  /// in order. Anything less is text: a document *about* merging quotes these
  /// markers, and quoting them must not turn a paragraph into a conflict.
  List<ConflictRegionValueObject> scan(String text) {
    if (!text.contains(_start)) {
      return const <ConflictRegionValueObject>[];
    }

    final List<String> lines = text.split('\n');
    final List<ConflictRegionValueObject> found =
        <ConflictRegionValueObject>[];

    // Offsets are tracked alongside the lines so a region can be replaced by
    // span later without the caller counting newlines again.
    int offset = 0;
    int index = 0;
    while (index < lines.length) {
      final String line = lines[index];
      if (!line.startsWith(_start)) {
        offset += line.length + 1;
        index += 1;
        continue;
      }

      final int startOffset = offset;
      final String currentLabel = _labelOf(line, _start);
      int cursor = offset + line.length + 1;
      int scan = index + 1;

      final List<String> current = <String>[];
      int? middle;
      while (scan < lines.length) {
        if (lines[scan].startsWith(_middle)) {
          middle = scan;
          break;
        }
        if (lines[scan].startsWith(_start)) {
          break;
        }
        current.add(lines[scan]);
        cursor += lines[scan].length + 1;
        scan += 1;
      }
      if (middle == null) {
        // An opening with no separator is not a conflict; carry on from the
        // line after it rather than swallowing the rest of the document.
        offset += line.length + 1;
        index += 1;
        continue;
      }

      cursor += lines[middle].length + 1;
      scan = middle + 1;
      final List<String> incoming = <String>[];
      int? closing;
      while (scan < lines.length) {
        if (lines[scan].startsWith(_end)) {
          closing = scan;
          break;
        }
        if (lines[scan].startsWith(_start) ||
            lines[scan].startsWith(_middle)) {
          break;
        }
        incoming.add(lines[scan]);
        cursor += lines[scan].length + 1;
        scan += 1;
      }
      if (closing == null) {
        offset += line.length + 1;
        index += 1;
        continue;
      }

      final int endOffset = cursor + lines[closing].length + 1;
      found.add(
        ConflictRegionValueObject(
          start: startOffset,
          end: endOffset > text.length ? text.length : endOffset,
          current: current.join('\n'),
          incoming: incoming.join('\n'),
          currentLabel: currentLabel,
          incomingLabel: _labelOf(lines[closing], _end),
        ),
      );

      offset = endOffset;
      index = closing + 1;
    }

    return found;
  }

  /// [text] with [region] replaced by the side [choice] names.
  ///
  /// A choice is an edit, not a save: this returns the new buffer and writes
  /// nothing, so the unsaved mark appears and undo puts it back.
  String resolve(
    String text,
    ConflictRegionValueObject region,
    ConflictChoiceEnum choice,
  ) {
    final String kept = switch (choice) {
      ConflictChoiceEnum.current => region.keepingCurrent,
      ConflictChoiceEnum.incoming => region.keepingIncoming,
      ConflictChoiceEnum.both => region.keepingBoth,
    };
    final String before = text.substring(0, region.start);
    final String after = text.substring(region.end);
    return kept.isEmpty ? '$before$after' : '$before$kept\n$after';
  }

  /// [text] cut into the stretches around its conflicts, in order.
  ///
  /// A conflict is rarely a whole paragraph: git writes its markers on their
  /// own lines, while markdown ends a paragraph only at a blank one, so one
  /// paragraph routinely holds ordinary prose, a whole conflict, and more
  /// prose. **Cutting at the markers is what keeps both true** — no marker
  /// reaches the preview, and nothing the document says disappears from it
  /// (`docs/product/editor/conflicted-document/doc.md`).
  ///
  /// A document with no conflict answers with itself, in one piece.
  List<ConflictSegment> segment(String text) {
    final List<ConflictRegionValueObject> regions = scan(text);
    if (regions.isEmpty) {
      return <ConflictSegment>[ConflictSegment.prose(text)];
    }
    final List<ConflictSegment> segments = <ConflictSegment>[];
    int at = 0;
    for (final ConflictRegionValueObject region in regions) {
      if (region.start > at) {
        segments.add(ConflictSegment.prose(text.substring(at, region.start)));
      }
      segments.add(ConflictSegment.conflict(region));
      at = region.end;
    }
    if (at < text.length) {
      segments.add(ConflictSegment.prose(text.substring(at)));
    }
    return segments;
  }

  /// Whether [text] still holds a marker of any kind.
  ///
  /// This is what refuses to stage a document mid-merge: git will happily
  /// record a marker somebody staged, and `<<<<<<<` committed into
  /// documentation is read by everyone who opens the file next
  /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
  bool holdsMarker(String text) => scan(text).isNotEmpty;

  /// What follows a marker on its own line, trimmed; empty when it says
  /// nothing.
  String _labelOf(String line, String marker) =>
      line.substring(marker.length).trim();
}

/// One stretch of a conflicted document: either prose or a conflict.
///
/// A `sealed` pair rather than a nullable field, so a caller that forgets one
/// of the two does not compile.
sealed class ConflictSegment {
  const ConflictSegment();

  /// Text to render the way the document is normally rendered.
  const factory ConflictSegment.prose(String text) = ConflictProse;

  /// A conflict to render as its two sides and the choice between them.
  const factory ConflictSegment.conflict(ConflictRegionValueObject region) =
      ConflictAt;
}

/// A stretch with no conflict in it.
final class ConflictProse extends ConflictSegment {
  /// Wraps [text].
  const ConflictProse(this.text);

  /// What it reads.
  final String text;
}

/// A stretch that is a conflict.
final class ConflictAt extends ConflictSegment {
  /// Wraps [region].
  const ConflictAt(this.region);

  /// The conflict, with both its sides.
  final ConflictRegionValueObject region;
}
