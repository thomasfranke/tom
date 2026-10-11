/// [ExportRepositoryImpl] where an export can cost a file: a destination
/// that already holds one, a render that fails, a folder the disk will not
/// write to — and which images it will read — over the real parser, both
/// real exporters and a real disk.
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
  late String base;
  late String exports;
  late SpaceEntity space;

  const ExportRepositoryImpl repository = ExportRepositoryImpl(
    source: ExportDataSource(
      exporters: <ExporterFormatEnum, DocumentExporter>{
        ExporterFormatEnum.html: MarkdownHtmlDocumentExporterImpl(),
        ExporterFormatEnum.pdf: PdfWidgetsDocumentExporterImpl(),
      },
      filesystem: DartIoFilesystemImpl(),
    ),
  );

  /// [markdown] as the preview would hold it, read by the real parser.
  Future<ParsedDocumentValueObject> parsed(
    String markdown, {
    String at = 'notes/release.md',
  }) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> read =
        await const MarkdownBlockReaderImpl(
          markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
        ).read(
          DocumentEntity(
            path: SpaceRelativePathValueObject(at),
            content: markdown,
          ),
        );
    return (read as Success<ParsedDocumentValueObject, DocumentFailure>).value;
  }

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  List<String> namesIn(String folder) => <String>[
    for (final FileSystemEntity entity in Directory(folder).listSync())
      entity.uri.pathSegments.lastWhere((String s) => s.isNotEmpty),
  ]..sort();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_export_destinations_');
    base = tempDir.resolveSymbolicLinksSync();
    // The space and the folder exports land in are neighbours, as on a
    // machine: a document is exported out of its space.
    exports = '$base/exports';
    Directory(exports).createSync();
    Directory('$base/space/notes/img').createSync(recursive: true);
    space = SpaceEntity(
      root: '$base/space',
      repositoryRoot: '$base/space',
      name: 'space',
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  const String posixOnly = 'permissions are POSIX here';

  group('a destination that already holds a file', () {
    for (final ExportFormatEnum format in ExportFormatEnum.values) {
      test('${format.name}: the file is replaced whole, and nothing is left '
          'beside it', () async {
        final String path = '$exports/release.${format.name}';
        // Longer than what replaces it, so a write in place would show.
        File(path).writeAsStringSync('old export ' * 20000);

        final Result<void, ExportFailure> result = await repository.export(
          space,
          await parsed('# New\n\nOnly this.\n'),
          format,
          path,
        );

        expect(result, isA<Success<void, ExportFailure>>());
        final String written = latin1.decode(File(path).readAsBytesSync());
        expect(written, isNot(contains('old export')));
        expect(
          written,
          startsWith(format == ExportFormatEnum.pdf ? '%PDF-' : '<!'),
        );
        expect(namesIn(exports), <String>['release.${format.name}']);
      });
    }

    test('a render that fails leaves the file that was there, byte for '
        'byte', () async {
      final String path = '$exports/release.pdf';
      File(path).writeAsStringSync('the export from yesterday');
      // A table row taller than a page, which the PDF engine cannot place.
      final String cell = List<String>.filled(6000, 'word').join(' ');

      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed('| a |\n|---|\n| $cell |\n'),
        ExportFormatEnum.pdf,
        path,
      );

      expect(
        failureOf(result),
        isA<ExportTooLarge>()
            .having(
              (ExportTooLarge f) => f.format,
              'format',
              ExportFormatEnum.pdf,
            )
            .having(
              (ExportTooLarge f) => f.cause,
              'cause',
              isA<DocumentExporterTooLarge>(),
            ),
      );
      expect(File(path).readAsStringSync(), 'the export from yesterday');
      expect(namesIn(exports), <String>['release.pdf']);
    });

    test(
      'and a render that fails where there was no file makes none',
      () async {
        final String cell = List<String>.filled(6000, 'word').join(' ');

        final Result<void, ExportFailure> result = await repository.export(
          space,
          await parsed('| a |\n|---|\n| $cell |\n'),
          ExportFormatEnum.pdf,
          '$exports/release.pdf',
        );

        expect(failureOf(result), isA<ExportTooLarge>());
        expect(namesIn(exports), isEmpty);
      },
    );

    test('the same document as HTML still exports: the limit is the '
        "page's", () async {
      final String cell = List<String>.filled(6000, 'word').join(' ');

      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed('| a |\n|---|\n| $cell |\n'),
        ExportFormatEnum.html,
        '$exports/release.html',
      );

      expect(result, isA<Success<void, ExportFailure>>());
      expect(File('$exports/release.html').lengthSync(), greaterThan(30000));
    });
  });

  group('a destination the disk refuses', () {
    test('a folder that cannot be written to keeps the export it had, and no '
        'temporary beside it', () async {
      final String path = '$exports/release.html';
      File(path).writeAsStringSync('the export from yesterday');
      Process.runSync('chmod', <String>['555', exports]);
      addTearDown(() => Process.runSync('chmod', <String>['755', exports]));

      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed('# New\n'),
        ExportFormatEnum.html,
        path,
      );

      expect(
        failureOf(result),
        isA<ExportCannotWrite>()
            .having((ExportCannotWrite f) => f.destination, 'destination', path)
            .having(
              (ExportCannotWrite f) => f.cause,
              'cause',
              isA<FilesystemAccessDenied>(),
            ),
      );
      expect(File(path).readAsStringSync(), 'the export from yesterday');
      expect(namesIn(exports), <String>['release.html']);
    }, skip: Platform.isWindows ? posixOnly : false);

    test(
      'a destination under a file names the destination asked for',
      () async {
        File('$exports/taken').writeAsStringSync('a file, not a folder');
        final String path = '$exports/taken/release.html';

        final Result<void, ExportFailure> result = await repository.export(
          space,
          await parsed('# New\n'),
          ExportFormatEnum.html,
          path,
        );

        expect(
          failureOf(result),
          isA<ExportCannotWrite>().having(
            (ExportCannotWrite f) => f.destination,
            'destination',
            path,
          ),
        );
        expect(
          File('$exports/taken').readAsStringSync(),
          'a file, not a folder',
        );
      },
    );
  });

  group('a destination a person would really choose', () {
    test('a folder that is not there yet is made on the way', () async {
      final String path = '$exports/2026/q3/release.html';

      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed('# New\n'),
        ExportFormatEnum.html,
        path,
      );

      expect(result, isA<Success<void, ExportFailure>>());
      expect(File(path).existsSync(), isTrue);
    });

    for (final String name in <String>[
      'Release notes — final.pdf',
      'Ação e revisão.pdf',
      '-draft.pdf',
    ]) {
      test('`$name` lands under that name, as a PDF', () async {
        final String path = '$exports/My Documents/$name';

        final Result<void, ExportFailure> result = await repository.export(
          space,
          await parsed('# Título\n\nAção.\n'),
          ExportFormatEnum.pdf,
          path,
        );

        expect(result, isA<Success<void, ExportFailure>>());
        final List<int> bytes = File(path).readAsBytesSync();
        expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
        expect(latin1.decode(bytes).trimRight(), endsWith('%%EOF'));
      });
    }
  });

  group('a format nobody writes', () {
    test('is unsupported, and makes no file', () async {
      const ExportRepositoryImpl htmlOnly = ExportRepositoryImpl(
        source: ExportDataSource(
          exporters: <ExporterFormatEnum, DocumentExporter>{
            ExporterFormatEnum.html: MarkdownHtmlDocumentExporterImpl(),
          },
          filesystem: DartIoFilesystemImpl(),
        ),
      );

      final Result<void, ExportFailure> result = await htmlOnly.export(
        space,
        await parsed('# New\n'),
        ExportFormatEnum.pdf,
        '$exports/release.pdf',
      );

      expect(
        failureOf(result),
        isA<ExportUnsupported>().having(
          (ExportUnsupported f) => f.format,
          'format',
          ExportFormatEnum.pdf,
        ),
      );
      expect(namesIn(exports), isEmpty);
    });

    test('an exporter handed the other format says so itself, and makes no '
        'file', () async {
      // Wired the wrong way round, which only the real exporters can refuse.
      const ExportRepositoryImpl crossed = ExportRepositoryImpl(
        source: ExportDataSource(
          exporters: <ExporterFormatEnum, DocumentExporter>{
            ExporterFormatEnum.html: PdfWidgetsDocumentExporterImpl(),
            ExporterFormatEnum.pdf: MarkdownHtmlDocumentExporterImpl(),
          },
          filesystem: DartIoFilesystemImpl(),
        ),
      );

      for (final ExportFormatEnum format in ExportFormatEnum.values) {
        expect(
          failureOf(
            await crossed.export(
              space,
              await parsed('# New\n'),
              format,
              '$exports/release.${format.name}',
            ),
          ),
          isA<ExportUnsupported>().having(
            (ExportUnsupported f) => f.cause,
            'cause',
            isA<DocumentExporterUnsupported>(),
          ),
          reason: format.name,
        );
      }
      expect(namesIn(exports), isEmpty);
    });
  });

  group('which images are read', () {
    late List<int> png;

    Future<String> html(String markdown) async {
      final String path = '$exports/release.html';
      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed(markdown),
        ExportFormatEnum.html,
        path,
      );
      expect(result, isA<Success<void, ExportFailure>>());
      return File(path).readAsStringSync();
    }

    setUp(() {
      // Read by path; the tests run from the package's own folder.
      png = File('../infra/test/fixtures/images/wide.png').readAsBytesSync();
    });

    test('one whose name is percent-encoded in the document is found by '
        'its real name', () async {
      File('$base/space/notes/img/my figure.png').writeAsBytesSync(png);

      expect(
        await html('![Chart](img/my%20figure.png)\n'),
        contains('src="data:image/png;base64,${base64.encode(png)}"'),
      );
    });

    test('one a folder up, still inside the space, is found', () async {
      File('$base/space/shared.png').writeAsBytesSync(png);

      expect(
        await html('![Chart](../shared.png)\n'),
        contains('src="data:image/png;base64,'),
      );
    });

    test('one outside the space is not read, though it is there', () async {
      File('$base/secret.png').writeAsBytesSync(png);

      final String page = await html('![Chart](../../secret.png)\n');

      expect(page, isNot(contains('data:image')));
      expect(page, contains('Chart'));
    });

    test(
      'one named by an absolute path is not read from the machine',
      () async {
        File('$base/secret.png').writeAsBytesSync(png);

        final String page = await html('![Chart]($base/secret.png)\n');

        expect(page, isNot(contains(base64.encode(png).substring(0, 64))));
      },
    );

    test('one on the network is left as its address, and nothing is '
        'fetched', () async {
      final String page = await html(
        '![Chart](https://example.invalid/chart.png)\n',
      );

      expect(page, isNot(contains('data:image')));
      expect(page, contains('https://example.invalid/chart.png'));
    });

    test('a file that is not an image does not stop the PDF', () async {
      File('$base/space/notes/img/broken.png').writeAsStringSync('not a png');
      final String path = '$exports/release.pdf';

      final Result<void, ExportFailure> result = await repository.export(
        space,
        await parsed('# Title\n\n![The chart](img/broken.png)\n'),
        ExportFormatEnum.pdf,
        path,
      );

      expect(result, isA<Success<void, ExportFailure>>());
      expect(
        latin1.decode(File(path).readAsBytesSync()),
        isNot(matches(RegExp(r'/Subtype\s*/Image'))),
      );
    });

    test(
      'a folder where the image should be does not stop the export',
      () async {
        Directory('$base/space/notes/img/folder.png').createSync();

        expect(await html('![Chart](img/folder.png)\n'), contains('Chart'));
      },
    );
  });

  group('an empty document', () {
    for (final ExportFormatEnum format in ExportFormatEnum.values) {
      test('exports as ${format.name}, a file with nothing in it to '
          'read', () async {
        final String path = '$exports/empty.${format.name}';

        final Result<void, ExportFailure> result = await repository.export(
          space,
          await parsed('', at: 'empty.md'),
          format,
          path,
        );

        expect(result, isA<Success<void, ExportFailure>>());
        expect(File(path).lengthSync(), greaterThan(0));
      });
    }
  });
}
