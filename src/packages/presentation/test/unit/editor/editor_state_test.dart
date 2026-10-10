import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  final DocumentEntity saved = DocumentEntity(
    path: SpaceRelativePathValueObject('guides/writing.md'),
    content: '# Title\n\nBody\n',
  );

  EditorState at(int offset) => EditorState.ready(
    saved: saved,
    source: saved.content,
    selectionStart: offset,
    selectionEnd: offset,
  );

  group('the caret', () {
    test('is line 1, column 1 at the very start', () {
      expect(at(0).caret, (line: 1, column: 1));
    });

    test('counts columns from one inside the first line', () {
      expect(at(3).caret, (line: 1, column: 4));
    });

    test('is column 1 right after a line break', () {
      expect(at(9).caret, (line: 3, column: 1));
    });

    test('is read at the end of the selection', () {
      final EditorState selecting = EditorState.ready(
        saved: saved,
        source: saved.content,
        selectionEnd: 13,
      );

      expect(selecting.caret, (line: 3, column: 5));
    });

    test('is nothing with no buffer', () {
      expect(const EditorState.empty().caret, isNull);
    });
  });

  group('what the buffer is', () {
    EditorState of(
      String path, {
      bool isDeleted = false,
      bool isBinary = false,
    }) => EditorState.ready(
      saved: DocumentEntity(
        path: SpaceRelativePathValueObject(path),
        content: '',
      ),
      source: '',
      isDeleted: isDeleted,
      isBinary: isBinary,
    );

    test('its kind is read off its extension', () {
      expect(of('site.yaml').kind, FileKindEnum.yaml);
      expect(of('guide.md').kind, FileKindEnum.markdown);
      expect(const EditorState.empty().kind, isNull);
    });

    test(
      'the preferences file is JSON and a draft markdown, wherever kept',
      () {
        final DocumentEntity file = DocumentEntity(
          path: SpaceRelativePathValueObject('feat.x'),
          content: '',
        );
        expect(
          EditorState.ready(saved: file, source: '', isPreferences: true).kind,
          FileKindEnum.json,
        );
        expect(
          EditorState.ready(saved: file, source: '', isDraft: true).kind,
          FileKindEnum.markdown,
        );
      },
    );

    test('only markdown that is text is rendered', () {
      expect(of('guide.md').isRendered, isTrue);
      expect(of('guide.md', isDeleted: true).isRendered, isTrue);
      expect(of('site.yaml').isRendered, isFalse);
      expect(of('odd.md', isBinary: true).isRendered, isFalse);
    });

    test('a deleted or binary file is read-only, and only those', () {
      expect(of('site.yaml').isReadOnly, isFalse);
      expect(of('site.yaml', isDeleted: true).isReadOnly, isTrue);
      expect(of('logo.png', isBinary: true).isReadOnly, isTrue);
      expect(const EditorState.empty().isReadOnly, isFalse);
    });

    test('the preferences file is held under a tab of its own', () {
      final DocumentEntity file = DocumentEntity(
        path: SpaceRelativePathValueObject('preferences.json'),
        content: '',
      );
      expect(
        EditorState.ready(saved: file, source: '', isPreferences: true).tab,
        DocumentTab.preferences(file.path),
      );
      expect(
        EditorState.ready(saved: file, source: '').tab,
        DocumentTab.inSpace(file.path),
      );
    });
  });
}
