import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_desktop/screens/search/search_focus.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// No pull request on offer: the row it would draw has tests of its own.
final class _NoPullRequest extends PullRequestNotifier {
  @override
  PullRequestState build() => const PullRequestState();
}

void main() {
  late _Documents documents;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );

  setUp(() {
    documents = _Documents();
    const _Silent silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        pullRequestProvider.overrideWith(_NoPullRequest.new),
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: silent,
          ),
        ),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
        indexSpaceProvider.overrideWithValue(
          const IndexSpaceUseCase(
            spaces: _NothingInIt(),
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
        indexDocumentProvider.overrideWithValue(
          const IndexDocumentUseCase(
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
        searchSpaceProvider.overrideWithValue(
          const SearchSpaceUseCase(
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the left column with a document open, asking about this file.
  Future<void> pumpColumn(WidgetTester tester, {String? terms}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs)
      ..read(spaceSessionProvider.notifier).show(note);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(
            body: Row(
              children: <Widget>[
                SizedBox(width: TomMetrics.explorer, child: FileTreePanel()),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await container
        .read(searchProvider.notifier)
        .scopeTo(SearchScopeEnum.thisFile);
    if (terms != null) {
      await container.read(searchProvider.notifier).type(terms);
    }
    await tester.pumpAndSettle();
  }

  SearchReady ready() => container.read(searchProvider) as SearchReady;

  /// Opens the second box the way the shell's ⌥⌘F does.
  Future<void> openReplace(WidgetTester tester) async {
    container.read(searchProvider.notifier).showReplacing(showing: true);
    await tester.pumpAndSettle();
  }

  group('the ⇄ in the field', () {
    late int presses;
    late FocusNode node;

    /// The column under a scope whose toggle flips the box, as the shell's
    /// ⌥⌘F does, and counts the presses.
    Future<void> pumpWithToggle(WidgetTester tester, {String? terms}) async {
      presses = 0;
      node = FocusNode();
      addTearDown(node.dispose);
      tester.view
        ..physicalSize = const Size(1280, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      container
        ..listen<EditorState>(editorProvider, (_, _) {})
        ..read(spaceSessionProvider.notifier).open(docs)
        ..read(spaceSessionProvider.notifier).show(note);
      void toggle() {
        presses++;
        container
            .read(searchProvider.notifier)
            .showReplacing(showing: !SearchBoxes.isReplacing(ready()));
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: tomTheme(Brightness.dark),
            home: Scaffold(
              body: SearchFocusScope(
                node: node,
                toggleReplace: toggle,
                child: const Row(
                  children: <Widget>[
                    SizedBox(
                      width: TomMetrics.explorer,
                      child: FileTreePanel(),
                    ),
                    Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (terms != null) {
        await container.read(searchProvider.notifier).type(terms);
      }
      await tester.pumpAndSettle();
    }

    Finder toggleButton() => find.byWidgetPredicate(
      (Widget w) => w is Tooltip && (w.message ?? '').contains('eplace ('),
    );

    testWidgets('is not drawn while there is nothing to replace', (
      WidgetTester tester,
    ) async {
      await pumpWithToggle(tester);

      expect(toggleButton(), findsNothing);
    });

    testWidgets('appears with the words, and says its keys', (
      WidgetTester tester,
    ) async {
      await pumpWithToggle(tester, terms: 'palette');

      expect(toggleButton(), findsOneWidget);
      expect(
        tester.widget<Tooltip>(toggleButton()).message,
        anyOf('Replace (⌥⌘F)', 'Replace (Ctrl+H)'),
      );
    });

    testWidgets('is the same press as the shortcut, and lights up', (
      WidgetTester tester,
    ) async {
      await pumpWithToggle(tester, terms: 'palette');

      await tester.tap(toggleButton());
      await tester.pumpAndSettle();

      expect(presses, 1);
      expect(find.text('Replace with'), findsOneWidget);
      final TomGlyphWidget glyph = tester.widget<TomGlyphWidget>(
        find.descendant(
          of: toggleButton(),
          matching: find.byType(TomGlyphWidget),
        ),
      );
      expect(glyph.color, TomColors.dark.accent);

      await tester.tap(toggleButton());
      await tester.pumpAndSettle();

      expect(presses, 2);
      expect(find.text('Replace with'), findsNothing);
    });

    testWidgets('sits thirty left of the clear, as the board draws it', (
      WidgetTester tester,
    ) async {
      await pumpWithToggle(tester, terms: 'palette');

      final double toggleX = tester.getCenter(toggleButton()).dx;
      final double clearX = tester
          .getCenter(find.byType(TomFieldClearWidget).first)
          .dx;

      expect(clearX - toggleX, closeTo(30, 1));
    });
  });

  testWidgets('the second box is not there until it is asked for', (
    WidgetTester tester,
  ) async {
    // Replacing is the rarer half, and a box nobody uses is a box in the way
    // of the results (`docs/product/search/replacing/doc.md`).
    await pumpColumn(tester, terms: 'palette');

    expect(find.text('Replace with'), findsNothing);

    await openReplace(tester);

    expect(find.text('Replace with'), findsOneWidget);
  });

  testWidgets('no chevron: both boxes span the column, eight in each side', (
    WidgetTester tester,
  ) async {
    // The `Explorer` master's field, 14..254 in an island at 6, and the
    // second box straight under it on the same edges.
    await pumpColumn(tester, terms: 'palette');
    await openReplace(tester);

    expect(
      find.descendant(
        of: find.byType(SearchBoxes),
        matching: find.byType(TomChevronWidget),
      ),
      findsNothing,
    );
    final Rect search = tester.getRect(
      find.descendant(
        of: find.byType(SearchFieldWidget),
        matching: find.byType(TomFieldBoxWidget),
      ),
    );
    final Rect replace = tester.getRect(
      find.ancestor(
        of: find.text('Replace with'),
        matching: find.byType(TomFieldBoxWidget),
      ),
    );
    expect(search.left, 8);
    expect(search.width, TomMetrics.explorer - 16);
    expect(replace.left, search.left);
    expect(replace.width, search.width);
    expect(replace.top, search.bottom + SearchDesign.boxGap);
  });

  testWidgets('an occurrence is its heading and the line it sits in', (
    WidgetTester tester,
  ) async {
    documents.content = '# Visual language\n\nValues live in palette.py.\n';

    await pumpColumn(tester, terms: 'palette');

    expect(find.text('1 occurrence in note.md'), findsOneWidget);
    expect(find.text('Visual language'), findsOneWidget);
  });

  testWidgets('pressing an occurrence goes to it: the selection is the match', (
    WidgetTester tester,
  ) async {
    // `docs/product/search/in-the-document/doc.md`.
    documents.content = '# Visual language\n\nValues live in palette.py.\n';
    await pumpColumn(tester, terms: 'palette');
    final OccurrenceValueObject found = ready().occurrences.single;

    await tester.tap(find.text('Visual language'));
    await tester.pumpAndSettle();

    final EditorReady editor = container.read(editorProvider) as EditorReady;
    expect(editor.selectionStart, found.start);
    expect(editor.selectionEnd, found.end);
    expect(editor.reveals, 1);
    expect(
      editor.source.substring(editor.selectionStart, editor.selectionEnd),
      'palette',
    );
  });

  testWidgets('This file with an empty box says to type, not the tree', (
    WidgetTester tester,
  ) async {
    // The third sentence of `docs/product/search/in-the-document/doc.md`.
    documents.content = '# Visual language\n\nValues live in palette.py.\n';
    await pumpColumn(tester);

    expect(find.text('Type to search this document.'), findsOneWidget);
    expect(find.text('note.md'), findsNothing);
  });

  testWidgets('with nothing to replace with, the count stands alone', (
    WidgetTester tester,
  ) async {
    // `Replace all` belongs beside the count, and only once there is a
    // replacement to make.
    documents.content = 'a palette here\n';

    await pumpColumn(tester, terms: 'palette');

    expect(find.text('Replace all'), findsNothing);

    await openReplace(tester);

    expect(find.text('Replace all'), findsOneWidget);
  });

  testWidgets('the row carries the two actions, and only the current one', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette and a palette\n';
    await pumpColumn(tester, terms: 'palette');

    await openReplace(tester);

    expect(ready().occurrences.length, 2);
    expect(find.byTooltip('Replace this one'), findsOneWidget);
    expect(find.byTooltip('Skip this one'), findsOneWidget);
  });

  testWidgets('skipping one takes it off the list without writing', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette and a palette\n';
    await pumpColumn(tester, terms: 'palette');
    await openReplace(tester);

    await tester.tap(find.byTooltip('Skip this one'));
    await tester.pumpAndSettle();

    expect(ready().occurrences.length, 1);
    expect(documents.written, isEmpty);
  });

  testWidgets('and replacing one writes it into the buffer', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette here\n';
    await pumpColumn(tester, terms: 'palette');
    await openReplace(tester);
    container.read(searchProvider.notifier).replaceWith('swatch');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Replace this one'));
    await tester.pumpAndSettle();

    expect(
      (container.read(editorProvider) as EditorReady).source,
      'a swatch here\n',
    );
    expect(documents.written, isEmpty, reason: 'the buffer, never the disk');
  });
}

/// A space with nothing in it; these tests are about the column.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );
}

/// An index that answers nothing; the whole-space half has its own test.
SearchRepository _emptyIndex(SpaceEntity space) => const _NoIndex();

final class _NoIndex implements SearchRepository {
  const _NoIndex();

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async => const Success<void, SearchFailure>(null);

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async =>
      const Success<void, SearchFailure>(null);

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async => const Success<List<SearchHitValueObject>, SearchFailure>(
    <SearchHitValueObject>[],
  );
}

/// The one document these tests open, and what was written to it.
final class _Documents implements DocumentRepository {
  String content = 'a palette here\n';
  final List<String> written = <String>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document.content);
    return const Success<void, DocumentFailure>(null);
  }
}

/// Observability that records nothing.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
