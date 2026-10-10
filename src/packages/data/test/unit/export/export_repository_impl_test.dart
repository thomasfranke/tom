/// [ExportRepositoryImpl] over exporters and a disk that answer on command,
/// because a real engine cannot be made to break on demand.
library;

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Exporter exporter;
  late _Filesystem filesystem;
  late ExportRepositoryImpl repository;

  final SpaceEntity space = SpaceEntity(
    root: '/code/docs',
    repositoryRoot: '/code',
    name: 'docs',
  );
  final ParsedDocumentValueObject parsed = ParsedDocumentValueObject(
    document: DocumentEntity(
      path: SpaceRelativePathValueObject('guide/intro.md'),
      content: '# Intro\n\nA claim.[^a]\n\n[^a]: The note.',
    ),
    blocks: const <BlockValueObject>[
      BlockValueObject(
        startLine: 0,
        endLine: 0,
        source: '# Intro',
        kind: BlockKindEnum.heading,
      ),
      BlockValueObject(
        startLine: 2,
        endLine: 2,
        source: 'A claim.[^a]',
        kind: BlockKindEnum.paragraph,
      ),
    ],
    linkDefinitions: '[guide]: https://example.com',
    footnotes: const <FootnoteValueObject>[
      FootnoteValueObject(label: 'a', number: 1, text: 'The note.'),
    ],
  );

  setUp(() {
    exporter = _Exporter();
    filesystem = _Filesystem();
    repository = ExportRepositoryImpl(
      source: ExportDataSource(
        exporters: <ExporterFormatEnum, DocumentExporter>{
          ExporterFormatEnum.pdf: exporter,
        },
        filesystem: filesystem,
      ),
    );
  });

  test('the exporter is handed the blocks the preview draws, titled by the '
      'name without its extension', () async {
    await repository.export(
      space,
      parsed,
      ExportFormatEnum.pdf,
      '/out/intro.pdf',
    );

    expect(exporter.asked, ExporterFormatEnum.pdf);
    expect(
      exporter.handed,
      const ExporterDocumentDto(
        title: 'intro',
        blocks: <ExporterBlockDto>[
          ExporterBlockDto(
            source: '# Intro',
            kind: ExporterBlockKindEnum.heading,
          ),
          ExporterBlockDto(
            source: 'A claim.[^a]',
            kind: ExporterBlockKindEnum.paragraph,
          ),
        ],
        linkDefinitions: '[guide]: https://example.com',
        footnotes: <ExporterFootnoteDto>[
          ExporterFootnoteDto(label: 'a', number: 1, text: 'The note.'),
        ],
      ),
    );
  });

  test(
    'the bytes the exporter wrote are the ones put at the destination',
    () async {
      final Result<void, ExportFailure> result = await repository.export(
        space,
        parsed,
        ExportFormatEnum.pdf,
        '/out/intro.pdf',
      );

      expect(result, isA<Success<void, ExportFailure>>());
      expect(filesystem.written, <String, List<int>>{
        '/out/intro.pdf': <int>[1, 2, 3],
      });
    },
  );

  test(
    'a format nobody writes is unsupported, and nothing is written',
    () async {
      final Result<void, ExportFailure> result = await repository.export(
        space,
        parsed,
        ExportFormatEnum.html,
        '/out/intro.html',
      );

      expect(
        (result as Failure<void, ExportFailure>).failure,
        isA<ExportUnsupported>().having(
          (ExportUnsupported failure) => failure.format,
          'format',
          ExportFormatEnum.html,
        ),
      );
      expect(filesystem.written, isEmpty);
    },
  );

  group("the exporter's failures, in the product's words", () {
    Future<ExportFailure> failureFor(DocumentExporterFailure failure) async {
      exporter.answer = Failure<Uint8List, DocumentExporterFailure>(failure);
      final Result<void, ExportFailure> result = await repository.export(
        space,
        parsed,
        ExportFormatEnum.pdf,
        '/out/intro.pdf',
      );
      expect(filesystem.written, isEmpty);
      return (result as Failure<void, ExportFailure>).failure;
    }

    test('an engine that broke cannot write the file', () async {
      const DocumentExporterFailure broke = DocumentExporterWriteFailed('x');
      expect(
        await failureFor(broke),
        const ExportCannotWrite('/out/intro.pdf', cause: broke),
      );
    });

    test('a block too large for a page is too large', () async {
      const DocumentExporterFailure large = DocumentExporterTooLarge('x');
      expect(
        await failureFor(large),
        const ExportTooLarge(ExportFormatEnum.pdf, cause: large),
      );
    });

    test('an exporter refusing the format is unsupported', () async {
      const DocumentExporterFailure refused = DocumentExporterUnsupported(
        ExporterFormatEnum.pdf,
      );
      expect(
        await failureFor(refused),
        const ExportUnsupported(ExportFormatEnum.pdf, cause: refused),
      );
    });
  });

  group('an image is read as the preview reads it', () {
    Future<Uint8List?> imageAt(String reference) async {
      await repository.export(
        space,
        parsed,
        ExportFormatEnum.pdf,
        '/out/intro.pdf',
      );
      return exporter.readImage?.call(reference);
    }

    test('from the document\'s own folder', () async {
      filesystem.files['/code/docs/guide/img/a.png'] = <int>[1, 2];

      expect(await imageAt('img/a.png'), <int>[1, 2]);
    });

    test('one folder up, or from the space\'s root after a slash, and with '
        'its spaces written as the link wrote them', () async {
      filesystem.files['/code/docs/a.png'] = <int>[3];
      filesystem.files['/code/docs/img/my pic.png'] = <int>[4];

      expect(await imageAt('../a.png'), <int>[3]);
      expect(await imageAt('/img/my%20pic.png'), <int>[4]);
    });

    test('nothing outside the space, and nothing off the network, is '
        'asked of the disk', () async {
      expect(await imageAt('../../secret.png'), isNull);
      expect(await imageAt('https://example.com/a.png'), isNull);
      expect(filesystem.read, isEmpty);
    });

    test('a file that is not there is nothing, not a failed export', () async {
      expect(await imageAt('img/gone.png'), isNull);
      expect(filesystem.read, <String>['/code/docs/guide/img/gone.png']);
    });
  });

  test('a disk that refuses the write cannot write the file, and says '
      'why underneath', () async {
    const FilesystemFailure denied = FilesystemAccessDenied('/out/intro.pdf');
    filesystem.failure = denied;

    final Result<void, ExportFailure> result = await repository.export(
      space,
      parsed,
      ExportFormatEnum.pdf,
      '/out/intro.pdf',
    );

    expect(
      (result as Failure<void, ExportFailure>).failure,
      const ExportCannotWrite('/out/intro.pdf', cause: denied),
    );
  });
}

