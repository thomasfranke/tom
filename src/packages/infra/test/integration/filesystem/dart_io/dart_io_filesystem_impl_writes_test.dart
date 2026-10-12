/// [DartIoFilesystemImpl] where a write can lose something: a folder that
/// refuses, a link, a mode, a race for one name, a name the disk dislikes.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// Why a test that takes a permission away does not run everywhere: Windows
/// has no POSIX modes, and root is refused nothing.
Object get _needsModes {
  if (Platform.isWindows) {
    return 'chmod does not model POSIX permissions on Windows';
  }
  final Object uid = Process.runSync('id', <String>['-u']).stdout as Object;
  return '$uid'.trim() == '0' ? 'root is refused nothing' : false;
}

void main() {
  late Directory tempDir;
  late DartIoFilesystemImpl filesystem;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_filesystem_writes_');
    filesystem = const DartIoFilesystemImpl();
  });

  tearDown(() {
    // Every folder is opened again first: a test that failed between its two
    // `chmod`s would otherwise leave one nothing can remove.
    if (!Platform.isWindows) {
      Process.runSync('chmod', <String>['-R', 'u+rwx', tempDir.path]);
    }
    tempDir.deleteSync(recursive: true);
  });

  /// A failure of variant [T] naming [path].
  Matcher named<T extends FilesystemFailure>(String path) =>
      isA<T>().having((T failure) => (failure as dynamic).path, 'path', path);

  /// The failure [result] holds, or a failure of the test if it succeeded.
  FilesystemFailure failureOf<T>(Result<T, FilesystemFailure> result) =>
      switch (result) {
        Failure<T, FilesystemFailure>(
          failure: final FilesystemFailure failure,
        ) =>
          failure,
        Success<T, FilesystemFailure>() => throw StateError(
          'expected a failure, got a success',
        ),
      };

  /// The names inside [folder], sorted — a temporary left behind shows here.
  List<String> namesIn(Directory folder) => <String>[
    for (final FileSystemEntity entity in folder.listSync(followLinks: false))
      entity.uri.pathSegments.lastWhere((String it) => it.isNotEmpty),
  ]..sort();

  /// A folder holding `note.md` that nothing may be written into.
  Directory readOnlyFolder() {
    final Directory folder = Directory('${tempDir.path}/locked')..createSync();
    File('${folder.path}/note.md').writeAsStringSync('as it was');
    Process.runSync('chmod', <String>['555', folder.path]);
    return folder;
  }

  /// The permission bits of the file at [path].
  int modeOf(String path) => File(path).statSync().mode & 0x1ff;

  group('a folder that refuses writes', () {
    test('a write over a file fails with FilesystemAccessDenied, the file is '
        'what it was and no temporary is left', () async {
      final Directory folder = readOnlyFolder();
      final String path = '${folder.path}/note.md';

      final Result<void, FilesystemFailure> written = await filesystem
          .writeFile(path, 'replaced');

      expect(failureOf(written), isA<FilesystemAccessDenied>());
      expect(File(path).readAsStringSync(), 'as it was');
      expect(namesIn(folder), <String>['note.md']);
    }, skip: _needsModes);

    test('a write of a new file fails and leaves nothing', () async {
      final Directory folder = readOnlyFolder();
      final String path = '${folder.path}/new.pdf';

      final Result<void, FilesystemFailure> written = await filesystem
          .writeBytes(path, Uint8List.fromList(<int>[1, 2, 3]));

      expect(failureOf(written), isA<FilesystemAccessDenied>());
      expect(namesIn(folder), <String>['note.md']);
    }, skip: _needsModes);

    test(
      'a refused write names the path that was asked for, never its '
      'temporary',
      () async {
        final Directory folder = readOnlyFolder();
        final String path = '${folder.path}/note.md';

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'replaced');

        expect(failureOf(written), named<FilesystemAccessDenied>(path));
      },
      skip: _needsModes != false
          ? _needsModes
          : 'defect S7-FS-2: the failure of a write carries the temporary\'s '
                'path (`note.md.<pid>.<n>.tom-tmp`), a file that never '
                'existed, where the contract says the path the operation '
                'was denied on',
    );

    test(
      'a create fails with FilesystemAccessDenied and leaves nothing',
      () async {
        final Directory folder = readOnlyFolder();
        final String path = '${folder.path}/new.md';

        final Result<void, FilesystemFailure> created = await filesystem
            .createFile(path, '# New');

        expect(failureOf(created), named<FilesystemAccessDenied>(path));
        expect(namesIn(folder), <String>['note.md']);
      },
      skip: _needsModes,
    );

    test('a folder cannot be created in it either', () async {
      final Directory folder = readOnlyFolder();
      final String path = '${folder.path}/drafts';

      final Result<void, FilesystemFailure> created = await filesystem
          .createDirectory(path);

      expect(failureOf(created), named<FilesystemAccessDenied>(path));
      expect(namesIn(folder), <String>['note.md']);
    }, skip: _needsModes);

    test(
      'a delete fails with FilesystemAccessDenied and the file stays',
      () async {
        final Directory folder = readOnlyFolder();
        final String path = '${folder.path}/note.md';

        final Result<void, FilesystemFailure> deleted = await filesystem.delete(
          path,
        );

        expect(failureOf(deleted), named<FilesystemAccessDenied>(path));
        expect(File(path).readAsStringSync(), 'as it was');
      },
      skip: _needsModes,
    );

    test('a delete of a tree holding one such folder fails, and what it '
        'could not remove is still there', () async {
      final Directory tree = Directory('${tempDir.path}/tree')..createSync();
      File('${tree.path}/free.md').writeAsStringSync('free');
      final Directory locked = Directory('${tree.path}/locked')..createSync();
      File('${locked.path}/kept.md').writeAsStringSync('kept');
      Process.runSync('chmod', <String>['555', locked.path]);

      final Result<void, FilesystemFailure> deleted = await filesystem.delete(
        tree.path,
      );

      expect(deleted, isA<Failure<void, FilesystemFailure>>());
      expect(failureOf(deleted), isA<FilesystemAccessDenied>());
      expect(File('${locked.path}/kept.md').readAsStringSync(), 'kept');
    }, skip: _needsModes);
  });

  group('a write over what is already there', () {
    test(
      'follows a symbolic link: the link stays one and its target is written',
      () async {
        final String target = '${tempDir.path}/shared/guide.md';
        File(target)
          ..createSync(recursive: true)
          ..writeAsStringSync('old');
        final String path = '${tempDir.path}/guide.md';
        Link(path).createSync(target);

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'new');

        expect(written, isA<Success<void, FilesystemFailure>>());
        expect(
          FileSystemEntity.typeSync(path, followLinks: false),
          FileSystemEntityType.link,
        );
        expect(File(target).readAsStringSync(), 'new');
        expect(namesIn(tempDir), <String>['guide.md', 'shared']);
      },
      skip: Platform.isWindows
          ? 'creating a link needs a privilege on Windows'
          : false,
    );

    test(
      'follows a link to a file that is not there yet, and creates it',
      () async {
        final String target = '${tempDir.path}/shared/later.md';
        Directory('${tempDir.path}/shared').createSync();
        final String path = '${tempDir.path}/later.md';
        Link(path).createSync('shared/later.md');

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'new');

        expect(written, isA<Success<void, FilesystemFailure>>());
        expect(
          FileSystemEntity.typeSync(path, followLinks: false),
          FileSystemEntityType.link,
        );
        expect(File(target).readAsStringSync(), 'new');
      },
      skip: Platform.isWindows
          ? 'creating a link needs a privilege on Windows'
          : false,
    );

    test(
      'a file nobody may write to is refused, and is what it was',
      () async {
        final String path = '${tempDir.path}/sealed.md';
        File(path).writeAsStringSync('old');
        Process.runSync('chmod', <String>['444', path]);

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'new');

        expect(failureOf(written), named<FilesystemAccessDenied>(path));
        expect(File(path).readAsStringSync(), 'old');
        expect(modeOf(path).toRadixString(8), '444');
        expect(namesIn(tempDir), <String>['sealed.md']);
      },
      skip: _needsModes,
    );

    test(
      'keeps the mode the file had',
      () async {
        final String path = '${tempDir.path}/private.md';
        File(path).writeAsStringSync('old');
        Process.runSync('chmod', <String>['600', path]);

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'new');

        expect(written, isA<Success<void, FilesystemFailure>>());
        expect(File(path).readAsStringSync(), 'new');
        expect(modeOf(path).toRadixString(8), '600');
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test(
      'keeps an executable script executable',
      () async {
        final String path = '${tempDir.path}/build.sh';
        File(path).writeAsStringSync('#!/bin/sh\n');
        Process.runSync('chmod', <String>['755', path]);

        await filesystem.writeFile(path, '#!/bin/sh\necho built\n');

        expect(modeOf(path).toRadixString(8), '755');
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );

    test('replaces a longer file whole, with no temporary beside it', () async {
      final String path = '${tempDir.path}/note.md';
      File(path).writeAsStringSync('a much longer text than the next one');

      await filesystem.writeFile(path, 'short');

      expect(File(path).readAsStringSync(), 'short');
      expect(namesIn(tempDir), <String>['note.md']);
    });
  });

  group('a parent that is a file', () {
    test('refuses a write below it, and the file is what it was', () async {
      final String parent = '${tempDir.path}/note.md';
      File(parent).writeAsStringSync('a document');

      final Result<void, FilesystemFailure> written = await filesystem
          .writeFile('$parent/child.md', 'below a file');

      // Not `alreadyExists`: only an exclusive create says that, by the
      // failure's own contract.
      expect(failureOf(written), isA<FilesystemOperationFailed>());
      expect(File(parent).readAsStringSync(), 'a document');
      expect(namesIn(tempDir), <String>['note.md']);
    });

    test('refuses a create below it', () async {
      final String parent = '${tempDir.path}/note.md';
      File(parent).writeAsStringSync('a document');

      final Result<void, FilesystemFailure> created = await filesystem
          .createFile('$parent/child.md', '');

      expect(created, isA<Failure<void, FilesystemFailure>>());
      expect(File(parent).readAsStringSync(), 'a document');
    });

    test('a read below it finds nothing rather than something', () async {
      final String parent = '${tempDir.path}/note.md';
      File(parent).writeAsStringSync('a document');

      final Result<String, FilesystemFailure> read = await filesystem.readFile(
        '$parent/child.md',
      );

      expect(read, isA<Failure<String, FilesystemFailure>>());
    });
  });

  group('createFile', () {
    test('twenty racing for one name: exactly one succeeds, the rest are '
        'told the name is taken', () async {
      final String path = '${tempDir.path}/untitled.md';

      final List<Result<void, FilesystemFailure>> results = await Future.wait(
        <Future<Result<void, FilesystemFailure>>>[
          for (int i = 0; i < 20; i++) filesystem.createFile(path, ''),
        ],
      );

      expect(
        results.whereType<Success<void, FilesystemFailure>>(),
        hasLength(1),
      );
      expect(
        results.whereType<Failure<void, FilesystemFailure>>().map(
          (Failure<void, FilesystemFailure> it) => it.failure,
        ),
        everyElement(named<FilesystemAlreadyExists>(path)),
      );
      expect(namesIn(tempDir), <String>['untitled.md']);
    });

    test('twenty racing with their own text: the file holds the winner\'s, '
        'whole', () async {
      final String path = '${tempDir.path}/untitled.md';

      final List<Result<void, FilesystemFailure>> results = await Future.wait(
        <Future<Result<void, FilesystemFailure>>>[
          for (int i = 0; i < 20; i++)
            filesystem.createFile(path, 'written by $i\n' * 200),
        ],
      );

      final int winner = results.indexWhere(
        (Result<void, FilesystemFailure> it) =>
            it is Success<void, FilesystemFailure>,
      );
      expect(
        results.whereType<Success<void, FilesystemFailure>>(),
        hasLength(1),
      );
      expect(File(path).readAsStringSync(), 'written by $winner\n' * 200);
      expect(namesIn(tempDir), <String>['untitled.md']);
    });

    test('where a folder holds the name fails with FilesystemAlreadyExists, '
        'and the folder keeps what it held', () async {
      final String path = '${tempDir.path}/guide.md';
      File('$path/inside.md')
        ..createSync(recursive: true)
        ..writeAsStringSync('kept');

      final Result<void, FilesystemFailure> created = await filesystem
          .createFile(path, '# Guide');

      expect(failureOf(created), named<FilesystemAlreadyExists>(path));
      expect(File('$path/inside.md').readAsStringSync(), 'kept');
    });

    test(
      'where a dangling link holds the name fails with '
      'FilesystemAlreadyExists, and nothing is created through the link',
      () async {
        final String target = '${tempDir.path}/elsewhere.md';
        final String path = '${tempDir.path}/guide.md';
        Link(path).createSync(target);

        final Result<void, FilesystemFailure> created = await filesystem
            .createFile(path, '# Guide');

        expect(failureOf(created), named<FilesystemAlreadyExists>(path));
        expect(File(target).existsSync(), isFalse);
        expect(
          FileSystemEntity.typeSync(path, followLinks: false),
          FileSystemEntityType.link,
        );
      },
      skip: Platform.isWindows
          ? 'creating a link needs a privilege on Windows'
          : false,
    );

    test(
      'whose text cannot be written leaves no empty file holding the name',
      () async {
        // 250 bytes is a name the disk takes; the temporary the write puts
        // beside it is longer than any name may be, so the create succeeds
        // and the write after it is refused by the machine itself.
        final String path = '${tempDir.path}/${'n' * 247}.md';

        final Result<void, FilesystemFailure> created = await filesystem
            .createFile(path, '# Seeded');

        expect(created, isA<Failure<void, FilesystemFailure>>());
        expect(File(path).existsSync(), isFalse);
        expect(namesIn(tempDir), isEmpty);
      },
      skip: Platform.isWindows
          ? 'the limit is the path\'s on Windows, not the name\'s'
          : 'defect A-09: createFile is an exclusive empty create and then '
                'the atomic write; when the write fails the empty file keeps '
                'the name, and the next read takes it for what was written',
    );
  });

  group('a name', () {
    for (final (String what, String name) in <(String, String)>[
      ('with a space', 'release notes.md'),
      ('with an accent, composed', 'Ação.md'),
      ('with an accent, decomposed', 'Ação.md'),
      ('with a leading dash', '-rf.md'),
      ('that is only dots and a dash', '..-.md'),
    ]) {
      test('$what is written, read, listed and removed', () async {
        final String path = '${tempDir.path}/$name';

        expect(
          await filesystem.writeFile(path, 'body'),
          isA<Success<void, FilesystemFailure>>(),
        );
        final Result<String, FilesystemFailure> read = await filesystem
            .readFile(path);
        final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
            await filesystem.listDirectory(tempDir.path);

        expect((read as Success<String, FilesystemFailure>).value, 'body');
        expect(
          (listed as Success<List<FilesystemEntryDto>, FilesystemFailure>).value
              .map((FilesystemEntryDto it) => it.path),
          <String>[path],
        );

        expect(
          await filesystem.delete(path),
          isA<Success<void, FilesystemFailure>>(),
        );
        expect(namesIn(tempDir), isEmpty);
      });
    }

    test(
      'with an accent is created once, whichever form asks second',
      () async {
        final String composed = '${tempDir.path}/Ação.md';
        final String decomposed = '${tempDir.path}/Ação.md';

        await filesystem.createFile(composed, 'first');
        final Result<void, FilesystemFailure> second = await filesystem
            .createFile(decomposed, 'second');

        // Which it is depends on the disk — one name on a disk that folds the
        // two forms, two names on one that does not — and never a replacement.
        expect(File(composed).readAsStringSync(), 'first');
        switch (second) {
          case Success<void, FilesystemFailure>():
            expect(namesIn(tempDir), hasLength(2));
          case Failure<void, FilesystemFailure>(
            failure: final FilesystemFailure failure,
          ):
            expect(failure, named<FilesystemAlreadyExists>(decomposed));
            expect(namesIn(tempDir), hasLength(1));
        }
      },
    );

    test(
      'as long as a name may be — 255 bytes — is written and read back',
      () async {
        final String path = '${tempDir.path}/${'n' * 252}.md';

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'body');

        expect(written, isA<Success<void, FilesystemFailure>>());
        expect(File(path).readAsStringSync(), 'body');
        expect(namesIn(tempDir), hasLength(1));
      },
      skip: Platform.isWindows
          ? 'the limit is the path\'s on Windows, not the name\'s'
          : 'defect S7-FS-1: the temporary is the name plus '
                '`.<pid>.<n>.tom-tmp`, so a file whose own name is legal but '
                'within about fifteen bytes of the limit can never be '
                'written — ENAMETOOLONG on the temporary',
    );

    test(
      'one byte longer than a name may be is refused, and nothing is '
      'left',
      () async {
        final String path = '${tempDir.path}/${'n' * 253}.md';

        final Result<void, FilesystemFailure> written = await filesystem
            .writeFile(path, 'body');
        final Result<void, FilesystemFailure> created = await filesystem
            .createFile(path, '');

        expect(failureOf(written), isA<FilesystemOperationFailed>());
        expect(failureOf(created), named<FilesystemOperationFailed>(path));
        expect(namesIn(tempDir), isEmpty);
      },
      skip: Platform.isWindows
          ? 'the limit is the path\'s on Windows, not the name\'s'
          : false,
    );
  });

  group('the bytes', () {
    test(
      'CRLF and a missing final newline are written byte for byte',
      () async {
        final String path = '${tempDir.path}/windows.md';
        const String content = '# Title\r\n\r\nBody\r\nlast line, no newline';

        await filesystem.writeFile(path, content);

        expect(File(path).readAsBytesSync(), utf8.encode(content));
        expect(
          (await filesystem.readFile(path)
                  as Success<String, FilesystemFailure>)
              .value,
          content,
        );
      },
    );

    test(
      'a lone carriage return and mixed endings are kept as they are',
      () async {
        final String path = '${tempDir.path}/mixed.md';
        const String content = 'one\rtwo\r\nthree\nfour\n\n';

        await filesystem.writeFile(path, content);

        expect(File(path).readAsBytesSync(), utf8.encode(content));
      },
    );

    test(
      'a byte order mark survives a read and the write of what was read',
      () async {
        final String path = '${tempDir.path}/bom.md';
        final List<int> bytes = <int>[
          0xEF,
          0xBB,
          0xBF,
          ...utf8.encode('# T\n'),
        ];
        File(path).writeAsBytesSync(bytes);

        final String read =
            (await filesystem.readFile(path)
                    as Success<String, FilesystemFailure>)
                .value;
        await filesystem.writeFile(path, read);

        expect(File(path).readAsBytesSync(), bytes);
      },
      skip:
          'defect S7-FS-3: `utf8.decode` drops a leading byte order mark, '
          'so a document that starts with one is read without it and saved '
          'three bytes shorter — the lossless read FilesystemNotUtf8 '
          'promises does not hold for it',
    );

    test('a file with no byte order mark is given none', () async {
      final String path = '${tempDir.path}/plain.md';

      await filesystem.writeFile(path, '# T\n');

      expect(File(path).readAsBytesSync(), utf8.encode('# T\n'));
    });

    test('an empty file reads as empty text and as no bytes', () async {
      final String path = '${tempDir.path}/empty.md';
      File(path).createSync();

      final Result<String, FilesystemFailure> text = await filesystem.readFile(
        path,
      );
      final Result<Uint8List, FilesystemFailure> bytes = await filesystem
          .readBytes(path);

      expect((text as Success<String, FilesystemFailure>).value, isEmpty);
      expect((bytes as Success<Uint8List, FilesystemFailure>).value, isEmpty);
    });

    test('writing empty text over a file empties it', () async {
      final String path = '${tempDir.path}/note.md';
      File(path).writeAsStringSync('something');

      await filesystem.writeFile(path, '');

      expect(File(path).lengthSync(), 0);
    });

    test('twenty megabytes go to the disk and come back the same', () async {
      final String path = '${tempDir.path}/large.bin';
      final Uint8List bytes = Uint8List(20 * 1024 * 1024);
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = (i * 31 + (i >> 8)) & 0xff;
      }

      final Result<void, FilesystemFailure> written = await filesystem
          .writeBytes(path, bytes);
      final Result<Uint8List, FilesystemFailure> read = await filesystem
          .readBytes(path);

      expect(written, isA<Success<void, FilesystemFailure>>());
      final Uint8List back =
          (read as Success<Uint8List, FilesystemFailure>).value;
      expect(back.length, bytes.length);
      int differing = 0;
      for (int i = 0; i < bytes.length; i++) {
        if (back[i] != bytes[i]) {
          differing++;
        }
      }
      expect(differing, 0);
      expect(namesIn(tempDir), <String>['large.bin']);
    });

    test(
      'a megabyte of text on one line, accents included, round-trips',
      () async {
        final String path = '${tempDir.path}/long-line.md';
        final String content = 'revisão ' * 120000;

        await filesystem.writeFile(path, content);

        expect(
          (await filesystem.readFile(path)
                  as Success<String, FilesystemFailure>)
              .value,
          content,
        );
      },
    );
  });
}
