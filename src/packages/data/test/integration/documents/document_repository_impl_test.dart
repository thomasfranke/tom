/// The document and space repositories against real disk.
///
/// The unit tests beside these prove the translation with doubles. This
/// proves the stack agrees with a real filesystem: what `dart:io` does with
/// a folder that does not exist, with bytes that are not text, and with a
/// space that is a folder inside a repository rather than the repository.
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
  late String repositoryRoot;
  late String root;
  late DocumentRepositoryImpl documents;
  late SpaceRepositoryImpl spaces;

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T>(Result<T> result) => switch (result) {
    Success<T>(value: final T value) => value,
    Failure<T>(failure: final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  void write(String relativePath, String content) {
    File('$root/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_documents_');
    // Resolved, because the macOS system temporary directory is a symlink
    // and a space must compare equal to the paths a listing reports.
    repositoryRoot = tempDir.resolveSymbolicLinksSync();
    // The normal case: the user opened `docs/` inside a repository.
    root = '$repositoryRoot/docs';
    Directory(root).createSync();
    final Space space = Space(
      root: root,
      repositoryRoot: repositoryRoot,
      name: 'docs',
    );
    const Filesystem filesystem = DartIoFilesystem();
    documents = DocumentRepositoryImpl(filesystem: filesystem, space: space);
    spaces = SpaceRepositoryImpl(filesystem: filesystem, space: space);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('reading a document', () {
    test('reads what is on disk, byte for byte', () async {
      write('guide.md', '# Guide\r\n\r\nBody\n\n');

      final Document document = valueOf(
        await documents.read(SpaceRelativePath('guide.md')),
      );

      expect(document.content, '# Guide\r\n\r\nBody\n\n');
      expect(document.path, SpaceRelativePath('guide.md'));
    });

    test('a file that is not there names the document', () async {
      expect(
        failureOf(await documents.read(SpaceRelativePath('missing.md'))),
        const DocumentNotFound('missing.md'),
      );
    });

    test('a file that is not text is refused rather than decoded', () async {
      // Latin-1 bytes that are not valid UTF-8. Opening this with
      // replacement characters would destroy the file on the next save.
      File('$root/binary.md').writeAsBytesSync(<int>[0xff, 0xfe, 0x00]);

      expect(
        failureOf(await documents.read(SpaceRelativePath('binary.md'))),
        const DocumentNotUtf8('binary.md'),
      );
    });

    test('a path outside the space cannot be spelled', () async {
      // The type is the guard: there is no way to ask for `../secrets.md`.
      expect(() => SpaceRelativePath('../secrets.md'), throwsArgumentError);
    });
  });

  group('writing a document', () {
    test('lands on disk where the space says', () async {
      valueOf(
        await documents.write(
          Document(path: SpaceRelativePath('guide.md'), content: '# Guide\n'),
        ),
      );

      expect(File('$root/guide.md').readAsStringSync(), '# Guide\n');
    });

    test('creates the folders on the way', () async {
      // Saving into a folder the user just named is a create.
      valueOf(
        await documents.write(
          Document(path: SpaceRelativePath('adr/001.md'), content: '# One\n'),
        ),
      );

      expect(File('$root/adr/001.md').readAsStringSync(), '# One\n');
    });

    test('replaces what was there, and reads back the same', () async {
      write('guide.md', '# Old\n');

      valueOf(
        await documents.write(
          Document(path: SpaceRelativePath('guide.md'), content: '# New\n'),
        ),
      );

      expect(
        valueOf(await documents.read(SpaceRelativePath('guide.md'))).content,
        '# New\n',
      );
    });

    test('writes UTF-8, and reads it back unchanged', () async {
      const String content = '# Guia\n\nAcentuação, ícones ✅, 中文\n';

      valueOf(
        await documents.write(
          Document(path: SpaceRelativePath('guia.md'), content: content),
        ),
      );

      expect(utf8.decode(File('$root/guia.md').readAsBytesSync()), content);
      expect(
        valueOf(await documents.read(SpaceRelativePath('guia.md'))).content,
        content,
      );
    });
  });

  group('listing the space', () {
    test('walks the whole folder in tree order', () async {
      write('guide.md', '# Guide\n');
      write('adr/001.md', '# One\n');
      write('adr/002.md', '# Two\n');

      final List<SpaceEntry> entries = valueOf(await spaces.entries());

      expect(entries.map((SpaceEntry entry) => entry.path.value), <String>[
        'adr',
        'adr/001.md',
        'adr/002.md',
        'guide.md',
      ]);
    });

    test('hides a real .git and keeps the other dotfolders', () async {
      Directory('$root/.git/objects').createSync(recursive: true);
      File('$root/.git/HEAD').writeAsStringSync('ref: refs/heads/main\n');
      write('.ai/skills.md', '# Skills\n');

      final List<String> paths = valueOf(
        await spaces.entries(),
      ).map((SpaceEntry entry) => entry.path.value).toList();

      expect(paths, contains('.ai'));
      expect(paths, contains('.ai/skills.md'));
      expect(paths.where((String path) => path.startsWith('.git')), isEmpty);
    });

    test('reports a link without following it', () async {
      write('guide.md', '# Guide\n');
      Link('$root/alias.md').createSync('$root/guide.md');

      final SpaceEntry entry = valueOf(
        await spaces.entries(),
      ).firstWhere((SpaceEntry entry) => entry.name == 'alias.md');

      expect(entry.type, SpaceEntryType.link);
      expect(entry.isDocument, isFalse);
    });

    test('a space whose folder is gone reports it as such', () async {
      Directory(root).deleteSync(recursive: true);

      expect(failureOf(await spaces.entries()), isA<SpaceFolderMissing>());
    });

    test('an empty space lists nothing, and does not fail', () async {
      expect(valueOf(await spaces.entries()), isEmpty);
    });
  });
}
