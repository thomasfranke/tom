import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('the name an export is offered under', () {
    test("is the document's, with the format's extension in place of its "
        'own', () {
      expect(ExportFormatEnum.pdf.fileNameFor('intro.md'), 'intro.pdf');
      expect(ExportFormatEnum.html.fileNameFor('intro.markdown'), 'intro.html');
    });

    test('keeps every dot but the last', () {
      expect(
        ExportFormatEnum.pdf.fileNameFor('release.2.0.md'),
        'release.2.0.pdf',
      );
    });

    test('gains the extension when the name has none', () {
      expect(ExportFormatEnum.html.fileNameFor('README'), 'README.html');
    });

    test('treats a leading dot as part of the name, not an extension', () {
      expect(ExportFormatEnum.pdf.fileNameFor('.notes'), '.notes.pdf');
    });
  });
}
