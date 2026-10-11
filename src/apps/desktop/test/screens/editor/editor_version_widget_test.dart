import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_version_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  testWidgets('a version is shown as source, read-only, and follows another', (
    WidgetTester tester,
  ) async {
    // `docs/product/git-workflow/file-history/doc.md`.
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[previewProvider.overrideWith(_Preview.new)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: EditorVersionWidget()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    CodeEditor editor() => tester.widget<CodeEditor>(find.byType(CodeEditor));
    expect(editor().readOnly, isTrue);
    expect(
      editor().controller!.text,
      '# Index\n\nas the first commit wrote it\n',
    );

    (container.read(previewProvider.notifier) as _Preview).show(
      '# Index\n\nsecond\n',
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(editor().controller!.text, '# Index\n\nsecond\n');
  });
}

DocumentEntity _document(String content) => DocumentEntity(
  path: SpaceRelativePathValueObject('index.md'),
  content: content,
);

final class _Preview extends PreviewNotifier {
  @override
  PreviewState build() => PreviewState.ready(
    ParsedDocumentValueObject(
      document: _document('# Index\n\nas the first commit wrote it\n'),
      blocks: const <BlockValueObject>[],
      linkDefinitions: '',
    ),
  );

  void show(String content) => state = PreviewState.ready(
    ParsedDocumentValueObject(
      document: _document(content),
      blocks: const <BlockValueObject>[],
      linkDefinitions: '',
    ),
  );
}
