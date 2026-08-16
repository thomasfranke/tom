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

  test(
    'writeFile fails with FilesystemEntryNotFound for a missing directory',
    () async {
      final Result<void> written = await filesystem.writeFile(
        '${tempDir.path}/no_such_dir/note.md',
        'content',
      );

      expect(written, isA<Failure<void>>());
      expect(
        (written as Failure<void>).failure,
        FilesystemEntryNotFound('${tempDir.path}/no_such_dir/note.md'),
      );
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
}
