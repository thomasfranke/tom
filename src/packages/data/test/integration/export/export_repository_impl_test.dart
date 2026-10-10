/// [ExportRepositoryImpl] over the real parser, both real exporters and a
/// real disk: markdown in, a file in a temporary folder out.
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late ExportRepositoryImpl repository;
  late SpaceEntity space;

  const String markdown = '''
# Release notes

The **diff** is [rendered][guide].[^why]

- one
- two

```dart
final int answer = 42;
```

[guide]: https://example.com/guide
[^why]: Because a reader reads prose, not lines.
''';

  Future<ParsedDocumentValueObject> parsed() async {
    final Result<ParsedDocumentValueObject, DocumentFailure> read =
        await const MarkdownBlockReaderImpl(
          markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
        ).read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('notes/release.md'),
            content: markdown,
          ),
        );
    return (read as Success<ParsedDocumentValueObject, DocumentFailure>).value;
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_export_test_');
    space = SpaceEntity(
      root: tempDir.path,
      repositoryRoot: tempDir.path,
      name: 'space',
    );
    repository = const ExportRepositoryImpl(
      source: ExportDataSource(
        exporters: <ExporterFormatEnum, DocumentExporter>{
          ExporterFormatEnum.html: MarkdownHtmlDocumentExporterImpl(),
          ExporterFormatEnum.pdf: PdfWidgetsDocumentExporterImpl(),
        },
        filesystem: DartIoFilesystemImpl(),
      ),
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test(
    'an HTML export is the preview\'s reading of the document, on disk',
    () async {
      final ParsedDocumentValueObject document = await parsed();
      final String path =
          '${tempDir.path}/${ExportFormatEnum.html.fileNameFor(document.document.name)}';

      final Result<void, ExportFailure> result = await repository.export(
        space,
        document,
        ExportFormatEnum.html,
        path,
      );

      expect(result, isA<Success<void, ExportFailure>>());
      expect(path, endsWith('release.html'));
      final String html = File(path).readAsStringSync();
      expect(html, contains('<title>release</title>'));
      expect(html, contains('<h1 id="release-notes">Release notes</h1>'));
      expect(
        html,
        contains(
          '<a href="https://example.com/guide">rendered</a>.<sup>1</sup>',
        ),
      );
      expect(html, contains('<li>two</li>'));
      expect(html, contains('final int answer = 42;'));
      expect(html, contains('Because a reader reads prose, not lines.'));
      // The definitions are scope, not content: the parse gives them no block.
      expect(html, isNot(contains('[guide]:')));
    },
  );

  test('a PDF export lands on disk as a PDF', () async {
    final String path = '${tempDir.path}/release.pdf';

    final Result<void, ExportFailure> result = await repository.export(
      space,
      await parsed(),
      ExportFormatEnum.pdf,
      path,
    );

    expect(result, isA<Success<void, ExportFailure>>());
    final List<int> bytes = File(path).readAsBytesSync();
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(latin1.decode(bytes), contains('https://example.com/guide'));
  });

  group('an image the document names', () {
    // The space is a folder of its own beside the exports, as on a machine.
    late SpaceEntity withFigure;
    late ParsedDocumentValueObject figure;

    setUp(() async {
      final String root = '${tempDir.path}/space';
      Directory('$root/notes/img').createSync(recursive: true);
      // Read by path; the tests run from the package's own folder.
      File(
        '../infra/test/fixtures/images/wide.png',
      ).copySync('$root/notes/img/wide.png');
      withFigure = SpaceEntity(root: root, repositoryRoot: root, name: 'space');
      final Result<ParsedDocumentValueObject, DocumentFailure> read =
          await const MarkdownBlockReaderImpl(
            markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
          ).read(
            DocumentEntity(
              path: SpaceRelativePathValueObject('notes/release.md'),
              content: '# Release\n\n![The chart](img/wide.png)\n',
            ),
          );
      figure =
          (read as Success<ParsedDocumentValueObject, DocumentFailure>).value;
    });

    test('is read from beside the document and embedded in the PDF', () async {
      final String path = '${tempDir.path}/release.pdf';

      await repository.export(withFigure, figure, ExportFormatEnum.pdf, path);

      final String pdf = latin1.decode(File(path).readAsBytesSync());
      expect(pdf, matches(RegExp(r'/Subtype\s*/Image')));
    });

    test('travels inside the HTML, since the file lands outside the '
        'space', () async {
      final String path = '${tempDir.path}/release.html';

      await repository.export(withFigure, figure, ExportFormatEnum.html, path);

      final String html = File(path).readAsStringSync();
      expect(html, contains('src="data:image/png;base64,'));
      expect(html, contains('alt="The chart"'));
    });

    test('that is gone leaves its words in the PDF, and the export '
        'whole', () async {
      File('${withFigure.root}/notes/img/wide.png').deleteSync();
      final String path = '${tempDir.path}/release.pdf';

      final Result<void, ExportFailure> result = await repository.export(
        withFigure,
        figure,
        ExportFormatEnum.pdf,
        path,
      );

      expect(result, isA<Success<void, ExportFailure>>());
      final String pdf = latin1.decode(File(path).readAsBytesSync());
      expect(pdf, isNot(matches(RegExp(r'/Subtype\s*/Image'))));
    });
  });

  test('a destination the disk will not take cannot be written, and the '
      'folder there is left alone', () async {
    final String path = '${tempDir.path}/taken';
    Directory(path).createSync();

    final Result<void, ExportFailure> result = await repository.export(
      space,
      await parsed(),
      ExportFormatEnum.html,
      path,
    );

    expect(
      (result as Failure<void, ExportFailure>).failure,
      isA<ExportCannotWrite>()
          .having((ExportCannotWrite f) => f.destination, 'destination', path)
          .having((ExportCannotWrite f) => f.cause, 'cause', isNotNull),
    );
    expect(Directory(path).existsSync(), isTrue);
  });
}
