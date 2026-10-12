/// The document pane over a change that is not a document: a binary file's
/// sentence, and a deleted file's last version, read-only and all removed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_binary_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;
  late _Holding editor;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  /// Mounts the pane with [path] on screen and the editor holding [state].
  Future<void> pumpPane(
    WidgetTester tester,
    String path,
    EditorState state,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor = _Holding(state)),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(SpaceRelativePathValueObject(path));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: EditorPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  EditorState deleted(String path, String source) => EditorState.ready(
    saved: DocumentEntity(
      path: SpaceRelativePathValueObject(path),
      content: source,
    ),
    source: source,
    isDeleted: true,
  );

  group('a binary file', () {
    final EditorState logo = EditorState.ready(
      saved: DocumentEntity(
        path: SpaceRelativePathValueObject('assets/logo.png'),
        content: '',
      ),
      source: '',
      isBinary: true,
    );

    testWidgets('says so, in place of a page of noise', (
      WidgetTester tester,
    ) async {
      await pumpPane(tester, 'assets/logo.png', logo);

      expect(find.byType(CodeEditor), findsNothing);
      expect(find.text('A binary file — not shown as text.'), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.text('A binary file — not shown as text.'))
            .style
            ?.color,
        TomColors.light.textSecondary,
      );
    });

    testWidgets('the sentence and the button are centred in the pane', (
      WidgetTester tester,
    ) async {
      await pumpPane(tester, 'assets/logo.png', logo);

      final Rect button = tester.getRect(find.byType(OutlinedButton));
      final Rect sentence = tester.getRect(
        find.text('A binary file — not shown as text.'),
      );
      expect(button.size, EditorBinaryWidget.button);
      expect(button.top - sentence.bottom, EditorBinaryWidget.gap);
      expect(button.center.dx, 640);
      expect((sentence.top + button.bottom) / 2, closeTo(400, 0.5));
    });

    testWidgets('the button reveals the file', (WidgetTester tester) async {
      await pumpPane(tester, 'assets/logo.png', logo);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(editor.revealed, 1);
    });
  });

  group('a deleted file', () {
    testWidgets('is read-only, and drawn plain when it is not markdown', (
      WidgetTester tester,
    ) async {
      await pumpPane(
        tester,
        'docs.yml',
        deleted('docs.yml', 'site_name: docs\nnav: []\n'),
      );

      final CodeEditor pane = tester.widget(find.byType(CodeEditor));
      expect(pane.readOnly, isTrue);
      expect(pane.style?.codeTheme, isNull);
    });

    testWidgets('every line is under the removed band, lettered R', (
      WidgetTester tester,
    ) async {
      // The letter on the run's first line, as for A and M: a mark on every
      // line of a block would be the same fact five times.
      await pumpPane(
        tester,
        'docs.yml',
        deleted('docs.yml', 'site_name: docs\nnav: []\ntheme: x\n'),
      );

      final EditorMarks marks =
          (tester
                      .widget<CustomPaint>(
                        find.descendant(
                          of: find.byType(EditorMarksWidget),
                          matching: find.byType(CustomPaint),
                        ),
                      )
                      .painter!
                  as EditorMarksPainter)
              .marks;
      expect(marks.at(0), EditorMarkEnum.removed);
      for (int line = 0; line < 3; line++) {
        expect(marks.bandAt(line), EditorMarkEnum.removed, reason: '$line');
      }
    });

    testWidgets('a deleted document is read-only in source as well', (
      WidgetTester tester,
    ) async {
      await pumpPane(tester, 'guide.md', deleted('guide.md', '# Guide\n'));

      final CodeEditor pane = tester.widget(find.byType(CodeEditor));
      expect(pane.readOnly, isTrue);
      expect(pane.style?.codeTheme, isNotNull);
    });
  });
}

/// An editor that holds the one buffer it was given, and counts reveals.
final class _Holding extends EditorNotifier {
  _Holding(this._state);

  final EditorState _state;
  int revealed = 0;

  @override
  EditorState build() => _state;

  @override
  Future<void> reveal() async => revealed++;
}
