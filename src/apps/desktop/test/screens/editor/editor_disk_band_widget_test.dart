/// The band over a tab whose file changed on disk under its edits.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/editor/editor_disk_band_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Editor editor;
  late ProviderContainer container;

  final SpaceRelativePathValueObject file = SpaceRelativePathValueObject(
    'preferences.json',
  );

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor = _Editor()),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpBand(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: EditorDiskBandWidget()),
        ),
      ),
    );
    await tester.pump();
  }

  /// The preferences file, with edits, and [changed] on disk or not.
  void holds({required bool changed}) => editor.state = EditorState.ready(
    saved: DocumentEntity(path: file, content: '{}'),
    source: '{"mine": true}',
    isPreferences: true,
    changedOnDisk: changed,
  );

  testWidgets('nothing is said while the file has not changed', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester);
    holds(changed: false);
    await tester.pump();

    expect(find.byType(NoticeBandWidget), findsNothing);
  });

  testWidgets('a change under edits is said, with both answers', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester);
    holds(changed: true);
    await tester.pump();

    expect(
      find.text('preferences.json changed on disk while you were editing it.'),
      findsOneWidget,
    );
    expect(find.text('Keep mine'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });

  testWidgets('a document of the space is named the same way', (
    WidgetTester tester,
  ) async {
    await pumpBand(tester);
    editor.state = EditorState.ready(
      saved: DocumentEntity(
        path: SpaceRelativePathValueObject('guides/writing.md'),
        content: '# As it was read\n',
      ),
      source: '# Mine\n',
      changedOnDisk: true,
    );
    await tester.pump();

    expect(
      find.text('writing.md changed on disk while you were editing it.'),
      findsOneWidget,
    );
    expect(find.text('Keep mine'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });

  testWidgets('it is drawn to the board: modified, 36 tall, pills 8 apart', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1164, 200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpBand(tester);
    holds(changed: true);
    await tester.pump();

    final TomColors colors = TomColors.of(
      tester.element(find.byType(NoticeBandWidget)),
    );
    final Rect band = tester.getRect(find.byType(NoticeBandWidget));
    expect(band.size, const Size(1164, 36));
    final Rect keep = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Keep mine'),
    );
    final Rect reload = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Reload'),
    );
    expect(reload.right, 1164 - 13);
    expect(reload.left - keep.right, 8);
    expect(keep.top, 6);
    expect(keep.height, 24);
    final Text sentence = tester.widget<Text>(
      find.text('preferences.json changed on disk while you were editing it.'),
    );
    expect(sentence.style?.color, colors.modified);
    final ColoredBox fill = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(NoticeBandWidget),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(fill.color, colors.modifiedSoft);
  });

  testWidgets('each answer reaches the editor', (WidgetTester tester) async {
    await pumpBand(tester);
    holds(changed: true);
    await tester.pump();

    await tester.tap(find.text('Keep mine'));
    await tester.tap(find.text('Reload'));

    expect(editor.answers, <String>['keep', 'reload']);
  });

  testWidgets('it speaks Portuguese too', (WidgetTester tester) async {
    await pumpBand(tester, locale: const Locale('pt'));
    holds(changed: true);
    await tester.pump();

    expect(find.text('Manter o meu'), findsOneWidget);
    expect(find.text('Recarregar'), findsOneWidget);
  });
}

/// An editor that holds what the test puts in it and records the answers.
final class _Editor extends EditorNotifier {
  final List<String> answers = <String>[];

  @override
  EditorState build() => const EditorState.empty();

  @override
  void keepMine() => answers.add('keep');

  @override
  Future<void> reload() async => answers.add('reload');
}
