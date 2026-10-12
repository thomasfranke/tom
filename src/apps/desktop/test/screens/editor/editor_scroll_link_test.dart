import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_version_widget.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The source's end of the link between the two panes of `Split` — tried on
/// the past version's pane, which is the same pane over the same editor.
void main() {
  late DocumentScrollLink link;
  late List<double> asked;
  late double previewAt;

  setUp(() {
    link = DocumentScrollLink();
    asked = <double>[];
    previewAt = 0;
  });

  /// A preview pane that only records what it is told.
  ScrollPane fakePreview() => (
    read: () => previewAt,
    follow: (double to) {
      asked.add(to);
      previewAt = to;
    },
  );

  Future<void> pump(WidgetTester tester, {DocumentScrollLink? linked}) async {
    tester.view
      ..physicalSize = const Size(700, 400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[previewProvider.overrideWith(_Preview.new)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(body: EditorVersionWidget(link: linked)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('it knows the line at its top', (WidgetTester tester) async {
    await pump(tester, linked: link);
    link.attachPreview(fakePreview());
    await tester.pumpAndSettle();

    expect(link.sourceLine, closeTo(0, 0.01));

    await tester.drag(find.byType(CodeEditor), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(link.sourceLine, greaterThan(20));
  });

  testWidgets('it tells the preview what the reader scrolled to', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachPreview(fakePreview());
    await tester.pumpAndSettle();
    asked.clear();

    await tester.drag(find.byType(CodeEditor), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(asked, isNotEmpty);
    expect(asked.last, closeTo(link.sourceLine!, 0.01));
  });

  testWidgets('it goes where the preview is, to the same line', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachPreview(fakePreview());
    await tester.pumpAndSettle();

    link.previewMoved(120.5);
    await tester.pumpAndSettle();

    expect(link.sourceLine, closeTo(120.5, 0.2));
  });

  testWidgets('what it was told to follow it does not tell back', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachPreview(fakePreview());
    await tester.pumpAndSettle();
    asked.clear();

    link.previewMoved(150);
    await tester.pumpAndSettle();
    link.previewMoved(30);
    await tester.pumpAndSettle();

    expect(link.sourceLine, closeTo(30, 0.2));
    expect(asked, isEmpty);
  });

  testWidgets('after following, the next scroll of the reader is heard', (
    WidgetTester tester,
  ) async {
    await pump(tester, linked: link);
    link.attachPreview(fakePreview());
    await tester.pumpAndSettle();
    link.previewMoved(100);
    await tester.pumpAndSettle();
    asked.clear();

    await tester.drag(find.byType(CodeEditor), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(asked, isNotEmpty);
    expect(asked.last, lessThan(100));
  });

  testWidgets('with no preview beside it nothing follows', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    link
      ..attachPreview(fakePreview())
      ..previewMoved(120);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CodeEditor), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(asked, isEmpty);
    expect(link.sourceLine, isNull);
  });
}

/// Two hundred lines, some long enough to wrap in a 700-wide pane.
String get _long => List<String>.generate(
  200,
  (int i) => i % 7 == 0
      ? 'Line $i ${'wraps over more than one row of the pane ' * 6}'
      : 'Line $i',
).join('\n');

final class _Preview extends PreviewNotifier {
  @override
  PreviewState build() => PreviewState.ready(
    ParsedDocumentValueObject(
      document: DocumentEntity(
        path: SpaceRelativePathValueObject('long.md'),
        content: _long,
      ),
      blocks: const <BlockValueObject>[],
      linkDefinitions: '',
    ),
  );
}
