import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// macOS for every test: `re_editor` decides once, in a lazy top-level
/// final, which keys it binds, and ⌥⌘F is its replace only there.
final TargetPlatformVariant _mac = TargetPlatformVariant.only(
  TargetPlatform.macOS,
);

void main() {
  late ProviderContainer container;

  setUp(() {
    final _Documents documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: const _Silent(),
          ),
        ),
        readVersionProvider.overrideWithValue(
          ReadVersionUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            observability: const _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            blocks: _Blocks(),
            differ: BlockDifferService(aligner: _Aligner()),
            observability: const _Silent(),
          ),
        ),
        fileTreeProvider.overrideWith(_Tree.new),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('⌥⌘F in the source pane reaches the window, not the package', (
    WidgetTester tester,
  ) async {
    // `re_editor` binds it to a find-and-replace this app has no panel for,
    // and with the keyboard in the pane it would win the race
    // (`docs/product/search/replacing/doc.md`).
    int pressed = 0;
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier)
      ..open(
        SpaceEntity(
          root: '/code/app/docs',
          repositoryRoot: '/code/app',
          name: 'docs',
        ),
      )
      ..show(SpaceRelativePathValueObject('index.md'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(
                  LogicalKeyboardKey.keyF,
                  meta: true,
                  alt: true,
                ): () =>
                    pressed++,
              },
              child: const EditorPanel(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump(PreviewNotifier.settle * 2);

    expect(pressed, 1);
  }, variant: _mac);
}

/// A tree with nothing in it; the pane's offer of names is not the subject.
final class _Tree extends FileTreeNotifier {
  @override
  FileTreeState build() => const FileTreeState.ready(
    entries: <SpaceEntryValueObject>[],
    collapsed: <SpaceRelativePathValueObject>{},
  );
}

/// A reader that splits nothing: one paragraph, whatever it is given.
final class _Blocks implements BlockReaderPort {
  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => Success<ParsedDocumentValueObject, DocumentFailure>(
    ParsedDocumentValueObject(
      document: document,
      blocks: <BlockValueObject>[
        BlockValueObject(
          startLine: 0,
          endLine: 0,
          source: document.content.trimRight(),
          kind: BlockKindEnum.paragraph,
        ),
      ],
      linkDefinitions: '',
    ),
  );
}

/// Git with no earlier version of anything, so no comparison is possible.
final class _Git implements GitRepository {
  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => Failure<String, GitFailure>(GitPathNotInRevision(path.value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An aligner nothing asks, because nothing gets that far here.
final class _Aligner implements BlockAlignerPort {
  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async => const Success<List<SequenceEditValueObject>, DocumentFailure>(
    <SequenceEditValueObject>[],
  );
}

/// One document, a heading and a line.
final class _Documents implements DocumentRepository {
  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: '# Index\n\nA palette here.\n'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
