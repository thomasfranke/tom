/// [DartIoFilesystemImpl] against a real temporary directory.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late DartIoFilesystemImpl filesystem;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_filesystem_test_');
    filesystem = const DartIoFilesystemImpl();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// [path] with forward slashes, whatever the platform reported.
  ///
  /// `dart:io` hands back a Windows path with backslashes, so an assertion
  /// written with `/` would fail on one of the three platforms.
  String slashed(String path) => path.replaceAll(r'\', '/');

  /// A failure of variant [T] naming [path].
  ///
  /// By variant and path rather than equality, because `operationFailed`
  /// carries the operating system's own words.
  Matcher named<T extends FilesystemFailure>(String path) =>
      isA<T>().having((T failure) => (failure as dynamic).path, 'path', path);

  test('writeFile then readFile round-trips the content', () async {
    final String path = '${tempDir.path}/note.md';

    final Result<void, FilesystemFailure> written = await filesystem.writeFile(
      path,
      '# Hello',
    );
    expect(written, isA<Success<void, FilesystemFailure>>());

    final Result<String, FilesystemFailure> read = await filesystem.readFile(
      path,
    );
    expect(read, isA<Success<String, FilesystemFailure>>());
    expect((read as Success<String, FilesystemFailure>).value, '# Hello');
  });

  test('writeFile overwrites an existing file', () async {
    final String path = '${tempDir.path}/note.md';

    await filesystem.writeFile(path, 'first');
    await filesystem.writeFile(path, 'second');

    final Result<String, FilesystemFailure> read = await filesystem.readFile(
      path,
    );
    expect((read as Success<String, FilesystemFailure>).value, 'second');
  });

  test(
    'readFile fails with FilesystemEntryNotFound for a missing file',
    () async {
      final Result<String, FilesystemFailure> read = await filesystem.readFile(
        '${tempDir.path}/missing.md',
      );

      expect(read, isA<Failure<String, FilesystemFailure>>());
      expect(
        (read as Failure<String, FilesystemFailure>).failure,
        named<FilesystemEntryNotFound>('${tempDir.path}/missing.md'),
      );
    },
  );

  test('a failure is the contract\'s vocabulary and nothing under it', () {
    // `cause` links two vocabularies, and an adapter has no second one to
    // link to, so the chain ends here.
    expect(
      filesystem.readFile('${tempDir.path}/missing.md'),
      completion(
        isA<Failure<String, FilesystemFailure>>().having(
          (Failure<String, FilesystemFailure> result) => result.failure.chain,
          'chain',
          hasLength(1),
        ),
      ),
    );
  });

  test('writeFile creates the directories the path needs', () async {
    final String path = '${tempDir.path}/notes/2026/q1.md';

    final Result<void, FilesystemFailure> written = await filesystem.writeFile(
      path,
      '# Q1',
    );

    expect(written, isA<Success<void, FilesystemFailure>>());
    expect(File(path).readAsStringSync(), '# Q1');
  });

  test('writeFile leaves nothing beside the file it wrote', () async {
    // The temporary sibling the write goes through is not the caller's
    // business.
    await filesystem.writeFile('${tempDir.path}/note.md', '# Hello');

    expect(
      tempDir.listSync().map(
        (FileSystemEntity e) => slashed(e.path).split('/').last,
      ),
      <String>['note.md'],
    );
  });

  test('a write that cannot land leaves no temporary behind', () async {
    // A directory cannot be replaced by a file, so the rename is what fails —
    // the moment a temporary would be orphaned.
    final String path = '${tempDir.path}/folder';
    Directory(path).createSync();

    final Result<void, FilesystemFailure> written = await filesystem.writeFile(
      path,
      'content',
    );

    expect(written, isA<Failure<void, FilesystemFailure>>());
    expect(Directory(path).existsSync(), isTrue);
    expect(
      tempDir.listSync().map(
        (FileSystemEntity e) => slashed(e.path).split('/').last,
      ),
      <String>['folder'],
    );
  });

  test(
    'readFile fails with FilesystemNotUtf8 for bytes that are not',
    () async {
      // A latin-1 accented byte, which is not a valid UTF-8 sequence.
      final String path = '${tempDir.path}/latin.md';
      File(path).writeAsBytesSync(<int>[0xE9, 0x63, 0x68, 0x6F]);

      final Result<String, FilesystemFailure> read = await filesystem.readFile(
        path,
      );

      expect(read, isA<Failure<String, FilesystemFailure>>());
      expect(
        (read as Failure<String, FilesystemFailure>).failure,
        named<FilesystemNotUtf8>(path),
      );
    },
  );

  test(
    'readFile fails with FilesystemOperationFailed for a directory',
    () async {
      final Result<String, FilesystemFailure> read = await filesystem.readFile(
        tempDir.path,
      );

      expect(read, isA<Failure<String, FilesystemFailure>>());
      expect(
        (read as Failure<String, FilesystemFailure>).failure,
        isA<FilesystemOperationFailed>(),
      );
    },
  );

  test(
    'readFile fails with FilesystemAccessDenied for an unreadable file',
    () async {
      final String path = '${tempDir.path}/locked.md';
      File(path).writeAsStringSync('secret');
      Process.runSync('chmod', <String>['000', path]);

      final Result<String, FilesystemFailure> read = await filesystem.readFile(
        path,
      );

      Process.runSync('chmod', <String>['644', path]);
      expect(read, isA<Failure<String, FilesystemFailure>>());
      expect(
        (read as Failure<String, FilesystemFailure>).failure,
        named<FilesystemAccessDenied>(path),
      );
    },
    skip: Platform.isWindows
        ? 'chmod does not model POSIX permissions on Windows'
        : false,
  );

  group('listDirectory', () {
    /// The shape the file tree actually walks: dotfolders alongside `.git/`,
    /// and markdown nested below the top level.
    setUp(() {
      for (final String relative in const <String>[
        'readme.md',
        'docs/guide.md',
        'docs/deep/nested.md',
        '.ai/skills/notes.md',
        '.git/config',
      ]) {
        File('${tempDir.path}/$relative')
          ..parent.createSync(recursive: true)
          ..writeAsStringSync('x');
      }
    });

    test('lists one level, sorted, without descending', () async {
      final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
          await filesystem.listDirectory(tempDir.path);

      expect(
        listed,
        isA<Success<List<FilesystemEntryDto>, FilesystemFailure>>(),
      );
      final List<String> names =
          (listed as Success<List<FilesystemEntryDto>, FilesystemFailure>).value
              .map((FilesystemEntryDto e) => slashed(e.path).split('/').last)
              .toList();
      expect(names, <String>['.ai', '.git', 'docs', 'readme.md']);
    });

    test('reports what each entry is', () async {
      final List<FilesystemEntryDto> entries =
          (await filesystem.listDirectory(tempDir.path)
                  as Success<List<FilesystemEntryDto>, FilesystemFailure>)
              .value;

      expect(
        entries
            .firstWhere((FilesystemEntryDto e) => e.path.endsWith('readme.md'))
            .type,
        FilesystemEntryTypeEnum.file,
      );
      expect(
        entries
            .firstWhere((FilesystemEntryDto e) => e.path.endsWith('docs'))
            .type,
        FilesystemEntryTypeEnum.directory,
      );
    });

    test('recursive reaches every dotfolder, filtering nothing', () async {
      final List<String> paths =
          (await filesystem.listDirectory(tempDir.path, recursive: true)
                  as Success<List<FilesystemEntryDto>, FilesystemFailure>)
              .value
              .map((FilesystemEntryDto e) => slashed(e.path))
              .toList();

      // `.git/` is hidden by the tree, not by the capability.
      final String root = slashed(tempDir.path);
      expect(paths, contains('$root/.git/config'));
      expect(paths, contains('$root/.ai/skills/notes.md'));
      expect(paths, contains('$root/docs/deep/nested.md'));
    });

    test(
      'reports a symlink as a link and does not follow it',
      () async {
        Link('${tempDir.path}/loop').createSync(tempDir.path);

        final List<FilesystemEntryDto> entries =
            (await filesystem.listDirectory(tempDir.path, recursive: true)
                    as Success<List<FilesystemEntryDto>, FilesystemFailure>)
                .value;

        // Following it would walk its own parent forever.
        expect(
          entries
              .firstWhere(
                (FilesystemEntryDto e) => slashed(e.path).endsWith('/loop'),
              )
              .type,
          FilesystemEntryTypeEnum.link,
        );
        expect(
          entries.where(
            (FilesystemEntryDto e) => slashed(e.path).contains('/loop/'),
          ),
          isEmpty,
        );
      },
      skip: Platform.isWindows
          ? 'creating a symlink needs Developer Mode or an elevated shell'
          : false,
    );

    test(
      'fails with FilesystemEntryNotFound for a missing directory',
      () async {
        final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
            await filesystem.listDirectory('${tempDir.path}/nowhere');

        expect(
          listed,
          isA<Failure<List<FilesystemEntryDto>, FilesystemFailure>>(),
        );
        expect(
          (listed as Failure<List<FilesystemEntryDto>, FilesystemFailure>)
              .failure,
          named<FilesystemEntryNotFound>('${tempDir.path}/nowhere'),
        );
      },
    );

    test(
      'a folder that cannot be opened costs that folder, not the listing',
      () async {
        final String locked = '${tempDir.path}/locked';
        Directory('$locked/inside').createSync(recursive: true);
        Process.runSync('chmod', <String>['000', locked]);

        final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
            await filesystem.listDirectory(tempDir.path, recursive: true);

        Process.runSync('chmod', <String>['755', locked]);
        expect(
          listed,
          isA<Success<List<FilesystemEntryDto>, FilesystemFailure>>(),
        );
        final List<String> paths =
            (listed as Success<List<FilesystemEntryDto>, FilesystemFailure>)
                .value
                .map((FilesystemEntryDto e) => slashed(e.path))
                .toList();
        // The folder itself is still reported: it exists, it just would not
        // open.
        expect(paths, contains('${slashed(tempDir.path)}/docs/deep/nested.md'));
        expect(paths, contains('${slashed(tempDir.path)}/locked'));
        expect(paths.where((String p) => p.contains('/locked/')), isEmpty);
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test(
      'fails with FilesystemAccessDenied when the directory itself will not '
      'open',
      () async {
        final String locked = '${tempDir.path}/locked';
        Directory(locked).createSync();
        Process.runSync('chmod', <String>['000', locked]);

        final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
            await filesystem.listDirectory(locked);

        Process.runSync('chmod', <String>['755', locked]);
        expect(
          listed,
          isA<Failure<List<FilesystemEntryDto>, FilesystemFailure>>(),
        );
        expect(
          (listed as Failure<List<FilesystemEntryDto>, FilesystemFailure>)
              .failure,
          named<FilesystemAccessDenied>(locked),
        );
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test('fails when the path is a file rather than a directory', () async {
      final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
          await filesystem.listDirectory('${tempDir.path}/readme.md');

      expect(
        listed,
        isA<Failure<List<FilesystemEntryDto>, FilesystemFailure>>(),
      );
    });
  });

  group('directoryExists', () {
    test('true for a directory', () async {
      final Result<bool, FilesystemFailure> exists = await filesystem
          .directoryExists(tempDir.path);

      expect((exists as Success<bool, FilesystemFailure>).value, isTrue);
    });

    test('false for a path with nothing at it', () async {
      final Result<bool, FilesystemFailure> exists = await filesystem
          .directoryExists('${tempDir.path}/gone');

      expect((exists as Success<bool, FilesystemFailure>).value, isFalse);
    });

    test(
      'fails when the parent directory cannot be read',
      () async {
        // Not false: "the folder is gone" and "this machine will not say" are
        // different answers.
        final String parent = '${tempDir.path}/locked';
        Directory('$parent/space').createSync(recursive: true);
        Process.runSync('chmod', <String>['000', parent]);

        final Result<bool, FilesystemFailure> exists = await filesystem
            .directoryExists('$parent/space');

        Process.runSync('chmod', <String>['755', parent]);
        expect(exists, isA<Failure<bool, FilesystemFailure>>());
        expect(
          (exists as Failure<bool, FilesystemFailure>).failure,
          named<FilesystemAccessDenied>('$parent/space'),
        );
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test('false for a file, which is not a directory', () async {
      final String path = '${tempDir.path}/note.md';
      File(path).writeAsStringSync('# Note');

      final Result<bool, FilesystemFailure> exists = await filesystem
          .directoryExists(path);

      expect((exists as Success<bool, FilesystemFailure>).value, isFalse);
    });
  });

  group('resolvePath', () {
    test(
      'follows a link to where the folder really is',
      () async {
        final String real = '${tempDir.path}/real';
        Directory('$real/docs').createSync(recursive: true);
        Link('${tempDir.path}/link').createSync(real);

        final Result<String, FilesystemFailure> resolved = await filesystem
            .resolvePath('${tempDir.path}/link/docs');

        expect(
          (resolved as Success<String, FilesystemFailure>).value,
          Directory('$real/docs').resolveSymbolicLinksSync(),
        );
      },
      skip: Platform.isWindows
          ? 'creating a symbolic link needs a privilege on Windows'
          : false,
    );

    test(
      'spells a folder with no link on it the way the machine does',
      () async {
        final String path = '${tempDir.path}/plain';
        Directory(path).createSync();

        final Result<String, FilesystemFailure> resolved = await filesystem
            .resolvePath(path);

        expect(
          (resolved as Success<String, FilesystemFailure>).value,
          Directory(path).resolveSymbolicLinksSync(),
        );
      },
    );

    test('fails for a path with nothing at it', () async {
      final String path = '${tempDir.path}/gone';

      final Result<String, FilesystemFailure> resolved = await filesystem
          .resolvePath(path);

      expect(
        (resolved as Failure<String, FilesystemFailure>).failure,
        named<FilesystemEntryNotFound>(path),
      );
    });
  });
}
