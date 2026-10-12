import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('the kind is read off the last extension, whatever its case', () {
    expect(FileKindEnum.of('docs/guide.md'), FileKindEnum.markdown);
    expect(FileKindEnum.of('README.MD'), FileKindEnum.markdown);
    expect(FileKindEnum.of('.github/workflows/ci.yml'), FileKindEnum.yaml);
    expect(FileKindEnum.of('config/site.yaml'), FileKindEnum.yaml);
    expect(FileKindEnum.of('package.json'), FileKindEnum.json);
    expect(FileKindEnum.of('archive.tar.json'), FileKindEnum.json);
  });

  test('no extension, an unknown one, or a dotfile is plain text', () {
    expect(FileKindEnum.of('LICENSE'), FileKindEnum.plainText);
    expect(FileKindEnum.of('notes.txt'), FileKindEnum.plainText);
    expect(FileKindEnum.of('.gitignore'), FileKindEnum.plainText);
  });

  test('only markdown is the kind the preview renders', () {
    expect(
      FileKindEnum.values.where((FileKindEnum kind) => kind.isMarkdown),
      <FileKindEnum>[FileKindEnum.markdown],
    );
  });
}
