import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const ScrollMapService service = ScrollMapService();

  BlockValueObject block(int start, int end) => BlockValueObject(
    startLine: start,
    endLine: end,
    source: '',
    kind: BlockKindEnum.paragraph,
  );

  // Lines 0 | blank | 2-5 | blank | 7-8, so three blocks and two gaps.
  final List<BlockValueObject> blocks = <BlockValueObject>[
    block(0, 0),
    block(2, 5),
    block(7, 8),
  ];

  group('a line is a block and how far into it', () {
    test('the first line of a block is its top', () {
      expect(service.blockAt(blocks, 2), (block: 1, fraction: 0.0));
    });

    test('a line inside a block is a fraction of its lines', () {
      // Four lines, 2..5: a half line past line 3 is 1.5 of 4.
      expect(service.blockAt(blocks, 3.5), (block: 1, fraction: 0.375));
    });

    test('a fractional line moves within the line', () {
      expect(service.blockAt(blocks, 2.5)!.fraction, closeTo(0.125, 1e-9));
    });

    test('a blank line between blocks is the top of the next', () {
      expect(service.blockAt(blocks, 1), (block: 1, fraction: 0.0));
      expect(service.blockAt(blocks, 6.4), (block: 2, fraction: 0.0));
    });

    test('before the first block is its top, after the last its foot', () {
      expect(service.blockAt(<BlockValueObject>[block(3, 4)], 0), (
        block: 0,
        fraction: 0.0,
      ));
      expect(service.blockAt(blocks, 40), (block: 2, fraction: 1.0));
    });

    test('a document with no blocks has no place', () {
      expect(service.blockAt(<BlockValueObject>[], 3), isNull);
    });
  });

  group('a block and a fraction are a line', () {
    test('the top of a block is its first line', () {
      expect(service.lineAt(blocks, 1, 0), 2);
    });

    test('a fraction walks its lines', () {
      expect(service.lineAt(blocks, 1, 0.375), 3.5);
      expect(service.lineAt(blocks, 2, 1), 9);
    });

    test('a block that is not there is the nearest one', () {
      expect(service.lineAt(blocks, -3, 0), 0);
      expect(service.lineAt(blocks, 9, 0.5), 8);
    });

    test('is the inverse of blockAt over the blocks', () {
      for (final double line in <double>[0, 2, 2.75, 3.5, 5.9, 7, 8.5]) {
        final ({int block, double fraction}) at = service.blockAt(
          blocks,
          line,
        )!;
        expect(
          service.lineAt(blocks, at.block, at.fraction),
          closeTo(line, 1e-9),
        );
      }
    });
  });
}
