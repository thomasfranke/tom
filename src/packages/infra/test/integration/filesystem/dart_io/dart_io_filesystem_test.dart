/// [DartIoFilesystem] against a real temporary directory.
///
/// Integration, not unit: the contract's whole job is talking to the actual
/// filesystem, so a fake would test nothing `dart:io` itself doesn't already
/// guarantee.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late DartIoFilesystem filesystem;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_filesystem_test_');
    filesystem = const DartIoFilesystem();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// [path] with forward slashes, whatever the platform reported.
  ///
  /// `dart:io` hands back a Windows path with backslashes, so an assertion
  /// written with `/` would pass on two of the three platforms TOM ships on
  /// and fail on the third. Normalising in the test keeps the assertion
  /// readable without pretending the difference is not there.
  String slashed(String path) => path.replaceAll(r'\', '/');

  test('writeFile then readFile round-trips the content', () async {
    final String path = '${tempDir.path}/note.md';

    final Result<void> written = await filesystem.writeFile(path, '# Hello');
    expect(written, isA<Success<void>>());

    final Result<String> read = await filesystem.readFile(path);
    expect(read, isA<Success<String>>());
    expect((read as Success<String>).value, '# Hello');
  });

  test('writeFile overwrites an existing file', () async {
    final String path = '${tempDir.path}/note.md';

    await filesystem.writeFile(path, 'first');
    await filesystem.writeFile(path, 'second');

    final Result<String> read = await filesystem.readFile(path);
    expect((read as Success<String>).value, 'second');
  });

  test(
    'readFile fails with FilesystemEntryNotFound for a missing file',
    () async {
      final Result<String> read = await filesystem.readFile(
        '${tempDir.path}/missing.md',
      );

      expect(read, isA<Failure<String>>());
      expect(
        (read as Failure<String>).failure,
        FilesystemEntryNotFound('${tempDir.path}/missing.md'),
      );
    },
  );

  test('writeFile creates the directories the path needs', () async {
    final String path = '${tempDir.path}/notes/2026/q1.md';

    final Result<void> written = await filesystem.writeFile(path, '# Q1');

    expect(written, isA<Success<void>>());
    expect(File(path).readAsStringSync(), '# Q1');
  });

  test('writeFile leaves nothing beside the file it wrote', () async {
    // The write goes through a temporary sibling and a rename — that is what
    // makes it atomic — and the temporary is not the caller's business.
    await filesystem.writeFile('${tempDir.path}/note.md', '# Hello');

    expect(
      tempDir.listSync().map(
        (FileSystemEntity e) => slashed(e.path).split('/').last,
      ),
      <String>['note.md'],
    );
  });

  test('a write that cannot land leaves no temporary behind', () async {
    // A directory cannot be replaced by a file: the rename is what fails,
    // which is precisely the moment a temporary would be orphaned.
    final String path = '${tempDir.path}/folder';
    Directory(path).createSync();

    final Result<void> written = await filesystem.writeFile(path, 'content');

    expect(written, isA<Failure<void>>());
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

      final Result<String> read = await filesystem.readFile(path);

      expect(read, isA<Failure<String>>());
      expect((read as Failure<String>).failure, FilesystemNotUtf8(path));
    },
  );

  test(
    'readFile fails with FilesystemOperationFailed for a directory',
    () async {
      final Result<String> read = await filesystem.readFile(tempDir.path);

      expect(read, isA<Failure<String>>());
      expect(
        (read as Failure<String>).failure,
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

      final Result<String> read = await filesystem.readFile(path);

      Process.runSync('chmod', <String>['644', path]);
      expect(read, isA<Failure<String>>());
      expect((read as Failure<String>).failure, FilesystemAccessDenied(path));
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
      final Result<List<FilesystemEntry>> listed = await filesystem
          .listDirectory(tempDir.path);

      expect(listed, isA<Success<List<FilesystemEntry>>>());
      final List<String> names = (listed as Success<List<FilesystemEntry>>)
          .value
          .map((FilesystemEntry e) => slashed(e.path).split('/').last)
          .toList();
      expect(names, <String>['.ai', '.git', 'docs', 'readme.md']);
    });

    test('reports what each entry is', () async {
      final List<FilesystemEntry> entries =
          (await filesystem.listDirectory(tempDir.path)
                  as Success<List<FilesystemEntry>>)
              .value;

      expect(
        entries
            .firstWhere((FilesystemEntry e) => e.path.endsWith('readme.md'))
            .type,
        FilesystemEntryType.file,
      );
      expect(
        entries.firstWhere((FilesystemEntry e) => e.path.endsWith('docs')).type,
        FilesystemEntryType.directory,
      );
    });

    test('recursive reaches every dotfolder, filtering nothing', () async {
      final List<String> paths =
          (await filesystem.listDirectory(tempDir.path, recursive: true)
                  as Success<List<FilesystemEntry>>)
              .value
              .map((FilesystemEntry e) => slashed(e.path))
              .toList();

      // `.git/` is hidden by the tree, not by the capability — the caller's
      // policy, so it has to arrive here.
      final String root = slashed(tempDir.path);
      expect(paths, contains('$root/.git/config'));
      expect(paths, contains('$root/.ai/skills/notes.md'));
      expect(paths, contains('$root/docs/deep/nested.md'));
    });

    test(
      'reports a symlink as a link and does not follow it',
      () async {
        Link('${tempDir.path}/loop').createSync(tempDir.path);

        final List<FilesystemEntry> entries =
            (await filesystem.listDirectory(tempDir.path, recursive: true)
                    as Success<List<FilesystemEntry>>)
                .value;

        // Following it would walk its own parent forever.
        expect(
          entries
              .firstWhere(
                (FilesystemEntry e) => slashed(e.path).endsWith('/loop'),
              )
              .type,
          FilesystemEntryType.link,
        );
        expect(
          entries.where(
            (FilesystemEntry e) => slashed(e.path).contains('/loop/'),
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
        final Result<List<FilesystemEntry>> listed = await filesystem
            .listDirectory('${tempDir.path}/nowhere');

        expect(listed, isA<Failure<List<FilesystemEntry>>>());
        expect(
          (listed as Failure<List<FilesystemEntry>>).failure,
          FilesystemEntryNotFound('${tempDir.path}/nowhere'),
        );
      },
    );

    test(
      'a folder that cannot be opened costs that folder, not the listing',
      () async {
        final String locked = '${tempDir.path}/locked';
        Directory('$locked/inside').createSync(recursive: true);
        Process.runSync('chmod', <String>['000', locked]);

        final Result<List<FilesystemEntry>> listed = await filesystem
            .listDirectory(tempDir.path, recursive: true);

        Process.runSync('chmod', <String>['755', locked]);
        expect(listed, isA<Success<List<FilesystemEntry>>>());
        final List<String> paths = (listed as Success<List<FilesystemEntry>>)
            .value
            .map((FilesystemEntry e) => slashed(e.path))
            .toList();
        // Everything readable is still there, and the folder itself is
        // reported — it exists, it just would not open.
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

        final Result<List<FilesystemEntry>> listed = await filesystem
            .listDirectory(locked);

        Process.runSync('chmod', <String>['755', locked]);
        expect(listed, isA<Failure<List<FilesystemEntry>>>());
        expect(
          (listed as Failure<List<FilesystemEntry>>).failure,
          FilesystemAccessDenied(locked),
        );
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test('fails when the path is a file rather than a directory', () async {
      final Result<List<FilesystemEntry>> listed = await filesystem
          .listDirectory('${tempDir.path}/readme.md');

      expect(listed, isA<Failure<List<FilesystemEntry>>>());
    });
  });

  group('directoryExists', () {
    test('true for a directory', () async {
      final Result<bool> exists = await filesystem.directoryExists(
        tempDir.path,
      );

      expect((exists as Success<bool>).value, isTrue);
    });

    test('false for a path with nothing at it', () async {
      final Result<bool> exists = await filesystem.directoryExists(
        '${tempDir.path}/gone',
      );

      expect((exists as Success<bool>).value, isFalse);
    });

    test(
      'fails when the parent directory cannot be read',
      () async {
        // Not false: `existsSync` throws here rather than answering, and the
        // difference matters — "the folder is gone" and "this machine will
        // not say" are different things to tell someone about a space.
        final String parent = '${tempDir.path}/locked';
        Directory('$parent/space').createSync(recursive: true);
        Process.runSync('chmod', <String>['000', parent]);

        final Result<bool> exists = await filesystem.directoryExists(
          '$parent/space',
        );

        Process.runSync('chmod', <String>['755', parent]);
        expect(exists, isA<Failure<bool>>());
        expect(
          (exists as Failure<bool>).failure,
          FilesystemAccessDenied('$parent/space'),
        );
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test('false for a file, which is not a directory', () async {
      final String path = '${tempDir.path}/note.md';
      File(path).writeAsStringSync('# Note');

      final Result<bool> exists = await filesystem.directoryExists(path);

      expect((exists as Success<bool>).value, isFalse);
    });
  });
}
