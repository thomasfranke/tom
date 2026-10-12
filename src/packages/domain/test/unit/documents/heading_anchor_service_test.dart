import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const HeadingAnchorService anchors = HeadingAnchorService();

  BlockValueObject block(String source, BlockKindEnum kind, int at) =>
      BlockValueObject(
        startLine: at,
        endLine: at + source.split('\n').length - 1,
        source: source,
        kind: kind,
      );

  BlockValueObject heading(String source, [int at = 0]) =>
      block(source, BlockKindEnum.heading, at);

  group('the slug is GitHub\'s', () {
    test('lowercased, each space a hyphen', () {
      expect(anchors.slugOf('The Layer Graph'), 'the-layer-graph');
    });

    test('punctuation dropped, hyphens and underscores kept', () {
      expect(anchors.slugOf("What's left? (v2.0)"), 'whats-left-v20');
      expect(anchors.slugOf('read_me - first'), 'read_me---first');
    });

    test('letters outside English kept', () {
      expect(anchors.slugOf('Configuração inicial'), 'configuração-inicial');
    });

    test('an anchor already a slug is itself', () {
      expect(anchors.slugOf('the-layer-graph'), 'the-layer-graph');
    });
  });

  group('the words of a heading', () {
    test('after the hashes, without a closing run', () {
      expect(anchors.textOf(heading('## Enforcement ##')), 'Enforcement');
      expect(anchors.textOf(heading('# Title')), 'Title');
    });

    test('above the underline', () {
      expect(
        anchors.textOf(heading('Enforcement\n-----------')),
        'Enforcement',
      );
    });

    test('a link keeps its words and loses its address', () {
      expect(
        anchors.textOf(heading('## See [the graph](graph.md)')),
        'See the graph',
      );
    });

    test('a paragraph has none', () {
      expect(
        anchors.textOf(block('# not', BlockKindEnum.paragraph, 0)),
        isNull,
      );
    });
  });

  group('the heading an anchor names', () {
    final List<BlockValueObject> blocks = <BlockValueObject>[
      heading('# Architecture'),
      block('The layers.', BlockKindEnum.paragraph, 2),
      heading('## Enforcement', 4),
      heading('## Setup', 6),
      heading('## Setup', 8),
    ];

    test('is found by its words, however they are cased', () {
      expect(anchors.headingOf('Enforcement', blocks), blocks[2]);
      expect(anchors.headingOf('enforcement', blocks), blocks[2]);
    });

    test('a repeat is reached by its suffix, the first by none', () {
      expect(anchors.headingOf('setup', blocks), blocks[3]);
      expect(anchors.headingOf('setup-1', blocks), blocks[4]);
    });

    test('one that names nothing finds nothing', () {
      expect(anchors.headingOf('deployment', blocks), isNull);
      expect(anchors.headingOf('?!', blocks), isNull);
    });

    test('a paragraph is never a heading, whatever it says', () {
      expect(anchors.headingOf('the-layers', blocks), isNull);
    });
  });
}
