import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_wikilink_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late _Tree tree;
  late ProviderContainer container;

  /// What the tree answers instead of its listing, when a test says so.
  FileTreeState? listing;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject roadmap = SpaceRelativePathValueObject(
    'tasks/roadmap.md',
  );

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
  );

  /// The board's paragraph: one link of each kind.
  const String paragraph =
      'See [[setup]], [[release-notes]] and [[index]] before the launch.\n';

  setUp(() {
    listing = null;
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        splitDocumentProvider.overrideWithValue(
          const SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => _Git(() => documents.content),
            blocks: const _Blocks(),
            differ: const BlockDifferService(
              aligner: TextDifferBlockAlignerImpl(
                differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
              ),
            ),
            observability: const _Silent(),
          ),
        ),
        fileTreeProvider.overrideWith(
          () => tree = _Tree(<SpaceEntryValueObject>[
            file('tasks/roadmap.md'),
            file('guides/setup.md'),
            file('index.md'),
            file('reference/index.md'),
          ], answer: listing),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpPreview(WidgetTester tester, String content) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    documents.content = content;
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(roadmap);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: PreviewPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The style the words [label] are drawn in.
  TextStyle styleOf(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!;

  group('each link is drawn by what it points at', () {
    testWidgets('one that resolves is accent, underlined', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      final TextStyle style = styleOf(tester, 'setup');
      expect(style.color, TomColors.light.accent);
      expect(style.decoration, TextDecoration.underline);
    });

    testWidgets('one that points at nothing is removed, underlined', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      final TextStyle style = styleOf(tester, 'release-notes');
      expect(style.color, TomColors.light.removed);
      expect(style.decoration, TextDecoration.underline);
    });

    testWidgets('one the space holds twice is modified, with the count', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      final Finder ambiguous = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.textSpan?.toPlainText() == 'index²',
      );
      expect(ambiguous, findsOneWidget);
      final TextSpan whole =
          tester.widget<Text>(ambiguous).textSpan! as TextSpan;
      final TextSpan words = whole.children!.first as TextSpan;
      final TextSpan count = whole.children!.last as TextSpan;
      expect(words.style?.color, TomColors.light.modified);
      expect(words.style?.decoration, TextDecoration.underline);
      // Raised by its glyph, and not part of the link's words.
      expect(count.style?.color, TomColors.light.modified);
      expect(count.style?.decoration, isNot(TextDecoration.underline));
    });

    testWidgets('the brackets never reach the screen', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      expect(find.textContaining('[[', findRichText: true), findsNothing);
      // The prose around the links is still one sentence.
      expect(
        find.textContaining('before the launch.', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('a label is shown instead of the target', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, 'Read [[setup|the setup guide]].\n');

      expect(find.text('the setup guide'), findsOneWidget);
      expect(find.text('setup'), findsNothing);
    });

    testWidgets('inside code it is only text', (WidgetTester tester) async {
      await pumpPreview(tester, 'Type `[[setup]]` to link.\n');

      expect(find.byType(PreviewWikilinkWidget), findsNothing);
      expect(
        find.textContaining('[[setup]]', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('before the space is listed it is plain prose, never red', (
      WidgetTester tester,
    ) async {
      listing = const FileTreeState.loading();
      await pumpPreview(tester, paragraph);

      final TextStyle style = styleOf(tester, 'release-notes');
      expect(style.color, TomColors.light.textPrimary);
      expect(style.decoration, isNot(TextDecoration.underline));
    });
  });

  group('clicking', () {
    testWidgets('a link that resolves opens its document', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      await tester.tap(find.text('setup'));
      await tester.pumpAndSettle();

      expect(
        container.read(spaceSessionProvider)?.openDocument?.value,
        'guides/setup.md',
      );
    });
  });

  group('a link to a heading', () {
    /// A link, a long body, and the heading at its end; every document here
    /// reads the same text, so the one the link opens holds it too.
    String linkingTo(String anchor, {String document = 'setup'}) => <String>[
      'Read [[$document#$anchor|when it fails]] first.',
      for (int each = 1; each <= 40; each++)
        'Paragraph $each, only here to push the end below the window.',
      '## Troubleshooting',
      // As much again under it, so the pane can bring it to the top.
      for (int each = 1; each <= 40; each++) 'Check number $each.',
    ].join('\n\n');

    double topOf(WidgetTester tester, String words) =>
        tester.getTopLeft(find.textContaining(words, findRichText: true)).dy;

    testWidgets('opens the document scrolled to that heading', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, linkingTo('Troubleshooting'));
      expect(find.textContaining('Troubleshooting'), findsNothing);

      await tester.tap(find.text('when it fails'));
      await tester.pumpAndSettle();

      expect(
        container.read(spaceSessionProvider)?.openDocument?.value,
        'guides/setup.md',
      );
      final double top = topOf(tester, 'Troubleshooting');
      expect(top, greaterThanOrEqualTo(0));
      expect(top, lessThan(100), reason: 'the heading is not at the top');
    });

    testWidgets('one that names no heading opens it at the top, silently', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, linkingTo('deployment'));

      await tester.tap(find.text('when it fails'));
      await tester.pumpAndSettle();

      expect(
        container.read(spaceSessionProvider)?.openDocument?.value,
        'guides/setup.md',
      );
      expect(find.text('when it fails'), findsOneWidget);
      expect(container.read(previewAnchorProvider), isNull);
    });

    testWidgets('one with no document scrolls the document it is in', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, linkingTo('Troubleshooting', document: ''));

      await tester.tap(find.text('when it fails'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider)?.openDocument, roadmap);
      expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[
        DocumentTab.inSpace(roadmap),
      ]);
      final double top = topOf(tester, 'Troubleshooting');
      expect(top, greaterThanOrEqualTo(0));
      expect(top, lessThan(100), reason: 'the heading is not at the top');
    });

    testWidgets('and is shown by its heading when it has no label', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, 'Jump to [[#Troubleshooting]].\n');

      expect(styleOf(tester, 'Troubleshooting').color, TomColors.light.accent);
    });

    testWidgets('one that names no heading leaves the pane where it is', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, linkingTo('nowhere', document: ''));
      final double before = topOf(tester, 'Paragraph 1,');

      await tester.tap(find.text('when it fails'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider)?.openDocument, roadmap);
      expect(topOf(tester, 'Paragraph 1,'), before);
      expect(container.read(previewAnchorProvider), isNull);
    });
  });

  group('an ambiguous link', () {
    final Finder link = find.text('index²', findRichText: true);

    testWidgets('opens nothing on a guess: it lists the candidates, each '
        'with its folder', (WidgetTester tester) async {
      await pumpPreview(tester, paragraph);
      expect(find.byType(TomMenuWidget), findsNothing);

      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider)?.openDocument, roadmap);
      expect(find.byType(TomMenuWidget), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(TomMenuWidget),
          matching: find.text('index.md'),
        ),
        findsNWidgets(2),
      );
      // The root is named by the space; a folder by its path from the root.
      expect(find.text('docs'), findsOneWidget);
      expect(find.text('reference'), findsOneWidget);
    });

    testWidgets('hangs the menu from the link, just under its line', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      await tester.tap(link);
      await tester.pumpAndSettle();

      final Rect words = tester.getRect(link);
      final Rect menu = tester.getRect(find.byType(TomMenuWidget));
      expect(menu.left, words.left);
      expect(menu.width, PreviewDesign.candidatesWidth);
      expect(menu.top, greaterThan(words.center.dy));
      expect(menu.top, lessThanOrEqualTo(words.bottom + 6));
    });

    testWidgets('choosing a candidate opens it', (WidgetTester tester) async {
      await pumpPreview(tester, paragraph);
      await tester.tap(link);
      await tester.pumpAndSettle();

      await tester.tap(find.text('reference'));
      await tester.pumpAndSettle();

      expect(
        container.read(spaceSessionProvider)?.openDocument?.value,
        'reference/index.md',
      );
      expect(find.byType(TomMenuWidget), findsNothing);
    });

    testWidgets('Escape puts the menu away, and so does pressing the link '
        'again', (WidgetTester tester) async {
      await pumpPreview(tester, paragraph);
      await tester.tap(link);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(TomMenuWidget), findsNothing);

      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(TomMenuWidget), findsOneWidget);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(TomMenuWidget), findsNothing);
      expect(container.read(spaceSessionProvider)?.openDocument, roadmap);
    });

    test('a candidate at the root is named by the space', () {
      expect(
        PreviewWikilinkWidget.folderOf(
          SpaceRelativePathValueObject('index.md'),
          'docs',
        ),
        'docs',
      );
      expect(
        PreviewWikilinkWidget.folderOf(
          SpaceRelativePathValueObject('docs/archive/index.md'),
          'docs',
        ),
        'docs/archive',
      );
    });
  });

  group('a link that points at nothing', () {
    Future<TestGesture> pointAt(WidgetTester tester, Finder finder) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(finder));
      await tester.pumpAndSettle();
      return mouse;
    }

    testWidgets('names what is missing when pointed at', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);
      expect(find.byType(PreviewWikilinkTipWidget), findsNothing);

      await pointAt(tester, find.text('release-notes'));

      expect(find.text('No document called release-notes.'), findsOneWidget);
      expect(find.text('Create it'), findsOneWidget);
    });

    testWidgets('the tip hangs under the word, the board\'s step left of it', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);

      await pointAt(tester, find.text('release-notes'));

      final Rect word = tester.getRect(find.text('release-notes'));
      final Rect tip = tester.getRect(find.byType(PreviewWikilinkTipWidget));
      expect(tip.left, word.left - PreviewDesign.tipInset);
      expect(tip.top, word.bottom + PreviewDesign.tipDrop);
      expect(tip.height, PreviewDesign.tipHeight);
      expect(tip.width, greaterThanOrEqualTo(PreviewDesign.tipWidth));
    });

    testWidgets('stays while the pointer crosses to it, and goes after', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);
      final TestGesture mouse = await pointAt(
        tester,
        find.text('release-notes'),
      );

      await mouse.moveTo(tester.getCenter(find.text('Create it')));
      await tester.pump(PreviewDesign.tipLinger * 2);
      expect(find.text('Create it'), findsOneWidget);

      await mouse.moveTo(Offset.zero);
      await tester.pump(PreviewDesign.tipLinger * 2);
      expect(find.byType(PreviewWikilinkTipWidget), findsNothing);
    });

    testWidgets('a click raises the tip too', (WidgetTester tester) async {
      await pumpPreview(tester, paragraph);

      await tester.tap(find.text('release-notes'));
      await tester.pumpAndSettle();

      expect(find.text('Create it'), findsOneWidget);
    });

    testWidgets('Create it makes it beside the document the link is in', (
      WidgetTester tester,
    ) async {
      await pumpPreview(tester, paragraph);
      await tester.tap(find.text('release-notes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create it'));
      await tester.pumpAndSettle();

      expect(tree.created, <(String?, String)>[('tasks', 'release-notes')]);
      expect(find.byType(PreviewWikilinkTipWidget), findsNothing);
    });
  });

  group('where a missing link is created', () {
    (String?, String)? where(String target, String? origin) {
      final (SpaceRelativePathValueObject?, String)? answer =
          PreviewWikilinkWidget.whereToCreate(
            WikilinkValueObject(target: target),
            origin == null ? null : SpaceRelativePathValueObject(origin),
          );
      return answer == null ? null : (answer.$1?.value, answer.$2);
    }

    test('a name goes beside the document it is written in', () {
      expect(where('setup', 'guides/writing.md'), ('guides', 'setup'));
      expect(where('setup', 'index.md'), (null, 'setup'));
    });

    test('a path goes where it says', () {
      expect(where('reference/setup', 'guides/writing.md'), (
        'reference',
        'setup',
      ));
    });

    test('a path that leaves the space is nowhere', () {
      expect(where('../outside', 'guides/writing.md'), isNull);
    });
  });

  test('the count is written in superscript digits', () {
    expect(PreviewWikilinkWidget.superscript(2), '²');
    expect(PreviewWikilinkWidget.superscript(13), '¹³');
  });
}

/// The tree, answering with a listing and remembering what it was asked to
/// create.
final class _Tree extends FileTreeNotifier {
  _Tree(this.entries, {this.answer});

  final List<SpaceEntryValueObject> entries;

  /// What the tree is instead of its listing, when a test says so.
  final FileTreeState? answer;

  /// Every creation asked for, as the folder and the name.
  final List<(String?, String)> created = <(String?, String)>[];

  @override
  FileTreeState build() =>
      answer ??
      FileTreeState.ready(
        entries: entries,
        collapsed: const <SpaceRelativePathValueObject>{},
      );

  @override
  Future<bool> createDocument(
    SpaceRelativePathValueObject? folder,
    String typed,
  ) async {
    created.add((folder?.value, typed));
    return true;
  }
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Git, whose `HEAD` holds what the working copy does: no diff to draw.
final class _Git implements GitRepository {
  _Git(this.committed);

  final String Function() committed;

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => Success<String, GitFailure>(committed());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The real reader over the real parser; a fake outline would test the fake.
final class _Blocks implements BlockReaderPort {
  const _Blocks();

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) => _reader.read(document);

  static const MarkdownBlockReaderImpl _reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
