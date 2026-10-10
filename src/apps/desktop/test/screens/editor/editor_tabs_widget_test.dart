/// The tab strip: one tab per open document, preview in italic, no close on
/// a tab that holds edits, and the menu a right click opens.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/editor/editor_tabs_widget.dart';
import 'package:tom_desktop/screens/export/save_location_picker.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late ProviderContainer container;
  late _Editor editor;
  late _Exports exports;
  late List<String> asked;
  String? answer;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject roadmap = SpaceRelativePathValueObject(
    'tasks/roadmap.md',
  );
  final SpaceRelativePathValueObject about = SpaceRelativePathValueObject(
    'about.md',
  );

  setUp(() {
    asked = <String>[];
    answer = '/out';
    container = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor = _Editor()),
        exportProvider.overrideWith(() => exports = _Exports()),
        // The save dialog answers a folder under `/out`, or null to cancel.
        saveLocationPickerProvider.overrideWithValue((
          String suggestedName,
          ExportFormatEnum format,
        ) async {
          asked.add(suggestedName);
          return answer == null ? null : '$answer/$suggestedName';
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the strip with `roadmap.md` kept and `about.md` in preview, the
  /// second on screen.
  Future<void> pumpStrip(WidgetTester tester) async {
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(roadmap)
      ..keep(DocumentTab.inSpace(roadmap))
      ..show(about);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(body: EditorTabsWidget()),
        ),
      ),
    );
    await tester.pump();
  }

  TextStyle styleOf(WidgetTester tester, String name) =>
      tester.widget<Text>(find.text(name)).style!;

  testWidgets('one tab per open document, named by the file', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    expect(find.text('roadmap.md'), findsOneWidget);
    expect(find.text('about.md'), findsOneWidget);
  });

  testWidgets('the strip starts at its left edge, the board\'s 16 in', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    expect(
      tester.getTopLeft(find.byType(TomGlyphWidget).first).dx,
      EditorTabsDesign.glyphLeft,
    );
  });

  testWidgets('the tab on screen is the bright one', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    expect(styleOf(tester, 'about.md').color, TomColors.dark.textPrimary);
    expect(styleOf(tester, 'roadmap.md').color, TomColors.dark.textMuted);
  });

  testWidgets('a tab opened by a click is italic until it is kept', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    expect(styleOf(tester, 'about.md').fontStyle, FontStyle.italic);
    expect(styleOf(tester, 'roadmap.md').fontStyle, FontStyle.normal);
  });

  testWidgets('choosing a tab puts its document on screen', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    await tester.tap(find.text('roadmap.md'));
    await tester.pump();

    expect(container.read(spaceSessionProvider)?.openDocument, roadmap);
  });

  testWidgets('a clean tab closes from its ✕', (WidgetTester tester) async {
    await pumpStrip(tester);

    await tester.tap(find.byTooltip('Close').first);
    await tester.pump();

    expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[
      DocumentTab.inSpace(about),
    ]);
  });

  testWidgets('an unsaved tab draws a dot and no ✕', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    editor.state = EditorState.ready(
      saved: DocumentEntity(path: about, content: '# About\n'),
      source: '# About, changed\n',
    );
    await tester.pump();

    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets('a right click opens the tab\'s menu under the pointer', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    final Offset at = tester.getCenter(find.text('roadmap.md'));
    await tester.tapAt(at, buttons: kSecondaryButton);
    await tester.pump();

    expect(find.text('Export as PDF…'), findsOneWidget);
    expect(find.text('Export as HTML…'), findsOneWidget);
    expect(find.text('Close tab'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(TomMenuWidget)), at);
  });

  testWidgets('Export as PDF asks where, offering the document\'s name', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    await tester.tapAt(
      tester.getCenter(find.text('roadmap.md')),
      buttons: kSecondaryButton,
    );
    await tester.pump();
    await tester.tap(find.text('Export as PDF…'));
    await tester.pump();

    expect(asked, <String>['roadmap.pdf']);
    expect(exports.exported, <Object>[
      (roadmap, ExportFormatEnum.pdf, '/out/roadmap.pdf'),
    ]);
    expect(find.byType(TomMenuWidget), findsNothing);
  });

  testWidgets('a cancelled dialog exports nothing', (
    WidgetTester tester,
  ) async {
    answer = null;
    await pumpStrip(tester);

    await tester.tapAt(
      tester.getCenter(find.text('about.md')),
      buttons: kSecondaryButton,
    );
    await tester.pump();
    await tester.tap(find.text('Export as HTML…'));
    await tester.pump();

    expect(asked, <String>['about.html']);
    expect(exports.exported, isEmpty);
  });

  group('the preferences file', () {
    final SpaceRelativePathValueObject file = SpaceRelativePathValueObject(
      'preferences.json',
    );

    testWidgets('is a tab after the documents\', the one on screen', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('preferences.json')).dx,
        greaterThan(tester.getTopLeft(find.text('about.md')).dx),
      );
      expect(
        styleOf(tester, 'preferences.json').color,
        TomColors.dark.textPrimary,
      );
      expect(styleOf(tester, 'about.md').color, TomColors.dark.textMuted);
      // Never in preview: it is opened on purpose, from the popover.
      expect(styleOf(tester, 'preferences.json').fontStyle, FontStyle.normal);
    });

    testWidgets('a document chosen takes the screen, and it comes back', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await tester.pump();

      await tester.tap(find.text('roadmap.md'));
      await tester.pump();
      expect(container.read(spaceSessionProvider)?.openDocument, roadmap);

      await tester.tap(find.text('preferences.json'));
      await tester.pump();
      expect(
        container.read(spaceSessionProvider)?.isShowingPreferencesFile,
        isTrue,
      );
    });

    testWidgets('closes from its ✕ like any tab', (WidgetTester tester) async {
      await pumpStrip(tester);
      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await tester.pump();

      await tester.tap(find.byTooltip('Close').last);
      await tester.pump();

      expect(find.text('preferences.json'), findsNothing);
      expect(container.read(spaceSessionProvider)?.openDocument, about);
    });

    testWidgets('offers no export, since it is not a document', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await tester.pump();

      await tester.tapAt(
        tester.getCenter(find.text('preferences.json')),
        buttons: kSecondaryButton,
      );
      await tester.pump();

      expect(find.byType(TomMenuWidget), findsNothing);
    });
  });

  group('a change that is not a document', () {
    testWidgets('a deleted file is struck through, then (deleted), in red', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      editor.state = EditorState.ready(
        saved: DocumentEntity(path: about, content: '# About\n'),
        source: '# About\n',
        isDeleted: true,
      );
      await tester.pump();

      final Text label = tester.widget<Text>(find.text('about.md (deleted)'));
      final List<InlineSpan> parts = (label.textSpan! as TextSpan).children!;
      expect(
        (parts.first as TextSpan).style?.decoration,
        TextDecoration.lineThrough,
      );
      expect((parts.last as TextSpan).text, ' (deleted)');
      expect((parts.last as TextSpan).style?.decoration, isNull);
      expect(label.style!.color, TomColors.dark.removed);
      // The other tab is untouched.
      expect(styleOf(tester, 'roadmap.md').color, TomColors.dark.textMuted);
    });

    testWidgets('a tab grows to fit (deleted) rather than shrinking', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      final double before = tester.getSize(find.text('about.md')).width;

      editor.state = EditorState.ready(
        saved: DocumentEntity(path: about, content: ''),
        source: '',
        isDeleted: true,
      );
      await tester.pump();

      expect(
        tester.getSize(find.text('about.md (deleted)')).width,
        greaterThan(before),
      );
    });

    testWidgets('a file that is not markdown offers no export', (
      WidgetTester tester,
    ) async {
      await pumpStrip(tester);
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('mkdocs.yml'));
      await tester.pump();

      await tester.tapAt(
        tester.getCenter(find.text('mkdocs.yml')),
        buttons: kSecondaryButton,
      );
      await tester.pump();

      expect(find.text('Export as PDF…'), findsNothing);
      expect(find.text('Export as HTML…'), findsNothing);
      expect(find.text('Close tab'), findsOneWidget);
    });
  });

  testWidgets('Close tab in the menu closes that tab', (
    WidgetTester tester,
  ) async {
    await pumpStrip(tester);

    await tester.tapAt(
      tester.getCenter(find.text('roadmap.md')),
      buttons: kSecondaryButton,
    );
    await tester.pump();
    await tester.tap(find.text('Close tab'));
    await tester.pump();

    expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[
      DocumentTab.inSpace(about),
    ]);
  });
}

/// An export that records what it was asked for.
final class _Exports extends ExportNotifier {
  final List<Object> exported = <Object>[];

  @override
  ExportState build() => const ExportState.idle();

  @override
  Future<void> export(
    SpaceRelativePathValueObject path,
    ExportFormatEnum format,
    String destination,
  ) async => exported.add((path, format, destination));
}

/// An editor that holds whatever the test puts in it.
final class _Editor extends EditorNotifier {
  @override
  EditorState build() => const EditorState.empty();
}