/// An exporter that keeps what it was handed and answers as told.
final class _Exporter implements DocumentExporter {
  Result<Uint8List, DocumentExporterFailure> answer =
      Success<Uint8List, DocumentExporterFailure>(
        Uint8List.fromList(<int>[1, 2, 3]),
      );
  ExporterDocumentDto? handed;
  ExporterFormatEnum? asked;
  ExporterImageReader? readImage;

  @override
  Future<Result<Uint8List, DocumentExporterFailure>> export(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  }) async {
    handed = document;
    asked = format;
    this.readImage = readImage;
    return answer;
  }
}

/// A disk that records the bytes it was given, or refuses them, and holds
/// the files it was told to.
final class _Filesystem implements Filesystem {
  final Map<String, List<int>> written = <String, List<int>>{};
  final Map<String, List<int>> files = <String, List<int>>{};
  final List<String> read = <String>[];
  FilesystemFailure? failure;

  @override
  Future<Result<Uint8List, FilesystemFailure>> readBytes(String path) async {
    read.add(path);
    return switch (files[path]) {
      final List<int> bytes => Success<Uint8List, FilesystemFailure>(
        Uint8List.fromList(bytes),
      ),
      null => Failure<Uint8List, FilesystemFailure>(
        FilesystemEntryNotFound(path),
      ),
    };
  }

  @override
  Future<Result<void, FilesystemFailure>> writeBytes(
    String path,
    Uint8List bytes,
  ) async {
    if (failure case final FilesystemFailure refused) {
      return Failure<void, FilesystemFailure>(refused);
    }
    written[path] = bytes.toList();
    return const Success<void, FilesystemFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
