import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_document_widget.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The preview's end of the link between the two panes of `Split`: it goes
/// where the source is, tells the source where it is, and never echoes.
void main() {
  const int count = 80;

  // One line apart in the source, every fifth block three lines long, so the
  // blocks are not alike in height or in lines.
  final List<BlockValueObject> blocks = <BlockValueObject>[];
  int line = 0;
  for (int i = 0; i < count; i++) {
    final int length = i % 5 == 0 ? 3 : 1;
    blocks.add(
      BlockValueObject(
        startLine: line,
        endLine: line + length - 1,
        source: List<String>.generate(
          length,
          (int at) => 'Paragraph $i line $at',
        ).join('\n'),
        kind: BlockKindEnum.paragraph,
      ),
    );
    line += length + 1;
  }
  final ParsedDocumentValueObject document = ParsedDocumentValueObject(
    document: DocumentEntity(
      path: SpaceRelativePathValueObject('long.md'),
      content: '',
    ),
    blocks: blocks,
    linkDefinitions: '',
  );

  late DocumentScrollLink link;
  late List<double> asked;
  late double sourceAt;

  setUp(() {
    link = DocumentScrollLink();
    asked = <double>[];
    sourceAt = 0;
  });

  /// A source pane that only records what it is told.
  ScrollPane fakeSource() => (
    read: () => sourceAt,
    follow: (double to) {
      asked.add(to);
      sourceAt = to;
    },
  );

  Future<void> pump(WidgetTester tester, {DocumentScrollLink? linked}) async {
    tester.view
      ..physicalSize = const Size(600, 500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: PreviewDocumentWidget(
              document: document,
              isReading: false,
              link: linked,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// How far below the pane's top the block's first line is drawn.
  double topOf(WidgetTester tester, int block) =>
      tester.getTopLeft(find.textContaining('Paragraph $block line 0')).dy -
      tester.getTopLeft(find.byType(ListView)).dy;

  /// The line at the top of the pane that the preview itself reports.
  int blockStartingAt(int index) => blocks[index].startLine;

  testWidgets('it goes where the source is, to the block that holds the line', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    await tester.pumpAndSettle();

    link.sourceMoved(blockStartingAt(40).toDouble());
    await tester.pumpAndSettle();

    expect(find.textContaining('Paragraph 40 line 0'), findsOneWidget);
    expect(topOf(tester, 40), closeTo(0, 2));
  });

  testWidgets('a place inside a block is the same fraction down it', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    await tester.pumpAndSettle();

    // Block 40 is three lines: a line and a half is halfway down it.
    link.sourceMoved(blockStartingAt(40) + 1.5);
    await tester.pumpAndSettle();

    // The block starts above the pane's top by half of its own height.
    final double height = tester
        .getSize(find.textContaining('Paragraph 40 line 0'))
        .height;
    expect(topOf(tester, 40), closeTo(-height / 2, 3));
  });

  testWidgets('it tells the source what the reader scrolled to', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    asked.clear();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(asked, isNotEmpty);
    // What the source was told is a line of the block at the top.
    final int top = blocks.indexWhere(
      (BlockValueObject it) => it.endLine + 1 > asked.last,
    );
    expect(top, greaterThan(5));
    expect(find.textContaining('Paragraph $top line 0'), findsOneWidget);
    expect(topOf(tester, top), lessThan(1));
  });

  testWidgets('what it was told to follow it does not tell back', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    await tester.pumpAndSettle();
    asked.clear();

    link.sourceMoved(blockStartingAt(55).toDouble());
    await tester.pumpAndSettle();
    link.sourceMoved(blockStartingAt(10).toDouble());
    await tester.pumpAndSettle();

    expect(find.textContaining('Paragraph 10 line 0'), findsOneWidget);
    expect(asked, isEmpty);
  });

  testWidgets('after following, the next scroll of the reader is heard', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    await tester.pumpAndSettle();
    link.sourceMoved(blockStartingAt(55).toDouble());
    await tester.pumpAndSettle();
    asked.clear();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(asked, isNotEmpty);
    expect(asked.last, lessThan(blockStartingAt(55).toDouble()));
  });

  testWidgets('with no source beside it nothing follows, and nothing is told', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    link
      ..attachSource(fakeSource())
      ..sourceMoved(blockStartingAt(40).toDouble());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    // The drag moved the pane and nobody was told; the source's move moved
    // nothing.
    expect(asked, isEmpty);
    expect(find.textContaining('Paragraph 40 line 0'), findsNothing);
    expect(link.isLinked, isFalse);
  });

  testWidgets('a preview that leaves the link stops following', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachSource(fakeSource());
    await tester.pumpAndSettle();
    expect(link.isLinked, isTrue);

    await pump(tester);

    expect(link.isLinked, isFalse);
  });
}
