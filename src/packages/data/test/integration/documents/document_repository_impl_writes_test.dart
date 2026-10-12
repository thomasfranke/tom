/// [DocumentRepositoryImpl] where a write can lose something: creating over
/// what is there, a space the machine will not write to, links, modes and the
/// names a person really types — on a real disk, a space below its repository.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String repositoryRoot;
  late String root;
  late DocumentRepositoryImpl documents;

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  /// A failure of variant [T] naming [path], the way the tree names it.
  Matcher named<T extends DocumentFailure>(String path) =>
      isA<T>().having((T failure) => (failure as dynamic).path, 'path', path);

  DocumentEntity document(String path, String content) => DocumentEntity(
    path: SpaceRelativePathValueObject(path),
    content: content,
  );

  void put(String relativePath, String content) {
    File('$root/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  String onDisk(String relativePath) =>
      File('$root/$relativePath').readAsStringSync();

  /// The names directly inside [folder], sorted — what a leftover temporary
  /// would show up in.
  List<String> namesIn(String folder) => <String>[
    for (final FileSystemEntity entity in Directory(folder).listSync())
      entity.uri.pathSegments.lastWhere((String s) => s.isNotEmpty),
  ]..sort();

  /// [path]'s permission bits, as `chmod` writes them.
  String modeOf(String path) =>
      (File(path).statSync().mode & 0x1ff).toRadixString(8);

  /// Runs `chmod`, and puts [restore] back when the test ends so the
  /// temporary folder can be removed.
  void chmod(String mode, String path, {String? restore}) {
    Process.runSync('chmod', <String>[mode, path]);
    if (restore != null) {
      addTearDown(() => Process.runSync('chmod', <String>[restore, path]));
    }
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_document_writes_');
    // Resolved, because the macOS temporary directory is a symlink.
    repositoryRoot = tempDir.resolveSymbolicLinksSync();
    root = '$repositoryRoot/docs';
    Directory(root).createSync();
    documents = DocumentRepositoryImpl(
      documents: const DocumentDataSource(filesystem: DartIoFilesystemImpl()),
      root: root,
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  const String posixOnly = 'permissions and links are POSIX here';

  group('creating a document', () {
    test('lands empty where the space says', () async {
      final Result<void, DocumentFailure> created = await documents.create(
        document('notes/untitled.md', ''),
      );

      expect(created, isA<Success<void, DocumentFailure>>());
      expect(File('$root/notes/untitled.md').lengthSync(), 0);
      expect(File('$repositoryRoot/notes/untitled.md').existsSync(), isFalse);
    });

    test('lands with its text, and nothing beside it', () async {
      await documents.create(document('seeded.md', '# Seeded\n'));

      expect(onDisk('seeded.md'), '# Seeded\n');
      expect(namesIn(root), <String>['seeded.md']);
    });

    test('never replaces a document that is there', () async {
      put('guide.md', '# Somebody wrote this\n');

      expect(
        failureOf(await documents.create(document('guide.md', '# Mine\n'))),
        named<DocumentAlreadyExists>('guide.md'),
      );
      expect(onDisk('guide.md'), '# Somebody wrote this\n');
      expect(namesIn(root), <String>['guide.md']);
    });

    test('nor an empty one', () async {
      put('guide.md', '');

      expect(
        failureOf(await documents.create(document('guide.md', '# Mine\n'))),
        named<DocumentAlreadyExists>('guide.md'),
      );
      expect(onDisk('guide.md'), isEmpty);
    });

    test('a name differing only by case is taken where the disk says so, '
        'and the document there is kept either way', () async {
      put('Guide.md', '# Capital\n');
      // Asked of the disk rather than of the platform: macOS can be either.
      final bool foldsCase = File('$root/guide.md').existsSync();

      final Result<void, DocumentFailure> created = await documents.create(
        document('guide.md', '# Lower\n'),
      );

      expect(onDisk('Guide.md'), '# Capital\n');
      if (foldsCase) {
        expect(failureOf(created), named<DocumentAlreadyExists>('guide.md'));
        expect(namesIn(root), <String>['Guide.md']);
      } else {
        expect(created, isA<Success<void, DocumentFailure>>());
        expect(namesIn(root), <String>['Guide.md', 'guide.md']);
      }
    });

    test('a folder holding the name is not a document to replace', () async {
      Directory('$root/guide.md').createSync();
      put('guide.md/inside.md', 'kept');

      expect(
        failureOf(await documents.create(document('guide.md', '# Mine\n'))),
        named<DocumentAlreadyExists>('guide.md'),
      );
      expect(onDisk('guide.md/inside.md'), 'kept');
    });

    test(
      'a link holding the name is kept, even one that points at nothing',
      () async {
        Link('$root/guide.md').createSync('$repositoryRoot/gone.md');

        expect(
          failureOf(await documents.create(document('guide.md', '# Mine\n'))),
          named<DocumentAlreadyExists>('guide.md'),
        );
        expect(
          FileSystemEntity.typeSync('$root/guide.md', followLinks: false),
          FileSystemEntityType.link,
        );
        expect(File('$repositoryRoot/gone.md').existsSync(), isFalse);
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test(
      'a space that cannot be written to refuses, and holds nothing new',
      () async {
        chmod('555', root, restore: '755');

        expect(
          failureOf(await documents.create(document('new.md', '# New\n'))),
          named<DocumentPermissionDenied>('new.md'),
        );
        expect(namesIn(root), isEmpty);
      },
      skip: Platform.isWindows ? posixOnly : false,
    );
  });

  group('writing a document', () {
    test('a space that cannot be written to keeps the document it had, and no '
        'temporary beside it', () async {
      put('guide.md', '# As it was\n');
      chmod('555', root, restore: '755');

      expect(
        failureOf(await documents.write(document('guide.md', '# Edited\n'))),
        named<DocumentPermissionDenied>('guide.md'),
      );
      expect(onDisk('guide.md'), '# As it was\n');
      expect(namesIn(root), <String>['guide.md']);
    }, skip: Platform.isWindows ? posixOnly : false);

    test(
      'a document that cannot be read is refused by name, not decoded',
      () async {
        put('locked.md', '# Locked\n');
        chmod('000', '$root/locked.md', restore: '644');

        expect(
          failureOf(
            await documents.read(SpaceRelativePathValueObject('locked.md')),
          ),
          named<DocumentPermissionDenied>('locked.md'),
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test('a folder called like a document is not read as one', () async {
      Directory('$root/x.md').createSync();

      expect(
        failureOf(await documents.read(SpaceRelativePathValueObject('x.md'))),
        named<DocumentOperationFailed>('x.md'),
      );
    });

    test(
      'and is not written over: the folder and what it holds stay',
      () async {
        put('x.md/inside.md', 'kept');

        expect(
          failureOf(await documents.write(document('x.md', '# Mine\n'))),
          isA<DocumentFailure>().having(
            (DocumentFailure failure) => (failure as dynamic).path,
            'path',
            'x.md',
          ),
        );
        expect(onDisk('x.md/inside.md'), 'kept');
        expect(namesIn(root), <String>['x.md']);
      },
    );

    test('a parent that is a file refuses, and the file is kept', () async {
      put('notes.md', '# A file, not a folder\n');

      expect(
        failureOf(
          await documents.write(document('notes.md/inner.md', '# Inner\n')),
        ),
        isA<DocumentFailure>().having(
          (DocumentFailure failure) => (failure as dynamic).path,
          'path',
          'notes.md/inner.md',
        ),
      );
      expect(onDisk('notes.md'), '# A file, not a folder\n');
      expect(namesIn(root), <String>['notes.md']);
    });

    test('an empty document is read as empty, and written as empty', () async {
      put('empty.md', '');

      final Result<DocumentEntity, DocumentFailure> read = await documents.read(
        SpaceRelativePathValueObject('empty.md'),
      );
      expect(
        (read as Success<DocumentEntity, DocumentFailure>).value.content,
        '',
      );

      put('full.md', '# Full\n');
      await documents.write(document('full.md', ''));
      expect(File('$root/full.md').lengthSync(), 0);
    });

    test('line endings and a missing final newline come back byte for '
        'byte', () async {
      const String text = '# Título\r\n\r\nLinha um\r\nlinha dois';

      await documents.write(document('crlf.md', text));

      expect(File('$root/crlf.md').readAsBytesSync(), const <int>[
        0x23, 0x20, 0x54, 0xc3, 0xad, 0x74, 0x75, 0x6c, 0x6f, 0x0d, 0x0a, //
        0x0d, 0x0a, 0x4c, 0x69, 0x6e, 0x68, 0x61, 0x20, 0x75, 0x6d, 0x0d,
        0x0a, 0x6c, 0x69, 0x6e, 0x68, 0x61, 0x20, 0x64, 0x6f, 0x69, 0x73,
      ]);
      final Result<DocumentEntity, DocumentFailure> read = await documents.read(
        SpaceRelativePathValueObject('crlf.md'),
      );
      expect(
        (read as Success<DocumentEntity, DocumentFailure>).value.content,
        text,
      );
    });
  });

  group('names a person really types', () {
    // The accent once composed (NFC) and once as a letter and a combining
    // mark (NFD), which is how macOS hands a name back.
    const Map<String, String> names = <String, String>{
      'a space': 'release notes/first draft.md',
      'an accent, composed': 'revisão/ação.md',
      'an accent, decomposed': 'revisão/ação.md',
      'a leading dash': '-draft.md',
      'a dot folder': '.notes/hidden.md',
      'an emoji': 'ideas \u{1F4A1}.md',
    };

    for (final MapEntry<String, String> name in names.entries) {
      test('${name.key}: written, read back, and replaced', () async {
        final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
          name.value,
        );

        expect(
          await documents.write(document(name.value, '# First\n')),
          isA<Success<void, DocumentFailure>>(),
        );
        expect(onDisk(name.value), '# First\n');

        await documents.write(document(name.value, '# Second\n'));
        final Result<DocumentEntity, DocumentFailure> read = await documents
            .read(path);

        expect(
          (read as Success<DocumentEntity, DocumentFailure>).value,
          DocumentEntity(path: path, content: '# Second\n'),
        );
        expect(
          failureOf(await documents.create(document(name.value, 'again'))),
          named<DocumentAlreadyExists>(name.value),
        );
      });
    }

    test('a name the disk has no room for is refused, and nothing is left '
        'behind', () async {
      // 256 bytes, one past what every disk this runs on allows for a name.
      final String tooLong = '${'n' * 253}.md';

      expect(
        failureOf(await documents.write(document(tooLong, '# Long\n'))),
        named<DocumentOperationFailed>(tooLong),
      );
      expect(namesIn(root), isEmpty);
    });
  });

  group('a link in the space', () {
    late String outside;

    setUp(() {
      outside = '$repositoryRoot/outside.md';
      File(outside).writeAsStringSync('# Outside the space\n');
      Link('$root/linked.md').createSync(outside);
    });

    test(
      'is read through, to the document it points at',
      () async {
        final Result<DocumentEntity, DocumentFailure> read = await documents
            .read(SpaceRelativePathValueObject('linked.md'));

        expect(
          (read as Success<DocumentEntity, DocumentFailure>).value.content,
          '# Outside the space\n',
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test('a save follows it: the document it points at is written and the link '
        'stays a link', () async {
      expect(
        await documents.write(document('linked.md', '# Saved\n')),
        isA<Success<void, DocumentFailure>>(),
      );

      expect(
        FileSystemEntity.typeSync('$root/linked.md', followLinks: false),
        FileSystemEntityType.link,
      );
      expect(File(outside).readAsStringSync(), '# Saved\n');
      expect(namesIn(root), <String>['linked.md']);
    }, skip: Platform.isWindows ? posixOnly : false);

    test(
      'a link that points at nothing reads as a document that is not there',
      () async {
        Link('$root/dangling.md').createSync('$repositoryRoot/gone.md');

        expect(
          failureOf(
            await documents.read(SpaceRelativePathValueObject('dangling.md')),
          ),
          named<DocumentNotFound>('dangling.md'),
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );
  });

  group("a document's mode", () {
    for (final String mode in <String>['600', '640', '755']) {
      test('is still $mode after a save', () async {
        put('guide.md', '# As it was\n');
        chmod(mode, '$root/guide.md');

        await documents.write(document('guide.md', '# Edited\n'));

        expect(onDisk('guide.md'), '# Edited\n');
        expect(modeOf('$root/guide.md'), mode);
      }, skip: Platform.isWindows ? posixOnly : false);
    }
  });
}
