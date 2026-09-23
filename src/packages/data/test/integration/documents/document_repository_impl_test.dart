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
  late SpaceEntity space;

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
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
    space = SpaceEntity(
      root: root,
      repositoryRoot: repositoryRoot,
      name: 'docs',
    );
    const Filesystem filesystem = DartIoFilesystemImpl();
    documents = DocumentRepositoryImpl(
      documents: const DocumentDataSource(filesystem: filesystem),
      space: space,
    );
    spaces = SpaceRepositoryImpl(
      spaces: SpaceDataSource(
        filesystem: filesystem,
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('reading a document', () {
    test('reads what is on disk, byte for byte', () async {
      write('guide.md', '# Guide\r\n\r\nBody\n\n');

      final DocumentEntity document = valueOf(
        await documents.read(SpaceRelativePathValueObject('guide.md')),
      );

      expect(document.content, '# Guide\r\n\r\nBody\n\n');
      expect(document.path, SpaceRelativePathValueObject('guide.md'));
    });

    test('a file that is not there names the document', () async {
      expect(
        failureOf(
          await documents.read(SpaceRelativePathValueObject('missing.md')),
        ),
        isA<DocumentNotFound>().having(
          (DocumentNotFound failure) => failure.path,
          'path',
          'missing.md',
        ),
      );
    });

    test('and the whole chain reaches the diagnostics', () async {
      // Two links, one per vocabulary crossed: what the product says and
      // what the capability said. The operating system's own words are not a
      // third link — an adapter keeps nothing of its own. The path the user
      // sees is space-relative; the absolute one is further down.
      final AppFailure failure = failureOf(
        await documents.read(SpaceRelativePathValueObject('missing.md')),
      );

      expect(failure.chain, hasLength(2));
      expect(failure.diagnostics, contains('missing.md'));
      expect(failure.diagnostics, contains(space.root));
    });

    test('a file that is not text is refused rather than decoded', () async {
      // Latin-1 bytes that are not valid UTF-8. Opening this with
      // replacement characters would destroy the file on the next save.
      File('$root/binary.md').writeAsBytesSync(<int>[0xff, 0xfe, 0x00]);

      expect(
        failureOf(
          await documents.read(SpaceRelativePathValueObject('binary.md')),
        ),
        isA<DocumentNotUtf8>().having(
          (DocumentNotUtf8 failure) => failure.path,
          'path',
          'binary.md',
        ),
      );
    });

    test('a path outside the space cannot be spelled', () async {
      // The type is the guard: there is no way to ask for `../secrets.md`.
      expect(
        () => SpaceRelativePathValueObject('../secrets.md'),
        throwsArgumentError,
      );
    });
  });

  group('writing a document', () {
    test('lands on disk where the space says', () async {
      valueOf(
        await documents.write(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guide.md'),
            content: '# Guide\n',
          ),
        ),
      );

      expect(File('$root/guide.md').readAsStringSync(), '# Guide\n');
    });

    test('creates the folders on the way', () async {
      // Saving into a folder the user just named is a create.
      valueOf(
        await documents.write(
          DocumentEntity(
            path: SpaceRelativePathValueObject('adr/001.md'),
            content: '# One\n',
          ),
        ),
      );

      expect(File('$root/adr/001.md').readAsStringSync(), '# One\n');
    });

    test('replaces what was there, and reads back the same', () async {
      write('guide.md', '# Old\n');

      valueOf(
        await documents.write(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guide.md'),
            content: '# New\n',
          ),
        ),
      );

      expect(
        valueOf(
          await documents.read(SpaceRelativePathValueObject('guide.md')),
        ).content,
        '# New\n',
      );
    });

    test('writes UTF-8, and reads it back unchanged', () async {
      const String content = '# Guia\n\nAcentuação, ícones ✅, 中文\n';

      valueOf(
        await documents.write(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guia.md'),
            content: content,
          ),
        ),
      );

      expect(utf8.decode(File('$root/guia.md').readAsBytesSync()), content);
      expect(
        valueOf(
          await documents.read(SpaceRelativePathValueObject('guia.md')),
        ).content,
        content,
      );
    });
  });

  group('listing the space', () {
    test('walks the whole folder in tree order', () async {
      write('guide.md', '# Guide\n');
      write('adr/001.md', '# One\n');
      write('adr/002.md', '# Two\n');

      final List<SpaceEntryValueObject> entries = valueOf(
        await spaces.entries(space),
      );

      expect(
        entries.map((SpaceEntryValueObject entry) => entry.path.value),
        <String>['adr', 'adr/001.md', 'adr/002.md', 'guide.md'],
      );
    });

    test('hides a real .git and keeps the other dotfolders', () async {
      Directory('$root/.git/objects').createSync(recursive: true);
      File('$root/.git/HEAD').writeAsStringSync('ref: refs/heads/main\n');
      write('.ai/skills.md', '# Skills\n');

      final List<String> paths = valueOf(
        await spaces.entries(space),
      ).map((SpaceEntryValueObject entry) => entry.path.value).toList();

      expect(paths, contains('.ai'));
      expect(paths, contains('.ai/skills.md'));
      expect(paths.where((String path) => path.startsWith('.git')), isEmpty);
    });

    test('reports a link without following it', () async {
      write('guide.md', '# Guide\n');
      Link('$root/alias.md').createSync('$root/guide.md');

      final SpaceEntryValueObject entry = valueOf(
        await spaces.entries(space),
      ).firstWhere((SpaceEntryValueObject entry) => entry.name == 'alias.md');

      expect(entry.type, SpaceEntryTypeEnum.link);
      expect(entry.isDocument, isFalse);
    });

    test('a space whose folder is gone reports it as such', () async {
      Directory(root).deleteSync(recursive: true);

      expect(failureOf(await spaces.entries(space)), isA<SpaceFolderMissing>());
    });

    test('an empty space lists nothing, and does not fail', () async {
      expect(valueOf(await spaces.entries(space)), isEmpty);
    });
  });
}
