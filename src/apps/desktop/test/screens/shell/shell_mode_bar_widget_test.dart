import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_bar_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late _Preferences preferences;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  setUp(() {
    documents = _Documents();
    preferences = _Preferences();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: preferences,
            observability: const _Silent(),
          ),
        ),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        // The modes ask the editor whether its buffer is binary, which
        // makes it read the preferences file once that is on screen.
        readPreferencesFileProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts [chrome] with [document] open when one is given.
  Future<void> pump(
    WidgetTester tester,
    Widget chrome, {
    SpaceRelativePathValueObject? document,
  }) async {
    container.read(spaceSessionProvider.notifier).open(docs);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(body: chrome),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The row above the document.
  Future<void> pumpBar(
    WidgetTester tester, {
    SpaceRelativePathValueObject? document,
  }) => pump(tester, const ShellModeBarWidget(), document: document);

  /// The modes, which the top bar carries
  /// (`docs/product/workspace/columns/doc.md`).
  Future<void> pumpModes(WidgetTester tester) =>
      pump(tester, const ShellModeControlWidget());

  testWidgets('it offers the three modes and no fourth', (
    WidgetTester tester,
  ) async {
    // No WYSIWYG (Decision 3).
    await pumpModes(tester);

    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Split'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
  });

  testWidgets('a space opens in split', (WidgetTester tester) async {
    await pumpModes(tester);

    expect(container.read(spaceSessionProvider)?.mode, DocumentModeEnum.split);
  });

  testWidgets('the row above the document carries no mode', (
    WidgetTester tester,
  ) async {
    // The modes are a choice about the window, so they sit with the
    // window's own controls in the top bar.
    await pumpBar(tester);

    expect(find.text('Source'), findsNothing);
    expect(find.text('Preview'), findsNothing);
  });

  testWidgets('choosing a mode writes it to the session', (
    WidgetTester tester,
  ) async {
    // The control names no panel; which panels a mode includes is the
    // descriptor's answer.
    await pumpModes(tester);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(
      container.read(spaceSessionProvider)?.mode,
      DocumentModeEnum.preview,
    );
  });

  testWidgets('the preferences file is source, and the other two are off', (
    WidgetTester tester,
  ) async {
    // Not markdown to render (`preferences/where-it-is-stored/doc.md`).
    await pumpModes(tester);
    container
        .read(spaceSessionProvider.notifier)
        .openPreferencesFile(SpaceRelativePathValueObject('preferences.json'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Source')).style?.color,
      TomColors.light.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Preview')).style?.color,
      TomColors.light.textMuted,
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(container.read(spaceSessionProvider)?.mode, DocumentModeEnum.split);
    expect(
      container.read(spaceSessionProvider)?.drawnMode,
      DocumentModeEnum.source,
    );
  });

  group('the unsaved mark', () {
    testWidgets('is absent while the buffer and the file agree', (
      WidgetTester tester,
    ) async {
      await pumpBar(tester, document: writing);

      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('appears the moment something is typed', (
      WidgetTester tester,
    ) async {
      await pumpBar(tester, document: writing);

      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      expect(find.text('Unsaved'), findsOneWidget);
    });

    testWidgets('goes once the write lands', (WidgetTester tester) async {
      await pumpBar(tester, document: writing);
      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      await container.read(editorProvider.notifier).save();
      await tester.pumpAndSettle();

      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('a refused save says so in different words', (
      WidgetTester tester,
    ) async {
      // A refused save is different news: the buffer holds work the file
      // does not.
      documents.refusal = Failure<void, DocumentFailure>(
        DocumentPermissionDenied(writing.value),
      );
      await pumpBar(tester, document: writing);
      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      await container.read(editorProvider.notifier).save();
      await tester.pumpAndSettle();

      expect(find.text('Not saved'), findsOneWidget);
      expect(find.text('Unsaved'), findsNothing);
    });
  });
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  Result<void, DocumentFailure>? refusal;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: '# ${path.name}\n'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      refusal ?? const Success<void, DocumentFailure>(null);
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

/// Preferences in memory, so a widget test needs no disk.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}
