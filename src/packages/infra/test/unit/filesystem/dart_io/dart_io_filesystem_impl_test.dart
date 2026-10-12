/// [DartIoFilesystemImpl] inside a temporary folder the test makes: no path
/// outside it is read or written. What a permission or a mount does to it is
/// the integration suite's.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory root;
  const DartIoFilesystemImpl filesystem = DartIoFilesystemImpl();

  setUp(() => root = Directory.systemTemp.createTempSync('tom_fs_unit_'));
  tearDown(() => root.deleteSync(recursive: true));

  T ok<T>(Result<T, FilesystemFailure> result) =>
      (result as Success<T, FilesystemFailure>).value;

  FilesystemFailure bad<T>(Result<T, FilesystemFailure> result) =>
      (result as Failure<T, FilesystemFailure>).failure;

  group('reading', () {
    test('a file comes back as text and as bytes', () async {
      File('${root.path}/a.md').writeAsStringSync('olá');

      expect(ok(await filesystem.readFile('${root.path}/a.md')), 'olá');
      expect(
        ok(await filesystem.readBytes('${root.path}/a.md')),
        utf8.encode('olá'),
      );
    });

    test('text that is not UTF-8 is refused rather than decoded', () async {
      File('${root.path}/a.md').writeAsBytesSync(<int>[0x61, 0xff]);

      expect(
        bad(await filesystem.readFile('${root.path}/a.md')),
        isA<FilesystemNotUtf8>(),
      );
      expect(ok(await filesystem.readBytes('${root.path}/a.md')), <int>[
        0x61,
        0xff,
      ]);
    });

    test('a missing file is not found, by its own path', () async {
      final String path = '${root.path}/none.md';

      final FilesystemFailure text = bad(await filesystem.readFile(path));
      final FilesystemFailure bytes = bad(await filesystem.readBytes(path));

      expect(text, isA<FilesystemEntryNotFound>());
      expect((text as FilesystemEntryNotFound).path, path);
      expect(bytes, isA<FilesystemEntryNotFound>());
    });

    test('a folder read as a file is a failure, never a throw', () async {
      expect(
        await filesystem.readBytes(root.path),
        isA<Failure<Uint8List, FilesystemFailure>>(),
      );
    });
  });

  group('writing', () {
    test(
      'a write creates the folders and leaves no temporary behind',
      () async {
        final String path = '${root.path}/deep/er/a.md';

        await filesystem.writeFile(path, 'one');
        await filesystem.writeFile(path, 'two');

        expect(File(path).readAsStringSync(), 'two');
        expect(
          Directory(
            '${root.path}/deep/er',
          ).listSync().map((FileSystemEntity e) => e.path),
          <String>[path],
        );
      },
    );

    test('a link is written through, and stays a link', () async {
      if (Platform.isWindows) {
        return;
      }
      final File real = File('${root.path}/real.md')..writeAsStringSync('old');
      final Link link = Link('${root.path}/link.md')..createSync(real.path);

      await filesystem.writeFile(link.path, 'new');

      expect(real.readAsStringSync(), 'new');
      expect(FileSystemEntity.isLinkSync(link.path), isTrue);
    });

    test('a link with a relative target is written through too', () async {
      if (Platform.isWindows) {
        return;
      }
      final Link link = Link('${root.path}/link.md')..createSync('real.md');

      expect(
        await filesystem.writeFile(link.path, 'made'),
        isA<Success<void, FilesystemFailure>>(),
      );
      expect(File('${root.path}/real.md').readAsStringSync(), 'made');
    });

    test('a write under a file fails with the path asked for', () async {
      File('${root.path}/f').writeAsStringSync('x');
      final String path = '${root.path}/f/sub/a.md';

      expect(
        await filesystem.writeFile(path, 'x'),
        isA<Failure<void, FilesystemFailure>>(),
      );
      expect(File('${root.path}/f').readAsStringSync(), 'x');
    });

    test('bytes are written as they are', () async {
      await filesystem.writeBytes(
        '${root.path}/b.bin',
        Uint8List.fromList(<int>[0, 255, 7]),
      );

      expect(File('${root.path}/b.bin').readAsBytesSync(), <int>[0, 255, 7]);
    });
  });

  group('creating', () {
    test('a file is created with its folders, empty or with content', () async {
      await filesystem.createFile('${root.path}/x/empty.md', '');
      await filesystem.createFile('${root.path}/x/full.md', '# T');

      expect(File('${root.path}/x/empty.md').readAsStringSync(), '');
      expect(File('${root.path}/x/full.md').readAsStringSync(), '# T');
    });

    test('a name taken is never overwritten', () async {
      File('${root.path}/a.md').writeAsStringSync('mine');

      final FilesystemFailure failure = bad(
        await filesystem.createFile('${root.path}/a.md', 'yours'),
      );

      expect(failure, isA<FilesystemAlreadyExists>());
      expect(File('${root.path}/a.md').readAsStringSync(), 'mine');
    });

    test('a folder is created once; again it is taken', () async {
      final String path = '${root.path}/a/b';

      expect(
        await filesystem.createDirectory(path),
        isA<Success<void, FilesystemFailure>>(),
      );
      expect(
        bad(await filesystem.createDirectory(path)),
        isA<FilesystemAlreadyExists>(),
      );
      expect(Directory(path).existsSync(), isTrue);
    });

    test('a folder under a file fails as a value', () async {
      File('${root.path}/f').writeAsStringSync('x');

      expect(
        await filesystem.createDirectory('${root.path}/f/sub'),
        isA<Failure<void, FilesystemFailure>>(),
      );
      expect(
        await filesystem.createFile('${root.path}/f/sub/a.md', ''),
        isA<Failure<void, FilesystemFailure>>(),
      );
    });
  });

  group('looking', () {
    test('a listing is sorted, typed, and optionally recursive', () async {
      Directory('${root.path}/d').createSync();
      File('${root.path}/d/in.md').writeAsStringSync('');
      File('${root.path}/b.md').writeAsStringSync('');
      if (!Platform.isWindows) {
        Link('${root.path}/c.lnk').createSync('b.md');
      }

      final List<FilesystemEntryDto> flat = ok(
        await filesystem.listDirectory(root.path),
      );
      final List<FilesystemEntryDto> deep = ok(
        await filesystem.listDirectory(root.path, recursive: true),
      );

      expect(
        flat.map((FilesystemEntryDto e) => e.path.split(RegExp(r'[/\\]')).last),
        <String>['b.md', if (!Platform.isWindows) 'c.lnk', 'd'],
      );
      expect(flat.last.type, FilesystemEntryTypeEnum.directory);
      expect(flat.first.type, FilesystemEntryTypeEnum.file);
      if (!Platform.isWindows) {
        expect(flat[1].type, FilesystemEntryTypeEnum.link);
      }
      expect(deep.length, flat.length + 1);
    });

    test('a folder that is not there is not found', () async {
      expect(
        bad(await filesystem.listDirectory('${root.path}/none')),
        isA<FilesystemEntryNotFound>(),
      );
    });

    test('a folder exists, a file or nothing does not', () async {
      File('${root.path}/a.md').writeAsStringSync('');

      expect(ok(await filesystem.directoryExists(root.path)), isTrue);
      expect(
        ok(await filesystem.directoryExists('${root.path}/a.md')),
        isFalse,
      );
      expect(
        ok(await filesystem.directoryExists('${root.path}/none')),
        isFalse,
      );
    });

    test('the type of an entry, or null for nothing', () async {
      File('${root.path}/a.md').writeAsStringSync('');
      if (!Platform.isWindows) {
        Link('${root.path}/l').createSync('a.md');
        expect(
          ok(await filesystem.entryTypeOf('${root.path}/l')),
          FilesystemEntryTypeEnum.link,
        );
      }

      expect(
        ok(await filesystem.entryTypeOf('${root.path}/a.md')),
        FilesystemEntryTypeEnum.file,
      );
      expect(
        ok(await filesystem.entryTypeOf(root.path)),
        FilesystemEntryTypeEnum.directory,
      );
      expect(ok(await filesystem.entryTypeOf('${root.path}/none')), isNull);
    });

    test('a path is resolved through its links', () async {
      Directory('${root.path}/real').createSync();
      if (!Platform.isWindows) {
        Link('${root.path}/alias').createSync('real');
        expect(
          ok(await filesystem.resolvePath('${root.path}/alias')),
          endsWith('real'),
        );
      }

      expect(
        bad(await filesystem.resolvePath('${root.path}/none')),
        isA<FilesystemEntryNotFound>(),
      );
    });
  });

  group('deleting', () {
    test(
      'a file, a folder with its contents, and a link without its target',
      () async {
        File('${root.path}/a.md').writeAsStringSync('');
        Directory('${root.path}/d/e').createSync(recursive: true);
        File('${root.path}/d/e/x.md').writeAsStringSync('');
        Directory('${root.path}/kept').createSync();
        File('${root.path}/kept/k.md').writeAsStringSync('');

        await filesystem.delete('${root.path}/a.md');
        await filesystem.delete('${root.path}/d');
        if (!Platform.isWindows) {
          Link('${root.path}/l').createSync('kept');
          await filesystem.delete('${root.path}/l');
          expect(
            FileSystemEntity.typeSync('${root.path}/l', followLinks: false),
            FileSystemEntityType.notFound,
          );
        }

        expect(File('${root.path}/a.md').existsSync(), isFalse);
        expect(Directory('${root.path}/d').existsSync(), isFalse);
        expect(File('${root.path}/kept/k.md').existsSync(), isTrue);
      },
    );

    test('what is not there is already deleted', () async {
      expect(
        await filesystem.delete('${root.path}/none'),
        isA<Success<void, FilesystemFailure>>(),
      );
    });
  });
}
