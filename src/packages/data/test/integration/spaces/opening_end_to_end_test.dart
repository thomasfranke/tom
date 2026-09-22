/// Opening a folder, with every real implementation behind it.
///
/// The others in this folder each test one class against one real thing.
/// This one wires the stack the way the composition root does — real disk,
/// real git, real JSON file — and asks the question the user asks: *open
/// this folder*. It is the only test that fails if the pieces are each
/// correct and do not fit together.
///
/// It stands in for clicking the button, which a test cannot do: the folder
/// picker is a native dialog.
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
  late String base;
  late String preferences;
  late SpaceRepository spaces;
  late RecentSpacesRepository recents;

  void git(List<String> arguments, {required String inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  String initRepository(String name) {
    final String path = '$base/$name';
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '.'], inside: path);
    return path;
  }

  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_end_to_end_');
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    preferences = '$base/support/preferences.json';
    // Exactly the graph `providers.dart` builds, with nothing faked.
    const Filesystem filesystem = DartIoFilesystem();
    spaces = SpaceRepositoryImpl(
      filesystem: filesystem,
      gitClientFor: (String folder) =>
          DartIoGitClient(workingDirectory: folder),
    );
    recents = RecentSpacesRepositoryImpl(
      settings: JsonFileSettings(filesystem: filesystem, path: preferences),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('a folder becomes a space, and is remembered on disk', () async {
    final String repoPath = initRepository('app');
    Directory('$repoPath/docs').createSync();

    final SpaceEntity space = valueOf(await spaces.open('$repoPath/docs'));
    valueOf(await recents.remember(space));

    // The space knows both paths, which is what every later git call needs.
    expect(space.root, '$repoPath/docs');
    expect(space.repositoryRoot, repoPath);
    expect(space.name, 'docs');

    // And it survives the process: a second repository over the same file
    // is what a restart looks like.
    final RecentSpacesRepository reopened = RecentSpacesRepositoryImpl(
      settings: JsonFileSettings(
        filesystem: const DartIoFilesystem(),
        path: preferences,
      ),
    );
    final List<RecentSpaceEntity> remembered = valueOf(await reopened.list());
    expect(remembered.single.root, '$repoPath/docs');
    expect(remembered.single.name, 'docs');
  });

  test('the preferences file is one a person could read', () async {
    final String repoPath = initRepository('app');

    valueOf(await recents.remember(valueOf(await spaces.open(repoPath))));

    final Object? stored = jsonDecode(File(preferences).readAsStringSync());
    expect(stored, isA<Map<String, Object?>>());
    expect((stored! as Map<String, Object?>).keys, contains('spaces.recent'));
  });

  test('a folder outside any repository is refused, and not remembered', () {
    // The product's rule, proved against a real git rather than a fake: TOM
    // never creates a repository on the user's behalf.
    final String loose = '$base/loose';
    Directory(loose).createSync();

    expect(
      spaces.open(loose),
      completion(isA<Failure<SpaceEntity, AppFailure>>()),
    );
    expect(File(preferences).existsSync(), isFalse);
  });

  test('nothing is written until something is actually stored', () {
    // A user who never opens a space never gets a preferences file.
    expect(File(preferences).existsSync(), isFalse);
  });
}
