/// [SpaceRepositoryImpl] on a real disk, past the happy path: making a
/// folder and its refusals, and a listing over what a real folder holds —
/// locked folders, links, a worktree's `.git`, odd names, thousands of files.
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
  late SpaceEntity space;
  late SpaceRepositoryImpl repository;

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

  void put(String relativePath, [String content = '']) {
    File('$root/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  Future<List<String>> listed() async => <String>[
    for (final SpaceEntryValueObject entry in valueOf(
      await repository.entries(space),
    ))
      entry.path.value,
  ];

  Future<Result<void, SpaceFailure>> createFolder(String path) =>
      repository.createFolder(space, SpaceRelativePathValueObject(path));

  /// Runs `chmod`, and puts [restore] back when the test ends so the
  /// temporary folder can be removed.
  void chmod(String mode, String path, {required String restore}) {
    Process.runSync('chmod', <String>[mode, path]);
    addTearDown(() => Process.runSync('chmod', <String>[restore, path]));
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_space_folders_');
    // Resolved, because the macOS temporary directory is a symlink and a
    // space must compare equal to the paths a listing reports.
    repositoryRoot = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    // A space below its repository's root, which is the ordinary case and the
    // one a test at the root cannot tell from a mistake (rule 12).
    root = '$repositoryRoot/docs';
    Directory(root).createSync();
    space = SpaceEntity(
      root: root,
      repositoryRoot: repositoryRoot,
      name: 'docs',
    );
    repository = SpaceRepositoryImpl(
      spaces: SpaceDataSource(
        filesystem: const DartIoFilesystemImpl(),
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  const String posixOnly = 'permissions and links are POSIX here';

  group('making a folder', () {
    test('it is made inside the space, not at the repository root', () async {
      expect(await createFolder('guides'), isA<Success<void, SpaceFailure>>());

      expect(Directory('$root/guides').existsSync(), isTrue);
      expect(Directory('$repositoryRoot/guides').existsSync(), isFalse);
      expect(await listed(), <String>['guides']);
    });

    test(
      'inside a folder that is not there yet, the way is made too',
      () async {
        await createFolder('guides/2026/q3');

        expect(await listed(), <String>[
          'guides',
          'guides/2026',
          'guides/2026/q3',
        ]);
      },
    );

    test(
      'a folder of that name is not reused, and keeps what it holds',
      () async {
        put('guides/start.md', '# Start\n');

        expect(
          failureOf(await createFolder('guides')),
          isA<SpaceEntryExists>().having(
            (SpaceEntryExists failure) => failure.path,
            'path',
            'guides',
          ),
        );
        expect(File('$root/guides/start.md').readAsStringSync(), '# Start\n');
      },
    );

    test('a file of that name is not shadowed, and keeps its text', () async {
      put('guides', 'a file with no extension\n');

      expect(
        failureOf(await createFolder('guides')),
        isA<SpaceEntryExists>().having(
          (SpaceEntryExists failure) => failure.path,
          'path',
          'guides',
        ),
      );
      expect(
        File('$root/guides').readAsStringSync(),
        'a file with no extension\n',
      );
    });

    test(
      'a link of that name is kept, even one that points at nothing',
      () async {
        Link('$root/guides').createSync('$repositoryRoot/gone');

        expect(
          failureOf(await createFolder('guides')),
          isA<SpaceEntryExists>(),
        );
        expect(
          FileSystemEntity.typeSync('$root/guides', followLinks: false),
          FileSystemEntityType.link,
        );
        expect(Directory('$repositoryRoot/gone').existsSync(), isFalse);
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test(
      'a space that cannot be written to refuses, and holds nothing new',
      () async {
        chmod('555', root, restore: '755');

        expect(
          failureOf(await createFolder('guides')),
          isA<SpaceAccessDenied>(),
        );
        expect(Directory(root).listSync(), isEmpty);
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test('under a file there is nowhere to make it, and the file is '
        'kept', () async {
      put('notes.md', '# Notes\n');

      expect(
        failureOf(await createFolder('notes.md/inner')),
        isA<SpaceFailure>(),
      );
      expect(File('$root/notes.md').readAsStringSync(), '# Notes\n');
    });

    for (final String name in <String>[
      'release notes',
      'revisão',
      '-drafts',
      '.hidden',
    ]) {
      test('`$name` is a name a folder can have', () async {
        expect(await createFolder(name), isA<Success<void, SpaceFailure>>());

        expect(Directory('$root/$name').existsSync(), isTrue);
        expect(
          failureOf(await createFolder(name)),
          isA<SpaceEntryExists>().having(
            (SpaceEntryExists failure) => failure.path,
            'path',
            name,
          ),
        );
      });
    }
  });

  group('listing', () {
    test('a folder the machine will not open costs itself: it is listed, its '
        'contents are not, and its neighbours are whole', () async {
      put('locked/secret.md');
      put('open/guide.md');
      put('readme.md');
      chmod('000', '$root/locked', restore: '755');

      expect(await listed(), <String>[
        'locked',
        'open',
        'open/guide.md',
        'readme.md',
      ]);
    }, skip: Platform.isWindows ? posixOnly : false);

    test(
      'a space whose own folder will not open is refused by name',
      () async {
        put('readme.md');
        chmod('000', root, restore: '755');

        expect(
          failureOf(await repository.entries(space)),
          isA<SpaceAccessDenied>().having(
            (SpaceAccessDenied failure) => failure.path,
            'path',
            root,
          ),
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test(
      'a space that became a file is a failure, not an empty tree',
      () async {
        Directory(root).deleteSync();
        File(root).writeAsStringSync('not a folder');

        expect(failureOf(await repository.entries(space)), isA<SpaceFailure>());
      },
    );

    test("`.git` as a file — a worktree's, a submodule's — is hidden like "
        'the folder', () async {
      put('.git', 'gitdir: /somewhere/else/.git/worktrees/docs\n');
      put('module/.git', 'gitdir: ../.git/modules/module\n');
      put('module/readme.md');
      put('readme.md');

      expect(await listed(), <String>[
        'module',
        'module/readme.md',
        'readme.md',
      ]);
    });

    test(
      'a `.git` folder below the root is not descended into either',
      () async {
        put('vendored/.git/HEAD', 'ref: refs/heads/main\n');
        put('vendored/.git/objects/aa/bb');
        put('vendored/guide.md');
        // Names that only start like it are ordinary.
        put('.gitignore');
        put('.github/workflows/ci.yml');

        expect(await listed(), <String>[
          '.github',
          '.github/workflows',
          '.github/workflows/ci.yml',
          'vendored',
          'vendored/guide.md',
          '.gitignore',
        ]);
      },
    );

    test(
      'a link to a folder is one row and is not walked, wherever it points',
      () async {
        put('real/guide.md');
        Directory('$repositoryRoot/outside').createSync();
        File('$repositoryRoot/outside/secret.md').writeAsStringSync('');
        Link('$root/inside-link').createSync('$root/real');
        Link('$root/outside-link').createSync('$repositoryRoot/outside');
        // A loop: a folder that holds a link back to the space.
        Link('$root/real/back').createSync(root);

        final List<SpaceEntryValueObject> entries = valueOf(
          await repository.entries(space),
        );

        expect(
          <String, SpaceEntryTypeEnum>{
            for (final SpaceEntryValueObject entry in entries)
              entry.path.value: entry.type,
          },
          <String, SpaceEntryTypeEnum>{
            'real': SpaceEntryTypeEnum.directory,
            'real/back': SpaceEntryTypeEnum.link,
            'real/guide.md': SpaceEntryTypeEnum.file,
            'inside-link': SpaceEntryTypeEnum.link,
            'outside-link': SpaceEntryTypeEnum.link,
          },
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test(
      'a link that points at nothing, and one to a document, are links',
      () async {
        put('guide.md');
        Link('$root/dangling.md').createSync('$repositoryRoot/gone.md');
        Link('$root/alias.md').createSync('$root/guide.md');

        final List<SpaceEntryValueObject> entries = valueOf(
          await repository.entries(space),
        );

        expect(
          <String, SpaceEntryTypeEnum>{
            for (final SpaceEntryValueObject entry in entries)
              entry.path.value: entry.type,
          },
          <String, SpaceEntryTypeEnum>{
            'alias.md': SpaceEntryTypeEnum.link,
            'dangling.md': SpaceEntryTypeEnum.link,
            'guide.md': SpaceEntryTypeEnum.file,
          },
        );
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test('a temporary a crashed save left behind is never offered as a '
        'document', () async {
      put('guide.md', '# Guide\n');
      // The name the atomic write gives its temporary.
      put('guide.md.4242.7.tom-tmp', '# Gui');

      final List<SpaceEntryValueObject> entries = valueOf(
        await repository.entries(space),
      );

      expect(
        <String>[
          for (final SpaceEntryValueObject entry in entries)
            if (entry.isDocument) entry.path.value,
        ],
        <String>['guide.md'],
      );
    });

    test('names are in order whatever their case', () async {
      for (final String name in <String>[
        'Zebra.md',
        'alpha.md',
        'Beta.md',
        'gamma.md',
      ]) {
        put(name);
      }

      expect(await listed(), <String>[
        'alpha.md',
        'Beta.md',
        'gamma.md',
        'Zebra.md',
      ]);
    });

    test('and whatever their accents: `Ácido` sorts with the a\'s', () async {
      for (final String name in <String>[
        'zebra.md',
        'Ácido.md',
        'bravo.md',
        'école.md',
        'delta.md',
      ]) {
        put(name);
      }

      // By first letter with its accent taken off, since a disk may hand a
      // name back composed or decomposed.
      const Map<String, String> bare = <String, String>{'Á': 'A', 'é': 'e'};
      expect(
        <String>[
          for (final String path in await listed()) bare[path[0]] ?? path[0],
        ],
        // Ácido · bravo · delta · école · zebra
        <String>['A', 'b', 'd', 'e', 'z'],
      );
    });

    test('names with a space, an accent and a leading dash come back as '
        'they are', () async {
      put('release notes/first draft.md');
      put('-draft.md');
      put('ação.md');

      final List<String> paths = await listed();

      expect(paths, hasLength(4));
      expect(
        paths,
        containsAll(<String>[
          'release notes',
          'release notes/first draft.md',
          '-draft.md',
        ]),
      );
      expect(paths, contains(anyOf('ação.md', 'ação.md')));
    });

    test('five thousand documents in fifty folders are all listed, folders '
        'first, inside ten seconds', () async {
      for (int folder = 0; folder < 50; folder++) {
        final String name = 'folder-${folder.toString().padLeft(2, '0')}';
        Directory('$root/$name').createSync();
        for (int file = 0; file < 100; file++) {
          File('$root/$name/doc-$file.md').writeAsStringSync('');
        }
      }
      put('readme.md');

      final Stopwatch watch = Stopwatch()..start();
      final List<SpaceEntryValueObject> entries = valueOf(
        await repository.entries(space),
      );
      watch.stop();

      expect(entries, hasLength(5051));
      expect(entries.first.path.value, 'folder-00');
      expect(entries.last.path.value, 'readme.md');
      expect(
        entries.where((SpaceEntryValueObject entry) => entry.isDocument),
        hasLength(5001),
      );
      // Generous on purpose: a slow shared runner, not a benchmark.
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });
  });

  group('opening', () {
    test('a file is not a folder to open', () async {
      put('readme.md');

      expect(
        failureOf(await repository.open('$root/readme.md')),
        isA<SpaceFolderMissing>().having(
          (SpaceFolderMissing failure) => failure.root,
          'root',
          '$root/readme.md',
        ),
      );
    });

    test('a folder named with a space and an accent opens under that '
        'name', () async {
      final String folder = '$root/release notes/revisão';
      Directory(folder).createSync(recursive: true);

      final SpaceEntity opened = valueOf(await repository.open(folder));

      expect(opened.name, anyOf('revisão', 'revisão'));
      expect(opened.root, endsWith(opened.name));
      expect(opened.hasRepository, isFalse);
    });

    test('a trailing slash is the same folder', () async {
      Directory('$root/guides').createSync();

      final SpaceEntity opened = valueOf(
        await repository.open('$root/guides/'),
      );

      expect(opened.root, '$root/guides');
      expect(opened.name, 'guides');
    });

    test('a folder behind one the machine will not open is refused, not '
        'missing', () async {
      Directory('$root/locked/inside').createSync(recursive: true);
      chmod('000', '$root/locked', restore: '755');

      expect(
        failureOf(await repository.open('$root/locked/inside')),
        isA<SpaceAccessDenied>(),
      );
    }, skip: Platform.isWindows ? posixOnly : false);
  });
}
